module owlchain.xdr.dataValue;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct DataValue
{
    ubyte[] value;

    static DataValue opCall()
    {
        DataValue newValue;
        return newValue;
    }

    static DataValue opCall(ref ubyte[] other)
    {
        DataValue newValue;
        newValue.value = other.dup;
        return newValue;
    }

    static DataValue opCall(ref const DataValue other)
    {
        DataValue newValue;
        newValue.value = other.value.dup;
        return newValue;
    }

    ref DataValue opAssign(DataValue other)
    {
        value = other.value.dup;
        return this;
    }

    ref DataValue opAssign(const DataValue other)
    {
        value = other.value.dup;
        return this;
    }

    ref DataValue opAssign(ref const(DataValue) other)
    {
        value = other.value.dup;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const DataValue encodedValue)
    {
        stream.writeUint(cast(uint)(encodedValue.value.length));
        stream.write(encodedValue.value);
    }

    static DataValue decode(XdrDataInputStream stream)
    {
        DataValue decodedValue;

        const uint size = stream.readUint();
        if (size > 0)
        {
            decodedValue.value.length = size;
            stream.read(decodedValue.value);
        }
        return decodedValue;
    }
}
