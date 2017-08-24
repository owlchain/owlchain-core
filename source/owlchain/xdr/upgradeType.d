module owlchain.xdr.upgradeType;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct UpgradeType
{
    ubyte[] value;

    static UpgradeType opCall(ubyte[] v)
    {
        UpgradeType h;
        h.value = v.dup;
        return h;
    }

    static UpgradeType opCall(const ubyte[] v)
    {
        UpgradeType h;
        h.value = v.dup;
        return h;
    }

    static UpgradeType opCall(UpgradeType s)
    {
        UpgradeType t;
        t.value = s.value.dup;
        return t;
    }

    static UpgradeType opCall(ref UpgradeType s)
    {
        UpgradeType t;
        t.value = s.value.dup;
        return t;
    }

    static UpgradeType opCall(ref const UpgradeType s)
    {
        UpgradeType t;
        t.value = s.value.dup;
        return t;
    }

    ref UpgradeType opAssign(UpgradeType s)
    {
        value = s.value.dup;
        return this;
    }

    ref UpgradeType opAssign(ref UpgradeType s)
    {
        value = s.value.dup;
        return this;
    }

    ref UpgradeType opAssign(ref const UpgradeType s)
    {
        value = s.value.dup;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const UpgradeType encodedUpgradeType)
    {
        int UpgradeTypesize = cast(int)encodedUpgradeType.value.length;
        stream.writeInt32(UpgradeTypesize);
        stream.write(encodedUpgradeType.value);
    }

    static UpgradeType decode(XdrDataInputStream stream)
    {
        UpgradeType decodedUpgradeType;
        int UpgradeTypesize = stream.readInt32();
        decodedUpgradeType.value.length = UpgradeTypesize;
        stream.read(decodedUpgradeType.value);
        return decodedUpgradeType;
    }
}

