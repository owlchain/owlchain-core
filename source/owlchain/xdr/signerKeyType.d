module owlchain.xdr.signerKeyType;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum SignerKeyType
{
    SIGNER_KEY_TYPE_ED25519 = 0,
    SIGNER_KEY_TYPE_PRE_AUTH_TX = 1,
    SIGNER_KEY_TYPE_HASH_X = 2
}
