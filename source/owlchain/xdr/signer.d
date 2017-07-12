module owlchain.xdr.signer;

import owlchain.xdr.type;
import owlchain.xdr.signerKey;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Signer
{
    SignerKey key;
    uint32 weight;
    
    static void encode(XdrDataOutputStream stream, ref const Signer encodedSigner)
    {
        SignerKey.encode(stream, encodedSigner.key);
        stream.writeUint32(encodedSigner.weight);
    }

    static Signer decode(XdrDataInputStream stream)
    {
        Signer decodedSigner;
        decodedSigner.key = SignerKey.decode(stream);
        decodedSigner.weight = stream.readUint32();
        return decodedSigner;
    }
}
