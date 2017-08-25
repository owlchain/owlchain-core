module owlchain.xdr.signerKeyType;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum SignerKeyType
{
    SIGNER_KEY_TYPE_ED25519 = 0,
    SIGNER_KEY_TYPE_PRE_AUTH_TX = 1,
    SIGNER_KEY_TYPE_HASH_X = 2
}

static void encodeSignerKeyType(XdrDataOutputStream stream, ref const SignerKeyType encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static SignerKeyType decodeSignerKeyType(XdrDataInputStream stream)
{
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            return SignerKeyType.SIGNER_KEY_TYPE_ED25519;
        case 1:
            return SignerKeyType.SIGNER_KEY_TYPE_PRE_AUTH_TX;
        case 2:
            return SignerKeyType.SIGNER_KEY_TYPE_HASH_X;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
}
