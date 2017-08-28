module owlchain.xdr.decoratedSignature;

import owlchain.xdr.type;
import owlchain.xdr.signatureHint;
import owlchain.xdr.signature;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct DecoratedSignature
{
    SignatureHint hint;
    Signature signature;

    static void encode(XdrDataOutputStream stream, ref const DecoratedSignature encodedValue)
    {
        SignatureHint.encode(stream, encodedValue.hint);
        Signature.encode(stream, encodedValue.signature);
    }

    static DecoratedSignature decode(XdrDataInputStream stream)
    {
        DecoratedSignature decodedValue;
        decodedValue.hint = SignatureHint.decode(stream);
        decodedValue.signature = Signature.decode(stream);
        return decodedValue;
    }
}
