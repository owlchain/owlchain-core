module owlchain.xdr.transactionResultPair;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.transactionResult;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TransactionResultPair
{
    Hash transactionHash;
    TransactionResult result;
    
    static void encode(XdrDataOutputStream stream, ref const TransactionResultPair encodedValue)
    {
        Hash.encode(stream, encodedValue.transactionHash);
        TransactionResult.encode(stream, encodedValue.result);
    }

    static TransactionResultPair decode(XdrDataInputStream stream)
    {
        TransactionResultPair decodedValue;

        decodedValue.transactionHash = Hash.decode(stream);
        decodedValue.result = TransactionResult.decode(stream);

        return decodedValue;
    }
}
