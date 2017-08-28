module owlchain.xdr.ledgerEntryChanges;

import owlchain.xdr.type;
import owlchain.xdr.ledgerEntryChange;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct LedgerEntryChanges
{
    LedgerEntryChange[] ledgerEntryChanges;

    static void encode(XdrDataOutputStream stream, ref const LedgerEntryChanges encoded)
    {
        int length = cast(int)(encoded.ledgerEntryChanges.length);
        stream.writeInt(length);
        for (int i = 0; i < length; i++)
        {
            LedgerEntryChange.encode(stream, encoded.ledgerEntryChanges[i]);
        }
    }

    static LedgerEntryChanges decode(XdrDataInputStream stream)
    {
        LedgerEntryChanges decoded;
        int length = stream.readInt();
        decoded.ledgerEntryChanges.length = 0;
        for (int i = 0; i < length; i++)
        {
            decoded.ledgerEntryChanges ~= LedgerEntryChange.decode(stream);
        }
        return decoded;
    }
}