module owlchain.xdr.ledgerEntryChange;

import owlchain.xdr.type;

import owlchain.xdr.ledgerEntryChangeType;
import owlchain.xdr.ledgerEntry;
import owlchain.xdr.ledgerKey;;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

class LedgerEntryChange
{
    LedgerEntryChangeType type;
    LedgerEntry created;
    LedgerEntry updated;
    LedgerKey removed;
    LedgerEntry state;

    static void encode(XdrDataOutputStream stream, ref const LedgerEntryChange encoded)
    {
        encodeLedgerEntryChangeType(stream, encoded.type);
        switch (encoded.type)
        {
            case LedgerEntryChangeType.LEDGER_ENTRY_CREATED:
                LedgerEntry.encode(stream, encoded.created);
                break;
            case LedgerEntryChangeType.LEDGER_ENTRY_UPDATED:
                LedgerEntry.encode(stream, encoded.updated);
                break;
            case LedgerEntryChangeType.LEDGER_ENTRY_REMOVED:
                LedgerKey.encode(stream, encoded.removed);
                break;
            case LedgerEntryChangeType.LEDGER_ENTRY_STATE:
                LedgerEntry.encode(stream, encoded.state);
                break;
            default:
                break;
        }
    }

    static LedgerEntryChange decode(XdrDataInputStream stream)
    {
        LedgerEntryChange decoded;
        decoded.type = decodeLedgerEntryChangeType(stream);
        switch (decoded.type)
        {
            case LedgerEntryChangeType.LEDGER_ENTRY_CREATED:
                decoded.created = LedgerEntry.decode(stream);
                break;
            case LedgerEntryChangeType.LEDGER_ENTRY_UPDATED:
                decoded.updated = LedgerEntry.decode(stream);
                break;
            case LedgerEntryChangeType.LEDGER_ENTRY_REMOVED:
                decoded.removed = LedgerKey.decode(stream);
                break;
            case LedgerEntryChangeType.LEDGER_ENTRY_STATE:
                decoded.state = LedgerEntry.decode(stream);
                break;
            default:
                break;
        }
        return decoded;
    }
}