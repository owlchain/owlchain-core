/**
	FreeList allocator proxy templates used to prevent memory segmentation
	on base allocator.

    Copyright: © 2012-2013 RejectedSoftware e.K.
    		   © 2014-2015 Etienne Cimon
    License: Subject to the terms of the MIT license.
    Authors: Sönke Ludwig, Etienne Cimon
*/
module memutils.freelist;

import memutils.allocators;
import memutils.memory;
import std.algorithm : min;

final class AutoFreeListAllocator(Base : Allocator) : Allocator {
	import std.typetuple;
	
	private {
		enum minExponent = 3;
		enum freeListCount = 12;
		static if (is(Base == MallocAllocator) && __VERSION__ >= 2072)
			FreeListMallocAllocator[freeListCount] m_freeLists;
		else
			FreeListAlloc!Base[freeListCount] m_freeLists;
		Base m_baseAlloc;
	}
	
	this()
	{
		version(TLSGC) { } else {
			if (!mtx) mtx = new Mutex;
		}
		m_baseAlloc = getAllocator!Base();
		foreach (i; iotaTuple!freeListCount) {
			static if (is(Base == MallocAllocator) && __VERSION__ >= 2072)
				m_freeLists[i] = new FreeListMallocAllocator(nthFreeListSize!(i));
			else
				m_freeLists[i] = new FreeListAlloc!Base(nthFreeListSize!(i));
		}
	}

	~this() {
		foreach(fl; m_freeLists)
			destroy(fl);
	}
	
	void[] alloc(size_t sz)
	{

		version(TLSGC) { } else {
			mtx.lock_nothrow();
			scope(exit) mtx.unlock_nothrow();
		}
		logTrace("AFL alloc ", sz);
		foreach (i; iotaTuple!freeListCount)
			if (sz <= nthFreeListSize!(i))
				return m_freeLists[i].alloc().ptr[0 .. sz];
		if (sz > nthFreeListSize!(freeListCount-1)) return m_baseAlloc.alloc(sz);
		assert(false);
	}

	void[] realloc(void[] data, size_t sz)
	{
		version(TLSGC) { } else {
			mtx.lock_nothrow();
			scope(exit) mtx.unlock_nothrow();
		}
		foreach (fl; m_freeLists) {
			if (data.length <= fl.elementSize) {
				// just grow the slice if it still fits into the free list slot
				if (sz <= fl.elementSize)
					return data.ptr[0 .. sz];
				
				// otherwise re-allocate
				auto newd = alloc(sz);
				assert(newd.ptr+sz <= data.ptr || newd.ptr >= data.ptr+data.length, "New block overlaps old one!?");
				auto len = min(data.length, sz);
				newd[0 .. len] = data[0 .. len];
				free(data);
				return newd;
			}
		}
		// forward large blocks to the base allocator
		return m_baseAlloc.realloc(data, sz);
	}

	void free(void[] data)
	{
		version(TLSGC) { } else {
			mtx.lock_nothrow();
			scope(exit) mtx.unlock_nothrow();
		}
		logTrace("AFL free ", data.length);
		foreach(i; iotaTuple!freeListCount) {
			if (data.length <= nthFreeListSize!i) {
				m_freeLists[i].free(data.ptr[0 .. nthFreeListSize!i]);
				return;
			}
		}
		if (data.length > nthFreeListSize!(freeListCount-1)) {
			m_baseAlloc.free(data);
			return;
		}
		assert(false);
	}
	
	private static pure size_t nthFreeListSize(size_t i)() { return 1 << (i + minExponent); }
	private template iotaTuple(size_t i) {
		static if (i > 1) alias iotaTuple = TypeTuple!(iotaTuple!(i-1), i-1);
		else alias iotaTuple = TypeTuple!(0);
	}
}

final class FreeListAlloc(Base : Allocator) : Allocator
{
	import memutils.vector : Vector;
	import memutils.utils : Malloc;
	private static struct FreeListSlot { FreeListSlot* next; }
	private {
		immutable size_t m_elemSize;
		Base m_baseAlloc;
		FreeListSlot* m_firstFree = null;
		size_t space;
		version(DebugLeaks) HashMap!(size_t, size_t, Malloc) m_owned;
		size_t m_nalloc = 0;
		size_t m_nfree = 0;
	}

	~this() {
		import core.thread : thread_isMainThread;
		version(DebugLeaks)//if (!thread_isMainThread)
		{
			if (m_owned.length > 0)
			{
				import std.stdio : writeln;
				foreach(const ref size_t ptr, const ref size_t size; m_owned)
					writeln( cast(void*)ptr, " : ", size);
				asm { int 3; }
			}
		}
		while ( m_firstFree ){
			auto slot = m_firstFree;
			m_firstFree = slot.next;
			slot.next = null;
			m_baseAlloc.free( (cast(void*)slot)[0 .. m_elemSize] );
			m_nfree--;
		}
		//foreach(size_t slot; m_owned[])
			//	m_baseAlloc.free( (cast(void*)slot)[0 .. m_elemSize]);
	
	}
	
	this(size_t elem_size)
	{
		assert(elem_size >= size_t.sizeof);
		m_elemSize = elem_size;
		m_baseAlloc = getAllocator!Base();
		//logTrace("Create FreeListAlloc %d", m_elemSize);
	}
	
	@property size_t elementSize() const { return m_elemSize; }
	
	void[] alloc(size_t sz)
	{
		assert(sz == m_elemSize, "Invalid allocation size.");
		return alloc();
	}
	
	void[] alloc()
	{
		void[] mem;
		if (m_nfree == 0) m_firstFree = null;
		if( m_firstFree ){
			auto slot = m_firstFree;
			if (--m_nfree == 0)
				m_firstFree = null;
			else {
				m_firstFree = slot.next;
			}
			mem = (cast(void*)slot)[0 .. m_elemSize];
		} else {
			mem = m_baseAlloc.alloc(m_elemSize);
			//logInfo("Alloc %d bytes: alloc: %d, free: %d", SZ, s_nalloc, s_nfree);
		}
		version(DebugLeaks)//if (!thread_isMainThread)
		{
			//import std.stdio : writeln;
			//Exception ex = new Exception("");
			//try throw ex; catch (Exception e) { 
			//writeln(mem.ptr, " : ", e.toString());
			//}
			m_owned[cast(size_t)mem.ptr] = m_elemSize;

		}
		m_nalloc++;
		//logInfo("Alloc %d bytes: alloc: %d, free: %d", SZ, s_nalloc, s_nfree);
		return mem;
	}

	void[] realloc(void[] mem, size_t sz)
	{
		version(DebugLeaks)//if (!thread_isMainThread)
			m_owned[cast(size_t)mem.ptr] = sz;
		assert(mem.length == m_elemSize);
		assert(sz == m_elemSize);
		return mem;
	}

	void free(void[] mem)
	{
		assert(mem.length == m_elemSize, "Memory block passed to free has wrong size.");
		auto s = cast(FreeListSlot*)mem.ptr;
		s.next = m_firstFree;

		version(DebugLeaks)//if (!thread_isMainThread)
			m_owned.remove(cast(size_t)mem.ptr);
		m_firstFree = s;
		m_nalloc--;
		m_nfree++;
	}
}

// workaround for 2.072.0 regression preventing FreeListAlloc template instantiation
private 
final class FreeListMallocAllocator
{
	import memutils.vector : Vector;
	import memutils.utils : Malloc;
	private static struct FreeListSlot { FreeListSlot* next; }
	private {
		immutable size_t m_elemSize;
		MallocAllocator m_baseAlloc;
		FreeListSlot* m_firstFree = null;
		size_t space;
		version(DebugLeaks) HashMap!(size_t, size_t, Malloc) m_owned;
		size_t m_nalloc = 0;
		size_t m_nfree = 0;
	}

	~this() {
		import core.thread : thread_isMainThread;
		version(DebugLeaks)//if (!thread_isMainThread)
		{
			if (m_owned.length > 0)
			{
				import std.stdio : writeln;
				foreach(const ref size_t ptr, const ref size_t size; m_owned)
					writeln( cast(void*)ptr, " : ", size);
				asm { int 3; }
			}
		}
		while ( m_firstFree ){
			auto slot = m_firstFree;
			m_firstFree = slot.next;
			slot.next = null;
			m_baseAlloc.free( (cast(void*)slot)[0 .. m_elemSize] );
			m_nfree--;
		}
		//foreach(size_t slot; m_owned[])
			//	m_baseAlloc.free( (cast(void*)slot)[0 .. m_elemSize]);
	
	}
	
	this(size_t elem_size)
	{
		assert(elem_size >= size_t.sizeof);
		m_elemSize = elem_size;
		m_baseAlloc = getAllocator!MallocAllocator();
		//logTrace("Create FreeListAlloc %d", m_elemSize);
	}
	
	@property size_t elementSize() const { return m_elemSize; }
	
	void[] alloc(size_t sz)
	{
		assert(sz == m_elemSize, "Invalid allocation size.");
		return alloc();
	}
	
	void[] alloc()
	{
		void[] mem;
		if (m_nfree == 0) m_firstFree = null;
		if( m_firstFree ){
			auto slot = m_firstFree;
			if (--m_nfree == 0)
				m_firstFree = null;
			else {
				m_firstFree = slot.next;
			}
			mem = (cast(void*)slot)[0 .. m_elemSize];
		} else {
			mem = m_baseAlloc.alloc(m_elemSize);
			//logInfo("Alloc %d bytes: alloc: %d, free: %d", SZ, s_nalloc, s_nfree);
		}
		version(DebugLeaks)//if (!thread_isMainThread)
		{
			//import std.stdio : writeln;
			//Exception ex = new Exception("");
			//try throw ex; catch (Exception e) { 
			//writeln(mem.ptr, " : ", e.toString());
			//}
			m_owned[cast(size_t)mem.ptr] = m_elemSize;

		}
		m_nalloc++;
		//logInfo("Alloc %d bytes: alloc: %d, free: %d", SZ, s_nalloc, s_nfree);
		return mem;
	}

	void[] realloc(void[] mem, size_t sz)
	{
		version(DebugLeaks)//if (!thread_isMainThread)
			m_owned[cast(size_t)mem.ptr] = sz;
		assert(mem.length == m_elemSize);
		assert(sz == m_elemSize);
		return mem;
	}

	void free(void[] mem)
	{
		assert(mem.length == m_elemSize, "Memory block passed to free has wrong size.");
		auto s = cast(FreeListSlot*)mem.ptr;
		s.next = m_firstFree;

		version(DebugLeaks)//if (!thread_isMainThread)
			m_owned.remove(cast(size_t)mem.ptr);
		m_firstFree = s;
		m_nalloc--;
		m_nfree++;
	}
}
