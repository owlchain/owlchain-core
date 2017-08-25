module owlchain.xdr.signatureHint;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.transactionEnvelope;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct SignatureHint
{
    ubyte[4] value;

    static void encode(XdrDataOutputStream stream, ref const SignatureHint encoded)
    {
        stream.write(encoded.value);
    }

    static SignatureHint decode(XdrDataInputStream stream)
    {
        SignatureHint decoded;
        stream.read(decoded.value);
        return decoded;
    }

}