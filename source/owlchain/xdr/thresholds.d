module owlchain.xdr.thresholds;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Thresholds
{
    ubyte[] thresholds;

    static Thresholds opCall()
    {
        Thresholds newValue;
        return newValue;
    }

    static Thresholds opCall(ref ubyte[] other)
    {
        Thresholds newValue;
        newValue.thresholds = other.dup;
        return newValue;
    }

    static Thresholds opCall(ref const Thresholds other)
    {
        Thresholds newValue;
        newValue.thresholds = other.thresholds.dup;
        return newValue;
    }

    ref Thresholds opAssign(Thresholds other)
    {
        thresholds = other.thresholds.dup;
        return this;
    }

    ref Thresholds opAssign(const Thresholds other)
    {
        thresholds = other.thresholds.dup;
        return this;
    }

    ref Thresholds opAssign(ref const(Thresholds) other)
    {
        thresholds = other.thresholds.dup;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const Thresholds encoded)
    {
        stream.writeUint(cast(uint)(encoded.thresholds.length));
        stream.write(encoded.thresholds);
    }

    static Thresholds decode(XdrDataInputStream stream)
    {
        Thresholds decoded;

        const uint size = stream.readUint();
        if (size > 0) 
        {
            decoded.thresholds.length = size;
            stream.read(decoded.thresholds);
        }
        return decoded;
    }
}