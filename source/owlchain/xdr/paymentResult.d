module owlchain.xdr.paymentResult;

import owlchain.xdr.type;
import owlchain.xdr.paymentResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct PaymentResult
{
    PaymentResultCode code;

    static void encode(XdrDataOutputStream stream, ref const PaymentResult encoded)
    {
        encodePaymentResultCode(stream, encoded.code);
    }

    static PaymentResult decode(XdrDataInputStream stream)
    {
        PaymentResult decoded;
        decoded.code = decodePaymentResultCode(stream);
        return decoded;
    }
}
