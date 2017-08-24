module owlchain.xdr.publicKey;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.publicKeyType;

struct PublicKey
{
    PublicKeyType discriminant;
    uint256 ed25519;

    int opCmp(ref PublicKey other)
    {
        if (ed25519 < other.ed25519)
        {
            return -1;
        }
        else if (ed25519 > other.ed25519)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }

    static void encode(XdrDataOutputStream stream, ref const PublicKey encodedPublicKey)
    {
        stream.writeInt32(encodedPublicKey.discriminant);
        switch (encodedPublicKey.discriminant)
        {
        case PublicKeyType.PUBLIC_KEY_TYPE_ED25519:
            stream.writeUint256(encodedPublicKey.ed25519);
            break;
        default:
            break;
        }
    }

    static PublicKey decode(XdrDataInputStream stream)
    {
        PublicKey decodedPublicKey;
        decodedPublicKey.discriminant = cast(PublicKeyType) stream.readInt32();
        switch (decodedPublicKey.discriminant)
        {
        case PublicKeyType.PUBLIC_KEY_TYPE_ED25519:
            decodedPublicKey.ed25519 = stream.readUint256();
            break;
        default:
            break;
        }
        return decodedPublicKey;
    }
}
