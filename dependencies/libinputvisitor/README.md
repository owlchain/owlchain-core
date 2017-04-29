libInputVisitor
===============

This simple library makes it easy to write [D](http://dlang.org) [input range](http://dlang.org/phobos/std_range.html) generators in a straightforward coroutine style, as [explained here](http://semitwist.com/articles/article/view/combine-coroutines-and-input-ranges-for-dead-simple-d-iteration).

This does come with a downside: Since D has no built-in support for coroutines, this library is implemented using D [fibers](http://dlang.org/phobos/core_thread.html#Fiber). This means every yield and resume require a context switch. This makes it considerably slower than foreach or an ordinary event-based input-range (but still very much faster than threads). Depending on your use-case, this may, or may not, be an issue. On the bright side, this does make it trivial to yield from inside any depth of function calls, and even from recursive functions.

This is open-course software licensed under the [WTFPL](http://sam.zoy.org/wtfpl/).

Usage
-----
Just add a ```visit()``` function (or two, or three...) to your struct or class as demonstrated in the [sample](https://github.com/Abscissa/libInputVisitor/blob/master/libInputVisitorExample.d) below. Then, obtain your instant input range by calling ```inputVisitor!YourElemType(yourObject)```.

Sample
------
```d
// libInputVisitorExample.d
// Requires DMD compiler v2.059 or up
// To complile and run:
//    rdmd libInputVisitorExample.d
import std.algorithm;
import std.range;
import std.stdio;
import libInputVisitor;

struct Foo
{
	string[] data = ["hello", "world"];
	bool wasVisited = false;
	
	void visit(InputVisitor!(Foo, string) v)
	{
		wasVisited = true;
		
		v.yield("a");
		v.yield("b");
		foreach(str; data)
			v.yield(str);
	}

	void visit(InputVisitor!(Foo, int) v)
	{
		wasVisited = true;

		v.yield(1);
		v.yield(2);
		v.yield(3);
	}
}

void main()
{
	Foo foo;

	// Prints: a, b, hello, world
	//
	// Note: If you get a stack overflow, try increasing the fiber's
	// stack size, for example:
	//   foo.inputVisitor!string(4096*32)
	foreach(item; foo.inputVisitor!string)
		writeln(item);

	// Prints: 1, 2, 3
	foreach(item; foo.inputVisitor!int)
		writeln(item);

	// It's a range! Prints: 10, 30
	auto myRange = foo.inputVisitor!int;
	foreach(item; myRange.filter!( x => x!=2 )().map!( x => x*10 )())
		writeln(item);
	
	// A NOTE ABOUT STRUCTS
	// --------------------
	// Remember that 'foo' is a struct (ie, pass-by-value), therefore
	// InputVisitor only iterates a COPY of 'foo'. To access InputVisitor's
	// copy of 'foo', use '.obj':
	assert(&myRange.obj != &foo);   // Different copies of 'foo'
	assert(!foo.wasVisited);        // Original 'foo' was only copied, never used.
	assert(myRange.obj.wasVisited); // InputRange's COPY of 'foo' was used.
}
```
