module owlchain.xdr.publicKey;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.publicKeyType;

struct PublicKey
{
    PublicKeyType discriminant;
    uint256 ed25519;

    static void encode(XdrDataOutputStream stream, ref const PublicKey encodedPublicKey)
    {
        PublicKeyType.encode(stream, encodedPublicKey.discriminant);
        switch (encodedPublicKey.discriminant.val)
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
        decodedPublicKey.discriminant = PublicKeyType.decode(stream);
        switch (decodedPublicKey.discriminant.val)
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