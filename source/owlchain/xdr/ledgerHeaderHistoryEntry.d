module owlchain.xdr.ledgerHeaderHistoryEntry;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.ledgerHeader;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct LedgerHeaderHistoryEntry
{
    Hash hash;
    LedgerHeader header;
    LedgerHeaderHistoryEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const LedgerHeaderHistoryEntry encoded)
    {
        Hash.encode(stream, encoded.hash);
        LedgerHeader.encode(stream, encoded.header);
        LedgerHeaderHistoryEntryExt.encode(stream, encoded.ext);
    }

    static LedgerHeaderHistoryEntry decode(XdrDataInputStream stream)
    {
        LedgerHeaderHistoryEntry decoded;
        decoded.hash = Hash.decode(stream);
        decoded.header = LedgerHeader.decode(stream);
        decoded.ext = LedgerHeaderHistoryEntryExt.decode(stream);
        return decoded;
    }
}

struct LedgerHeaderHistoryEntryExt 
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const LedgerHeaderHistoryEntryExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static LedgerHeaderHistoryEntryExt decode(XdrDataInputStream stream)
    {
        LedgerHeaderHistoryEntryExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}