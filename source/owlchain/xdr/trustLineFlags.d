module owlchain.xdr.trustLineFlags;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum TrustLineFlags
{
    AUTHORIZED_FLAG = 1,
}

static void encodeTrustLineFlags(XdrDataOutputStream stream, ref const TrustLineFlags encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static TrustLineFlags decodeTrustLineFlags(XdrDataInputStream stream)
{
    TrustLineFlags decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case -1:
            decodedType = TrustLineFlags.AUTHORIZED_FLAG;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}