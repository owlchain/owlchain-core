module owlchain.xdr.operationType;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

// === xdr source ============================================================

//  enum OperationType
//  {
//      CREATE_ACCOUNT = 0,
//      PAYMENT = 1,
//      PATH_PAYMENT = 2,
//      MANAGE_OFFER = 3,
//      CREATE_PASSIVE_OFFER = 4,
//      SET_OPTIONS = 5,
//      CHANGE_TRUST = 6,
//      ALLOW_TRUST = 7,
//      ACCOUNT_MERGE = 8,
//      INFLATION = 9,
//      MANAGE_DATA = 10
//  };

//  ===========================================================================

enum OperationType
{
    CREATE_ACCOUNT = 0,
    PAYMENT = 1,
    PATH_PAYMENT = 2,
    MANAGE_OFFER = 3,
    CREATE_PASSIVE_OFFER = 4,
    SET_OPTIONS = 5,
    CHANGE_TRUST = 6,
    ALLOW_TRUST = 7,
    ACCOUNT_MERGE = 8,
    INFLATION = 9,
    MANAGE_DATA = 10
}

static void encodeOperationType(XdrDataOutputStream stream, ref const OperationType encodedValue)
{
    int32 value = cast(int) encodedValue;
    stream.writeInt32(value);
}

static OperationType decodeOperationType(XdrDataInputStream stream)
{
    OperationType decodedValue;
    int32 value = stream.readInt32();
    switch (value)
    {
    case 0:
        decodedValue = OperationType.CREATE_ACCOUNT;
        break;
    case 1:
        decodedValue = OperationType.PAYMENT;
        break;
    case 2:
        decodedValue = OperationType.PATH_PAYMENT;
        break;
    case 3:
        decodedValue = OperationType.MANAGE_OFFER;
        break;
    case 4:
        decodedValue = OperationType.CREATE_PASSIVE_OFFER;
        break;
    case 5:
        decodedValue = OperationType.SET_OPTIONS;
        break;
    case 6:
        decodedValue = OperationType.CHANGE_TRUST;
        break;
    case 7:
        decodedValue = OperationType.ALLOW_TRUST;
        break;
    case 8:
        decodedValue = OperationType.ACCOUNT_MERGE;
        break;
    case 9:
        decodedValue = OperationType.INFLATION;
        break;
    case 10:
        decodedValue = OperationType.MANAGE_DATA;
        break;
    default:
        throw new Exception("Unknown enum value" ~ to!string(value));
    }
    return decodedValue;
}
