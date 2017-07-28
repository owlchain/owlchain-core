module owlchain.xdr.signature;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Signature
{
    ubyte[] signature;
    
    static void encode(XdrDataOutputStream stream, ref const Signature encodedSignature)
    {
        int Signaturesize = cast(int)(encodedSignature.signature.length);
        stream.writeInt(Signaturesize);
        stream.write(encodedSignature.signature);
    }

    static Signature decode(XdrDataInputStream stream)
    {
        Signature decodedSignature;
        int signatureSize = stream.readInt();
        decodedSignature.signature.length = signatureSize;
        stream.read(decodedSignature.signature);
        return decodedSignature;
    }

}