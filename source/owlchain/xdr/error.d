module owlchain.xdr.error;

import std.conv;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum ErrorCode
{
    ERR_MISC = 0,
    ERR_DATA = 1,
    ERR_CONF = 2,
    ERR_AUTH = 3,
    ERR_LOAD = 4
}

struct Error
{
    ErrorCode code;
    string msg;

    static void encode(XdrDataOutputStream stream, ref const Error encodedValue)
    {
        stream.writeInt32(encodedValue.code);
        stream.writeString(encodedValue.msg);
    }

    static Error decode(XdrDataInputStream stream)
    {
        Error decodedValue;

        int32 value = cast(ErrorCode) stream.readInt32();
        switch (value)
        {
        case 0:
            decodedValue.code = ErrorCode.ERR_MISC;
            break;
        case 1:
            decodedValue.code = ErrorCode.ERR_DATA;
            break;
        case 2:
            decodedValue.code = ErrorCode.ERR_CONF;
            break;
        case 3:
            decodedValue.code = ErrorCode.ERR_AUTH;
            break;
        case 4:
            decodedValue.code = ErrorCode.ERR_LOAD;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
            break;
        }
        decodedValue.msg = stream.readString();
        return decodedValue;
    }
}
