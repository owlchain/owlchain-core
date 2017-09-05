module owlchain.xdr.publicKey;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.publicKeyType;

struct PublicKey
{
    PublicKeyType type;
    uint256 ed25519;

    int opCmp(const PublicKey other) const
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
        encodePublicKeyType(stream, encodedPublicKey.type);
        switch (encodedPublicKey.type)
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
        decodedPublicKey.type = decodePublicKeyType(stream);
        switch (decodedPublicKey.type)
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
