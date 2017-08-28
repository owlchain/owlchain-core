module owlchain.xdr.transactionHistoryResultEntry;

import owlchain.xdr.type;

import owlchain.xdr.transactionResultSet;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TransactionHistoryResultEntry
{
    uint32 ledgerSeq;
    TransactionResultSet txResultSet;
    TransactionHistoryResultEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const TransactionHistoryResultEntry encoded)
    {
        stream.writeUint32(encoded.ledgerSeq); 
        TransactionResultSet.encode(stream, encoded.txResultSet);
        TransactionHistoryResultEntryExt.encode(stream, encoded.ext);
    }

    static TransactionHistoryResultEntry decode(XdrDataInputStream stream)
    {
        TransactionHistoryResultEntry decoded;
        decoded.ledgerSeq = stream.readUint32();
        decoded.txResultSet = TransactionResultSet.decode(stream);
        decoded.ext = TransactionHistoryResultEntryExt.decode(stream);
        return decoded;
    }
}

struct TransactionHistoryResultEntryExt
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const TransactionHistoryResultEntryExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static TransactionHistoryResultEntryExt decode(XdrDataInputStream stream)
    {
        TransactionHistoryResultEntryExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}