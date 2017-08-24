module owlchain.utils.uniqueStruct;

import std.typecons;

struct UniqueStruct(T)
{
    /** Represents a reference to $(D T). Resolves to $(D T*) if $(D T) is a value type. */
    static if (is(T : Object))
        alias RefT = T;
    else
        alias RefT = T*;

public:
    // Deferred in case we get some language support for checking uniqueness.
    version (None) /**
        Allows safe construction of $(D UniqueStruct). It creates the resource and
        guarantees unique ownership of it (unless $(D T) publishes aliases of
        $(D this)).
        Note: Nested structs/classes cannot be created.
        Params:
        args = Arguments to pass to $(D T)'s constructor.
        ---
        static class C {}
        auto u = UniqueStruct!(C).create();
        ---
        */
    static UniqueStruct!T create(A...)(auto ref A args)
            if (__traits(compiles, new T(args)))
    {
        debug (UniqueStruct)
            writeln("UniqueStruct.create for ", T.stringof);
        UniqueStruct!T u;
        u._p = new T(args);
        return u;
    }

    /**
    Constructor that takes an rvalue.
    It will ensure uniqueness, as long as the rvalue
    isn't just a view on an lvalue (e.g., a cast).
    Typical usage:
    ----
    UniqueStruct!Foo f = new Foo;
    ----
    */
    this(RefT p)
    {
        debug (UniqueStruct)
            writeln("UniqueStruct constructor with rvalue");
        _p = p;
    }
    /**
    Constructor that takes an lvalue. It nulls its source.
    The nulling will ensure uniqueness as long as there
    are no previous aliases to the source.
    */
    this(ref RefT p)
    {
        _p = p;
        debug (UniqueStruct)
            writeln("UniqueStruct constructor nulling source");
        p = null;
        assert(p is null);
    }
    /**
    Constructor that takes a $(D UniqueStruct) of a type that is convertible to our type.

    Typically used to transfer a $(D UniqueStruct) rvalue of derived type to
    a $(D UniqueStruct) of base type.
    Example:
    ---
    class C : Object {}

    UniqueStruct!C uc = new C;
    UniqueStruct!Object uo = uc.release;
    ---
    */
    this(U)(UniqueStruct!U u) if (is(u.RefT : RefT))
    {
        debug (UniqueStruct)
            writeln("UniqueStruct constructor converting from ", U.stringof);
        _p = u._p;
        u._p = null;
    }

    /// Transfer ownership from a $(D UniqueStruct) of a type that is convertible to our type.
    void opAssign(U)(UniqueStruct!U u) if (is(u.RefT : RefT))
    {
        debug (UniqueStruct)
            writeln("UniqueStruct opAssign converting from ", U.stringof);
        // first delete any resource we own
        destroy(this);
        _p = u._p;
        u._p = null;
    }

    ~this()
    {
        debug (UniqueStruct)
            writeln("UniqueStruct destructor of ", (_p is null) ? null : _p);
        if (_p !is null)
        {
            delete _p;
            _p = null;
        }
    }

    /** Returns whether the resource exists. */
    @property bool isEmpty() const
    {
        return _p is null;
    }
    /** Transfer ownership to a $(D UniqueStruct) rvalue. Nullifies the current contents.
    Same as calling std.algorithm.move on it.
    */
    UniqueStruct release()
    {
        debug (UniqueStruct)
            writeln("UniqueStruct Release");
        import std.algorithm.mutation : move;

        return this.move;
    }

    /** Forwards member access to contents. */
    mixin Proxy!_p;

    /**
    Postblit operator is undefined to prevent the cloning of $(D UniqueStruct) objects.
    */
    @disable this(this);

private:
    RefT _p;
}
