module owlchain.xdr.envelopeType;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum EnvelopeType  {
    ENVELOPE_TYPE_BCP = 1,
    ENVELOPE_TYPE_TX = 2,
    ENVELOPE_TYPE_AUTH = 3
}

static void encodeEnvelopeType(XdrDataOutputStream stream, EnvelopeType encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static EnvelopeType decodeEnvelopeType(XdrDataInputStream stream)
{
    const int32 value = stream.readInt32();
    switch (value)
    {
    case 1:
        return EnvelopeType.ENVELOPE_TYPE_BCP;
    case 2:
        return EnvelopeType.ENVELOPE_TYPE_TX;
    case 3:
        return EnvelopeType.ENVELOPE_TYPE_AUTH;
    default:
        throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
}
