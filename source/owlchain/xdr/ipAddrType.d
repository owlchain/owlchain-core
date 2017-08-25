module owlchain.xdr.ipAddrType;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum IPAddrType
{
    IPv4 = 0,
    IPv6 = 1,
}

static void encodeIPAddrType(XdrDataOutputStream stream, ref const IPAddrType encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static IPAddrType decodeIPAddrType(XdrDataInputStream stream)
{
    const int32 value = stream.readInt32();
    switch (value)
    {
    case 0:
        return IPAddrType.IPv4;
    case 1:
        return IPAddrType.IPv6;
    default:
        throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
}
