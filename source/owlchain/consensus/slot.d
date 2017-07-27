module owlchain.consensus.slot;

import std.stdio;
import std.conv;
import std.json;
import std.digest.sha;
import std.algorithm : canFind;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.envelope;
import owlchain.xdr.value;
import owlchain.xdr.quorumSet;
import owlchain.xdr.nodeID;
import owlchain.xdr.ballot;
import owlchain.xdr.statement;
import owlchain.xdr.statementType;

import std.typecons;
import owlchain.consensus.consensusProtocol;
import owlchain.consensus.consensusProtocolDriver;
import owlchain.consensus.localNode;
import owlchain.consensus.ballotProtocol;
import owlchain.consensus.nominationProtocol;

import owlchain.xdr.statement;
import owlchain.utils.globalChecks;

alias StatementsValidated = Tuple!(Statement, "statement", bool, "fullyValidated");

// The Slot object is in charge of maintaining the state of the Consensus Protocol
// for a given slot index.
class Slot 
{
private:
    uint64 _slotIndex;

    ConsensusProtocol _consensusProtocol;
    BallotProtocol _ballotProtocol;
    NominationProtocol _nominationProtocol;

    // keeps track of all statements seen so far for this slot.
    // it is used for debugging purpose
    // second: if the slot was fully validated at the time
    StatementsValidated [] _statementsHistory;

    // true if the Slot was fully validated
    bool _fullyValidated;

public:

    this(uint64 slotIndex, ConsensusProtocol cp)
    {
        _slotIndex = slotIndex;
        _consensusProtocol = cp;

        _ballotProtocol = new BallotProtocol(this);
        _nominationProtocol = new NominationProtocol(this);

        _fullyValidated = _consensusProtocol.getLocalNode().isValidator;
    }

    uint64 getSlotIndex()
    {
        return _slotIndex;
    }

    ConsensusProtocol getCP()
    {
        return _consensusProtocol;
    }

    ConsensusProtocolDriver getCPDriver()
    {
        return _consensusProtocol.getCPDriver();
    }

    BallotProtocol getBallotProtocol()
    {
        return _ballotProtocol;
    }

    ref const(Value) getLatestCompositeCandidate()
    {
        return _nominationProtocol.getLatestCompositeCandidate();
    }

    // returns the latest messages the slot emitted
    Envelope [] getLatestMessagesSend()
    {
        Envelope [] res;
        if (_fullyValidated)
        {
            Envelope * e;
            e = _nominationProtocol.getLastMessageSend();
            if (e)
            {
                res ~= *e;
            }

            EnvelopePtr e1;
            e1 = _ballotProtocol.getLastMessageSend();
            if (e1.refCountedStore.isInitialized)
            {
                res ~= e1;
            }
        }
        return res;
    }

    // forces the state to match the one in the envelope
    // this is used when rebuilding the state after a crash for example
    void setStateFromEnvelope(ref const Envelope e)
    {
        if (e.statement.nodeID == _consensusProtocol.getLocalNodeID() && e.statement.slotIndex == _slotIndex)
        {
            if (e.statement.pledges.type.val == StatementType.CP_ST_NOMINATE)
            {
                _nominationProtocol.setStateFromEnvelope(e);
            }
            else
            {
                _ballotProtocol.setStateFromEnvelope(e);
            }
        }
        else
        {
            writefln("[%s], %s", "DEBUG", "ConsensusProtocol", "Slot.setStateFromEnvelope invalid envelope");
        }
    }

    // returns the latest messages known for this slot
    Envelope[] getCurrentState()
    {
        Envelope[] res;
        res = _nominationProtocol.getCurrentState();
        res ~= _ballotProtocol.getCurrentState();
        return res;
    }

    // returns messages that helped this slot externalize
    Envelope[] getExternalizingState()
    {
        return _ballotProtocol.getExternalizingState();
    }

    // records the statement in the historical record for this slot
    void recordStatement(ref const Statement st)
    {
        StatementsValidated value;
        value.statement = cast(Statement)st;
        value.fullyValidated = _fullyValidated;
        _statementsHistory ~= value;
    }

    // Process a newly received envelope for this slot and update the state of the slot accordingly.
    // self: set to true when node wants to record its own messages (potentially triggering more transitions)
    ConsensusProtocol.EnvelopeState 
    processEnvelope(ref const Envelope envelope, bool self)
    {
        dbgAssert(envelope.statement.slotIndex == _slotIndex);

        writefln("[%s], %s, %s %d %s", "DEBUG", "ConsensusProtocol", "Slot.processEnvelope", _slotIndex, _consensusProtocol.envToStr(envelope));

        ConsensusProtocol.EnvelopeState res;
        try
        {
            if (envelope.statement.pledges.type.val == StatementType.CP_ST_NOMINATE)
            {
                res = _nominationProtocol.processEnvelope(envelope);
            }
            else
            {
                res = _ballotProtocol.processEnvelope(envelope, self);
            }
        }
        catch (Exception e)
        {
            JSONValue[string] jsonObject;
            JSONValue info = jsonObject;
            dumpInfo(info);
            writefln("[%s], %s, %s", "DEBUG", "ConsensusProtocol", "Exception in processEnvelope");

            throw new Exception("Exception in processEnvelope");
        }
        return res;
    }

    // abandon's current ballot, move to a new ballot
    bool abandonBallot()
    {
        return _ballotProtocol.abandonBallot(0);
    }

    // bumps the ballot based on the local state and the value passed in:
    // in prepare phase, attempts to take value
    // otherwise, no-ops
    // force: when true, always bumps the value, otherwise only bumps
    // the state if no value was prepared
    bool bumpState(ref const Value value, bool force)
    {
        return _ballotProtocol.bumpState(value, force);
    }

    // attempts to nominate a value for consensus
    bool nominate(ref const Value value, ref const Value previousValue, bool timedout)
    {
        return _nominationProtocol.nominate(value, previousValue, timedout);
    }

    void stopNomination()
    {
        _nominationProtocol.stopNomination();
    }

    bool isFullyValidated()
    {
        return _fullyValidated;
    }

    void setFullyValidated(bool fullyValidated)
    {
        _fullyValidated = fullyValidated;
    }

    // returns if a node is in the quorum originating at the local node
    ConsensusProtocol.TriBool isNodeInQuorum(ref const NodeID node)
    {
        // build the mapping between nodes and envelopes
        Statement*[][NodeID] m;
        // this may be reduced to the pair (at most) of the latest
        // statements for each protocol
        for (int i = 0; i < _statementsHistory.length; i++)
        {
            auto e = _statementsHistory[i];
            if (!m.keys.canFind(e.statement.nodeID)) 
            {
                Statement*[] v;
                v ~= &(e.statement);
                m[e.statement.nodeID] = v;
            } 
            else
            {
                m[e.statement.nodeID] ~= &(e.statement);
            }
        }

        return _consensusProtocol.getLocalNode().isNodeInQuorum(
            node, 
            (ref const Statement st) {
                // uses the companion set here as we want to consider
                // nodes that were used up to EXTERNALIZE
                Hash h = getCompanionQuorumSetHashFromStatement(st);
                return getCPDriver().getQSet(h);
            },
            m);
    }

    // status methods
    size_t getStatementCount()
    {
        return _statementsHistory.length;
    }

    // returns information about the local state in JSON format
    // including historical statements if available
    void dumpInfo(ref JSONValue ret)
    {
        import std.utf;

        JSONValue[string] slotValueObject;
        JSONValue slotValue = slotValueObject;
        JSONValue[] statements;
        slotValue.object["statements"] = statements;

        QuorumSetPtr[Hash] qSetsUsed;
        int count = 0;
        for (int i = 0; i < _statementsHistory.length; i++)
        {
            auto item = _statementsHistory[i];

            slotValue["statements"].array ~= 
                JSONValue(
                          toUTF8(
                                 getCP().envToStr(item.statement) ~ to!string(item.fullyValidated)
                                 )
                          );

            Hash qSetHash = getCompanionQuorumSetHashFromStatement(item.statement);
            auto qSet = getCPDriver().getQSet(qSetHash);
            if (qSet.refCountedStore.isInitialized)
            {
                qSetsUsed[qSetHash] = qSet;
            }
        }

        JSONValue[string] qSetsObject;
        JSONValue qSets = qSetsObject;
        foreach (Hash h, const QuorumSetPtr q; qSetsUsed)
        {
            JSONValue[string] qsObject;
            JSONValue qs = qsObject;
            getLocalNode().toJson(q, qs);
            qSets.object[toHexString(h.hash)] = qs;
        }
        slotValue.object["quorum_sets"] = qSets;

        slotValue.object["validated"] = JSONValue(_fullyValidated);

        _nominationProtocol.dumpInfo(slotValue);
        _ballotProtocol.dumpInfo(slotValue);

        JSONValue[string] slotsObject;
        JSONValue slots = slotsObject;
        string slotKey = to!string(_slotIndex);
        slots.object[slotKey] = slotValue;
        ret.object["slots"] = slots;
    }

    // returns information about the quorum for a given node
    void dumpQuorumInfo(ref JSONValue ret, ref const NodeID id, bool summary)
    {
        JSONValue[string] quorumInfoObject;
        JSONValue quorumInfo = quorumInfoObject;

        _ballotProtocol.dumpQuorumInfo(quorumInfo, id, summary);

        string key = to!string(_slotIndex);
        ret.object[key] = quorumInfo;
    }

    // returns the hash of the QuorumSet that should be downloaded
    // with the statement.
    // note: the companion hash for an EXTERNALIZE statement does
    // not match the hash of the QSet, but the hash of commitQuorumSetHash
    static Hash getCompanionQuorumSetHashFromStatement(ref const Statement st)
    {
        Hash h;
        switch (st.pledges.type.val)
        {
            case StatementType.CP_ST_PREPARE:
                h = cast(Hash)(st.pledges.prepare.quorumSetHash);
                break;
            case StatementType.CP_ST_CONFIRM:
                h = cast(Hash)(st.pledges.confirm.quorumSetHash);
                break;
            case StatementType.CP_ST_EXTERNALIZE:
                h = cast(Hash)(st.pledges.externalize.commitQuorumSetHash);
                break;
            case StatementType.CP_ST_NOMINATE:
                h = cast(Hash)(st.pledges.nominate.quorumSetHash);
                break;
            default:
                dbgAbort();
        }
        return h;
    }

    // returns the values associated with the statement
    static Value[] getStatementValues(ref const Statement st)
    {
        Value[] res;
        if (st.pledges.type.val == StatementType.CP_ST_NOMINATE)
        {
            res = NominationProtocol.getStatementValues(st);
        }
        else
        {
            res ~= (BallotProtocol.getWorkingBallot(st).value);
        }
        return res;
    }

    // returns the QuorumSet that should be used for a node given the
    // statement (singleton for externalize)
    QuorumSetPtr getQuorumSetFromStatement(ref const Statement st)
    {
        QuorumSetPtr res;
        StatementType t = st.pledges.type;

        if (t.val == StatementType.CP_ST_EXTERNALIZE)
        {
            res = LocalNode.getSingletonQSet(st.nodeID);
        }
        else
        {
            Hash h;
            if (t.val == StatementType.CP_ST_PREPARE)
            {
                h = cast(Hash)(st.pledges.prepare.quorumSetHash);
            }
            else if (t.val == StatementType.CP_ST_CONFIRM)
            {
                h = cast(Hash)(st.pledges.confirm.quorumSetHash);
            }
            else if (t.val == StatementType.CP_ST_NOMINATE)
            {
                h = cast(Hash)(st.pledges.nominate.quorumSetHash);
            }
            else
            {
                dbgAbort();
            }
            res = getCPDriver().getQSet(h);
        }
        return res;
    }

    // wraps a statement in an envelope (sign it, etc)
    Envelope createEnvelope(ref const Statement statement)
    {
        Envelope envelope;

        envelope.statement = cast(Statement)statement;
        auto mySt = envelope.statement;
        mySt.nodeID = getCP().getLocalNodeID();
        mySt.slotIndex = _slotIndex;

        getCPDriver().signEnvelope(envelope);

        return envelope;
    }

    // ** federated agreement helper functions

    // returns true if the statement defined by voted and accepted
    // should be accepted
    bool federatedAccept(StatementPredicate voted, StatementPredicate accepted, ref const Envelope [NodeID] envs)
    {
        // Checks if the nodes that claimed to accept the statement form a
        // v-blocking set
        if (getLocalNode().isVBlocking(getLocalNode().getQuorumSet(), envs, accepted))
        {
            return true;
        }

        // Checks if the set of nodes that accepted or voted for it form a quorum
        auto ratifyFilter = (ref const Statement st) {
            bool res;
            res = accepted(st) || voted(st);
            return res;
        };

        if (LocalNode.isQuorum(
                getLocalNode().getQuorumSet(), 
                envs,
                (ref const Statement st) {
                    return getQuorumSetFromStatement(st);
                },
                ratifyFilter)
        )
        {
            return true;
        }
        return false;
    }

    // returns true if the statement defined by voted
    // is ratified
    bool federatedRatify(StatementPredicate voted, ref const Envelope [NodeID] envs)
    {
        return LocalNode.isQuorum(
                getLocalNode().getQuorumSet(), 
                envs,
                (ref const Statement st) {
                    return getQuorumSetFromStatement(st);
                },
                voted);
    }

    ref LocalNode getLocalNode()
    {
        return getCP().getLocalNode();
    }

    enum int NOMINATION_TIMER = 0;
    enum int BALLOT_PROTOCOL_TIMER = 1;

protected :
    Envelope [] getEntireCurrentState()
    {
        bool old = _fullyValidated;
        // fake fully validated to force returning all envelopes
        _fullyValidated = true;
        auto r = getCurrentState();
        _fullyValidated = old;
        return r;
    }
}