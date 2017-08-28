module owlchain.xdr.operationMeta;

import owlchain.xdr.type;

import owlchain.xdr.ledgerEntryChanges;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct OperationMeta
{
    LedgerEntryChanges changes;

    static void encode(XdrDataOutputStream stream, ref const OperationMeta encoded)
    {
        LedgerEntryChanges.encode(stream, encoded.changes);
    }

    static OperationMeta decode(XdrDataInputStream stream)
    {
        OperationMeta decoded;
        decoded.changes = LedgerEntryChanges.decode(stream);
        return decoded;
    }
}
