module owlchain.xdr.changeTrustResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum ChangeTrustResultCode
{
    CHANGE_TRUST_SUCCESS = 0,   
    CHANGE_TRUST_MALFORMED = -1,
    CHANGE_TRUST_NO_ISSUER = -2,
    CHANGE_TRUST_INVALID_LIMIT = -3,
    CHANGE_TRUST_LOW_RESERVE = -4,
    CHANGE_TRUST_SELF_NOT_ALLOWED = -5
}

static void encodeChangeTrustResultCode(XdrDataOutputStream stream, ref const ChangeTrustResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static ChangeTrustResultCode decodeChangeTrustResultCode(XdrDataInputStream stream)
{
    ChangeTrustResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = ChangeTrustResultCode.CHANGE_TRUST_SUCCESS;
            break;
        case -1:
            decodedType = ChangeTrustResultCode.CHANGE_TRUST_MALFORMED;
            break;
        case -2:
            decodedType = ChangeTrustResultCode.CHANGE_TRUST_NO_ISSUER;
            break;
        case -3:
            decodedType = ChangeTrustResultCode.CHANGE_TRUST_INVALID_LIMIT;
            break;
        case -4:
            decodedType = ChangeTrustResultCode.CHANGE_TRUST_LOW_RESERVE;
            break;
        case -5:
            decodedType = ChangeTrustResultCode.CHANGE_TRUST_SELF_NOT_ALLOWED;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
