/*
* Derived from Botan's Mlock Allocator
* 
* This is a more advanced base allocator.
* 
* (C) 2012,2014 Jack Lloyd
* (C) 2014-2015 Etienne Cimon
* (C) 2014,2015 Etienne Cimon
*
* Distributed under the terms of the Simplified BSD License (see Botan's license.txt)
*/
module memutils.securepool;
import memutils.constants;
static if (HasSecurePool):

package:

import memutils.rbtree;
import std.algorithm;
import core.sync.mutex;
import std.conv : to;
import memutils.allocators;
import memutils.utils : Malloc;

version(Posix) {

	version(linux) import core.sys.linux.sys.mman;
	else version(Posix) import core.sys.posix.sys.mman;
	import core.sys.posix.sys.resource;
	
	enum {
		RLIMIT_MEMLOCK = 8
	}
	version(OSX) 
		enum MAP_LOCKED = 0;
	enum { MADV_DONTDUMP = 16 }
}
version(Windows) {
	@nogc private nothrow pure:
	import core.sys.windows.windows;

	enum PROT_READ = 0;
	enum PROT_WRITE = 0;
	enum MAP_ANON = 0;
	enum MAP_SHARED = 0;
	enum MAP_LOCKED = 0;
	void* MAP_FAILED = null;

	extern(Windows) {
		BOOL VirtualLock(LPVOID lpAddress, SIZE_T dwSize);
		BOOL VirtualUnlock(LPVOID lpAddress, SIZE_T dwSize);
		LPVOID VirtualAlloc(LPVOID lpAddress, SIZE_T dwSize, DWORD flAllocationType, DWORD flProtect);
		BOOL VirtualFree(LPVOID lpAddress, SIZE_T dwSize, DWORD dwFreeType);
		BOOL SetProcessWorkingSetSize(HANDLE hProcess, SIZE_T dwMinimumWorkingSetSize, SIZE_T dwMaximumWorkingSetSize);
	}
	int mlock(void* ptr, size_t sz) {
		return cast(int) VirtualLock(cast(LPVOID) ptr, cast(SIZE_T) sz);
	}
	
	int munlock(void* ptr, size_t sz) {
		
		return cast(int) VirtualUnlock(cast(LPVOID) ptr, cast(SIZE_T) sz);
	}
	
	private void* mmap(void* ptr, size_t length, int prot, int flags, int fd, size_t offset) {
		enum MEM_RESERVE     = 0x00002000;
		enum MEM_COMMIT     = 0x00001000;
		enum PAGE_READWRITE = 0x04;
		return cast(void*) VirtualAlloc(cast(LPVOID) null, cast(SIZE_T) length, cast(DWORD) (MEM_RESERVE | MEM_COMMIT), cast(DWORD) PAGE_READWRITE);
	}
	
	void munmap(void* ptr, size_t sz)
	{
		enum MEM_RELEASE = 0x8000;
		VirtualFree(cast(LPVOID) ptr, cast(SIZE_T) sz, cast(DWORD) MEM_RELEASE);
	}
	
}

final class SecurePool
{
	__gshared immutable size_t alignment = 0x08;
public:
	void[] alloc(size_t n)
	{
		synchronized(m_mtx) {
			if (!m_pool)
				return null;
			
			if (n > m_pool.length || n > SecurePool_MLock_Max)
				return null;
			
			void[]* best_fit_ref;
			void[] best_fit;
			size_t i;
			foreach (ref slot; m_freelist[])
			{
				// If we have a perfect fit, use it immediately
				if (slot.length == n && (cast(size_t)slot.ptr % alignment) == 0)
				{
					m_freelist.remove(slot);					
					assert(cast(size_t)(slot.ptr - m_pool.ptr) % alignment == 0, "Returning correctly aligned pointer");
					
					return slot;
				}
				
				if (slot.length >= (n + padding_for_alignment(cast(size_t)slot.ptr, alignment) ) &&
					( !best_fit_ref || (best_fit.length > slot.length) ) )
				{
					best_fit_ref = &slot;
					best_fit = slot;
				}
				i++;
			}
			
			if (best_fit_ref)
			{
				const size_t alignment_padding = padding_for_alignment(cast(size_t)best_fit.ptr, alignment);
				
				// absorb misalignment
				void[] remainder = (best_fit.ptr + n + alignment_padding)[0 .. best_fit.length - (n + alignment_padding)];
				if (remainder.length > 0) {
					*best_fit_ref = remainder;
				} else {
					m_freelist.remove(best_fit);
				}

				size_t offset = best_fit.ptr - m_pool.ptr;
				
				assert((cast(size_t)(m_pool.ptr) + offset + alignment_padding) % alignment == 0, "Returning correctly aligned pointer");
				
				return (best_fit.ptr + alignment_padding)[0 .. n];
			}
			
			return null;
		}
	}

	bool has(void[] mem) {
		synchronized(m_mtx) {
			if (!m_pool)
				return false;
			
			if (!ptr_in_pool(m_pool, mem.ptr, mem.length))
				return false;
		}
		return true;
	}

	bool free(void[] mem)
	{
		if (!has(mem)) return false;

		synchronized(m_mtx) {
			import std.range : front, empty;


			bool is_merged;
			void[] combined;
			
			auto upper_range = m_freelist.upperBoundRange(mem);
			if (!upper_range.empty && upper_range.front().ptr > (mem.ptr + mem.length) && (upper_range.front().ptr - alignment) < (mem.ptr + mem.length))
			{
				//import std.stdio : writeln;
				logTrace("Pool item (>): ", upper_range.front().ptr, " .. ", upper_range.front().ptr + upper_range.front().length, " <==> ", mem.ptr, " .. ", mem.ptr + mem.length);
				
				// we can merge with the next block
				void[] upper_elem = upper_range.front();
				size_t alignment_padding = upper_elem.ptr - (mem.ptr + mem.length);
				assert(alignment_padding < alignment, "Alignment padding error on upper bound");
				combined = mem.ptr[0 .. mem.length + alignment_padding + upper_elem.length];
				
				m_freelist.remove(upper_elem);
				mem = combined;
			}
			
			auto lower_range = m_freelist.lowerBoundRange(mem);
			if (!lower_range.empty && (lower_range.back().ptr + lower_range.back().length) < mem.ptr && (lower_range.back().ptr + lower_range.back().length + alignment) > mem.ptr)
			{
				// import std.stdio : writeln;
				logTrace("Pool item (<): ", lower_range.back().ptr, " .. ", lower_range.back().ptr + lower_range.back().length, " <==> ", mem.ptr, " .. ", mem.ptr + mem.length);
				// we can merge with the next block
				void[] lower_elem = lower_range.back();
				size_t alignment_padding = mem.ptr - ( lower_range.back().ptr + lower_range.back().length );
				assert(alignment_padding < alignment, "Alignment padding error on lower bound " ~ mem.ptr.to!string ~ ": " ~ alignment_padding.to!string ~ "/" ~ alignment.to!string);
				combined = lower_elem.ptr[0 .. lower_elem.length + alignment_padding + mem.length];
				m_freelist.remove(lower_elem);
				mem = combined;
			}
			m_freelist.insert(mem);
			return true;
		}
	}
package:
	this()
	{
		logTrace("Loading SecurePool instance ...");
		m_mtx = new Mutex;
		
		auto pool_size = mlock_limit();
		
		if (pool_size)
		{
			void* pool_ptr;
			pool_ptr = mmap(null, pool_size,
				PROT_READ | PROT_WRITE,
				MAP_ANON | MAP_SHARED | MAP_LOCKED,
				-1, 0);
			
			if (pool_ptr == MAP_FAILED)
			{
				throw new Exception("Failed to mmap SecurePool pool");
			}

			m_pool_unaligned = pool_ptr[0 .. pool_size];

			import core.stdc.string : memset;
			memset(m_pool_unaligned.ptr, 0, m_pool_unaligned.length);
			
			if (mlock(m_pool_unaligned.ptr, m_pool_unaligned.length) != 0)
			{
				munmap(m_pool_unaligned.ptr, m_pool_unaligned.length);
				m_pool_unaligned = null;
				import core.stdc.errno;
				logError("Could not mlock " ~ to!string(pool_size) ~ " bytes: " ~ errno().to!string);
				return;
			}
			
			version(Posix) posix_madvise(m_pool_unaligned.ptr, m_pool_unaligned.length, MADV_DONTDUMP);
			
			m_pool = m_pool_unaligned.ptr[cast(size_t)m_pool_unaligned.ptr % alignment .. m_pool_unaligned.length - (m_pool_unaligned.length % alignment)];
			
			m_freelist.insert(m_pool);
		}
	}
	
	~this()
	{
		if (m_pool)
		{
			import core.stdc.string : memset;
			memset(m_pool_unaligned.ptr, 0, m_pool_unaligned.length);
			munlock(m_pool_unaligned.ptr, m_pool_unaligned.length);
			munmap(m_pool_unaligned.ptr, m_pool_unaligned.length);
			m_pool = null;
			m_pool_unaligned = null;
		}
	}
	
private:
	__gshared Mutex m_mtx;
	RBTree!(void[], "a.ptr < b.ptr", false, Malloc) m_freelist;
	void[] m_pool;
	void[] m_pool_unaligned;
}

private:

size_t mlock_limit()
{
	/*
    * Linux defaults to only 64 KiB of mlockable memory per process
    * (too small) but BSDs offer a small fraction of total RAM (more
    * than we need). Bound the total mlock size to 512 KiB which is
    * enough to run the entire test suite without spilling to non-mlock
    * memory (and thus presumably also enough for many useful
    * programs), but small enough that we should not cause problems
    * even if many processes are mlocking on the same machine.
    */
	__gshared immutable size_t MLOCK_UPPER_BOUND = 512*1024;
	
	version(Posix) {
		rlimit limits;
		getrlimit(RLIMIT_MEMLOCK, &limits);
		
		if (limits.rlim_cur < limits.rlim_max)
		{
			limits.rlim_cur = limits.rlim_max;
			setrlimit(RLIMIT_MEMLOCK, &limits);
			getrlimit(RLIMIT_MEMLOCK, &limits);
		}
		return std.algorithm.min(limits.rlim_cur, MLOCK_UPPER_BOUND);
	}
	version(Windows) {
		BOOL success = SetProcessWorkingSetSize(cast(void*)GetCurrentProcessId(), 512*1024, 315*4096);
		if (success == 0)
			return 0;
		return MLOCK_UPPER_BOUND;
	}
}

bool ptr_in_pool(in void[] pool, in void* buf_ptr, size_t bufsize) pure
{
	if (buf_ptr < pool.ptr || buf_ptr >= pool.ptr + pool.length)
		return false;
	
	assert(buf_ptr + bufsize <= pool.ptr + pool.length, "Pointer does not partially overlap pool");
	
	return true;
}

size_t padding_for_alignment(size_t offset, size_t desired_alignment) pure
{
	size_t mod = offset % desired_alignment;
	if (mod == 0)
		return 0; // already right on
	return desired_alignment - mod;
}
