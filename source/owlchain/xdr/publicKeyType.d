module owlchain.xdr.publicKeyType;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct PublicKeyType
{
    int32 val;

    enum int32 PUBLIC_KEY_TYPE_ED25519 = 0;

    this(int32 value)
    {
        val = value;
    }

    static void encode(XdrDataOutputStream stream, ref const PublicKeyType value)
    {
        stream.writeInt32(value.val);
    }

    static PublicKeyType decode(XdrDataInputStream stream)
    {
        int value = stream.readInt32();
        switch (value) {
            case 0: 
                return PublicKeyType(PublicKeyType.PUBLIC_KEY_TYPE_ED25519);
            default:
                throw new Exception("Unknown enum value");
        }
    }
}