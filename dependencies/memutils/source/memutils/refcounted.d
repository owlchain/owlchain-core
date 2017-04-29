module memutils.refcounted;

import memutils.allocators;
import memutils.helpers;
import std.conv : to, emplace;
import std.traits : hasIndirections, Unqual, isImplicitlyConvertible;
import memutils.utils;
import std.algorithm : countUntil;

struct RefCounted(T, ALLOC = ThreadMem)
{
	import core.memory : GC;
	mixin Embed!(m_object, false);
	static if (!is(ALLOC == AppMem)) enum NOGC = true;
	enum isRefCounted = true;

	enum ElemSize = AllocSize!T;
	alias TR = RefTypeOf!T;	
	private TR m_object;
	private ulong* m_refCount;
	private void function(void*) m_free;

	static RefCounted opCall(ARGS...)(auto ref ARGS args)
	{
		RefCounted ret;

		ret.m_object = ObjectAllocator!(T, ALLOC).alloc(args);
		ret.m_refCount = ObjectAllocator!(ulong, ALLOC).alloc();
		// logTrace("refcount: ", cast(void*)ret.m_refCount, " m_object: ", cast(void*)ret.m_object, " Type: ", T.stringof);
		(*ret.m_refCount) = 1;
		logTrace("Allocating: ", cast(void*)ret.m_object, " of ", T.stringof, " sz: ", ElemSize, " allocator: ", ALLOC.stringof);
		return ret;
	}
	
	const ~this()
	{
		//logDebug("RefCounted dtor: ", T.stringof);
		dtor((cast(RefCounted*)&this));
	}
	
	static void dtor(U)(U* ctxt) {
		static if (!is (U == typeof(this))) {
			typeof(this)* this_ = cast(typeof(this)*)ctxt;
			this_.m_object = cast(typeof(this.m_object)) ctxt.m_object;
			this_.m_refCount = cast(typeof(this.m_refCount)) ctxt.m_refCount;
			this_._deinit();
		}
		else {
			ctxt._clear();
		}
	}
	
	const this(this)
	{
		//logDebug("RefCounted copy ctor");
		(cast(RefCounted*)&this).copyctor();
	}
	
	void copyctor() {
		
		if (!m_object)
			defaultInit();

		checkInvariants();
		if (m_object) (*m_refCount)++; 
		
	}
	
	void opAssign(U : RefCounted)(in U other) const
	{
		if (other.m_object is this.m_object) return;
		static if (is(U == RefCounted))
			(cast(RefCounted*)&this).opAssignImpl(*cast(U*)&other);
	}
	
	ref typeof(this) opAssign(U : RefCounted)(in U other) const
	{
		if (other.m_object is this.m_object) return;
		static if (is(U == RefCounted))
			(cast(RefCounted*)&this).opAssignImpl(*cast(U*)&other);
		return this;
	}
	
	private void opAssignImpl(U)(U other) {
		_clear();
		m_object = cast(typeof(this.m_object))other.m_object;
		m_refCount = other.m_refCount;
		static if (!is (U == typeof(this))) {
			static void destr(void* ptr) {
				U.dtor(cast(typeof(&this))ptr);
			}
			m_free = &destr;
		} else
			m_free = other.m_free;
		if( m_object )
			(*m_refCount)++;
	}
	
	private void _clear()
	{
		checkInvariants();
		if( m_object ){
			if( --(*m_refCount) == 0 ){
				//logTrace("RefCounted clear: ", T.stringof);
				logTrace("Clearing Object: ", cast(void*)m_object);
				if (m_free)
					m_free(cast(void*)&this);
				else {
					_deinit();
				}
			}
		}
		
		m_object = null;
		m_refCount = null;
		m_free = null;
	}

	bool opCast(U : bool)() const nothrow
	{
		//try logTrace("RefCounted opcast: bool ", T.stringof); catch {}
		return !(m_object is null && !m_refCount && !m_free);
	}

	U opCast(U)() const nothrow
		if (__traits(hasMember, U, "isRefCounted") && (isImplicitlyConvertible!(U.T, T) || isImplicitlyConvertible!(T, U.T)))
	{
		//try logTrace("RefCounted opcast: ", T.stringof, " => ", U.stringof); catch {}
		static assert(U.sizeof == typeof(this).sizeof, "Error, U: "~ U.sizeof.to!string~ " != this: " ~ typeof(this).sizeof.to!string);
		try { 
			U ret = U.init;
			ret.m_object = cast(U.TR)this.m_object;

			static if (!is (U == typeof(this))) {
				if (!m_free) {
					static void destr(void* ptr) {
						dtor(cast(U*)ptr);
					}
					ret.m_free = &destr;
				}
				else
					ret.m_free = m_free;
			}
			else ret.m_free = m_free;
			
			ret.m_refCount = cast(ulong*)this.m_refCount;
			(*ret.m_refCount) += 1;
			return ret;
		} catch(Throwable e) { try logError("Error in catch: ", e.toString()); catch {} }
		return U.init;
	}

	private void _deinit() {
		//logTrace("Freeing: ", T.stringof, " ptr ", cast(void*) m_object, " sz: ", ElemSize, " allocator: ", ALLOC.stringof);
		ObjectAllocator!(T, ALLOC).free(m_object);
		//logTrace("Freeing refcount: ", cast(void*)m_refCount, " object: ", cast(void*)m_object, " Type: ", T.stringof);
		ObjectAllocator!(ulong, ALLOC).free(m_refCount);
		m_refCount = null;
		m_object = null;
	}


	private @property ulong refCount() const {
		if (!m_refCount) return 0;
		return *m_refCount;
	}


	private void defaultInit() const {
		static if (__traits(compiles, { this.opCall(); }())) {
			if (!m_object) {
				auto newObj = this.opCall();
				(cast(RefCounted*)&this).m_object = newObj.m_object;
				(cast(RefCounted*)&this).m_refCount = newObj.m_refCount;
				newObj.m_object = null;
			}
		}
		
	}
	
	private void checkInvariants()
	const {
		assert(!m_object || refCount > 0, (!m_object) ? "No m_object" : "Zero Refcount: " ~ refCount.to!string ~ " for " ~ T.stringof);
	}
}
