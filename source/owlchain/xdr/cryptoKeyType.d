module owlchain.xdr.cryptoKeyType;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum CryptoKeyType
{
    KEY_TYPE_ED25519 = 0,
    KEY_TYPE_PRE_AUTH_TX = 1,
    KEY_TYPE_HASH_X = 2
}

static void encodeCryptoKeyType(XdrDataOutputStream stream, ref const CryptoKeyType encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static CryptoKeyType decodeCreateAccountResultCode(XdrDataInputStream stream)
{
    CryptoKeyType decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = CryptoKeyType.KEY_TYPE_ED25519;
            break;
        case 1:
            decodedType = CryptoKeyType.KEY_TYPE_PRE_AUTH_TX;
            break;
        case 2:
            decodedType = CryptoKeyType.KEY_TYPE_HASH_X;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
