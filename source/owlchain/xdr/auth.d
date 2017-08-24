module owlchain.xdr.auth;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Auth
{
    int32 unused;

    static void encode(XdrDataOutputStream stream, ref const Auth encoded)
    {
        stream.writeInt32(encoded.unused);
    }

    static Auth decode(XdrDataInputStream stream)
    {
        Auth decoded;

        decoded.unused = stream.readInt32();
        return decoded;
    }
}