module owlchain.xdr.transactionSignaturePayload;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.envelopeType;
import owlchain.xdr.transaction;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TransactionSignaturePayload
{
    Hash networkId;
    TransactionSignaturePayloadTaggedTransaction taggedTransaction;

    static void encode(XdrDataOutputStream stream, ref const TransactionSignaturePayload encodedValue)
    {
        Hash.encode(stream, encodedValue.networkId);
        TransactionSignaturePayloadTaggedTransaction.encode(stream, encodedValue.taggedTransaction);
    }

    static TransactionSignaturePayload decode(XdrDataInputStream stream)
    {
        TransactionSignaturePayload decodedValue;

        decodedValue.networkId = Hash.decode(stream);
        decodedValue.taggedTransaction = TransactionSignaturePayloadTaggedTransaction.decode(stream);

        return decodedValue;
    }
}

struct TransactionSignaturePayloadTaggedTransaction
{
    EnvelopeType type;
    Transaction tx;

    static void encode(XdrDataOutputStream stream, ref const TransactionSignaturePayloadTaggedTransaction encodedValue)
    {
        encodeEnvelopeType(stream, encodedValue.type);
        Transaction.encode(stream, encodedValue.tx);
    }

    static TransactionSignaturePayloadTaggedTransaction decode(XdrDataInputStream stream)
    {
        TransactionSignaturePayloadTaggedTransaction decodedValue;

        decodedValue.type = decodeEnvelopeType(stream);
        decodedValue.tx = Transaction.decode(stream);

        return decodedValue;
    }
}
