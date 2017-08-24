module owlchain.xdr.curve25519Secret;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Curve25519Secret
{
    ubyte [32] key;
    
    static void encode(XdrDataOutputStream stream, ref const Curve25519Secret encoded)
    {
        stream.write(encoded.key);
    }

    static Curve25519Secret decode(XdrDataInputStream stream)
    {
        Curve25519Secret decoded;
        stream.read(decoded.key);
        return decoded;
    }

}