module owlchain.xdr.ledgerEntryChangeType;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum LedgerEntryChangeType
{
    LEDGER_ENTRY_CREATED = 0, // entry was added to the ledger
    LEDGER_ENTRY_UPDATED = 1, // entry was modified in the ledger
    LEDGER_ENTRY_REMOVED = 2, // entry was removed from the ledger
    LEDGER_ENTRY_STATE = 3    // value of the entry
}

static void encodeLedgerEntryChangeType(XdrDataOutputStream stream, ref const LedgerEntryChangeType encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static LedgerEntryChangeType decodeLedgerEntryChangeType(XdrDataInputStream stream)
{
    LedgerEntryChangeType decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 1:
            decodedType = LedgerEntryChangeType.LEDGER_ENTRY_CREATED;
            break;
        case 2:
            decodedType = LedgerEntryChangeType.LEDGER_ENTRY_UPDATED;
            break;
        case 3:
            decodedType = LedgerEntryChangeType.LEDGER_ENTRY_REMOVED;
            break;
        case 4:
            decodedType = LedgerEntryChangeType.LEDGER_ENTRY_STATE;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
