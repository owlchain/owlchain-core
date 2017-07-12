module owlchain.xdr.historyEntryV0;

import owlchain.xdr.quorumSet;
import owlchain.xdr.ledgerMessages;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct HistoryEntryV0
{
    QuorumSet[] quorumSets;
    LedgerMessages ledgerMessages;

    static void encode(XdrDataOutputStream stream, ref const HistoryEntryV0 encodedHistoryEntryV0)
    {
        int quorumSetssize = cast(int)(encodedHistoryEntryV0.quorumSets.length);
        stream.writeInt(quorumSetssize);
        for (int i = 0; i < quorumSetssize; i++)
        {
            QuorumSet.encode(stream, encodedHistoryEntryV0.quorumSets[i]);
        }
        LedgerMessages.encode(stream, encodedHistoryEntryV0.ledgerMessages);
    }

    static HistoryEntryV0 decode(XdrDataInputStream stream)
    {
        HistoryEntryV0 decodedHistoryEntryV0;
        int quorumSetssize = stream.readInt();
        decodedHistoryEntryV0.quorumSets.length = quorumSetssize;
        for (int i = 0; i < quorumSetssize; i++)
        {
            decodedHistoryEntryV0.quorumSets[i] = QuorumSet.decode(stream);
        }
        decodedHistoryEntryV0.ledgerMessages = LedgerMessages.decode(stream);
        return decodedHistoryEntryV0;
    }
}
