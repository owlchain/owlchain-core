module owlchain.xdr.transactionHistoryEntry;

import owlchain.xdr.type;

import owlchain.xdr.transactionSet;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TransactionHistoryEntry
{
    uint32 ledgerSeq;
    TransactionSet txSet;
    TransactionHistoryEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const TransactionHistoryEntry encoded)
    {
        stream.writeUint32(encoded.ledgerSeq); 
        TransactionSet.encode(stream, encoded.txSet);
        TransactionHistoryEntryExt.encode(stream, encoded.ext);
    }

    static TransactionHistoryEntry decode(XdrDataInputStream stream)
    {
        TransactionHistoryEntry decoded;
        decoded.ledgerSeq = stream.readUint32();
        decoded.txSet = TransactionSet.decode(stream);
        decoded.ext = TransactionHistoryEntryExt.decode(stream);
        return decoded;
    }
}

struct TransactionHistoryEntryExt
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const TransactionHistoryEntryExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static TransactionHistoryEntryExt decode(XdrDataInputStream stream)
    {
        TransactionHistoryEntryExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}
