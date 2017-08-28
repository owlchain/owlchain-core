module owlchain.xdr.transactionEnvelope;

import owlchain.xdr.type;
import owlchain.xdr.transaction;
import owlchain.xdr.decoratedSignature;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TransactionEnvelope
{
    Transaction tx;
    DecoratedSignature[] signatures;

    ref TransactionEnvelope opAssign(TransactionEnvelope other)
    {
        tx = other.tx;
        signatures.length = 0;
        for (int i = 0; i < other.signatures.length; i++)
        {
            signatures ~= other.signatures[i];
        }
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const TransactionEnvelope encodedValue)
    {
        Transaction.encode(stream, encodedValue.tx);
        const int32 length = cast(int32)encodedValue.signatures.length;
        stream.writeInt32(length);
        for (int i = 0; i < length; i++)
        {
            DecoratedSignature.encode(stream, encodedValue.signatures[i]);
        }
    }

    static TransactionEnvelope decode(XdrDataInputStream stream)
    {
        TransactionEnvelope decodedValue;

        decodedValue.tx = Transaction.decode(stream);
        decodedValue.signatures.length = 0;
        const int32 length = stream.readInt32();
        for (int i = 0; i < length; i++)
        {
            decodedValue.signatures ~= DecoratedSignature.decode(stream);
        }
        return decodedValue;
    }
}
