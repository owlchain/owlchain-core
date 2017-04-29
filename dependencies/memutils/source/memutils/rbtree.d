/**
 * Implementation of a custom allocator red-black tree container.
 * 
 * Copyright: Red-black tree code copyright (C) 2008- by Steven Schveighoffer. Other code
 * copyright 2010- Andrei Alexandrescu. All rights reserved by the respective holders.
 * License: Distributed under the Boost Software License, Version 1.0.
 * (See at $(WEB boost.org/LICENSE_1_0.txt)).
 * Authors: Steven Schveighoffer, $(WEB erdani.com, Andrei Alexandrescu)
*/
module memutils.rbtree;

import std.functional; // : binaryFun;
import std.traits;
import std.range;
import std.algorithm : countUntil;
import memutils.allocators;
import memutils.refcounted;
import memutils.vector;
import memutils.constants;
import memutils.utils;

alias RBTreeRef(T,  alias less = "a < b", bool allowDuplicates = true, ALLOC = ThreadMem) = RefCounted!(RBTree!(T, less, allowDuplicates, ALLOC));

/**
 * All inserts, removes, searches, and any function in general has complexity
 * of $(BIGOH lg(n)).
 *
 * To use a different comparison than $(D "a < b"), pass a different operator string
 * that can be used by $(XREF functional, binaryFun), or pass in a
 * function, delegate, functor, or any type where $(D less(a, b)) results in a $(D bool)
 * value.
 *
 * Note that less should produce a strict ordering.  That is, for two unequal
 * elements $(D a) and $(D b), $(D less(a, b) == !less(b, a)). $(D less(a, a)) should
 * always equal $(D false).
 *
 * If $(D allowDuplicates) is set to $(D true), then inserting the same element more than
 * once continues to add more elements.  If it is $(D false), duplicate elements are
 * ignored on insertion.  If duplicates are allowed, then new elements are
 * inserted after all existing duplicate elements.
 */
struct RBTree(T, alias less = "a < b", bool allowDuplicates = true, ALLOC = ThreadMem)
	if(is(typeof(binaryFun!less(T.init, T.init))))
{
	@disable this(this);

	import std.range : Take;
	import std.typetuple : allSatisfy;
	import std.traits;
	
	alias _less = binaryFun!less;
	
	// BUG: this must come first in the struct due to issue 2810
	
	// add an element to the tree, returns the node added, or the existing node
	// if it has already been added and allowDuplicates is false
	
	private auto _add(Elem n)
	{
		Node result;
		static if(!allowDuplicates)
			bool added = true;

		if(!_end.left)
		{
			_end.left = _begin = result = allocate(n);
		}
		else
		{
			Node newParent = _end.left;
			Node nxt = void;
			while(true)
			{
				if(_less(n, newParent.value))
				{
					nxt = newParent.left;
					if(nxt is null)
					{
						//
						// add to right of new parent
						//
						newParent.left = result = allocate(n);
						break;
					}
				}
				else
				{
					static if(!allowDuplicates)
					{
						if(!_less(newParent.value, n))
						{
							result = newParent;
							added = false;
							break;
						}
					}
					nxt = newParent.right;
					if(nxt is null)
					{
						//
						// add to right of new parent
						//
						newParent.right = result = allocate(n);
						break;
					}
				}
				newParent = nxt;
			}
			if(_begin.left)
				_begin = _begin.left;
		}
		
		static if(allowDuplicates)
		{
			result.setColor(_end);
			++_length;
			return result;
		}
		else
		{
			import std.typecons : Tuple;
			
			if(added)
			{
				++_length;
				result.setColor(_end);
			}
			return Tuple!(bool, "added", Node, "n")(added, result);
		}
	}
	
	
	private enum doUnittest = false;
	
	/**
      * Element type for the tree
      */
	alias Elem = T;
	
	// used for convenience
	private alias Node = RBNode!(Elem, ALLOC).Node;

	private Node   _root;
	private Node   _end;
	private Node   _begin;
	private size_t _length;

	package void _defaultInitialize()
	{
		if (!_end) {
			_begin = _end = _root = allocate();
		}
	}
	
	static private Node allocate()
	{
		return ObjectAllocator!(RBNode!(Elem, ALLOC), ALLOC).alloc();
	}
	
	static private Node allocate(Elem v)
	{
		auto result = allocate();
		logTrace("Allocating node ", cast(void*)result);
		result.value = v;
		return result;
	}
	
	// find a node based on an element value
	private Node _find(Elem e) const
	{
		static if(allowDuplicates)
		{
			Node cur = _end.left;
			Node result = null;
			while(cur)
			{
				if(_less(cur.value, e))
					cur = cur.right;
				else if(_less(e, cur.value))
					cur = cur.left;
				else
				{
					// want to find the left-most element
					result = cur;
					cur = cur.left;
				}
			}
			return result;
		}
		else
		{
			Node cur = _end.left;
			while(cur)
			{
				if(_less(cur.value, e))
					cur = cur.right;
				else if(_less(e, cur.value))
					cur = cur.left;
				else
					return cur;
			}
			return null;
		}
	}
	
	
	
	/**
     * Check if any elements exist in the container.  Returns $(D false) if at least
     * one element exists.
     */
	@property bool empty() const
	{
		return _end.left is null;
	}
	
	/++
        Returns the number of elements in the container.

        Complexity: $(BIGOH 1).
    +/
	@property size_t length() const
	{
		return _length;
	}
		
	/**
     * Fetch a range that spans all the elements in the container.
     *
     * Complexity: $(BIGOH 1)
     */
	RBRange!(Elem, ALLOC) opSlice()
	{
		_defaultInitialize();
		return range(_begin, _end);
	}
	
	/**
     * The front element in the container
     *
     * Complexity: $(BIGOH 1)
     */
	ref Elem front()
	{
		_defaultInitialize();
		return _begin.value;
	}
	
	/**
     * The last element in the container
     *
     * Complexity: $(BIGOH log(n))
     */
	ref Elem back()
	{
		_defaultInitialize();
		return _end.prev.value;
	}
	
	/++
        $(D in) operator. Check to see if the given element exists in the
        container.

       Complexity: $(BIGOH log(n))
     +/
	bool opBinaryRight(string op)(Elem e) const if (op == "in") 
	{
		return _find(e) !is null;
	}
	
	/**
     * Removes all elements from the container.
     *
     * Complexity: $(BIGOH 1)
     */
	void clear()
	{
		_defaultInitialize();
		logTrace("Clearing rbtree");
		while (length > 0)
			removeAny();
		logTrace(length, " items left");
		return;
	}
	
	/**
     * Insert a single element in the container.  Note that this does not
     * invalidate any ranges currently iterating the container.
     *
     * Complexity: $(BIGOH log(n))
     */
	size_t insert(Stuff)(Stuff stuff) if (isImplicitlyConvertible!(Stuff, Elem))
	{
		_defaultInitialize();
		static if(allowDuplicates)
		{
			_add(stuff);
			return 1;
		}
		else
		{
			return(_add(stuff).added ? 1 : 0);
		}
	}
	
	/**
     * Insert a range of elements in the container.  Note that this does not
     * invalidate any ranges currently iterating the container.
     *
     * Complexity: $(BIGOH m * log(n))
     */
	size_t insert(Stuff)(Stuff stuff) if(isInputRange!Stuff && isImplicitlyConvertible!(ElementType!Stuff, Elem))
	{
		_defaultInitialize();
		size_t result = 0;
		static if(allowDuplicates)
		{
			foreach(e; stuff)
			{
				++result;
				_add(e);
			}
		}
		else
		{
			foreach(e; stuff)
			{
				if(_add(e).added)
					++result;
			}
		}
		return result;
	}

	
	/**
     * Remove an element from the container and return its value.
     *
     * Complexity: $(BIGOH log(n))
     */
	Elem removeAny()
	{
		_defaultInitialize();
		scope(success)
			--_length;
		auto n = _begin;
		auto result = n.value;
		_begin = n.remove(_end);
		return result;
	}
	
	/**
     * Remove the front element from the container.
     *
     * Complexity: $(BIGOH log(n))
     */
	void removeFront()
	{
		_defaultInitialize();
		scope(success)
			--_length;
		_begin = _begin.remove(_end);
	}
	
	/**
     * Remove the back element from the container.
     *
     * Complexity: $(BIGOH log(n))
     */
	void removeBack()
	{
		_defaultInitialize();
		scope(success)
			--_length;
		auto lastnode = _end.prev;
		if(lastnode is _begin)
			_begin = _begin.remove(_end);
		else
			lastnode.remove(_end);
	}
	
	/++
       Removes elements from the container that are equal to the given values
       according to the less comparator. One element is removed for each value
       given which is in the container. If $(D allowDuplicates) is true,
       duplicates are removed only if duplicate values are given.

       Returns: The number of elements removed.

       Complexity: $(BIGOH m log(n)) (where m is the number of elements to remove)

       Examples:
--------------------
auto rbt = redBlackTree!true(0, 1, 1, 1, 4, 5, 7);
rbt.removeKey(1, 4, 7);
assert(equal(rbt[], [0, 1, 1, 5]));
rbt.removeKey(1, 1, 0);
assert(equal(rbt[], [5]));
--------------------
      +/
	size_t remove(U...)(U elems)
		if(allSatisfy!(isImplicitlyConvertibleToElem, U))
	{
		_defaultInitialize();
		Elem[U.length] toRemove;
		
		foreach(i, e; elems)
			toRemove[i] = e;
		
		return remove(toRemove[]);
	}
	
	/++ Ditto +/
	size_t remove(U)(U[] elems)
		if(isImplicitlyConvertible!(U, Elem))
	{
		_defaultInitialize();
		immutable lenBefore = length;
		
		foreach(e; elems)
		{
			auto beg = _firstGreaterEqual(e);
			if(beg is _end || _less(e, beg.value))
				// no values are equal
				continue;
			immutable isBegin = (beg is _begin);
			beg = beg.remove(_end);
			if(isBegin)
				_begin = beg;
			--_length;
		}
		
		return lenBefore - length;
	}
	
	/++ Ditto +/
	size_t remove(Stuff)(Stuff stuff)
		if(isInputRange!Stuff &&
			isImplicitlyConvertible!(ElementType!Stuff, Elem) &&
			!isDynamicArray!Stuff)
	{
		_defaultInitialize();
		import std.array : array;
		//We use array in case stuff is a Range from this RedBlackTree - either
		//directly or indirectly.
		return remove(array(stuff));
	}
	
	//Helper for removeKey.
	private template isImplicitlyConvertibleToElem(U)
	{
		enum isImplicitlyConvertibleToElem = isImplicitlyConvertible!(U, Elem);
	}
	
	/**
     * Compares two trees for equality.
     *
     * Complexity: $(BIGOH n*log(n))
     */
	bool opEquals(ref RBTree rhs)
	{
		_defaultInitialize();
		import std.algorithm : equal;
		if (rhs.empty) return false;
		
		// If there aren't the same number of nodes, we can't be equal.
		if (this._length != rhs._length) return false;
		
		auto thisRange = this[];
		auto thatRange = rhs[];
		return equal!(function(Elem a, Elem b) => !_less(a,b) && !_less(b,a))(thisRange, thatRange);
	}
	
	// find the first node where the value is > e
	private Node _firstGreater(Elem e)
	{
		// can't use _find, because we cannot return null
		auto cur = _end.left;
		auto result = _end;
		while(cur)
		{
			if(_less(e, cur.value))
			{
				result = cur;
				cur = cur.left;
			}
			else
				cur = cur.right;
		}
		return result;
	}
	
	// find the first node where the value is >= e
	private Node _firstGreaterEqual(Elem e)
	{
		// can't use _find, because we cannot return null.
		auto cur = _end.left;
		auto result = _end;
		while(cur)
		{
			if(_less(cur.value, e))
				cur = cur.right;
			else
			{
				result = cur;
				cur = cur.left;
			}
			
		}
		return result;
	}
	
	/**
     * Get a range from the container with all elements that are > e according
     * to the less comparator
     *
     * Complexity: $(BIGOH log(n))
     */
	auto upperBoundRange(Elem e)
	{
		_defaultInitialize();
		return range(_firstGreater(e), _end);
	}
	
	/**
     * Get a range from the container with all elements that are < e according
     * to the less comparator
     *
     * Complexity: $(BIGOH log(n))
     */
	auto lowerBoundRange(Elem e)
	{
		_defaultInitialize();
		return range(_begin, _firstGreaterEqual(e));
	}
	
	/**
     * Get a range from the container with all elements that are == e according
     * to the less comparator
     *
     * Complexity: $(BIGOH log(n))
     */
	auto getValuesAt(Elem e)
	{
		_defaultInitialize();
		auto beg = _firstGreaterEqual(e);
		if(beg is _end || _less(e, beg.value))
			// no values are equal
			return range(beg, beg);
		static if(allowDuplicates)
		{
			return range(beg, _firstGreater(e));
		}
		else
		{
			// no sense in doing a full search, no duplicates are allowed,
			// so we just get the next node.
			return range(beg, beg.next);
		}
	}

	this(size_t elems) {
		_defaultInitialize();
	}

	/**
     * Constructor. Pass in an array of elements, or individual elements to
     * initialize the tree with.
     */
	this(Elem[] elems...)
	{
		_defaultInitialize();
		static if (is(Elem == void[])) {
			foreach(elem;elems) insert(elem);
		}
		else
			insert(elems);
	}
	
	/**
     * Constructor. Pass in a range of elements to initialize the tree with.
     */
	this(Stuff)(Stuff stuff) if (isInputRange!Stuff && isImplicitlyConvertible!(ElementType!Stuff, Elem))
	{
		_defaultInitialize();
		insert(stuff);
	}

	~this() {
		if (!_end) return;
		clear();
		ObjectAllocator!(RBNode!(Elem, ALLOC), ALLOC).free(_root);
	}
	
	private this(Node end, size_t length)
	{
		_end = end;
		_begin = end.leftmost;
		_length = length;
	}
}

/*
 * Implementation for a Red Black node for use in a Red Black Tree (see below)
 *
 * this implementation assumes we have a marker Node that is the parent of the
 * root Node.  This marker Node is not a valid Node, but marks the end of the
 * collection.  The root is the left child of the marker Node, so it is always
 * last in the collection.  The marker Node is passed in to the setColor
 * function, and the Node which has this Node as its parent is assumed to be
 * the root Node.
 *
 * A Red Black tree should have O(lg(n)) insertion, removal, and search time.
 */
struct RBNode(V, ALLOC)
{
	/*
     * Convenience alias
     */
	alias Node = RBNode!(V, ALLOC)*;
	
	private Node _left;
	private Node _right;
	private Node _parent;
	
	/**
     * The value held by this node
     */
	V value;
	
	/**
     * Enumeration determining what color the node is.  Null nodes are assumed
     * to be black.
     */
	enum Color : byte
	{
		Red,
		Black
	}
	
	/**
     * The color of the node.
     */
	Color color;
	
	/**
     * Get the left child
     */
	@property Node left() const
	{
		return cast(Node)_left;
	}
	
	/**
     * Get the right child
     */
	@property inout(Node) right() inout
	{
		return _right;
	}
	
	/**
     * Get the parent
     */
	@property Node parent()
	{
		return _parent;
	}
	
	/**
     * Set the left child.  Also updates the new child's parent node.  This
     * does not update the previous child.
     *
     * Returns newNode
     */
	@property Node left(Node newNode)
	{
		_left = newNode;
		if(newNode !is null)
			newNode._parent = &this;
		return newNode;
	}
	
	/**
     * Set the right child.  Also updates the new child's parent node.  This
     * does not update the previous child.
     *
     * Returns newNode
     */
	@property Node right(Node newNode)
	{
		_right = newNode;
		if(newNode !is null)
			newNode._parent = &this;
		return newNode;
	}
	
	// assume _left is not null
	//
	// performs rotate-right operation, where this is T, _right is R, _left is
	// L, _parent is P:
	//
	//      P         P
	//      |   ->    |
	//      T         L
	//     / \       / \
	//    L   R     a   T
	//   / \           / \
	//  a   b         b   R
	//
	/**
     * Rotate right.  This performs the following operations:
     *  - The left child becomes the parent of this node.
     *  - This node becomes the new parent's right child.
     *  - The old right child of the new parent becomes the left child of this
     *    node.
     */
	Node rotateR()
		in
	{
		assert(_left !is null);
	}
	body
	{
		// sets _left._parent also
		if(isLeftNode)
			parent.left = _left;
		else
			parent.right = _left;
		Node tmp = _left._right;
		
		// sets _parent also
		_left.right = &this;
		
		// sets tmp._parent also
		left = tmp;
		
		return &this;
	}
	
	// assumes _right is non null
	//
	// performs rotate-left operation, where this is T, _right is R, _left is
	// L, _parent is P:
	//
	//      P           P
	//      |    ->     |
	//      T           R
	//     / \         / \
	//    L   R       T   b
	//       / \     / \
	//      a   b   L   a
	//
	/**
     * Rotate left.  This performs the following operations:
     *  - The right child becomes the parent of this node.
     *  - This node becomes the new parent's left child.
     *  - The old left child of the new parent becomes the right child of this
     *    node.
     */
	Node rotateL()
		in
	{
		assert(_right !is null);
	}
	body
	{
		// sets _right._parent also
		if(isLeftNode)
			parent.left = _right;
		else
			parent.right = _right;
		Node tmp = _right._left;
		
		// sets _parent also
		_right.left = &this;
		
		// sets tmp._parent also
		right = tmp;
		return &this;
	}
	
	
	/**
     * Returns true if this node is a left child.
     *
     * Note that this should always return a value because the root has a
     * parent which is the marker node.
     */
	@property bool isLeftNode() const
	in
	{
		assert(_parent !is null);
	}
	body
	{
		return _parent._left is &this;
	}
	
	/**
     * Set the color of the node after it is inserted.  This performs an
     * update to the whole tree, possibly rotating nodes to keep the Red-Black
     * properties correct.  This is an O(lg(n)) operation, where n is the
     * number of nodes in the tree.
     *
     * end is the marker node, which is the parent of the topmost valid node.
     */
	void setColor(Node end)
	{
		// test against the marker node
		if(_parent !is end)
		{
			if(_parent.color == Color.Red)
			{
				Node cur = &this;
				while(true)
				{
					// because root is always black, _parent._parent always exists
					if(cur._parent.isLeftNode)
					{
						// parent is left node, y is 'uncle', could be null
						Node y = cur._parent._parent._right;
						if(y !is null && y.color == Color.Red)
						{
							cur._parent.color = Color.Black;
							y.color = Color.Black;
							cur = cur._parent._parent;
							if(cur._parent is end)
							{
								// root node
								cur.color = Color.Black;
								break;
							}
							else
							{
								// not root node
								cur.color = Color.Red;
								if(cur._parent.color == Color.Black)
									// satisfied, exit the loop
									break;
							}
						}
						else
						{
							if(!cur.isLeftNode)
								cur = cur._parent.rotateL();
							cur._parent.color = Color.Black;
							cur = cur._parent._parent.rotateR();
							cur.color = Color.Red;
							// tree should be satisfied now
							break;
						}
					}
					else
					{
						// parent is right node, y is 'uncle'
						Node y = cur._parent._parent._left;
						if(y !is null && y.color == Color.Red)
						{
							cur._parent.color = Color.Black;
							y.color = Color.Black;
							cur = cur._parent._parent;
							if(cur._parent is end)
							{
								// root node
								cur.color = Color.Black;
								break;
							}
							else
							{
								// not root node
								cur.color = Color.Red;
								if(cur._parent.color == Color.Black)
									// satisfied, exit the loop
									break;
							}
						}
						else
						{
							if(cur.isLeftNode)
								cur = cur._parent.rotateR();
							cur._parent.color = Color.Black;
							cur = cur._parent._parent.rotateL();
							cur.color = Color.Red;
							// tree should be satisfied now
							break;
						}
					}
				}
				
			}
		}
		else
		{
			//
			// this is the root node, color it black
			//
			color = Color.Black;
		}
	}
	
	/**
     * Remove this node from the tree.  The 'end' node is used as the marker
     * which is root's parent.  Note that this cannot be null!
     *
     * Returns the next highest valued node in the tree after this one, or end
     * if this was the highest-valued node.
     */
	Node remove(Node end)
	{
		//
		// remove this node from the tree, fixing the color if necessary.
		//
		Node x;
		Node ret = next;
		
		// if this node has 2 children
		if (_left !is null && _right !is null)
		{
			//
			// normally, we can just swap this node's and y's value, but
			// because an iterator could be pointing to y and we don't want to
			// disturb it, we swap this node and y's structure instead.  This
			// can also be a benefit if the value of the tree is a large
			// struct, which takes a long time to copy.
			//
			Node yp, yl, yr;
			Node y = ret; // y = next
			yp = y._parent;
			yl = y._left;
			yr = y._right;
			auto yc = y.color;
			auto isyleft = y.isLeftNode;
			
			//
			// replace y's structure with structure of this node.
			//
			if(isLeftNode)
				_parent.left = y;
			else
				_parent.right = y;
			//
			// need special case so y doesn't point back to itself
			//
			y.left = _left;
			if(_right is y)
				y.right = &this;
			else
				y.right = _right;
			y.color = color;
			
			//
			// replace this node's structure with structure of y.
			//
			left = yl;
			right = yr;
			if(_parent !is y)
			{
				if(isyleft)
					yp.left = &this;
				else
					yp.right = &this;
			}
			color = yc;
		}
		
		// if this has less than 2 children, remove it
		if(_left !is null)
			x = _left;
		else
			x = _right;
		
		bool deferedUnlink = false;
		if(x is null)
		{
			// pretend this is a null node, defer unlinking the node
			x = &this;
			deferedUnlink = true;
		}
		else if(isLeftNode)
			_parent.left = x;
		else
			_parent.right = x;
		
		// if the color of this is black, then it needs to be fixed
		if(color == color.Black)
		{
			// need to recolor the tree.
			while(x._parent !is end && x.color == Node.Color.Black)
			{
				if(x.isLeftNode)
				{
					// left node
					Node w = x._parent._right;
					if(w.color == Node.Color.Red)
					{
						w.color = Node.Color.Black;
						x._parent.color = Node.Color.Red;
						x._parent.rotateL();
						w = x._parent._right;
					}
					Node wl = w.left;
					Node wr = w.right;
					if((wl is null || wl.color == Node.Color.Black) &&
						(wr is null || wr.color == Node.Color.Black))
					{
						w.color = Node.Color.Red;
						x = x._parent;
					}
					else
					{
						if(wr is null || wr.color == Node.Color.Black)
						{
							// wl cannot be null here
							wl.color = Node.Color.Black;
							w.color = Node.Color.Red;
							w.rotateR();
							w = x._parent._right;
						}
						
						w.color = x._parent.color;
						x._parent.color = Node.Color.Black;
						w._right.color = Node.Color.Black;
						x._parent.rotateL();
						x = end.left; // x = root
					}
				}
				else
				{
					// right node
					Node w = x._parent._left;
					if(w.color == Node.Color.Red)
					{
						w.color = Node.Color.Black;
						x._parent.color = Node.Color.Red;
						x._parent.rotateR();
						w = x._parent._left;
					}
					Node wl = w.left;
					Node wr = w.right;
					if((wl is null || wl.color == Node.Color.Black) &&
						(wr is null || wr.color == Node.Color.Black))
					{
						w.color = Node.Color.Red;
						x = x._parent;
					}
					else
					{
						if(wl is null || wl.color == Node.Color.Black)
						{
							// wr cannot be null here
							wr.color = Node.Color.Black;
							w.color = Node.Color.Red;
							w.rotateL();
							w = x._parent._left;
						}
						
						w.color = x._parent.color;
						x._parent.color = Node.Color.Black;
						w._left.color = Node.Color.Black;
						x._parent.rotateR();
						x = end.left; // x = root
					}
				}
			}
			x.color = Node.Color.Black;
		}
		
		if(deferedUnlink)
		{
			//
			// unlink this node from the tree
			//
			if(isLeftNode)
				_parent.left = null;
			else
				_parent.right = null;
			
		}
		
		// clean references to help GC - Bugzilla 12915
		_left = _right = _parent = null;
		
		/// this node object can now be safely deleted
		logTrace("Freeing node ", cast(void*)&this);
		ObjectAllocator!(RBNode!(V, ALLOC), ALLOC).free(cast(RBNode!(V, ALLOC)*)&this);
		
		return ret;
	}
	
	/**
     * Return the leftmost descendant of this node.
     */
	@property Node leftmost()
	{
		Node result = &this;
		while(result._left !is null)
			result = result._left;
		return result;
	}
	
	/**
     * Return the rightmost descendant of this node
     */
	@property Node rightmost()
	{
		Node result = &this;
		while(result._right !is null)
			result = result._right;
		return result;
	}
	
	/**
     * Returns the next valued node in the tree.
     *
     * You should never call this on the marker node, as it is assumed that
     * there is a valid next node.
     */
	@property Node next()
	{
		Node n = &this;
		if(n.right is null)
		{
			while(n._parent && !n.isLeftNode)
				n = n._parent;
			return n._parent;
		}
		else if (n.right !is null) {
			if (!n._parent) return null;
			return n.right.leftmost;
		}
		else return null;
	}
	
	/**
     * Returns the previous valued node in the tree.
     *
     * You should never call this on the leftmost node of the tree as it is
     * assumed that there is a valid previous node.
     */
	@property Node prev()
	{
		Node n = &this;
		if(n.left is null)
		{
			while(n.isLeftNode)
				n = n._parent;
			return n._parent;
		}
		else
			return n.left.rightmost;
	}
	
	@property Node dup() const
	{
		Node copy = ObjectAllocator!(RBNode!(V, ALLOC), ALLOC).alloc();
		logTrace("Allocating node ", cast(void*)copy);
		copy.value = cast(V)value;
		copy.color = color;
		if(_left !is null)
			copy.left = _left.dup();
		if(_right !is null)
			copy.right = _right.dup();
		return copy;
	}
}

/**
 * The range type for $(D RedBlackTree)
 */
struct RBRange(Elem, ALLOC)
{
	alias Node = RBNode!(Elem, ALLOC).Node;
	private Node _begin;
	private Node _end;
	
	private this(Node b, Node e)
	{
		_begin = b;
		_end = e;
	}

	/**
     * Returns $(D true) if the range is _empty
     */
	@property bool empty() const
	{
		return _begin is _end || !_begin;
	}
	
	/**
     * Returns the first element in the range
     */
	@property ref Elem front()
	{
		return _begin.value;
	}
	
	/**
         * Returns the last element in the range
         */
	@property ref Elem back()
	{
		return _end.prev.value;
	}
	
	/**
         * pop the front element from the range
         *
         * complexity: amortized $(BIGOH 1)
         */
	void popFront()
	{
		_begin = _begin.next;
	}
	
	/**
         * pop the back element from the range
         *
         * complexity: amortized $(BIGOH 1)
         */
	void popBack()
	{
		_end = _end.prev;
	}
	
	/**
         * Trivial _save implementation, needed for $(D isForwardRBRange).
         */
	@property RBRange save()
	{
		return *cast(RBRange*)&this;
	}
}

private auto range(Elem, ALLOC)(RBNode!(Elem, ALLOC)* start, RBNode!(Elem, ALLOC)* end) {
	return RBRange!(Elem, ALLOC)(start, end);
}

auto vector(Elem, ALLOC)(RBRange!(Elem, ALLOC) r) {
	return Vector!(Unqual!Elem, ALLOC)(r);
}