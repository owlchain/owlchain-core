/**
	Memory provider allocators to be used in templated composition 
	within other, designated allocators.

    Copyright: © 2012-2013 RejectedSoftware e.K.
    		   © 2014-2015 Etienne Cimon
    License: Subject to the terms of the MIT license.
    Authors: Sönke Ludwig, Etienne Cimon
*/
module memutils.memory;

import memutils.allocators;
import memutils.helpers;
import std.algorithm : min;
import core.stdc.stdlib;

final class GCAllocator : Allocator {
	import core.memory : GC;
	void[] alloc(size_t sz)
	{
		auto mem = GC.malloc(sz+Allocator.alignment);
		auto alignedmem = adjustPointerAlignment(mem);
		assert(alignedmem - mem <= Allocator.alignment);
		auto ret = alignedmem[0 .. sz];
		ensureValidMemory(ret);
		return ret;
	}
	
	void[] realloc(void[] mem, size_t new_size)
	{
		size_t csz = min(mem.length, new_size);
		
		auto p = extractUnalignedPointer(mem.ptr);
		size_t misalign = mem.ptr - p;
		assert(misalign <= Allocator.alignment);
		
		void[] ret;
		auto extended = GC.extend(p, new_size - mem.length, new_size - mem.length);
		if (extended) {
			assert(extended >= new_size+Allocator.alignment);
			ret = p[misalign .. new_size+misalign];
		} else {
			ret = alloc(new_size);
			ret[0 .. csz] = mem[0 .. csz];
		}
		ensureValidMemory(ret);
		return ret;
	}

	/// calls to free are optional if stability is favored over speed
	void free(void[] mem)
	{
		GC.free(extractUnalignedPointer(mem.ptr));
	}
}

final class MallocAllocator : Allocator {
	import core.exception : OutOfMemoryError;

	void[] alloc(size_t sz)
	{
		static err = new immutable OutOfMemoryError;
		auto ptr = .malloc(sz + Allocator.alignment);
		if (ptr is null) throw err;
		return adjustPointerAlignment(ptr)[0 .. sz];
	}

	void[] realloc(void[] mem, size_t new_size)
	{
		size_t csz = min(mem.length, new_size);
		auto p = extractUnalignedPointer(mem.ptr);
		size_t oldmisalign = mem.ptr - p;
		
		auto pn = cast(ubyte*).realloc(p, new_size+Allocator.alignment);
		if (p == pn) return pn[oldmisalign .. new_size+oldmisalign];
		
		auto pna = cast(ubyte*)adjustPointerAlignment(pn);
		auto newmisalign = pna - pn;
		
		// account for changed alignment after realloc (move memory back to aligned position)
		if (oldmisalign != newmisalign) {
			if (newmisalign > oldmisalign) {
				foreach_reverse (i; 0 .. csz)
					pn[i + newmisalign] = pn[i + oldmisalign];
			} else {
				foreach (i; 0 .. csz)
					pn[i + newmisalign] = pn[i + oldmisalign];
			}
		}
		
		return pna[0 .. new_size];
	}
	
	void free(void[] mem)
	{
		.free(extractUnalignedPointer(mem.ptr));
	}
}