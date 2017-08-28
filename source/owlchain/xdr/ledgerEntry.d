module owlchain.xdr.ledgerEntry;

import owlchain.xdr.type;
import owlchain.xdr.accountEntry;
import owlchain.xdr.ledgerEntryType;
import owlchain.xdr.trustLineEntry;
import owlchain.xdr.offerEntry;
import owlchain.xdr.dataEntry;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct LedgerEntry
{
    uint32 lastModifiedLedgerSeq;
    LedgerEntryData data;
    LedgerEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const LedgerEntry encoded)
    {
        stream.writeUint32(encoded.lastModifiedLedgerSeq);
        LedgerEntryData.encode(stream, encoded.data);
        LedgerEntryExt.encode(stream, encoded.ext);
    }

    static LedgerEntry decode(XdrDataInputStream stream)
    {
        LedgerEntry decoded;
        decoded.lastModifiedLedgerSeq = stream.readUint32();
        decoded.data = LedgerEntryData.decode(stream);
        decoded.ext = LedgerEntryExt.decode(stream);
        return decoded;
    }
}

struct LedgerEntryData
{
    LedgerEntryType type;
    AccountEntry account;
    TrustLineEntry trustLine;
    OfferEntry offer;
    DataEntry data;

    static void encode(XdrDataOutputStream stream, ref const LedgerEntryData encoded)
    {
        encodeLedgerEntryType(stream, encoded.type);
        switch (encoded.type)
        {
        case LedgerEntryType.ACCOUNT:
            AccountEntry.encode(stream, encoded.account);
            break;
        case LedgerEntryType.TRUSTLINE:
            TrustLineEntry.encode(stream, encoded.trustLine);
            break;
        case LedgerEntryType.OFFER:
            OfferEntry.encode(stream, encoded.offer);
            break;
        case LedgerEntryType.DATA:
            DataEntry.encode(stream, encoded.data);
            break;
        default:
            break;
        }
    }

    static LedgerEntryData decode(XdrDataInputStream stream)
    {
        LedgerEntryData decoded;
        decoded.type = decodeLedgerEntryType(stream);
        switch (decoded.type)
        {
        case LedgerEntryType.ACCOUNT:
            decoded.account = AccountEntry.decode(stream);
            break;
        case LedgerEntryType.TRUSTLINE:
            decoded.trustLine = TrustLineEntry.decode(stream);
            break;
        case LedgerEntryType.OFFER:
            decoded.offer = OfferEntry.decode(stream);
            break;
        case LedgerEntryType.DATA:
            decoded.data = DataEntry.decode(stream);
            break;
        default:
            break;
        }
        return decoded;
    }
}

struct LedgerEntryExt
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const LedgerEntryExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static LedgerEntryExt decode(XdrDataInputStream stream)
    {
        LedgerEntryExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}
