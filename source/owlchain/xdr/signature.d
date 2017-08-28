module owlchain.xdr.signature;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Signature
{
    ubyte[] signature;

    static Signature opCall()
    {
        Signature newValue;
        return newValue;
    }

    static Signature opCall(ref ubyte[] other)
    {
        Signature newValue;
        newValue.signature = other.dup;
        return newValue;
    }

    static Signature opCall(ref const Signature other)
    {
        Signature newValue;
        newValue.signature = other.signature.dup;
        return newValue;
    }

    ref Signature opAssign(Signature s)
    {
        signature = s.signature.dup;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const Signature encodedSignature)
    {
        int Signaturesize = cast(int)(encodedSignature.signature.length);
        stream.writeInt(Signaturesize);
        stream.write(encodedSignature.signature);
    }

    static Signature decode(XdrDataInputStream stream)
    {
        Signature decodedSignature;
        const int signatureSize = stream.readInt();
        decodedSignature.signature.length = signatureSize;
        stream.read(decodedSignature.signature);
        return decodedSignature;
    }

}
