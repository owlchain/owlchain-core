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
module memutils.cryptosafe;
import memutils.constants;
static if (HasCryptoSafe):
pragma(msg, "Enhanced memory security is enabled.");

import memutils.allocators;
import memutils.securepool;
import memutils.debugger;

final class SecureAllocator(Base : Allocator) : Allocator
{
private:	
	Base m_secondary;
	static if (HasSecurePool) {
		
		__gshared SecurePool ms_zeroise;
		__gshared bool ms_deinit;
		shared static this() { 
			//logDebug("Shared static this() SecurePool");
			if (!ms_zeroise) ms_zeroise = new SecurePool();
		}
		shared static ~this() { 
			if (ms_zeroise) { destroy(ms_zeroise); ms_zeroise = null; ms_deinit = true; }
		}
	}

public:	
	this() {
		version(TLSGC) { } else {
			if (!mtx) mtx = new Mutex;
		}
		static if (HasSecurePool) {
			if (!ms_zeroise) ms_zeroise = new SecurePool();
		}
		m_secondary = getAllocator!Base();
	}
	
	void[] alloc(size_t n)
	{
		version(TLSGC) { } else {
			mtx.lock_nothrow();
			scope(exit) mtx.unlock_nothrow();
		}
		static if (HasSecurePool) {
			//logDebug("CryptoSafe alloc ", n);
			if (void[] p = ms_zeroise.alloc(n)) {
				//logDebug("alloc P: ", p.length, " & ", p.ptr);
				return p;
			}
		}
		//logDebug("secondary alloc");
		void[] p = m_secondary.alloc(n);

		//logDebug("FALLBACK alloc P: ", p.length, " & ", p.ptr);
		return p;
	}

	void[] realloc(void[] mem, size_t n)
	{
		version(TLSGC) { } else {
			mtx.lock_nothrow();
			scope(exit) mtx.unlock_nothrow();
		}
		//logTrace("realloc P: ", mem.length, " & ", mem.ptr);
		if (n <= mem.length)
			return mem;
		import core.stdc.string : memmove, memset;

		static if (HasSecurePool) {
			if (ms_zeroise.has(mem)) {
				void[] p = ms_zeroise.alloc(n);
				if (!p) 
					p = m_secondary.alloc(n);
				memmove(p.ptr, mem.ptr, mem.length);
				memset(mem.ptr, 0, mem.length);
				ms_zeroise.free(mem);
				return p;
			}
		}

		return m_secondary.realloc(mem, n);
	}

	void free(void[] mem)
	{
		version(TLSGC) { } else {
			mtx.lock_nothrow();
			scope(exit) mtx.unlock_nothrow();
		}
		//logTrace("free P: ", mem.length, " & ", mem.ptr);
		import core.stdc.string : memset;
		bool skip_zero;
		if (mem.length > 1024) {
			skip_zero = true;
			ubyte* ptr = cast(ubyte*)mem.ptr;
			// check some random bytes for zero
			size_t j;
			foreach (i; 0 .. mem.length/128) {
				if (ptr[j]+4 == 0 && ptr[j]+8 == 0 && ptr[j]+50 == 0 && ptr[j]+80 == 0) {
					j += 128;
					continue;
				}
				skip_zero = false;
				break;
			}
		}
		if (!skip_zero)
			memset(mem.ptr, 0, mem.length);
		static if (HasSecurePool)
			if (ms_deinit || ms_zeroise.free(mem))
				return;
		m_secondary.free(mem);
	}

}