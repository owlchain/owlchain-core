module owlchain.xdr.signerKeyType;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct SignerKeyType
{
    enum
    {
        int32 SIGNER_KEY_TYPE_ED25519 = 0,
        int32 SIGNER_KEY_TYPE_PRE_AUTH_TX = 1,
        int32 SIGNER_KEY_TYPE_HASH_X = 2
    }

    int32 val;

    this (int32 value)
    {
        val = value;
    }

    static void encode(XdrDataOutputStream stream, ref const SignerKeyType value)
    {
        stream.writeInt32(value.val);
    }

    static SignerKeyType decode(XdrDataInputStream stream)
    {
        int value = stream.readInt32();
        switch (value) {
            case 0: return SignerKeyType(SIGNER_KEY_TYPE_ED25519);
            case 1: return SignerKeyType(SIGNER_KEY_TYPE_PRE_AUTH_TX);
            case 2: return SignerKeyType(SIGNER_KEY_TYPE_HASH_X);
            default:
                throw new Exception("Unknown enum value");
        }
    }

}