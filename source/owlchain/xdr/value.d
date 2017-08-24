module owlchain.xdr.value;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import std.container.rbtree;

alias RedBlackTree!(Value, "(a.value < b.value)") ValueSet;

struct Value
{
    ubyte[] value;

    static Value opCall()
    {
        Value newValue;
        return newValue;
    }

    static Value opCall(ref ubyte[] other)
    {
        Value newValue;
        newValue.value = other.dup;
        return newValue;
    }

    static Value opCall(ref const Value other)
    {
        Value newValue;
        newValue.value = other.value.dup;
        return newValue;
    }

    ref Value opAssign(Value other)
    {
        value = other.value.dup;
        return this;
    }

    ref Value opAssign(const Value other)
    {
        value = other.value.dup;
        return this;
    }

    ref Value opAssign(ref const(Value) other)
    {
        value = other.value.dup;
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
