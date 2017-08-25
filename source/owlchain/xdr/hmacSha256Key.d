module owlchain.xdr.hmacSha256Key;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct HmacSha256Key
{
    byte[32] key;

    static void encode(XdrDataOutputStream stream, ref const HmacSha256Key encodedValue)
    {    
        stream.write(encodedValue.key);
    }

    static HmacSha256Key decode(XdrDataInputStream stream)
    {
        HmacSha256Key decodedValue;

        stream.read(decodedValue.key);
        return decodedValue;
    }
}