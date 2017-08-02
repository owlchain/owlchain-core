module owlchain.xdr.statement;

import owlchain.xdr.type;
import owlchain.xdr.nodeID;
import owlchain.xdr.hash;
import owlchain.xdr.ballot;
import owlchain.xdr.statementType;
import owlchain.xdr.nomination;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Statement
{
    NodeID nodeID;
    uint64 slotIndex;
    StatementPledges pledges;

    static void encode(XdrDataOutputStream stream, ref const Statement encodedStatement)
    {
        NodeID.encode(stream, encodedStatement.nodeID);
        stream.writeUint64(encodedStatement.slotIndex);
        StatementPledges.encode(stream, encodedStatement.pledges);
    }
    
    static Statement decode(XdrDataInputStream stream)
    {
        Statement decodedStatement;
        decodedStatement.nodeID = NodeID.decode(stream);
        decodedStatement.slotIndex = stream.readUint64();
        decodedStatement.pledges = StatementPledges.decode(stream);
        return decodedStatement;
    }
}

struct StatementPledges
{
    StatementType type;
    StatementPrepare prepare;
    StatementConfirm confirm;
    StatementExternalize externalize;
    Nomination nominate;

    static void encode(XdrDataOutputStream stream, ref const StatementPledges encodedStatementPledges)
    {
        stream.writeInt32(encodedStatementPledges.type);

        switch (encodedStatementPledges.type)
        {
            case StatementType.CP_ST_PREPARE:
                StatementPrepare.encode(stream, encodedStatementPledges.prepare);
                break;
            case StatementType.CP_ST_CONFIRM:
                StatementConfirm.encode(stream, encodedStatementPledges.confirm);
                break;
            case StatementType.CP_ST_EXTERNALIZE:
                StatementExternalize.encode(stream, encodedStatementPledges.externalize);
                break;
            case StatementType.CP_ST_NOMINATE:
                Nomination.encode(stream, encodedStatementPledges.nominate);
                break;
            default:
        }
    }

    static StatementPledges decode(XdrDataInputStream stream)
    {
        StatementPledges decodedStatementPledges;

        int32 value = stream.readInt32();
        switch (value) {
            case 0: 
                decodedStatementPledges.type = StatementType.CP_ST_PREPARE;
                break;
            case 1: 
                decodedStatementPledges.type = StatementType.CP_ST_CONFIRM;
                break;
            case 2: 
                decodedStatementPledges.type = StatementType.CP_ST_EXTERNALIZE;
                break;
            case 3: 
                decodedStatementPledges.type = StatementType.CP_ST_NOMINATE;
                break;
            default:
                throw new Exception("Unknown enum value");
        }

        switch (decodedStatementPledges.type)
        {
            case StatementType.CP_ST_PREPARE:
                decodedStatementPledges.prepare = StatementPrepare.decode(stream);
                break;
            case StatementType.CP_ST_CONFIRM:
                decodedStatementPledges.confirm = StatementConfirm.decode(stream);
                break;
            case StatementType.CP_ST_EXTERNALIZE:
                decodedStatementPledges.externalize = StatementExternalize.decode(stream);
                break;
            case StatementType.CP_ST_NOMINATE:
                decodedStatementPledges.nominate = Nomination.decode(stream);
                break;
            default:
        }
        return decodedStatementPledges;
    }
}

struct StatementPrepare
{
    Hash quorumSetHash;
    Ballot ballot;
    Ballot prepared;
    uint32 nC;
    Ballot preparedPrime;
    uint32 nH;

    static void encode(XdrDataOutputStream stream, ref const StatementPrepare encodedStatementPrepare)
    {
        Hash.encode(stream, encodedStatementPrepare.quorumSetHash);
        Ballot.encode(stream, encodedStatementPrepare.ballot);
        Ballot.encode(stream, encodedStatementPrepare.prepared);
        Ballot.encode(stream, encodedStatementPrepare.preparedPrime);
        stream.writeUint32(encodedStatementPrepare.nC);
        stream.writeUint32(encodedStatementPrepare.nH);
    }

    static StatementPrepare decode(XdrDataInputStream stream)
    {
        StatementPrepare decodedStatementPrepare;
        decodedStatementPrepare.quorumSetHash = Hash.decode(stream);
        decodedStatementPrepare.ballot = Ballot.decode(stream);
        decodedStatementPrepare.prepared = Ballot.decode(stream);
        decodedStatementPrepare.preparedPrime = Ballot.decode(stream);
        decodedStatementPrepare.nC = stream.readUint32();
        decodedStatementPrepare.nH = stream.readUint32();
        return decodedStatementPrepare;
    }
}

struct StatementConfirm
{
    Ballot ballot;
    uint32 nPrepared;
    uint32 nCommit;
    uint32 nH;
    Hash quorumSetHash;

    static void encode(XdrDataOutputStream stream, ref const StatementConfirm encodedStatementConfirm)
    {
        Ballot.encode(stream, encodedStatementConfirm.ballot);
        stream.writeUint32(encodedStatementConfirm.nPrepared);
        stream.writeUint32(encodedStatementConfirm.nCommit);
        stream.writeUint32(encodedStatementConfirm.nH);
        Hash.encode(stream, encodedStatementConfirm.quorumSetHash);
    }

    static StatementConfirm decode(XdrDataInputStream stream)
    {
        StatementConfirm decodedStatementConfirm;
        decodedStatementConfirm.ballot = Ballot.decode(stream);
        decodedStatementConfirm.nPrepared = stream.readUint32();
        decodedStatementConfirm.nCommit = stream.readUint32();
        decodedStatementConfirm.nH = stream.readUint32();
        decodedStatementConfirm.quorumSetHash = Hash.decode(stream);
        return decodedStatementConfirm;
    }

}
struct StatementExternalize
{
    Ballot commit;
    uint32 nH;
    Hash commitQuorumSetHash;

    static void encode(XdrDataOutputStream stream, ref const StatementExternalize encodedStatementExternalize)
    {
        Ballot.encode(stream, encodedStatementExternalize.commit);
        stream.writeUint32(encodedStatementExternalize.nH);
        Hash.encode(stream, encodedStatementExternalize.commitQuorumSetHash);
    }

    static StatementExternalize decode(XdrDataInputStream stream)
    {
        StatementExternalize decodedStatementExternalize;
        decodedStatementExternalize.commit = Ballot.decode(stream);
        decodedStatementExternalize.nH = stream.readUint32();
        decodedStatementExternalize.commitQuorumSetHash = Hash.decode(stream);
        return decodedStatementExternalize;
    }
}
