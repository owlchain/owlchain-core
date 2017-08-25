module owlchain.ledger.entryFrame;

import owlchain.database.database;
import owlchain.xdr.ledgerKey;
import owlchain.xdr.ledgerEntry;
import owlchain.xdr.ledgerEntryType;

class EntryFrame
{
protected:
    bool mKeyCalculated;
    LedgerKey mKey;

    void clearCached()
    {
        mKeyCalculated = false;
    }
public:
    LedgerEntry mEntry;

    this(LedgerEntryType type)
    {

    }

    this(LedgerEntry from)
    {

    }

    
    static EntryFrame FromXDR(ref LedgerEntry from)
    {
        return null;
    }

    static EntryFrame storeLoad(ref LedgerKey key, Database db)
    {
        return null;
    }

    // Static helpers for working with the DB LedgerEntry cache.
    static void flushCachedEntry(ref LedgerKey key, Database db)
    {

    }

    static bool cachedEntryExists(ref LedgerKey key, Database db)
    {
        return false;
    }

    static LedgerEntry getCachedEntry(ref LedgerKey key, Database db)
    {
        LedgerEntry v;
        return v;
    }

    static void putCachedEntry(ref LedgerKey key, LedgerEntry p, Database db)
    {

    }

}
