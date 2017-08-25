module owlchain.xdr.transaction;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.sequenceNumber;
import owlchain.xdr.timeBounds;
import owlchain.xdr.memo;
import owlchain.xdr.operation;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Transaction
{
    AccountID sourceAccount;
    uint32 fee;
    SequenceNumber seqNum;
    TimeBounds timeBounds;
    Memo memo;
    Operation[] operations;
    TransactionExt ext;

    ref Transaction opAssign(Transaction other)
    {
        sourceAccount = other.sourceAccount;
        fee = other.fee;
        seqNum = other.seqNum;
        timeBounds = other.timeBounds;
        memo = other.memo;
        operations.length = 0;
        for (int i = 0; i < other.operations.length; i++)
        {
            operations ~= other.operations[i];
        }
        ext = other.ext;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const Transaction encodedValue)
    {
        AccountID.encode(stream, encodedValue.sourceAccount);
        stream.writeUint32(encodedValue.fee);
        SequenceNumber.encode(stream, encodedValue.seqNum);
        
        {
            stream.writeInt32(1);
            TimeBounds.encode(stream, encodedValue.timeBounds);
        }

        Memo.encode(stream, encodedValue.memo);
        const int32 length = cast(int32)encodedValue.operations.length;
        stream.writeInt32(length);
        for (int i = 0; i < length; i++)
        {
            Operation.encode(stream, encodedValue.operations[i]);
        }
        TransactionExt.encode(stream, encodedValue.ext);
    }

    static Transaction decode(XdrDataInputStream stream)
    {
        Transaction decodedValue;
        decodedValue.sourceAccount = AccountID.decode(stream);
        decodedValue.fee = stream.readUint32();
        decodedValue.seqNum = SequenceNumber.decode(stream);
        const int32 timeBoundsPresent = stream.readInt32();
        if (timeBoundsPresent != 0)
        {
            decodedValue.timeBounds = TimeBounds.decode(stream);
        }
        decodedValue.memo = Memo.decode(stream);
        decodedValue.operations.length = 0;
        const int32 length = stream.readInt32();
        for (int i = 0; i < length; i++)
        {
            decodedValue.operations ~= Operation.decode(stream);
        }
        decodedValue.ext = TransactionExt.decode(stream);
        return decodedValue;
    }
}

struct TransactionExt
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const TransactionExt encodedValue)
    {
        stream.writeInt32(encodedValue.v);
    }

    static TransactionExt decode(XdrDataInputStream stream)
    {
        TransactionExt decodedValue;
        decodedValue.v = stream.readInt32();
        return decodedValue;
    }
}