module owlchain.xdr.curve25519Public;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Curve25519Public
{
    ubyte [32] key;
    
    static void encode(XdrDataOutputStream stream, ref const Curve25519Public encoded)
    {
        stream.write(encoded.key);
    }

    static Curve25519Public decode(XdrDataInputStream stream)
    {
        Curve25519Public decoded;
        stream.read(decoded.key);
        return decoded;
    }

}