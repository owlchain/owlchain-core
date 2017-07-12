module owlchain.xdr.historyEntry;

import owlchain.xdr.type;
import owlchain.xdr.historyEntryV0;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct HistoryEntry
{
    int32 discriminant;
    HistoryEntryV0 v0;

    static void encode(XdrDataOutputStream stream, ref const HistoryEntry encodedHistoryEntry)
    {
        stream.writeInt32(encodedHistoryEntry.discriminant);
        switch (encodedHistoryEntry.discriminant) {
            case 0:
                HistoryEntryV0.encode(stream, encodedHistoryEntry.v0);
                break;
            default:
                break;
        }
    }

    static HistoryEntry decode(XdrDataInputStream stream)
    {
        HistoryEntry decodedHistoryEntry;
        decodedHistoryEntry.discriminant = stream.readInt32();
        switch (decodedHistoryEntry.discriminant) {
            case 0:
                decodedHistoryEntry.v0 = HistoryEntryV0.decode(stream);
                break;
            default:
                break;
        }
        return decodedHistoryEntry;
    }
}