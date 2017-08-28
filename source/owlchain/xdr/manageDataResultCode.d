module owlchain.xdr.manageDataResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum ManageDataResultCode
{
    MANAGE_DATA_SUCCESS = 0,
    MANAGE_DATA_NOT_SUPPORTED_YET = -1,
    MANAGE_DATA_NAME_NOT_FOUND = -2,
    MANAGE_DATA_LOW_RESERVE = -3,
    MANAGE_DATA_INVALID_NAME = -4,
}

static void encodeManageDataResultCode(XdrDataOutputStream stream, ref const ManageDataResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static ManageDataResultCode decodeManageDataResultCode(XdrDataInputStream stream)
{
    ManageDataResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = ManageDataResultCode.MANAGE_DATA_SUCCESS;
            break;
        case -1:
            decodedType = ManageDataResultCode.MANAGE_DATA_NOT_SUPPORTED_YET;
            break;
        case -2:
            decodedType = ManageDataResultCode.MANAGE_DATA_NAME_NOT_FOUND;
            break;
        case -3:
            decodedType = ManageDataResultCode.MANAGE_DATA_LOW_RESERVE;
            break;
        case -4:
            decodedType = ManageDataResultCode.MANAGE_DATA_INVALID_NAME;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
