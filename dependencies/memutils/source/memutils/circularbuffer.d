/**
	Utility functions for circular array processing
	Copyright: © 2012 RejectedSoftware e.K., © 2014-2015 Etienne Cimon
	License: Subject to the terms of the MIT license, as written in the included LICENSE file.
	Authors: Sönke Ludwig, Etienne Cimon
*/
module memutils.circularbuffer;

import memutils.allocators;
import memutils.constants;
import std.algorithm;
import std.traits : hasElaborateDestructor, isBasicType, isPointer;
import memutils.utils;

struct CircularBuffer(T, size_t N = 0, ALLOC = ThreadMem) {
	@disable this(this);

	private {
		static if( N > 0 ) T[N] m_buffer;
		else T[] m_buffer;
		size_t m_start = 0;
		size_t m_fill = 0;
	}
	static if( N == 0 ){
		this(size_t capacity) { m_buffer = allocArray!(T, ALLOC)(capacity); }
		~this() { if (m_buffer) freeArray!(T, ALLOC)(m_buffer, m_fill, m_start); }
	} 
	else {
		// clear ring buffer static fields upon removal (to run struct destructors, if T is a struct)
		~this() 
		{ 
			// TODO: Test this
			// destroy(m_buffer[m_start .. m_fill]); 
		}
	}
	@property bool empty() const { return m_fill == 0; }
	@property bool full() const { return m_fill == m_buffer.length; }
	@property size_t length() const { return m_fill; }
	@property size_t freeSpace() const { return m_buffer.length - m_fill; }
	@property size_t capacity() const { return m_buffer.length; }
	static if( N == 0 ){
		@property void capacity(size_t new_size)
		{
			if (new_size <= length || new_size == capacity) return;
			if( m_buffer.length ){
				auto temp = allocArray!(T, ALLOC)(new_size);
				size_t tmp_fill = m_fill;
				read(temp[0 .. m_fill]);
				m_start = 0;
				m_fill = tmp_fill;
				freeArray!(T, ALLOC)(m_buffer, m_fill, m_start);
				m_buffer = temp;
			} else m_buffer = allocArray!(T, ALLOC)(new_size);
		}
	}
	@property ref inout(T) front() inout { assert(!empty); return m_buffer[m_start]; }
	@property ref inout(T) back() inout { assert(!empty); return m_buffer[mod(m_start+m_fill-1)]; }
	void clear()
	{
		popFrontN(length);
		assert(m_fill == 0);
		m_start = 0;
	}
	void put()(T itm) { assert(m_fill < m_buffer.length); m_buffer[mod(m_start + m_fill++)] = itm; }
	void forcePut()(T itm) { if (m_fill >= m_buffer.length) popBack(); m_buffer[mod(m_start + m_fill++)] = itm; }
	void put(TC : T)(TC[] itms)
	{
		if( !itms.length ) return;
		static if( N == 0 ) {
			if (m_fill+itms.length > m_buffer.length)
				capacity = capacity*2;
		} else assert(m_fill+itms.length <= m_buffer.length, "Cannot write to buffer, it is full.");
		if( mod(m_start+m_fill) >= mod(m_start+m_fill+itms.length) ){
			size_t chunk1 = m_buffer.length - (m_start+m_fill);
			size_t chunk2 = itms.length - chunk1;
			m_buffer[m_start+m_fill .. m_buffer.length] = itms[0 .. chunk1];
			m_buffer[0 .. chunk2] = itms[chunk1 .. $];
		} else {
			m_buffer[mod(m_start+m_fill) .. mod(m_start+m_fill)+itms.length] = itms[];
		}
		m_fill += itms.length;
	}
	void putN(size_t n) { assert(m_fill+n <= m_buffer.length); m_fill += n; }
	void popFront() { assert(!empty); m_start = mod(m_start+1); m_fill--; }
	void popFrontN(size_t n) { 
		import core.stdc.string : memset; 
		assert(length >= n); 
		m_start = mod(m_start + n);
		m_fill -= n;
	}
	void popBack() { assert(!empty); m_fill--; }
	void popBackN(size_t n) { assert(length >= n); m_fill -= n; }

	// moves all the values from the buffer one step down at start of the reference range
	void removeAt(Range r)
	{
		assert(r.m_buffer is m_buffer);
		if( m_start + m_fill > m_buffer.length ){
			assert(r.m_start >= m_start && r.m_start < m_buffer.length || r.m_start < mod(m_start+m_fill));
			if( r.m_start > m_start ){
				foreach(i; r.m_start .. m_buffer.length-1)
					m_buffer[i] = m_buffer[i+1];
				m_buffer[$-1] = m_buffer[0];
				foreach(i; 0 .. mod(m_start + m_fill - 1))
					m_buffer[i] = m_buffer[i+1];
			} else {
				foreach(i; r.m_start .. mod(m_start + m_fill - 1))
					m_buffer[i] = m_buffer[i+1];
			}
		} else {
			assert(r.m_start >= m_start && r.m_start < m_start+m_fill);
			foreach(i; r.m_start .. m_start+m_fill-1)
				m_buffer[i] = m_buffer[i+1];
		}
		m_fill--;
		static if (hasElaborateDestructor!T) { // calls destructors
			static if (is(T == struct) && isPointer!T) .destroy(*m_buffer[mod(m_start+m_fill)]);
			else .destroy(m_buffer[mod(m_start+m_fill)]);
		}
	}
	inout(T)[] peek() inout { return m_buffer[m_start .. min(m_start+m_fill, m_buffer.length)]; }
	T[] peekDst() {
		if( m_start + m_fill < m_buffer.length ) return m_buffer[m_start+m_fill .. $];
		else return m_buffer[mod(m_start+m_fill) .. m_start];
	}
	void read(T[] dst)
	{
		import core.stdc.string : memset;
		assert(dst.length <= length);
		if( !dst.length ) return;
		if( mod(m_start) >= mod(m_start+dst.length) ){
			size_t chunk1 = m_buffer.length - m_start;
			size_t chunk2 = dst.length - chunk1;
			dst[0 .. chunk1] = m_buffer[m_start .. $];
			dst[chunk1 .. $] = m_buffer[0 .. chunk2];
			//static if (is(ALLOC == SecureMem)) 
			//{
			//	memset(m_buffer.ptr + m_start, 0, chunk1);
			//	memset(m_buffer.ptr, 0, chunk2);
			//}
		} else {
			dst[] = m_buffer[m_start .. m_start+dst.length];
			//static if (is(ALLOC == SecureMem)) 
			//	memset(m_buffer.ptr + m_start, 0, dst.length);
		}
		popFrontN(dst.length);
	}
	int opApply(scope int delegate(ref T itm) del)
	{
		if( m_start+m_fill > m_buffer.length ){
			foreach(i; m_start .. m_buffer.length)
				if( auto ret = del(m_buffer[i]) )
					return ret;
			foreach(i; 0 .. mod(m_start+m_fill))
				if( auto ret = del(m_buffer[i]) )
					return ret;
		} else {
			foreach(i; m_start .. m_start+m_fill)
				if( auto ret = del(m_buffer[i]) )
					return ret;
		}
		return 0;
	}
	ref inout(T) opIndex(size_t idx) inout { assert(idx < length); return m_buffer[mod(m_start+idx)]; }
	Range opSlice() { return Range(m_buffer, m_start, m_fill); }
	Range opSlice(size_t from, size_t to)
	{
		assert(from <= to);
		assert(to <= m_fill);
		return Range(m_buffer, mod(m_start+from), to-from);
	}
	size_t opDollar(size_t dim)() const if(dim == 0) { return length; }
	private size_t mod(size_t n)
	const {
		static if( N == 0 ){
			/*static if(PotOnly){
            return x & (m_buffer.length-1);
            } else {*/
			return n % m_buffer.length;
			//}
		} else static if( ((N - 1) & N) == 0 ){
			return n & (N - 1);
		} else return n % N;
	}
	static struct Range {
		private {
			T[] m_buffer;
			size_t m_start;
			size_t m_length;
		}
		private this(T[] buffer, size_t start, size_t length)
		{
			m_buffer = buffer;
			m_start = start;
			m_length = length;
		}
		@property bool empty() const { return m_length == 0; }
		@property inout(T) front() inout { assert(!empty); return m_buffer[m_start]; }
		void popFront()
		{
			assert(!empty);
			m_start++;
			m_length--;
			if( m_start >= m_buffer.length )
				m_start = 0;
		}
	}
}

unittest {
	import std.range : isInputRange, isOutputRange;
	static assert(isInputRange!(CircularBuffer!int) && isOutputRange!(CircularBuffer!int, int));

	// test static buffer
	CircularBuffer!(int, 5) buf;
	assert(buf.length == 0 && buf.freeSpace == 5); buf.put(1); // |1 . . . .
	assert(buf.length == 1 && buf.freeSpace == 4); buf.put(2); // |1 2 . . .
	assert(buf.length == 2 && buf.freeSpace == 3); buf.put(3); // |1 2 3 . .
	assert(buf.length == 3 && buf.freeSpace == 2); buf.put(4); // |1 2 3 4 .
	assert(buf.length == 4 && buf.freeSpace == 1); buf.put(5); // |1 2 3 4 5
	assert(buf.length == 5 && buf.freeSpace == 0);
	assert(buf.front == 1);
	buf.popFront(); // .|2 3 4 5
	assert(buf.front == 2);
	buf.popFrontN(2); // . . .|4 5
	assert(buf.front == 4);
	assert(buf.length == 2 && buf.freeSpace == 3);
	buf.put([6, 7, 8]); // 6 7 8|4 5
	assert(buf.length == 5 && buf.freeSpace == 0);
	int[5] dst;
	buf.read(dst); // . . .|. .
	assert(dst == [4, 5, 6, 7, 8]);
	assert(buf.length == 0 && buf.freeSpace == 5);
	buf.put([1, 2]); // . . .|1 2
	assert(buf.length == 2 && buf.freeSpace == 3);
	buf.read(dst[0 .. 2]); //|. . . . .
	assert(dst[0 .. 2] == [1, 2]);
}
