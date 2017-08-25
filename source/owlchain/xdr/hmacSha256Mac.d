module owlchain.xdr.hmacSha256Mac;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct HmacSha256Mac
{
    byte[32] mac;

    static void encode(XdrDataOutputStream stream, ref const HmacSha256Mac encodedValue)
    {    
        stream.write(encodedValue.mac);
    }

    static HmacSha256Mac decode(XdrDataInputStream stream)
    {
        HmacSha256Mac decodedValue;

        stream.read(decodedValue.mac);
        return decodedValue;
    }
}