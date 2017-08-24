module owlchain.xdr.price;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Price
{
    int32 n;
    int32 d;

    static void encode(XdrDataOutputStream stream, ref const Price encoded)
    {
        stream.writeInt32(encoded.n);
        stream.writeInt32(encoded.d);
    }

    static Price decode(XdrDataInputStream stream)
    {
        Price decoded;
        decoded.n = stream.readInt32();
        decoded.d = stream.readInt32();
        return decoded;
    }

}
