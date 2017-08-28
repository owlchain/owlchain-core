module owlchain.xdr.transactionResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum TransactionResultCode
{
    txSUCCESS = 0, // all operations succeeded
    
    txFAILED = -1, // one of the operations failed (none were applied)

    txTOO_EARLY = -2,         // ledger closeTime before minTime
    txTOO_LATE = -3,          // ledger closeTime after maxTime
    txMISSING_OPERATION = -4, // no operation was specified
    txBAD_SEQ = -5,           // sequence number does not match source account
    txBAD_AUTH = -6,             // too few valid signatures / wrong network
    txINSUFFICIENT_BALANCE = -7, // fee would bring account below reserve
    txNO_ACCOUNT = -8,           // source account not found
    txINSUFFICIENT_FEE = -9,     // fee is too small
    txBAD_AUTH_EXTRA = -10,      // unused signatures attached to transaction
    txINTERNAL_ERROR = -11       // an unknown error occured
}

static void encodeTransactionResultCode(XdrDataOutputStream stream, ref const TransactionResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static TransactionResultCode decodeTransactionResultCode(XdrDataInputStream stream)
{
    TransactionResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = TransactionResultCode.txSUCCESS;
            break;
        case -1:
            decodedType = TransactionResultCode.txFAILED;
            break;
        case -2:
            decodedType = TransactionResultCode.txTOO_EARLY;
            break;
        case -3:
            decodedType = TransactionResultCode.txTOO_LATE;
            break;
        case -4:
            decodedType = TransactionResultCode.txMISSING_OPERATION;
            break;
        case -5:
            decodedType = TransactionResultCode.txBAD_SEQ;
            break;
        case -6:
            decodedType = TransactionResultCode.txBAD_AUTH;
            break;
        case -7:
            decodedType = TransactionResultCode.txINSUFFICIENT_BALANCE;
            break;
        case -8:
            decodedType = TransactionResultCode.txNO_ACCOUNT;
            break;
        case -9:
            decodedType = TransactionResultCode.txINSUFFICIENT_FEE;
            break;
        case -10:
            decodedType = TransactionResultCode.txBAD_AUTH_EXTRA;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}