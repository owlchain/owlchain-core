module memutils.scoped;

import core.thread : Fiber;
import memutils.constants;
import memutils.allocators;
import memutils.pool;
import memutils.utils;
import memutils.vector;
import memutils.refcounted;
import memutils.unique;
import memutils.hashmap;
import memutils.freelist;
import memutils.memory;
import std.traits : hasElaborateDestructor, isArray;
import std.algorithm : min;
import std.exception;
import core.exception;

alias ScopedPool = RefCounted!ScopedPoolImpl;

final class ScopedPoolImpl {
	// TODO: Use a name for debugging?

	int id;
	/// Initializes a scoped pool with max_mem
	/// max_mem doesn't do anything at the moment
	this(size_t max_mem = 0) {
		PoolStack.push();
		id = PoolStack.top.id;
	}

	~this() {
		debug if(id != PoolStack.top.id) unfreeze();
		PoolStack.pop();
	}

	/// Use only if ScopedPool is the highest on stack.
	void freeze() {
		enforce(id == PoolStack.top.id);
		enforce(PoolStack.freeze(1) == 1, "Failed to freeze pool");
	}

	void unfreeze() {
		enforce(PoolStack.unfreeze(1) == 1, "Failed to unfreeze pool");
		enforce(id == PoolStack.top.id);
	}
}

T alloc(T, ARGS...)(auto ref ARGS args)
	if (is(T == class) || is(T == interface) || __traits(isAbstractClass, T))
{
	T ret;
	
	if (!PoolStack.empty) {
		ret = ObjectAllocator!(T, PoolStack).alloc(args);
		
		// Add destructor to pool
		static if (hasElaborateDestructor!T || __traits(hasMember, T, "__dtor") ) 
			PoolStack.top().onDestroy(&ret.__dtor);
	}
	else {
		ret = new T(args);
	}
	
	return ret;
}

T* alloc(T, ARGS...)(auto ref ARGS args)
	if (!(is(T == class) || is(T == interface) || __traits(isAbstractClass, T)))
{
	T* ret;
	
	if (!PoolStack.empty) {
		ret = ObjectAllocator!(T, PoolStack).alloc(args);
		
		// Add destructor to pool
		static if (hasElaborateDestructor!T || __traits(hasMember, T, "__dtor") ) 
			PoolStack.top.onDestroy(&ret.__dtor);
		
	}
	else {
		ret = new T(args);
	}
	
	return ret;
}

/// arrays
auto alloc(T)(size_t n)
	if (isArray!T)
{
	import std.range : ElementType;
	
	T ret;
	if (!PoolStack.empty) {
		ret = allocArray!(ElementType!T, PoolStack)(n);
		registerPoolArray(ret);
	}
	else {
		ret = new T(n);
	}
	return ret;
}

auto realloc(T)(ref T arr, size_t n)
	if (isArray!T)
{
	import std.range : ElementType;
	T ret;
	if (!PoolStack.empty) {
		scope(exit) arr = null;
		ret = reallocArray!(ElementType!T, PoolStack)(arr, n);
		reregisterPoolArray(arr, ret);
	}
	else {
		arr.length = n;
		ret = arr;
	}
}


struct PoolStack {
static:
	@property bool empty() { return m_tstack.empty && m_fstack.empty; }

	/// returns the most recent unfrozen pool, null if none available
	@property ManagedPool top() {
		if (Fiber.getThis() && !m_fstack.empty) {
			return m_fstack.top;
		}
		return m_tstack.top;
	}

	/// creates a new pool as the fiber stack top or the thread stack top
	void push() {
		//logTrace("Pushing PoolStack");
		if (Fiber.getThis())
			return m_fstack.push();
		m_tstack.push();
		//logTrace("Pushed ThreadStack");
	}

	/// destroy the most recent pool and free all its resources, calling destructors
	/// if you're in a fiber, search for stack top in the fiber stack or the fiber freezer and destroy it.
	/// otherwise, search in the thread stack or the thread freezer and destroy it.
	void pop() {
		//logTrace("Pop PoolStack");
		if (Fiber.getThis() && (!m_fstack.empty || !m_ffreezer.empty))
		{
			//logTrace("Pop FiberStack");
			if (m_fstack.hasTop)
				return m_fstack.pop();
			//else
			auto ret = m_ffreezer.pop(1);
			//logTrace("Pop ThreadStack instead");
			m_fstack.cnt--;
			return;
		}
		// else
		auto top = m_tstack.top;
		assert(top, "Can't find a pool to pop");
		//logTrace("Pop ThreadStack");
		if (m_tstack.hasTop)
			return m_tstack.pop();
		//logTrace("Doesn't have top?");
		//else
		auto ret = m_tfreezer.pop(1);

		m_tstack.cnt--;
		//logTrace("Destroyign ", ret.back.id);

	}

	void disable() {
		freeze(m_tstack.length + m_fstack.length);
	}

	void enable() {
		unfreeze(m_ffreezer.length + m_tfreezer.length);
	}

package:
	// returns number of pools frozen
	size_t freeze(size_t n = 1) {
		auto minsz = min(m_fstack.length, n);

		if (minsz > 0) {
			auto frozen = m_fstack.freeze(minsz);
			m_ffreezer.push(frozen);
		}

		if (minsz < n) {
			auto tsz = min(m_tstack.length, n - minsz);
			if (tsz > 0) {
				auto frozen = m_tstack.freeze(tsz);
			 	m_tfreezer.push(frozen);
			}
			return tsz + minsz;
		}
		return minsz;
	}

	// returns number of pools unfrozen
	size_t unfreeze(size_t n = 1) {
		auto minsz = min(m_ffreezer.length, n);
		
		if (minsz > 0) m_fstack.unfreeze(m_ffreezer.pop(minsz));
		
		if (minsz < n) {
			auto tsz = min(m_tfreezer.length, n - minsz);
			if (tsz > 0) m_tstack.unfreeze(m_tfreezer.pop(tsz));
			return tsz + minsz;
		}
		return minsz;
	}

	~this() {
		destroy(m_fstack);
		destroy(m_tstack);
	}

private static:
	// active
	ThreadPoolStack m_tstack;
	FiberPoolStack m_fstack;

	// frozen
	ThreadPoolFreezer m_tfreezer;
	FiberPoolFreezer m_ffreezer;

}

package:

alias Pool = PoolAllocator!(AutoFreeListAllocator!(MallocAllocator));
alias ManagedPool = RefCounted!(Pool);

/// User utility for allocating on lower level pools
struct ThreadPoolFreezer 
{
	@disable this(this);
	@property size_t length() const { return m_pools.length; }
	@property bool empty() const { return length == 0; }

	void push(Array!(ManagedPool, Malloc) pools)
	{
		//logTrace("Push Thread Freezer of ", m_pools.length);
		// insert sorted
		foreach(ref item; pools[]) {
			bool found;
			foreach (size_t i, ref el; m_pools[]) {
				if (item.id < el.id) {
					m_pools.insertBefore(i, item);
					found = true;
					break;
				}
			}
			if (!found) m_pools ~= item;
		}
		//logTrace("Pushed Thread Freezer now ", m_pools.length);
	}

	Array!(ManagedPool, Malloc) pop(size_t n) {
		assert(!empty);
		//logTrace("Pop Thread Freezer of ", m_pools.length, " id ", m_pools.back.id);
		// already sorted
		auto pools = Array!(ManagedPool, Malloc)( m_pools[$-n .. $] );

		
		m_pools.length = (m_pools.length - 1);
		//logTrace("Popped Thread Freezer returning ", pools.length, " expecting ", n);
		//logTrace("Returning ID ", pools.back.id);
		return pools;
	}
	
package:
	Vector!(ManagedPool, Malloc) m_pools;
}

/// User utility for allocating on lower level pools
struct FiberPoolFreezer
{
	@disable this(this);
	@property size_t fibers() const { return m_pools.length; }
	
	@property size_t length() const { 
		Fiber f = Fiber.getThis();
		if (auto ptr = (f in m_pools)) {
			return (*ptr).length;
		}
		return 0;
	}

	@property bool empty() const {
		return length == 0; 
	}

	void push(Array!(ManagedPool, Malloc) pools)
	{
		//logTrace("Push Fiber Freezer of ", length);
		Fiber f = Fiber.getThis();
		assert(f !is null);
		if (auto ptr = (f in m_pools)) {
			auto arr = *ptr;

			// insert sorted
			foreach(ref item; pools[]) {
				bool found;
				foreach (size_t i, ref el; arr[]) {
					if (item.id < el.id) {
						arr.insertBefore(i, item);
						found = true;
						break;
					}
				}
				if (!found) arr ~= item;
			}
			//logTrace("Pushed Fiber Freezer of ", length);
			return;
		}
		//else
		m_pools[f] = pools.dupr;
		//logTrace("Pushed Fiber Freezer of ", length);
	}

	Array!(ManagedPool, Malloc) pop(size_t n) {
		//logTrace("Pop Fiber Freezer of ", length);
		assert(!empty);
		
		Fiber f = Fiber.getThis();
		auto arr = m_pools[f];

		if (arr.empty) {
			m_pools.remove(f);
			return Array!(ManagedPool, Malloc)();
		}

		// already sorted
		auto pools = Array!(ManagedPool, Malloc)( arr[$-n .. $] );
		arr.length = (arr.length - n);
		//logTrace("Popped Fiber Freezer of ", length);
		return pools;
	}

private:

	HashMap!(Fiber, Array!(ManagedPool, Malloc), Malloc) m_pools;
}
struct ThreadPoolStack
{
	@disable this(this);
	@property size_t length() const { return m_pools.length; }
	@property bool empty() const { return length == 0; }
	size_t opDollar() const { return length; }
	@property bool hasTop() { return length > 0 && cnt-1 == top.id; }


	ManagedPool opIndex(size_t n) {
		//logTrace("OpIndex[", n, "] in Thread Pool of ", length, " top: ", cnt, " id: ", m_pools[n].id);
		return m_pools[n];
	}

	@property ManagedPool top() 
	{
		//logTrace("Front Thread Pool of ", length);
		if (empty) {
			//logTrace("Empty");
			return ManagedPool();
		}
		return m_pools.back;
	}

	void pop()
	{
		assert(!empty);
		//logTrace("Pop Thread Pool of ", length, " top: ", cnt, " back id: ", m_pools.back.id);
		auto pool = m_pools.back;
		assert(pool.id == cnt-1);
		--cnt;
		m_pools.removeBack();
		//if (!empty) logTrace("Popped Thread Pool of ", length, " top: ", cnt, " back id: ", m_pools.back.id);
	}

	void push() {
		//if (!m_pools.empty) logTrace("Push Thread Pool of ", length, " top: ", cnt, " back id: ", m_pools.back.id);
		//else logTrace("Push Thread Pool of ", length, " top: ", cnt);
		ManagedPool pool = ManagedPool();
		pool.id = cnt++;
		m_pools.pushBack(pool);
		//logTrace("Pushed Thread Pool of ", length, " top: ", cnt, " back id: ", m_pools.back.id);
	}

	Array!(ManagedPool, Malloc) freeze(size_t n) {
		assert(!empty);
		//if (!m_pools.empty) logTrace("Freeze ", n, " in Thread Pool of ", length, " top: ", cnt);
		//else logTrace("Freeze ", n, " in Thread Pool of ", length, " top: ", cnt, " back id: ", m_pools.back.id);
		assert(n <= length);
		Array!(ManagedPool, Malloc) ret;
		ret[] = m_pools[$-n .. $];
		m_pools.length = (m_pools.length - 1);
		//logTrace("Returning ", ret.length);
		//if (!empty) logTrace("Freezeed ", n, " in Thread Pool of ", length, " top: ", cnt, " back id: ", m_pools.back.id);
		return ret;
	}

	void unfreeze(Array!(ManagedPool, Malloc) pools) {
		//logTrace("Unfreeze ", pools.length, " in Thread Pool of ", length, " top: ", cnt, " back id: ", m_pools.back.id);
		// insert sorted
		foreach(ref item; pools[]) {
			bool found;
			foreach (size_t i, ref el; m_pools[]) {
				if (item.id < el.id) {
					m_pools.insertBefore(i, item);
					found = true;
					break;
				}
			}
			if (!found) m_pools ~= item;
		}
		//logTrace("Unfreezed ", pools.length, " in Thread Pool of ", length, " top: ", cnt, " back id: ", m_pools.back.id);
	}

package:
	int cnt;
	Vector!(ManagedPool, Malloc) m_pools;
}

struct FiberPoolStack
{
	@disable this(this);
	@property size_t fibers() const { return m_pools.length; }

	@property size_t length() const {
		Fiber f = Fiber.getThis();
		if (auto ptr = (f in m_pools)) {
			return (*ptr).length;
		}
		return 0;
	}

	@property bool hasTop() { return length > 0 && cnt-1 == top.id; }

	@property bool empty() const {
		return length == 0; 
	}

	size_t opDollar() const { return length; }

	ManagedPool opIndex(size_t n) {
		assert(!empty);
		Fiber f = Fiber.getThis();
		//logTrace("OpIndex[", n, "] in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f][n].id);
		return m_pools[f][n];

	}

	@property ManagedPool top() 
	{
		assert(!empty);
		Fiber f = Fiber.getThis();
		if (auto ptr = (f in m_pools)) {
			//logTrace("top in Fiber Pool of ", length, " top: ", cnt, " len: ", (*ptr).back().id);
			return (*ptr).back();
		}
		return ManagedPool();

	}

	// returns next item ie. top()
	void pop() {
		assert(!empty);

		Fiber f = Fiber.getThis();
		//logTrace("pop in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f].back.id);
		auto arr = m_pools[f];
		assert(arr.back.id == cnt-1);
		arr.removeBack();
		cnt++;
		if (arr.empty) 
			m_pools.remove(f);
		//if (!empty) logTrace("popped in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f].back.id);
	}

	void push()
	{
		ManagedPool pool = ManagedPool();
		pool.id = cnt++;
		Fiber f = Fiber.getThis();
		//if (!empty) logTrace("Push in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools.get(f).back.id);
		assert(f !is null);
		if (auto ptr = (f in m_pools)) {
			*ptr ~= pool;
			//logTrace("Pushed in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f].back.id);
			return;
		}
		//else
		m_pools[f] = Array!(ManagedPool, Malloc)();
		m_pools[f] ~= pool;
		//logDebug("Pushed in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f].back.id);
	}

	// returns the frozen items
	Array!(ManagedPool, Malloc) freeze(size_t n) {
		assert(n <= length);
		Fiber f = Fiber.getThis();
		//logTrace("Freeze in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f].back.id);
		auto arr = m_pools[f];
		Array!(ManagedPool, Malloc) ret;
		ret[] = arr[$-n .. $];
		arr.length = (arr.length - n);
		//logTrace("Frozen in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f].back.id);
		return ret;
	}


	void unfreeze(Array!(ManagedPool, Malloc) items)
	{
		Fiber f = Fiber.getThis();
		assert(f !is null);
		//logTrace("Unfreeze in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f].back.id);
		if (auto ptr = (f in m_pools)) {
			auto arr = *ptr;
			// insert sorted
			foreach(ref item; items[]) {
				bool found;
				foreach (size_t i, ref el; arr[]) {
					if (item.id < el.id) {
						arr.insertBefore(i, item);
						found = true;
						break;
					}
				}
				if (!found) arr ~= item;
			}
			//logTrace("Unfrozen in Fiber Pool of ", length, " top: ", cnt, " id: ", m_pools[f].back.id);
			return;
		}
		assert(false);
	}
package:
	int cnt;
	HashMap!(Fiber, Array!(ManagedPool, Malloc), Malloc) m_pools;
}


private void registerPoolArray(T)(ref T arr) {
	import std.range : ElementType;
	// Add destructors to fiber pool
	static if (is(T == struct) && (hasElaborateDestructor!(ElementType!T) || __traits(hasMember, ElementType!T, "__dtor") )) {
		foreach (ref el; arr)
			PoolStack.top.onDestroy(&el.__dtor);
	}
}

private void reregisterPoolArray(T)(ref T arr, ref T arr2) {
	import std.range : ElementType;
	// Add destructors to fiber pool
	static if (is(T == struct) && (hasElaborateDestructor!(ElementType!T) || __traits(hasMember, ElementType!T, "__dtor") )) {
		if (arr.ptr is arr2.ptr && arr2.length > arr.length) {
			foreach (ref el; arr2[arr.length - 1 .. $])
				PoolStack.top.onDestroy(&el.__dtor);
		}
		else {
			PoolStack.top.removeArrayDtors(&arr.back.__dtor, arr.length);
			registerPoolArray(arr2);
		}
	}
}