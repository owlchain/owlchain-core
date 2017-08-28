module owlchain.xdr.manageOfferResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum ManageOfferResultCode
{
    MANAGE_OFFER_SUCCESS = 0,
    MANAGE_OFFER_MALFORMED = -1,
    MANAGE_OFFER_SELL_NO_TRUST = -2,
    MANAGE_OFFER_BUY_NO_TRUST = -3,
    MANAGE_OFFER_SELL_NOT_AUTHORIZED = -4,
    MANAGE_OFFER_BUY_NOT_AUTHORIZED = -5,
    MANAGE_OFFER_LINE_FULL = -6,
    MANAGE_OFFER_UNDERFUNDED = -7,
    MANAGE_OFFER_CROSS_SELF = -8,
    MANAGE_OFFER_SELL_NO_ISSUER = -9,
    MANAGE_OFFER_BUY_NO_ISSUER = -10,
    MANAGE_OFFER_NOT_FOUND = -11,
    MANAGE_OFFER_LOW_RESERVE = -12
}

static void encodeManageOfferResultCode(XdrDataOutputStream stream, ref const ManageOfferResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static ManageOfferResultCode decodeManageOfferResultCode(XdrDataInputStream stream)
{
    ManageOfferResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_SUCCESS;
            break;
        case -1:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_MALFORMED;
            break;
        case -2:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_SELL_NO_TRUST;
            break;
        case -3:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_BUY_NO_TRUST;
            break;
        case -4:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_SELL_NOT_AUTHORIZED;
            break;
        case -5:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_BUY_NOT_AUTHORIZED;
            break;
        case -6:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_LINE_FULL;
            break;
        case -7:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_UNDERFUNDED;
            break;
        case -8:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_CROSS_SELF;
            break;
        case -9:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_SELL_NO_ISSUER;
            break;
        case -10:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_BUY_NO_ISSUER;
            break;
        case -11:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_NOT_FOUND;
            break;
        case -12:
            decodedType = ManageOfferResultCode.MANAGE_OFFER_LOW_RESERVE;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
