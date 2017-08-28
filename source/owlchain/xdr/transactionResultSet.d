module owlchain.xdr.transactionResultSet;

import owlchain.xdr.type;
import owlchain.xdr.transactionResultPair;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TransactionResultSet
{
    TransactionResultPair[] results;

    ref TransactionResultSet opAssign(TransactionResultSet other)
    {
        results.length = 0;
        for (int i = 0; i < other.results.length; i++)
        {
            results ~= other.results[i];
        }
        return this;
    }
    
    static void encode(XdrDataOutputStream stream, ref const TransactionResultSet encodedValue)
    {
        const int32 length = cast(int32)encodedValue.results.length;
        stream.writeInt32(length);
        for (int i = 0; i < length; i++)
        {
            TransactionResultPair.encode(stream, encodedValue.results[i]);
        }
    }

    static TransactionResultSet decode(XdrDataInputStream stream)
    {
        TransactionResultSet decodedValue;

        decodedValue.results.length = 0;
        const int32 length = stream.readInt32();
        for (int i = 0; i < length; i++)
        {
            decodedValue.results ~= TransactionResultPair.decode(stream);
        }
        return decodedValue;
    }
}
