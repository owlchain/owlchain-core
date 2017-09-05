module owlchain.xdr.changeTrustResult;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.changeTrustResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct ChangeTrustResult
{
    ChangeTrustResultCode code;

    static void encode(XdrDataOutputStream stream, ref const ChangeTrustResult encoded)
    {
        encodeChangeTrustResultCode(stream, encoded.code);
    }

    static ChangeTrustResult decode(XdrDataInputStream stream)
    {
        ChangeTrustResult decoded;
        decoded.code = decodeChangeTrustResultCode(stream);
        return decoded;
    }
}
