module owlchain.xdr.transactionSet;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.transactionEnvelope;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TransactionSet
{
    Hash previousLedgerHash;
    TransactionEnvelope[] txs;

    ref TransactionSet opAssign(TransactionSet other)
    {
        previousLedgerHash = other.previousLedgerHash;
        txs.length = 0;
        for (int i = 0; i < other.txs.length; i++)
        {
            txs ~= other.txs[i];
        }
        return this;
    }
    static void encode(XdrDataOutputStream stream, ref const TransactionSet encodedValue)
    {
        Hash.encode(stream, encodedValue.previousLedgerHash);
        const int32 length = cast(int32)encodedValue.txs.length;
        stream.writeInt32(length);
        for (int i = 0; i < length; i++)
        {
            TransactionEnvelope.encode(stream, encodedValue.txs[i]);
        }
    }

    static TransactionSet decode(XdrDataInputStream stream)
    {
        TransactionSet decodedValue;

        decodedValue.previousLedgerHash = Hash.decode(stream);
        decodedValue.txs.length = 0;
        const int32 length = stream.readInt32();
        for (int i = 0; i < length; i++)
        {
            decodedValue.txs ~= TransactionEnvelope.decode(stream);
        }
        return decodedValue;
    }
}
