module owlchain.xdr.inflationResult;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.inflationResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct InflationResult
{
    InflationResultCode code;

    static void encode(XdrDataOutputStream stream, ref const InflationResult encoded)
    {
        encodeInflationResultCode(stream, encoded.code);
    }

    static InflationResult decode(XdrDataInputStream stream)
    {
        InflationResult decoded;
        decoded.code = decodeInflationResultCode(stream);
        return decoded;
    }
}
