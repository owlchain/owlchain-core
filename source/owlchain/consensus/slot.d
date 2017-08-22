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

alias Tuple!(Statement, "statement", bool, "fullyValidated") StatementsValidated;

// The Slot object is in charge of maintaining the state of the Consensus Protocol
// for a given slot index.
class Slot
{
private:
    uint64 mSlotIndex;

    ConsensusProtocol mConsensusProtocol;
    BallotProtocol mBallotProtocol;
    NominationProtocol mNominationProtocol;

    // keeps track of all statements seen so far for this slot.
    // it is used for debugging purpose
    // second: if the slot was fully validated at the time
    StatementsValidated[] mStatementsHistory;

    // true if the Slot was fully validated
    bool mFullyValidated;

public:

    this(uint64 slotIndex, ConsensusProtocol cp)
    {
        mSlotIndex = slotIndex;
        mConsensusProtocol = cp;

        mBallotProtocol = new BallotProtocol(this);
        mNominationProtocol = new NominationProtocol(this);

        mFullyValidated = mConsensusProtocol.getLocalNode().isValidator;
    }

    uint64 getSlotIndex()
    {
        return mSlotIndex;
    }

    ConsensusProtocol getCP()
    {
        return mConsensusProtocol;
    }

    ConsensusProtocolDriver getCPDriver()
    {
        return mConsensusProtocol.getCPDriver();
    }

    BallotProtocol getBallotProtocol()
    {
        return mBallotProtocol;
    }

    ref Value getLatestCompositeCandidate()
    {
        return mNominationProtocol.getLatestCompositeCandidate();
    }

    // returns the latest messages the slot emitted
    Envelope[] getLatestMessagesSend()
    {
        Envelope[] res;
        if (mFullyValidated)
        {
            Envelope* e;
            e = mNominationProtocol.getLastMessageSend();
            if (e)
            {
                res ~= *e;
            }

            EnvelopePtr e1;
            e1 = mBallotProtocol.getLastMessageSend();
            if (e1.refCountedStore.isInitialized)
            {
                res ~= e1;
            }
        }
        return res;
    }

    // forces the state to match the one in the envelope
    // this is used when rebuilding the state after a crash for example
    void setStateFromEnvelope(ref Envelope e)
    {
        if (e.statement.nodeID == mConsensusProtocol.getLocalNodeID()
                && e.statement.slotIndex == mSlotIndex)
        {
            if (e.statement.pledges.type == StatementType.CP_ST_NOMINATE)
            {
                mNominationProtocol.setStateFromEnvelope(e);
            }
            else
            {
                mBallotProtocol.setStateFromEnvelope(e);
            }
        }
        else
        {
            writefln("[DEBUG], ConsensusProtocol Slot.setStateFromEnvelope invalid envelope");
        }
    }

    // returns the latest messages known for this slot
    Envelope[] getCurrentState()
    {
        Envelope[] res;
        res = mNominationProtocol.getCurrentState();
        res ~= mBallotProtocol.getCurrentState();
        return res;
    }

    // returns messages that helped this slot externalize
    Envelope[] getExternalizingState()
    {
        return mBallotProtocol.getExternalizingState();
    }

    // records the statement in the historical record for this slot
    void recordStatement(ref Statement st)
    {
        StatementsValidated value;
        value.statement = st;
        value.fullyValidated = mFullyValidated;
        mStatementsHistory ~= value;
    }

    // Process a newly received envelope for this slot and update the state of the slot accordingly.
    // self: set to true when node wants to record its own messages (potentially triggering more transitions)
    ConsensusProtocol.EnvelopeState processEnvelope(ref Envelope envelope, bool self)
    {
        dbgAssert(envelope.statement.slotIndex == mSlotIndex);

        //if (Logging::logDebug("ConsensusProtocol"))
        //writefln("[DEBUG], ConsensusProtocol Slot.processEnvelope %d %s", mSlotIndex, mConsensusProtocol.envToStr(envelope));

        ConsensusProtocol.EnvelopeState res;
        try
        {
            if (envelope.statement.pledges.type == StatementType.CP_ST_NOMINATE)
            {
                res = mNominationProtocol.processEnvelope(envelope);
            }
            else
            {
                res = mBallotProtocol.processEnvelope(envelope, self);
            }
        }
        catch (Exception e)
        {
            JSONValue[string] jsonObject;
            JSONValue info = jsonObject;
            dumpInfo(info);
            writefln("[ERROR], ConsensusProtocol %s state: %s  processing envelope: %s",
                    "Exception in processEnvelope", info.toString(),
                    mConsensusProtocol.envToStr(envelope));

            throw new Exception("Exception in processEnvelope");
        }
        return res;
    }

    // abandon's current ballot, move to a new ballot
    bool abandonBallot()
    {
        return mBallotProtocol.abandonBallot(0);
    }

    // bumps the ballot based on the local state and the value passed in:
    // in prepare phase, attempts to take value
    // otherwise, no-ops
    // force: when true, always bumps the value, otherwise only bumps
    // the state if no value was prepared
    bool bumpState(ref Value value, bool force)
    {
        return mBallotProtocol.bumpState(value, force);
    }

    // attempts to nominate a value for consensus
    bool nominate(ref Value value, ref Value previousValue, bool timedout)
    {
        return mNominationProtocol.nominate(value, previousValue, timedout);
    }

    void stopNomination()
    {
        mNominationProtocol.stopNomination();
    }

    bool isFullyValidated()
    {
        return mFullyValidated;
    }

    void setFullyValidated(bool fullyValidated)
    {
        mFullyValidated = fullyValidated;
    }

    // returns if a node is in the quorum originating at the local node
    ConsensusProtocol.TriBool isNodeInQuorum(ref NodeID node)
    {
        // build the mapping between nodes and envelopes
        Statement*[][NodeID] m;
        // this may be reduced to the pair (at most) of the latest
        // statements for each protocol
        for (int i = 0; i < mStatementsHistory.length; i++)
        {
            auto e = mStatementsHistory[i];
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

        return mConsensusProtocol.getLocalNode().isNodeInQuorum(node, (ref Statement st) {
            // uses the companion set here as we want to consider
            // nodes that were used up to EXTERNALIZE
            Hash h = getCompanionQuorumSetHashFromStatement(st);
            return getCPDriver().getQSet(h);
        }, m);
    }

    // status methods
    size_t getStatementCount()
    {
        return mStatementsHistory.length;
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

        QuorumSet[Hash] qSetsUsed;
        int count = 0;
        for (int i = 0; i < mStatementsHistory.length; i++)
        {
            auto item = mStatementsHistory[i];

            slotValue["statements"].array ~= JSONValue(toUTF8(getCP()
                    .envToStr(item.statement) ~ to!string(item.fullyValidated)));

            Hash qSetHash = getCompanionQuorumSetHashFromStatement(item.statement);
            auto qSet = getCPDriver().getQSet(qSetHash);
            if (qSet.refCountedStore.isInitialized)
            {
                qSetsUsed[qSetHash] = cast(QuorumSet) qSet;
            }
        }

        JSONValue[string] qSetsObject;
        JSONValue quorumSets = qSetsObject;
        foreach (ref const Hash h, ref QuorumSet q; qSetsUsed)
        {
            JSONValue[string] qsObject;
            JSONValue qs = qsObject;
            getLocalNode().toJson(q, qs);
            string LKey = toHexString(h.hash)[0 .. 5];
            quorumSets.object[LKey] = qs;
        }
        slotValue.object["quorum_sets"] = quorumSets;

        slotValue.object["validated"] = JSONValue(mFullyValidated);

        mNominationProtocol.dumpInfo(slotValue);
        mBallotProtocol.dumpInfo(slotValue);

        JSONValue[string] slotsObject;
        JSONValue slots = slotsObject;

        string slotKey = to!string(mSlotIndex);
        slots.object[slotKey] = slotValue;

        ret.object["slots"] = slots;
    }

    // returns information about the quorum for a given node
    void dumpQuorumInfo(ref JSONValue ret, ref NodeID id, bool summary)
    {
        JSONValue[string] quorumInfoObject;
        JSONValue quorumInfo = quorumInfoObject;

        mBallotProtocol.dumpQuorumInfo(quorumInfo, id, summary);

        string key = to!string(mSlotIndex);
        ret.object[key] = quorumInfo;
    }

    // returns the hash of the QuorumSet that should be downloaded
    // with the statement.
    // note: the companion hash for an EXTERNALIZE statement does
    // not match the hash of the QSet, but the hash of commitQuorumSetHash
    static Hash getCompanionQuorumSetHashFromStatement(ref Statement st)
    {
        Hash h;
        switch (st.pledges.type)
        {
        case StatementType.CP_ST_PREPARE:
            h = st.pledges.prepare.quorumSetHash;
            break;
        case StatementType.CP_ST_CONFIRM:
            h = st.pledges.confirm.quorumSetHash;
            break;
        case StatementType.CP_ST_EXTERNALIZE:
            h = st.pledges.externalize.commitQuorumSetHash;
            break;
        case StatementType.CP_ST_NOMINATE:
            h = st.pledges.nominate.quorumSetHash;
            break;
        default:
            dbgAbort();
        }
        return h;
    }

    // returns the values associated with the statement
    static Value[] getStatementValues(ref Statement st)
    {
        Value[] res;
        if (st.pledges.type == StatementType.CP_ST_NOMINATE)
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
    QuorumSetPtr getQuorumSetFromStatement(ref Statement st)
    {
        QuorumSetPtr res;
        StatementType t = st.pledges.type;

        if (t == StatementType.CP_ST_EXTERNALIZE)
        {
            res = LocalNode.getSingletonQSet(st.nodeID);
        }
        else
        {
            Hash h;
            if (t == StatementType.CP_ST_PREPARE)
            {
                h = st.pledges.prepare.quorumSetHash;
            }
            else if (t == StatementType.CP_ST_CONFIRM)
            {
                h = st.pledges.confirm.quorumSetHash;
            }
            else if (t == StatementType.CP_ST_NOMINATE)
            {
                h = st.pledges.nominate.quorumSetHash;
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
    Envelope createEnvelope(ref Statement statement)
    {
        Envelope envelope;
        envelope.statement = statement;
        envelope.statement.nodeID = getCP().getLocalNodeID();
        envelope.statement.slotIndex = mSlotIndex;

        getCPDriver().signEnvelope(envelope);

        return envelope;
    }

    // ** federated agreement helper functions

    // returns true if the statement defined by voted and accepted
    // should be accepted
    bool federatedAccept(StatementPredicate voted, StatementPredicate accepted,
            ref Envelope[NodeID] envs)
    {
        // Checks if the nodes that claimed to accept the statement form a
        // v-blocking set
        if (getLocalNode().isVBlocking(getLocalNode().getQuorumSet(), envs, accepted))
        {
            return true;
        }

        if (LocalNode.isQuorum(getLocalNode().getQuorumSet(), envs, (ref Statement st) {
                return getQuorumSetFromStatement(st);
            }, (ref Statement st) {
                // Checks if the set of nodes that accepted or voted for it form a quorum
                return accepted(st) || voted(st);
            }))
        {
            return true;
        }
        return false;
    }

    // returns true if the statement defined by voted
    // is ratified
    bool federatedRatify(StatementPredicate voted, ref Envelope[NodeID] envs)
    {
        return LocalNode.isQuorum(getLocalNode().getQuorumSet(), envs, (ref Statement st) {
            return getQuorumSetFromStatement(st);
        }, voted);
    }

    ref LocalNode getLocalNode()
    {
        return getCP().getLocalNode();
    }

    enum int NOMINATION_TIMER = 0;
    enum int BALLOT_PROTOCOL_TIMER = 1;

    Envelope[] getEntireCurrentState()
    {
        bool old = mFullyValidated;
        // fake fully validated to force returning all envelopes
        mFullyValidated = true;
        auto r = getCurrentState();
        mFullyValidated = old;
        return r;
    }
}
