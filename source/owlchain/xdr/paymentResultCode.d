module owlchain.xdr.paymentResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum PaymentResultCode
{
    PAYMENT_SUCCESS = 0,
    PAYMENT_MALFORMED = -1,
    PAYMENT_UNDERFUNDED = -2,
    PAYMENT_SRC_NO_TRUST = -3,
    PAYMENT_SRC_NOT_AUTHORIZED = -4,
    PAYMENT_NO_DESTINATION = -5,
    PAYMENT_NO_TRUST = -6,
    PAYMENT_NOT_AUTHORIZED = -7,
    PAYMENT_LINE_FULL = -8,
    PAYMENT_NO_ISSUER = -9,
}

static void encodePaymentResultCode(XdrDataOutputStream stream, ref const PaymentResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static PaymentResultCode decodePaymentResultCode(XdrDataInputStream stream)
{
    PaymentResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = PaymentResultCode.PAYMENT_SUCCESS;
            break;
        case -1:
            decodedType = PaymentResultCode.PAYMENT_MALFORMED;
            break;
        case -2:
            decodedType = PaymentResultCode.PAYMENT_UNDERFUNDED;
            break;
        case -3:
            decodedType = PaymentResultCode.PAYMENT_SRC_NO_TRUST;
            break;
        case -4:
            decodedType = PaymentResultCode.PAYMENT_SRC_NOT_AUTHORIZED;
            break;
        case -5:
            decodedType = PaymentResultCode.PAYMENT_NO_DESTINATION;
            break;
        case -6:
            decodedType = PaymentResultCode.PAYMENT_NO_TRUST;
            break;
        case -7:
            decodedType = PaymentResultCode.PAYMENT_NOT_AUTHORIZED;
            break;
        case -8:
            decodedType = PaymentResultCode.PAYMENT_LINE_FULL;
            break;
        case -9:
            decodedType = PaymentResultCode.PAYMENT_NO_ISSUER;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
