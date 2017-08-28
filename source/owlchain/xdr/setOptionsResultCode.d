module owlchain.xdr.setOptionsResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum SetOptionsResultCode
{
    SET_OPTIONS_SUCCESS = 0,
    SET_OPTIONS_LOW_RESERVE = -1,
    SET_OPTIONS_TOO_MANY_SIGNERS = -2,
    SET_OPTIONS_BAD_FLAGS = -3,
    SET_OPTIONS_INVALID_INFLATION = -4,
    SET_OPTIONS_CANT_CHANGE = -5,
    SET_OPTIONS_UNKNOWN_FLAG = -6,
    SET_OPTIONS_THRESHOLD_OUT_OF_RANGE = -7,
    SET_OPTIONS_BAD_SIGNER = -8,
    SET_OPTIONS_INVALID_HOME_DOMAIN = -9,
}

static void encodeSetOptionsResultCode(XdrDataOutputStream stream, ref const SetOptionsResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static SetOptionsResultCode decodeSetOptionsResultCode(XdrDataInputStream stream)
{
    SetOptionsResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = SetOptionsResultCode.SET_OPTIONS_SUCCESS;
            break;
        case -1:
            decodedType = SetOptionsResultCode.SET_OPTIONS_LOW_RESERVE;
            break;
        case -2:
            decodedType = SetOptionsResultCode.SET_OPTIONS_TOO_MANY_SIGNERS;
            break;
        case -3:
            decodedType = SetOptionsResultCode.SET_OPTIONS_BAD_FLAGS;
            break;
        case -4:
            decodedType = SetOptionsResultCode.SET_OPTIONS_INVALID_INFLATION;
            break;
        case -5:
            decodedType = SetOptionsResultCode.SET_OPTIONS_CANT_CHANGE;
            break;
        case -6:
            decodedType = SetOptionsResultCode.SET_OPTIONS_UNKNOWN_FLAG;
            break;
        case -7:
            decodedType = SetOptionsResultCode.SET_OPTIONS_THRESHOLD_OUT_OF_RANGE;
            break;
        case -8:
            decodedType = SetOptionsResultCode.SET_OPTIONS_BAD_SIGNER;
            break;
        case -9:
            decodedType = SetOptionsResultCode.SET_OPTIONS_INVALID_HOME_DOMAIN;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}