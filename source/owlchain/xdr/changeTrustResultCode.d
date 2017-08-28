module owlchain.xdr.changeTrustOpResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum ChangeTrustOpResultCode
{
    CHANGE_TRUST_SUCCESS = 0,   
    CHANGE_TRUST_MALFORMED = -1,
    CHANGE_TRUST_NO_ISSUER = -2,
    CHANGE_TRUST_INVALID_LIMIT = -3,
    CHANGE_TRUST_LOW_RESERVE = -4,
    CHANGE_TRUST_SELF_NOT_ALLOWED = -5
}

static void encodeChangeTrustOpResultCode(XdrDataOutputStream stream, ref const ChangeTrustOpResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static ChangeTrustOpResultCode decodeChangeTrustOpResultCode(XdrDataInputStream stream)
{
    ChangeTrustOpResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = ChangeTrustOpResultCode.CHANGE_TRUST_SUCCESS;
            break;
        case -1:
            decodedType = ChangeTrustOpResultCode.CHANGE_TRUST_MALFORMED;
            break;
        case -2:
            decodedType = ChangeTrustOpResultCode.CHANGE_TRUST_NO_ISSUER;
            break;
        case -3:
            decodedType = ChangeTrustOpResultCode.CHANGE_TRUST_INVALID_LIMIT;
            break;
        case -4:
            decodedType = ChangeTrustOpResultCode.CHANGE_TRUST_LOW_RESERVE;
            break;
        case -5:
            decodedType = ChangeTrustOpResultCode.CHANGE_TRUST_SELF_NOT_ALLOWED;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
