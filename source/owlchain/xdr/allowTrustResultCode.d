module owlchain.xdr.allowTrustResultCode;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import std.conv;
enum AllowTrustResultCode
{
    ALLOW_TRUST_SUCCESS = 0,
    ALLOW_TRUST_MALFORMED = -1,
    ALLOW_TRUST_NO_TRUST_LINE = -2,
    ALLOW_TRUST_TRUST_NOT_REQUIRED = -3,
    ALLOW_TRUST_CANT_REVOKE = -4,
    ALLOW_TRUST_SELF_NOT_ALLOWED = -5,
}

static void encodeAllowTrustResultCode(XdrDataOutputStream stream, ref const AllowTrustResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static AllowTrustResultCode decodeAllowTrustResultCode(XdrDataInputStream stream)
{
    AllowTrustResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = AllowTrustResultCode.ALLOW_TRUST_SUCCESS;
            break;
        case -1:
            decodedType = AllowTrustResultCode.ALLOW_TRUST_MALFORMED;
            break;
        case -2:
            decodedType = AllowTrustResultCode.ALLOW_TRUST_NO_TRUST_LINE;
            break;
        case -3:
            decodedType = AllowTrustResultCode.ALLOW_TRUST_TRUST_NOT_REQUIRED;
            break;
        case -4:
            decodedType = AllowTrustResultCode.ALLOW_TRUST_CANT_REVOKE;
            break;
        case -5:
            decodedType = AllowTrustResultCode.ALLOW_TRUST_SELF_NOT_ALLOWED;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
