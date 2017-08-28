module owlchain.xdr.changeTrustOpResult;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.changeTrustOpResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct ChangeTrustOpResult
{
    ChangeTrustOpResultCode code;

    static void encode(XdrDataOutputStream stream, ref const ChangeTrustOpResult encoded)
    {
        encodeChangeTrustOpResultCode(stream, encoded.code);
    }

    static ChangeTrustOpResult decode(XdrDataInputStream stream)
    {
        ChangeTrustOpResult decoded;
        decoded.code = decodeChangeTrustOpResultCode(stream);
        return decoded;
    }
}
