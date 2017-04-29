module memutils.utils;

import core.thread : Fiber;	
import std.traits : isPointer, hasIndirections, hasElaborateDestructor, isArray, ReturnType;
import std.conv : emplace;
import core.stdc.string : memset, memcpy;
import memutils.allocators;
import std.algorithm : startsWith;
import memutils.constants;
import memutils.vector : Array;
import std.range : ElementType;
import memutils.helpers : UnConst;

struct AppMem {
	mixin ConvenienceAllocators!(NativeGC, typeof(this));
}

struct ThreadMem {
	mixin ConvenienceAllocators!(LocklessFreeList, typeof(this));
}

struct SecureMem {
	mixin ConvenienceAllocators!(CryptoSafe, typeof(this));
}
// Reserved for containers
struct Malloc {
	enum ident = Mallocator;
}

package:


template ObjectAllocator(T, ALLOC)
{
	import std.traits : ReturnType;
	import core.memory : GC;
	enum ElemSize = AllocSize!T;

	static if (ALLOC.stringof == "PoolStack") {
		ReturnType!(ALLOC.top) function() m_getAlloc = &ALLOC.top;
	}
	static if (__traits(hasMember, T, "NOGC")) enum NOGC = T.NOGC;
	else enum NOGC = false;

	alias TR = RefTypeOf!T;


	TR alloc(ARGS...)(auto ref ARGS args)
	{
		static if (ALLOC.stringof != "PoolStack") {
			auto allocator_ = getAllocator!(ALLOC.ident)(false);
			auto mem = allocator_.alloc(ElemSize);
		}
		else
			auto mem = m_getAlloc().alloc(ElemSize);
		static if ( ALLOC.stringof != "AppMem" && hasIndirections!T && !NOGC) 
		{
			static if (__traits(compiles, { GC.addRange(null, 0, typeid(string)); }()))
				GC.addRange(mem.ptr, ElemSize, typeid(T));
			else
				GC.addRange(mem.ptr, ElemSize);	
		}

		return emplace!T(mem, args);

	}

	void free(TR obj)
	{

		static if( ALLOC.stringof != "AppMem" && hasIndirections!T && !NOGC) {
			GC.removeRange(cast(void*)obj);
		}

		TR objc = obj;
		static if (is(TR == T*)) .destroy(*objc);
		else .destroy(objc);

		static if (ALLOC.stringof != "PoolStack") {
			if (auto a = getAllocator!(ALLOC.ident)(true))
				a.free((cast(void*)obj)[0 .. ElemSize]);
		}
		else
			m_getAlloc().free((cast(void*)obj)[0 .. ElemSize]);

	}
}

/// Allocates an array without touching the memory.
T[] allocArray(T, ALLOC = ThreadMem)(size_t n)
{
	import core.memory : GC;
	mixin(translateAllocator());
	auto allocator = thisAllocator();

	auto mem = allocator.alloc(T.sizeof * n);
	// logTrace("alloc ", T.stringof, ": ", mem.ptr);
	auto ret = (cast(T*)mem.ptr)[0 .. n];
	// logTrace("alloc ", ALLOC.stringof, ": ", mem.ptr, ":", mem.length);
	static if (__traits(hasMember, T, "NOGC")) enum NOGC = T.NOGC;
	else enum NOGC = false;
	
	static if( ALLOC.stringof != "AppMem" && hasIndirections!T && !NOGC) {
		static if (__traits(compiles, { GC.addRange(null, 0, typeid(string)); }()))
			GC.addRange(mem.ptr, mem.length, typeid(T));
		else
			GC.addRange(mem.ptr, mem.length);
	}

	// don't touch the memory - all practical uses of this function will handle initialization.
	return ret;
}

T[] reallocArray(T, ALLOC = ThreadMem)(T[] array, size_t n) {
	import core.memory : GC;
	assert(n > array.length, "Cannot reallocate to smaller sizes");
	mixin(translateAllocator());
	auto allocator = thisAllocator();
	// logTrace("realloc before ", ALLOC.stringof, ": ", cast(void*)array.ptr, ":", array.length);

	//logTrace("realloc fre ", T.stringof, ": ", array.ptr);
	auto mem = allocator.realloc((cast(void*)array.ptr)[0 .. array.length * T.sizeof], T.sizeof * n);
	//logTrace("realloc ret ", T.stringof, ": ", mem.ptr);
	auto ret = (cast(T*)mem.ptr)[0 .. n];
	// logTrace("realloc after ", ALLOC.stringof, ": ", mem.ptr, ":", mem.length);
	
	static if (__traits(hasMember, T, "NOGC")) enum NOGC = T.NOGC;
	else enum NOGC = false;
	
	static if (ALLOC.stringof != "AppMem" && hasIndirections!T && !NOGC) {
		GC.removeRange(array.ptr);
		static if (__traits(compiles, { GC.addRange(null, 0, typeid(string)); }()))
                GC.addRange(mem.ptr, mem.length, typeid(T));
        else
                GC.addRange(mem.ptr, mem.length);
		// Zero out unused capacity to prevent gc from seeing false pointers
		memset(mem.ptr + (array.length * T.sizeof), 0, (n - array.length) * T.sizeof);
	}
	
	return ret;
}

void freeArray(T, ALLOC = ThreadMem)(auto ref T[] array, size_t max_destroy = size_t.max, size_t offset = 0)
{
	import core.memory : GC;
	mixin(translateAllocator());
	auto allocator = thisAllocator(true); // freeing. Avoid allocating in a dtor
	if (!allocator) return;

	// logTrace("free ", ALLOC.stringof, ": ", cast(void*)array.ptr, ":", array.length);
	static if (__traits(hasMember, T, "NOGC")) enum NOGC = T.NOGC;
	else enum NOGC = false;
	
	static if (ALLOC.stringof != "AppMem" && hasIndirections!T && !NOGC) {
		GC.removeRange(array.ptr);
	}

	static if (hasElaborateDestructor!T) { // calls destructors, but not for indirections...
		size_t i;
		foreach (ref e; array) {
			if (i < offset) { i++; continue; }
			if (i + offset == max_destroy) break;
			static if (is(T == struct) && !isPointer!T) .destroy(e);
			i++;
		}
	}
	allocator.free((cast(void*)array.ptr)[0 .. array.length * T.sizeof]);
	array = null;
}

mixin template ConvenienceAllocators(alias ALLOC, alias THIS) {
	package enum ident = ALLOC;
static:
	// objects
	auto alloc(T, ARGS...)(auto ref ARGS args) 
		if (!isArray!T)
	{
		return ObjectAllocator!(T, THIS).alloc(args);
	}
	
	void free(T)(auto ref T* obj)
		if (!isArray!T && !is(T : Object))
	{
		scope(exit) obj = null;
		ObjectAllocator!(T, THIS).free(obj);
	}
	
	void free(T)(auto ref T obj)
		if (!isArray!T && is(T  : Object))
	{
		scope(exit) obj = null;
		ObjectAllocator!(T, THIS).free(obj);
	}

	/// arrays
	auto alloc(T)(size_t n)
		if (isArray!T)
	{
		alias ElType = UnConst!(typeof(T.init[0]));
		return allocArray!(ElType, THIS)(n);
	}

	auto copy(T)(auto ref T arr)
		if (isArray!T)
	{
		alias ElType = UnConst!(typeof(arr[0]));
		auto arr_copy = allocArray!(ElType, THIS)(arr.length);
		memcpy(arr_copy.ptr, arr.ptr, arr.length * ElType.sizeof);

		return cast(T)arr_copy;
	}

	auto realloc(T)(auto ref T arr, size_t n)
		if (isArray!T)
	{
		alias ElType = UnConst!(typeof(arr[0]));
		scope(exit) arr = null;
		auto arr_copy = reallocArray!(typeof(arr[0]), THIS)(arr, n);
		return cast(T) arr_copy;
	}
	
	void free(T)(auto ref T arr)
		if (isArray!T)
	{
		alias ElType = typeof(arr[0]);
		scope(exit) arr = null;
		freeArray!(ElType, THIS)(arr);
	}

}

string translateAllocator() { /// requires (ALLOC) template parameter
	return `
	static if (ALLOC.stringof != "PoolStack") {
		ReturnType!(getAllocator!(ALLOC.ident)) thisAllocator(bool is_freeing = false) {
			return getAllocator!(ALLOC.ident)(is_freeing);
		}
	}
	else {
		ReturnType!(ALLOC.top) function() thisAllocator = &ALLOC.top;
	}
	`;
}
