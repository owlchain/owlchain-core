module owlchain.xdr.signerKey;

import owlchain.xdr.type;
import owlchain.xdr.signerKeyType;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct SignerKey
{  
    SignerKeyType type;
    uint256 ed25519;
    uint256 preAuthTx;
    uint256 hashX;

    static void encode(XdrDataOutputStream stream, ref const SignerKey encodedSignerKey)
    {
        stream.writeInt32(encodedSignerKey.type);
        switch (encodedSignerKey.type) {
            case SignerKeyType.SIGNER_KEY_TYPE_ED25519:
                stream.writeUint256(encodedSignerKey.ed25519);
                break;
            case SignerKeyType.SIGNER_KEY_TYPE_PRE_AUTH_TX:
                stream.writeUint256(encodedSignerKey.preAuthTx);
                break;
            case SignerKeyType.SIGNER_KEY_TYPE_HASH_X:
                stream.writeUint256(encodedSignerKey.hashX);
                break;
            default:
        }
    }

    static SignerKey decode(XdrDataInputStream stream)
    {
        SignerKey decodedSignerKey;

        int32 value = stream.readInt32();
        switch (value) {
            case 0: 
                decodedSignerKey.type = SignerKeyType.SIGNER_KEY_TYPE_ED25519;
                break;
            case 1: 
                decodedSignerKey.type = SignerKeyType.SIGNER_KEY_TYPE_PRE_AUTH_TX;
                break;
            case 2: 
                decodedSignerKey.type = SignerKeyType.SIGNER_KEY_TYPE_HASH_X;
                break;
            default:
                throw new Exception("Unknown enum value");
        }
        switch (decodedSignerKey.type) {
            case SignerKeyType.SIGNER_KEY_TYPE_ED25519:
                decodedSignerKey.ed25519 = stream.readUint256();
                break;
            case SignerKeyType.SIGNER_KEY_TYPE_PRE_AUTH_TX:
                decodedSignerKey.preAuthTx = stream.readUint256();
                break;
            case SignerKeyType.SIGNER_KEY_TYPE_HASH_X:
                decodedSignerKey.hashX = stream.readUint256();
                break;
            default:
        }
        return decodedSignerKey;
    }
}