module owlchain.xdr.operationResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum OperationResultCode
{
    opINNER = 0,        // inner object result is valid
    opBAD_AUTH = -1,    // too few valid signatures / wrong network
    opNO_ACCOUNT = -2,  // source account was not found
}

static void encodeOperationResultCode(XdrDataOutputStream stream, ref const OperationResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static OperationResultCode decodeOperationResultCode(XdrDataInputStream stream)
{
    OperationResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = OperationResultCode.opINNER;
            break;
        case -1:
            decodedType = OperationResultCode.opBAD_AUTH;
            break;
        case -2:
            decodedType = OperationResultCode.opNO_ACCOUNT;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
