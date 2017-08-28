module owlchain.xdr.pathPaymentResult;

import owlchain.xdr.type;
import owlchain.xdr.pathPaymentResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct PathPaymentResult
{
    PathPaymentResultCode code;

    static void encode(XdrDataOutputStream stream, ref const PathPaymentResult encoded)
    {
        encodePathPaymentResultCode(stream, encoded.code);
    }

    static PathPaymentResult decode(XdrDataInputStream stream)
    {
        PathPaymentResult decoded;
        decoded.code = decodePathPaymentResultCode(stream);
        return decoded;
    }
}
