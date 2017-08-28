module owlchain.xdr.inflationResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum InflationResultCode
{
    // codes considered as "success" for the operation
    INFLATION_SUCCESS = 0,   
    // codes considered as "failure" for the operation
    INFLATION_NOT_TIME = -1,
}

static void encodeInflationResultCode(XdrDataOutputStream stream, ref const InflationResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static InflationResultCode decodeInflationResultCode(XdrDataInputStream stream)
{
    InflationResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = InflationResultCode.INFLATION_SUCCESS;
            break;
        case -1:
            decodedType = InflationResultCode.INFLATION_NOT_TIME;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
