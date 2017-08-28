module owlchain.xdr.bcpHistoryEntry;

import owlchain.xdr.type;
import owlchain.xdr.bcpHistoryEntryV0;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct BCPHistoryEntry
{
    int32 discriminant;
    BCPHistoryEntryV0 v0;

    static void encode(XdrDataOutputStream stream, ref const BCPHistoryEntry encodedHistoryEntry)
    {
        stream.writeInt32(encodedHistoryEntry.discriminant);
        switch (encodedHistoryEntry.discriminant)
        {
        case 0:
            BCPHistoryEntryV0.encode(stream, encodedHistoryEntry.v0);
            break;
        default:
            break;
        }
    }

    static BCPHistoryEntry decode(XdrDataInputStream stream)
    {
        BCPHistoryEntry decodedHistoryEntry;
        decodedHistoryEntry.discriminant = stream.readInt32();
        switch (decodedHistoryEntry.discriminant)
        {
        case 0:
            decodedHistoryEntry.v0 = BCPHistoryEntryV0.decode(stream);
            break;
        default:
            break;
        }
        return decodedHistoryEntry;
    }
}
