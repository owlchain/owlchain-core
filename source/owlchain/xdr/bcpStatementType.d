module owlchain.xdr.bcpStatementType;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum BCPStatementType
{
    BCP_ST_PREPARE = 0,
    BCP_ST_CONFIRM = 1,
    BCP_ST_EXTERNALIZE = 2,
    BCP_ST_NOMINATE = 3
}

static void encodeBCPStatementType(XdrDataOutputStream stream, ref const BCPStatementType encodedValue)
{
    int32 value = cast(int) encodedValue;
    stream.writeInt32(value);
}

static BCPStatementType decodeBCPStatementType(XdrDataInputStream stream)
{
    BCPStatementType decodedValue;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedValue = BCPStatementType.BCP_ST_PREPARE;
            break;
        case 1:
            decodedValue = BCPStatementType.BCP_ST_CONFIRM;
            break;
        case 2:
            decodedValue = BCPStatementType.BCP_ST_EXTERNALIZE;
            break;
        case 3:
            decodedValue = BCPStatementType.BCP_ST_NOMINATE;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value, 10));
    }
    return decodedValue;
}
