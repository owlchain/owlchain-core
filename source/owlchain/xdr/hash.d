module owlchain.xdr.hash;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Hash
{
    ubyte[] hash;

    static void encode(XdrDataOutputStream stream, ref const Hash encodedHash)
    {
        stream.write(encodedHash.hash);
    }

    static Hash decode(XdrDataInputStream stream)
    {
        Hash decodedHash;
        ubyte[] temp;
        temp.length = 32;
        stream.read(temp);
        decodedHash.hash = temp;
        return decodedHash;
    }
}