module owlchain.xdr.bcpHistoryEntryV0;

import owlchain.xdr.bcpQuorumSet;
import owlchain.xdr.ledgerMessages;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct BCPHistoryEntryV0
{
    BCPQuorumSet[] quorumSets;
    LedgerMessages ledgerMessages;

    ref BCPHistoryEntryV0 opAssign(BCPHistoryEntryV0 s)
    {
        quorumSets.length = 0;
        for (int i = 0; i < s.quorumSets.length; i++)
        {
            quorumSets ~= cast(BCPQuorumSet)s.quorumSets[i];
        }
        ledgerMessages = s.ledgerMessages;
        return this;
    }

    ref BCPHistoryEntryV0 opAssign(ref BCPHistoryEntryV0 s)
    {
        quorumSets.length = 0;
        for (int i = 0; i < s.quorumSets.length; i++)
        {
            quorumSets ~= cast(BCPQuorumSet)s.quorumSets[i];
        }
        ledgerMessages = s.ledgerMessages;
        return this;
    }

    ref BCPHistoryEntryV0 opAssign(ref const(BCPHistoryEntryV0) s)
    {
        quorumSets.length = 0;
        for (int i = 0; i < s.quorumSets.length; i++)
        {
            quorumSets ~= cast(BCPQuorumSet)s.quorumSets[i];
        }
        ledgerMessages = s.ledgerMessages;
        return this;
    }
    static void encode(XdrDataOutputStream stream, ref const BCPHistoryEntryV0 encodedHistoryEntryV0)
    {
        int quorumSetssize = cast(int)(encodedHistoryEntryV0.quorumSets.length);
        stream.writeInt(quorumSetssize);
        for (int i = 0; i < quorumSetssize; i++)
        {
            BCPQuorumSet.encode(stream, encodedHistoryEntryV0.quorumSets[i]);
        }
        LedgerMessages.encode(stream, encodedHistoryEntryV0.ledgerMessages);
    }

    static BCPHistoryEntryV0 decode(XdrDataInputStream stream)
    {
        BCPHistoryEntryV0 decodedHistoryEntryV0;
        const int quorumSetssize = stream.readInt();
        decodedHistoryEntryV0.quorumSets.length = quorumSetssize;
        for (int i = 0; i < quorumSetssize; i++)
        {
            decodedHistoryEntryV0.quorumSets[i] = BCPQuorumSet.decode(stream);
        }
        decodedHistoryEntryV0.ledgerMessages = LedgerMessages.decode(stream);
        return decodedHistoryEntryV0;
    }
}
