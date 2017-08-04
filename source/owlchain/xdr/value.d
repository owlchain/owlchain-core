module owlchain.xdr.value;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import std.container.rbtree;

alias RedBlackTree !(Value, "(a.value < b.value)") ValueSet;

struct Value
{
    ubyte[] value;

    static Value opCall()
    {
        Value h;
        return h;
    }

    static Value opCall(const ubyte[] v)
    {
        Value h;
        h.value = v.dup;
        return h;
    }

    static Value opCall(ref const Value v)
    {
        Value h;
        h.value = v.value.dup;
        return h;
    }

    ref Value opAssign(const Value v)
    {
        value = v.value.dup;
        return this;
    }

    ref Value opAssign(ref const(Value) v)
    {
        value = v.value.dup;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const Value encodedValue)
    {
        stream.writeUint(cast(uint)(encodedValue.value.length));
        stream.write(encodedValue.value);
    }

    static Value decode(XdrDataInputStream stream)
    {
        Value decodedValue;

        uint size = stream.readUint();
        if (size > 0) 
        {
            decodedValue.value.length = size;
            stream.read(decodedValue.value);
        }
        return decodedValue;
    }
}
