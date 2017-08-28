module owlchain.xdr.pathPaymentResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum PathPaymentResultCode
{
    PATH_PAYMENT_SUCCESS = 0,
    PATH_PAYMENT_MALFORMED = -1,
    PATH_PAYMENT_UNDERFUNDED = -2,
    PATH_PAYMENT_SRC_NO_TRUST = -3,
    PATH_PAYMENT_SRC_NOT_AUTHORIZED = -4,
    PATH_PAYMENT_NO_DESTINATION = -5,
    PATH_PAYMENT_NO_TRUST = -6,
    PATH_PAYMENT_NOT_AUTHORIZED = -7,
    PATH_PAYMENT_LINE_FULL = -8,
    PATH_PAYMENT_NO_ISSUER = -9,
    PATH_PAYMENT_TOO_FEW_OFFERS = -10,
    PATH_PAYMENT_OFFER_CROSS_SELF = -11,
    PATH_PAYMENT_OVER_SENDMAX = -12,
}

static void encodePathPaymentResultCode(XdrDataOutputStream stream, ref const PathPaymentResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static PathPaymentResultCode decodePathPaymentResultCode(XdrDataInputStream stream)
{
    PathPaymentResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_SUCCESS;
            break;
        case -1:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_MALFORMED;
            break;
        case -2:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_UNDERFUNDED;
            break;
        case -3:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_SRC_NO_TRUST;
            break;
        case -4:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_SRC_NOT_AUTHORIZED;
            break;
        case -5:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_NO_DESTINATION;
            break;
        case -6:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_NO_TRUST;
            break;
        case -7:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_NOT_AUTHORIZED;
            break;
        case -8:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_LINE_FULL;
            break;
        case -9:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_NO_ISSUER;
            break;
        case -10:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_TOO_FEW_OFFERS;
            break;
        case -11:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_OFFER_CROSS_SELF;
            break;
        case -12:
            decodedType = PathPaymentResultCode.PATH_PAYMENT_OVER_SENDMAX;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
