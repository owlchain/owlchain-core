module memutils.vector;

import std.algorithm : swap, initializeAll;
import std.range : empty;
import std.traits;
import core.stdc.string;
import std.range : isInputRange, isForwardRange, isRandomAccessRange, ElementType, refRange, RefRange, hasLength;
import core.exception : RangeError;
import std.exception : enforce;
import memutils.allocators;
import memutils.helpers;
import memutils.utils;
import memutils.refcounted;
import std.conv : emplace, to;

public alias SecureArray(T) = Array!(T, SecureMem);

template Array(T, ALLOC = ThreadMem) 
	if (!is (T == RefCounted!(Vector!(T, ALLOC), ALLOC)))
{
	alias Array = RefCounted!(Vector!(T, ALLOC), ALLOC);
}

public alias SecureVector(T) = Vector!(T, SecureMem);
// TODO: Remove implicit string casting for Vector!ubyte! Encourage use of Vector!char [].idup instead.

/// An array that uses a custom allocator.
struct Vector(T, ALLOC = ThreadMem)
{	
	@disable this(this);
	static if (!is(ALLOC == AppMem)) enum NOGC = true;
	void opAssign()(auto ref Vector!(T, ALLOC) other) {
		if (other.ptr !is this.ptr)
			this.swap(other);
	}

	void opAssign()(ref T[] other) {
		this[] = other[];
	}
	
	// Payload cannot be copied
	private struct Payload
	{
		size_t _capacity;
		T[] _payload;
		
		// Convenience constructor
		this()(auto ref T[] p) 
		{ 
			if (p.length == 0) return;

			length = p.length;

			static if (isImplicitlyConvertible!(T, T)) {
				if (_payload.ptr is p.ptr && _payload.length == p.length) {
					p = null;
				}
				else {
					_payload[] = p[0 .. $]; // todo: use emplace?
				}
			}
			else
			{
				memmove(_payload.ptr, p.ptr, T.sizeof*p.length);
			}
		}
		
		// Destructor releases array memory
		~this() const
		{
			if (_capacity == 0 || _payload.ptr is null)
				return;
			T[] data = cast(T[]) _payload.ptr[0 .. _capacity];
			freeArray!(T, ALLOC)(data, _payload.length); // calls destructors and frees memory
		}
		
		void opAssign(Payload rhs)
		{
			assert(false);
		}
		
		// Duplicate data
		// @property Payload dup()
		// {
		//     Payload result;
		//     result._payload = _payload.dup;
		//     // Conservatively assume initial capacity == length
		//     result._capacity = result._payload.length;
		//     return result;
		// }
		
		// length
		@property size_t length() const
		{
			return _payload.length;
		}
		
		// length
		@property void length(size_t newLength)
		{
			if (length > 0 && length >= newLength)
			{
				// shorten
				static if (hasElaborateDestructor!T) {
					foreach (ref e; _payload.ptr[newLength .. _payload.length]) {
						static if (is(T == struct) && !isPointer!T) // call destructors but not for indirections...
							.destroy(e);
					}
					
					// Zero out unused capacity to prevent gc from seeing
					// false pointers
					static if (hasIndirections!T)
						memset(_payload.ptr + newLength, 0, (_payload.length - newLength) * T.sizeof);
				}
				_payload = _payload.ptr[0 .. newLength];
				return;
			}
			
			if (newLength > 0) {
				// enlarge
				auto startEmplace = length;
				reserve(newLength);
				_payload = _payload.ptr[0 .. newLength];
				static if (!isImplicitlyConvertible!(T, T)) {
					T t = T();
					foreach (size_t i; startEmplace .. length) 
						memmove(_payload.ptr + i, &t, T.sizeof); 
					
				} else
					initializeAll(_payload.ptr[startEmplace .. length]);
			}
		}
		
		// capacity
		@property size_t capacity() const
		{
			return _capacity;
		}
		
		// reserve
		void reserve(size_t elements)
		{
			if (elements <= capacity) return;
			// TODO: allow vector to become smaller?

			TRACE("Reserve ", length, " => ", elements, " elements.");

			if (_capacity > 0) {
				size_t len = _payload.length;
				_payload = _payload.ptr[0 .. _capacity];
				_payload = reallocArray!(T, ALLOC)(_payload, elements)[0 .. len];
			}
			else if (elements > 0) {
				_payload = allocArray!(T, ALLOC)(elements)[0 .. _payload.length];
			}
			_capacity = elements;
		}

		static if (is(T == char))
		size_t pushBack(Stuff)(Stuff stuff) 
			if (is(Stuff == char[]) || is(Stuff == string))
		{
			TRACE("Vector.append @disabled this(this)");
			if (_capacity <= length + stuff.length)
			{
				reserve(1 + (length + stuff.length) * 3 / 2);
			}
			assert(capacity >= length + stuff.length && _payload.ptr);
						
			memmove(_payload.ptr + _payload.length, stuff.ptr, stuff.length);
			_payload = _payload.ptr[0 .. _payload.length + stuff.length];
			
			return 1;
		}

		size_t pushBack(Stuff)(auto ref Stuff stuff)
			if (!isImplicitlyConvertible!(T, T) && is(T == Stuff))
		{
			TRACE("Vector.append @disabled this(this)");
			if (_capacity == length)
			{
				reserve(1 + capacity * 3 / 2);
			}
			assert(capacity > length && _payload.ptr);
			
			T* t = &stuff;
			
			memmove(_payload.ptr + _payload.length, t, T.sizeof);
			memset(t, 0, T.sizeof);
			_payload = _payload.ptr[0 .. _payload.length + 1];
			
			return 1;
		}
		
		// Insert one item
		size_t pushBack(Stuff)(auto ref Stuff stuff)
			if (isImplicitlyConvertible!(T, T) && isImplicitlyConvertible!(Stuff, T))
		{
			TRACE("Vector.append");
			logTrace("Capacity: ", _capacity, " length: ", length);
			if (_capacity == length)
			{
				reserve(1 + capacity * 3 / 2);
			}
			assert(capacity > length && _payload.ptr, "Payload pointer " ~ _payload.ptr.to!string ~ "'s capacity: " ~ capacity.to!string ~ " must be more than " ~ length.to!string);
			emplace(_payload.ptr + _payload.length, stuff);
			_payload = _payload.ptr[0 .. _payload.length + 1];
			return 1;
		}
		
		/// Insert a range of items
		size_t pushBack(Stuff)(auto ref Stuff stuff)
			if (isInputRange!Stuff && (isImplicitlyConvertible!(ElementType!Stuff, T) || is(T == ElementType!Stuff)))
		{
			TRACE("Vector.append 2");
			static if (hasLength!Stuff)
			{
				immutable oldLength = length;
				reserve(oldLength + stuff.length);
			}
			size_t result;
			foreach (ref item; stuff)
			{
				pushBack(item);
				++result;
			}
			static if (hasLength!Stuff)
			{
				assert(length == oldLength + stuff.length);
			}
			return result;
		}
	}
	
	private alias Data = Payload;
	private Data _data;
	
	this(size_t elms) {
		resize(elms);
	}
	
	/**
        Constructor taking a number of items
     */
	this(U)(U[] values...)
		if (isImplicitlyConvertible!(U, T))
	{
		// TODO: This doesn't work with refcounted
		_data = Data(cast(T[])values);
	}

	/**
        Constructor taking an input range
     */
	this(Stuff)(Stuff stuff)
		if (isInputRange!Stuff && isImplicitlyConvertible!(UnConst!(ElementType!Stuff), T) && !is(Stuff == T[]))
	{
		insertBack(stuff);
	}
	
	/**
	 * Move Constructor
	*/
	this()(auto ref typeof(this) other) {
		if (this.ptr !is other.ptr)
			this.swap(other);
		else {
			typeof(this) ini;
			other.swap(ini);
		}
	}

	/**
        Duplicates the container. The elements themselves are not transitively
        duplicated.

        Complexity: $(BIGOH n).
     */
	@property Vector!(T, ALLOC) dup() const
	{
		static if (__traits(compiles, { T a; T b; a = b; } ())) {
			auto ret = Vector!(T, ALLOC)(cast(T[])_data._payload);
			return ret.move;
		}
		else static if (__traits(hasMember, T, "dup")) // Element is @disable this(this) but has dup()
		{
			Vector!(T, ALLOC) vec = Vector!(T, ALLOC)(length);
			// swap each element with a duplicate
			foreach (size_t i, ref el; _data._payload) {
				T t = el.dup;
				memmove(vec._data._payload.ptr + i, &t, T.sizeof);
				memset(&t, 0, T.sizeof);
			}
			return vec.move();
		} else static assert(false, "Cannot dup() the element: " ~ T.stringof);
	}
	
	/// ditto
	@property RefCounted!(Vector!(T, ALLOC), ALLOC) dupr() const
	{
		return RefCounted!(Vector!(T, ALLOC), ALLOC)(cast(T[])_data._payload);
	}
	
	void swap(ref Vector!(T, ALLOC) other) {
		import std.algorithm : swap;
		.swap(_data._payload, other._data._payload);
		.swap(_data._capacity, other._data._capacity);
	}
	
	@property Vector!(T, ALLOC) move() {
		return Vector!(T, ALLOC)(this);
	}
	
	/**
        Property returning $(D true) if and only if the container has no
        elements.

        Complexity: $(BIGOH 1)
     */
	@property bool empty() const
	{
		return !_data._payload || _data._payload.empty;
	}
	
	/**
        Returns the number of elements in the container.

        Complexity: $(BIGOH 1).
     */
	@property size_t length() const
	{
		return _data._payload.length;
	}
	
	/// ditto
	size_t opDollar() const
	{
		return length;
	}
	
	@property T* ptr() inout {
		return cast(T*) _data._payload.ptr;
	}
	
	@property T* end() inout {
		return this.ptr + this.length;
	}
	
	/**
        Returns the maximum number of elements the container can store without
           (a) allocating memory, (b) invalidating iterators upon insertion.

        Complexity: $(BIGOH 1)
     */
	@property size_t capacity() const
	{
		return _data._capacity;
	}

	/*
	@property auto range() {
		return refRange(&_data._payload);
	}
	*/
	
	/**
        Ensures sufficient capacity to accommodate $(D e) elements.

        Postcondition: $(D capacity >= e)

        Complexity: $(BIGOH 1)
     */
	void reserve(size_t elements)
	{
		_data.reserve(elements);
	}
	
	/**
        Returns an array that can be translated to a range using ($D refRange).

        Complexity: $(BIGOH 1)
     */
	auto opSlice() inout
	{
		//static if (is(T[] == ubyte[]))
		//	return cast(string) _data._payload;
		//else
		return *cast(T[]*)&_data._payload;
	}
	
	/**
        Returns an array of the container from index $(D a) up to (excluding) index $(D b).

        Precondition: $(D a <= b && b <= length)

        Complexity: $(BIGOH 1)
     */
	T[] opSlice(size_t i, size_t j) const
	{
		version (assert) if (i > j || j > length) throw new RangeError();
		return (cast(T[])_data._payload)[i .. j];
	}
	
	/**
        Forward to $(D opSlice().front) and $(D opSlice().back), respectively.

        Precondition: $(D !empty)

        Complexity: $(BIGOH 1)
     */
	@property ref T front()
	{
		return _data._payload[0];
	}
	
	/// ditto
	@property ref T back()
	{
		return _data._payload[$ - 1];
	}
	
	/**
        Indexing operators yield or modify the value at a specified index.

        Precondition: $(D i < length)

        Complexity: $(BIGOH 1)
     */	
	ref T opIndex(size_t i) const
	{
		return *cast(T*)&_data._payload[i];
	}
	
	void opIndexAssign(U)(auto ref U val, size_t i)
	{
		static if (__traits(compiles, {_data._payload[i] = cast(T) val; }()))
			_data._payload[i] = cast(T) val;
		else { // swap
			memmove(_data._payload.ptr + i, &val, U.sizeof);
			memset(&val, 0, U.sizeof);
		}
	}
	/**
        Slicing operations execute an operation on an entire slice.

        Precondition: $(D i < j && j < length)

        Complexity: $(BIGOH slice.length)
     */
	void opSliceAssign(Stuff)(auto ref Stuff value)
	{
		static if (isRandomAccessRange!Stuff)
		{
			_data.length = value.length;
			_data._payload.ptr[0 .. value.length] = value[0 .. $];
		} else static if (is(UnConst!Stuff == Vector!(T, ALLOC))) {
			_data.length = value._data.length;
			_data._payload[] = value._data._payload[];
		}
		else static if (isImplicitlyConvertible!(T, ElementType!Stuff)) {
			_data.length = value.length;
			_data._payload[] = cast(T[]) value;
		} else static assert(false, "Can't convert " ~ Stuff.stringof ~ " to " ~ T.stringof ~ "[]");
	}
	
	/// ditto
	void opSliceAssign(Stuff)(Stuff value, size_t i, size_t j)
	{
		auto slice = _data._payload;
		slice[i .. j] = value;
	}
	
	/// ditto
	void opSliceUnary(string op)()
		if(op == "++" || op == "--")
	{
		mixin(op~"_data._payload[];");
	}
	
	/// ditto
	void opSliceUnary(string op)(size_t i, size_t j)
		if(op == "++" || op == "--")
	{
		mixin(op~"slice[i .. j];");
	}
	
	/// ditto
	void opSliceOpAssign(string op)(T value)
	{
		mixin("_data._payload[] "~op~"= value;");
	}
	
	/// ditto
	void opSliceOpAssign(string op)(T value, size_t i, size_t j)
	{
		mixin("slice[i .. j] "~op~"= value;");
	}
	
	/**
        Returns a new container that's the concatenation of $(D this) and its
        argument. $(D opBinaryRight) is only defined if $(D Stuff) does not
        define $(D opBinary).

        Complexity: $(BIGOH n + m), where m is the number of elements in $(D
        stuff)
     */
	auto opBinary(string op, Stuff)(Stuff stuff)
		if (op == "~")
	{
		TRACE("Appending stuff");
		RefCounted!(Vector!(T, ALLOC), ALLOC) result;
		// @@@BUG@@ result ~= this[] doesn't work
		auto r = this[];
		result ~= r;
		assert(result.length == length);
		result ~= stuff[];
		return result;
	}
	
	void opOpAssign(string op, U)(auto ref U input)
		if (op == "^")
	{
		if (this.length < input.length)
			this.resize(input.length);

		pure static void xorBuf(T)(T* output, const(T)* input, size_t length)
		{
			while (length >= 8)
			{
				output[0 .. 8] ^= input[0 .. 8];
				
				output += 8; input += 8; length -= 8;
			}
			
			output[0 .. length] ^= input[0 .. length];
		}

		xorBuf(this.ptr, input.ptr, input.length);
	}
	
	/**
        Forwards to $(D pushBack(stuff)).
     */
	void opOpAssign(string op, Stuff)(auto ref Stuff stuff)
		if (op == "~")
	{
		static if (is (Stuff == RefCounted!(typeof(this)))) {
			insertBack(cast(T[]) stuff[]);
		}
		else static if (is (Stuff == typeof(this))) {
			insertBack(cast(T[]) stuff[]);
		}
		else
		{
			insertBack(stuff);
		}
	}
	
	/**
        Removes all contents from the container. The container decides how $(D
        capacity) is affected.

        Postcondition: $(D empty)

        Complexity: $(BIGOH n)
     */
	void clear()
	{
		TRACE("Vector.clear()");
		_data.length = 0;
	}
	
	
	/**
        Sets the number of elements in the container to $(D newSize). If $(D
        newSize) is greater than $(D length), the added elements are added to
        unspecified positions in the container and initialized with $(D
        T.init).

        Complexity: $(BIGOH abs(n - newLength))

        Postcondition: $(D length == newLength)
     */
	@property void length(size_t newLength)
	{
		_data.length = newLength;
	}
	
	void resize(size_t newLength)
	{
		this.length = newLength;
	}
	
	import std.traits : isNumeric;
	
	int opCmp(Alloc)(auto const ref Vector!(T, Alloc) other) const 
	{
		if (this[] == other[])
			return 0;
		else if (this[] < other[])
			return -1;
		else
			return 0;
	}

	size_t pushBack(Stuff...)(Stuff stuff) 
		if (!isNumeric!Stuff || !is ( T == ubyte ))
	{
		return insertBack(stuff);
	}
	
	size_t pushBack(Stuff...)(Stuff stuff) 
		if (isNumeric!Stuff && is(T == ubyte))
	{
		return insertBack(cast(T) stuff);
	}

	size_t insert(Stuff...)(Stuff stuff) {
		return insertBack(stuff);
	}
	
	/**
        Inserts $(D value) to the front or back of the container. $(D stuff)
        can be a value convertible to $(D T) or a range of objects convertible
        to $(D T). The stable version behaves the same, but guarantees that
        ranges iterating over the container are never invalidated.

        Returns: The number of elements inserted

        Complexity: $(BIGOH m * log(n)), where $(D m) is the number of
        elements in $(D stuff)
    */
	size_t insertBack(Stuff)(auto ref Stuff stuff)
	{
		import std.traits : isImplicitlyConvertible;
		static if (isImplicitlyConvertible!(Stuff, T[]))
			return _data.pushBack(cast(T[])stuff);
		else static if (isSomeString!(Stuff) && !isImplicitlyConvertible!(Stuff, T)) {
			return _data.pushBack(cast(T[])stuff);
		}
		else static if (isSomeString!(Stuff) && isImplicitlyConvertible!(Stuff, T)) {
			return _data.pushBack(cast(T)stuff);
		}
		else static if (isInputRange!(Stuff) && isImplicitlyConvertible!(ForeachType!Stuff, T)) {
			size_t i;
			foreach (ref el; stuff) {
				_data.pushBack(el);
				i++;
			}
			return i;
		}
		else
			return _data.pushBack(cast(T) stuff);
	}

	/**
        Removes the value at the back of the container. The stable version
        behaves the same, but guarantees that ranges iterating over the
        container are never invalidated.

        Precondition: $(D !empty)

        Complexity: $(BIGOH log(n)).
    */
	void removeBack()
	{
		enforce(!empty);
		static if (hasElaborateDestructor!T)
			.destroy(_data._payload[$ - 1]);
		
		_data._payload = _data._payload[0 .. $ - 1];
	}
	
	@trusted
	void removeFront() { 
	
		enforce(!empty);
		static if (hasElaborateDestructor!T)
			.destroy(_data._payload[0]);
		if (_data._payload.length > 1) {
			memmove(_data._payload.ptr, _data._payload.ptr + 1, T.sizeof * (_data._payload.length - 1));
			memset(_data._payload.ptr + _data._payload.length - 1, 0, T.sizeof);
		}
		_data._payload.length -= 1;	
	}
	
	/**
        Removes $(D howMany) values at the front or back of the
        container. Unlike the unparameterized versions above, these functions
        do not throw if they could not remove $(D howMany) elements. Instead,
        if $(D howMany > n), all elements are removed. The returned value is
        the effective number of elements removed. The stable version behaves
        the same, but guarantees that ranges iterating over the container are
        never invalidated.

        Returns: The number of elements removed

        Complexity: $(BIGOH howMany).
    */
	size_t removeBack(size_t howMany)
	{
		if (howMany > length) howMany = length;
		static if (hasElaborateDestructor!T)
			foreach (ref e; _data._payload[$ - howMany .. $])
				.destroy(e);
		
		_data._payload = _data._payload[0 .. $ - howMany];
		return howMany;
	}

	/**
        Inserts $(D stuff) before position i.

        Returns: The number of values inserted.

        Complexity: $(BIGOH n + m), where $(D m) is the length of $(D stuff)
     */
	void insertBefore(Stuff)(size_t i, Stuff stuff)
		if (isImplicitlyConvertible!(Stuff, T))
	{
		enforce(i <= length);
		reserve(length + 1);

		// Move elements over by one slot
		memmove(_data._payload.ptr + i + 1,
				_data._payload.ptr + i,
				T.sizeof * (length - i));
		emplace(_data._payload.ptr + i, stuff);
		_data._payload = _data._payload.ptr[0 .. _data._payload.length + 1];
	}
	
	/// ditto
	size_t insertBefore(Stuff)(size_t i, Stuff stuff)
		if (isInputRange!Stuff && isImplicitlyConvertible!(ElementType!Stuff, T))
	{
		enforce(i <= length);
		static if (isForwardRange!Stuff)
		{
			// Can find the length in advance
			auto extra = walkLength(stuff);
			if (!extra) return 0;
			reserve(length + extra);
			// Move elements over by extra slots
			memmove(_data._payload.ptr + i + extra,
				_data._payload.ptr + i,
				T.sizeof * (length - i));
			foreach (p; _data._payload.ptr + i ..
				_data._payload.ptr + i + extra)
			{
				emplace(p, stuff.front);
				stuff.popFront();
			}
			_data._payload = _data._payload.ptr[0 .. _data._payload.length + extra];
			return extra;
		}
		else
		{
			enforce(_data);
			immutable offset = i;
			enforce(offset <= length);
			auto result = pushBack(stuff);
			bringToFront(this[offset .. length - result],
						 this[length - result .. length]);
			return result;
		}
	}
	
	/// ditto
	size_t insertAfter(Stuff)(size_t i, Stuff stuff)
	{
		enforce(r._outer._data is _data);
		// TODO: optimize
		immutable offset = i;
		enforce(offset <= length);
		auto result = pushBack(stuff);
		bringToFront(this[offset .. length - result],
					 this[length - result .. length]);
		return result;
	}

	bool opEquals()(auto const ref RefCounted!(Vector!(T, ALLOC), ALLOC) other_) const {
		import memutils.constants : logTrace;
		if (other_.empty && empty())
			return true;
		else if (other_.empty)
			return false;
		if (other_.length != length)
			return false;
		// TODO: use the true types
		return _data._payload[0 .. length] == other_._data._payload[0 .. length];
	}

	bool opEquals()(auto const ref Vector!(T, ALLOC) other_) const {
		if (other_.empty && empty())
			return true;
		else if (other_.empty)
			return false;
		if (other_.length != length)
			return false;

		return _data._payload[0 .. length] == other_._data._payload[0 .. length];
	}

	bool opEquals()(auto const ref T[] other) {
		logTrace("other: ", other, " this: ", _data._payload);
		return other == _data._payload;
	}
	
}

auto array(T)(T[] val) 
{
	return Array!(Unqual!T)(val);
}

auto vector(T)(T[] val)
{
	return Vector!(Unqual!T)(val);
}

void TRACE(T...)(T t) {
	//import std.stdio : writeln;
	//writeln(t);
}
