/**
	Memory pool with destructors, useful for scoped allocators.

    Copyright: © 2012-2013 RejectedSoftware e.K.
    		   © 2014-2015 Etienne Cimon
    License: Subject to the terms of the MIT license.
    Authors: Sönke Ludwig, Etienne Cimon
*/
module memutils.pool;

import memutils.allocators;
import std.conv : emplace;
import std.algorithm : min, max;
import memutils.vector;

final class PoolAllocator(Base : Allocator)
{
	public int id = -1; // intrusive ID used for ScopedPools

	static align(8) struct Pool { Pool* next; void[] data; void[] remaining; }

	private {
		Allocator m_baseAllocator;
		Pool* m_freePools;
		Pool* m_fullPools;
		Vector!(void delegate()) m_destructors;
		int m_pools;
	}
	public size_t m_poolSize;
	
	this(size_t pool_size = 64*1024)
	{
		m_poolSize = pool_size;
		m_baseAllocator = getAllocator!Base();
	}

	void[] alloc(size_t sz)
	{
		auto aligned_sz = alignedSize(sz);

		Pool* pprev = null;
		Pool* p = cast(Pool*)m_freePools;
		size_t i;
		while(i < m_pools && p && p.remaining.length < aligned_sz ) {
			pprev = p;
			p = p.next;
			i++;
		}
		
		if( !p || p.remaining.length == 0 || p.remaining.length < aligned_sz ) {
			auto pmem = m_baseAllocator.alloc(AllocSize!Pool);
			
			p = emplace!Pool(pmem);
			p.data = m_baseAllocator.alloc(max(aligned_sz, m_poolSize));
			p.remaining = p.data;
			p.next = cast(Pool*)m_freePools;
			m_freePools = p;
			m_pools++;
			pprev = null;
		}
		logTrace("0 .. ", aligned_sz, " but remaining: ", p.remaining.length);
		auto ret = p.remaining[0 .. aligned_sz];
		logTrace("p.remaining: ", aligned_sz, " .. ", p.remaining.length);
		p.remaining = p.remaining[aligned_sz .. $];
		if( !p.remaining.length ){
			if( pprev ) {
				pprev.next = p.next;
			} else {
				m_freePools = p.next;
			}
			p.next = cast(Pool*)m_fullPools;
			m_fullPools = p;
		}
		//logDebug("PoolAllocator ", id, " allocated ", sz, " with ", totalSize());
		
		return ret[0 .. sz];
	}
	
	void[] realloc(void[] arr, size_t newsize)
	{
		auto aligned_sz = alignedSize(arr.length);
		auto aligned_newsz = alignedSize(newsize);
		logTrace("realloc: ", arr.ptr, " sz ", arr.length, " aligned: ", aligned_sz, " => ", newsize, " aligned: ", aligned_newsz);
		if( aligned_newsz <= aligned_sz ) return arr.ptr[0 .. newsize];
		
		auto pool = m_freePools;
		bool last_in_pool = pool && arr.ptr+aligned_sz == pool.remaining.ptr;
		if( last_in_pool && pool.remaining.length+aligned_sz >= aligned_newsz ) {
			pool.remaining = pool.remaining[aligned_newsz-aligned_sz .. $];
			arr = arr.ptr[0 .. aligned_newsz];
			assert(arr.ptr+arr.length == pool.remaining.ptr, "Last block does not align with the remaining space!?");
			return arr[0 .. newsize];
		} else {
			auto ret = alloc(newsize);
			assert(ret.ptr >= arr.ptr+aligned_sz || ret.ptr+ret.length <= arr.ptr, "New block overlaps old one!?");
			ret[0 .. min(arr.length, newsize)] = arr[0 .. min(arr.length, newsize)];
			return ret;
		}
	}
	
	void free(void[] mem)
	{

	}
	
	void freeAll()
	{
		//logDebug("Destroying ", totalSize(), " of data, allocated: ", allocatedSize());
		// destroy all initialized objects
		foreach_reverse (ref dtor; m_destructors[])
			dtor();

		destroy(m_destructors);

		size_t i;
		// put all full Pools into the free pools list
		for (Pool* p = cast(Pool*)m_fullPools, pnext; p && i < m_pools; (p = pnext), i++) {
			pnext = p.next;
			p.next = cast(Pool*)m_freePools;
			m_freePools = cast(Pool*)p;
		}
		i=0;
		// free up all pools
		for (Pool* p = cast(Pool*)m_freePools; p && i < m_pools; (p = p.next), i++) {
			p.remaining = p.data;
		}
	}
	
	void reset()
	{
		//logDebug("Reset()");
		freeAll();
		Pool* pnext;
		size_t i;
		for (auto p = cast(Pool*)m_freePools; p && i < m_pools; (p = pnext), i++) {
			pnext = p.next;
			m_baseAllocator.free(p.data);
			m_baseAllocator.free((cast(void*)p)[0 .. AllocSize!Pool]);
		}
		m_freePools = null;
		
	}

	package void onDestroy(void delegate() dtor) {
		m_destructors ~= dtor;
	}

	package void removeArrayDtors(void delegate() last_dtor, size_t n) {
		bool found;
		foreach_reverse(i, ref el; m_destructors[]) {
			if (el == last_dtor)
			{
				Vector!(void delegate()) arr;
				if (n >= i)
					arr ~= m_destructors[0 .. i-n+1];
				if (i != m_destructors.length - 1)
					arr ~= m_destructors[i+1 .. $];
				m_destructors[] = arr[];
				found = true;
				break;
			}
		}
		assert(found);
	}

	@property size_t totalSize()
	{
		size_t amt = 0;
		size_t i;
		for (auto p = m_fullPools; p && i < m_pools; (p = p.next), i++)
			amt += p.data.length;
		i=0;
		for (auto p = m_freePools; p && i < m_pools; (p = p.next), i++)
			amt += p.data.length;
		return amt;
	}
	
	@property size_t allocatedSize()
	{
		size_t amt = 0;
		size_t i;
		for (auto p = m_fullPools; p && i < m_pools; (p = p.next), i++)
			amt += p.data.length;
		i = 0;
		for (auto p = m_freePools; p && i < m_pools; (p = p.next), i++)
			amt += p.data.length - p.remaining.length;
		return amt;
	}

	~this() { reset(); }
}
