module owlchain.consensus.slot;

import std.stdio;
import std.conv;
import std.json;
import std.digest.sha;
import std.algorithm : canFind;

import owlchain.xdr;

import std.typecons;
import owlchain.consensus.bcp;
import owlchain.consensus.bcpDriver;
import owlchain.consensus.localNode;
import owlchain.consensus.ballotProtocol;
import owlchain.consensus.nominationProtocol;

import owlchain.xdr.bcpStatement;
import owlchain.utils.globalChecks;

alias Tuple!(BCPStatement, "statement", bool, "fullyValidated") BCPStatementsValidated;

// The Slot object is in charge of maintaining the state of the BCP
// for a given slot index.
class Slot
{
private:
    uint64 mSlotIndex;

    BCP mBCP;
    BallotProtocol mBallotProtocol;
    NominationProtocol mNominationProtocol;

    // keeps track of all statements seen so far for this slot.
    // it is used for debugging purpose
    // second: if the slot was fully validated at the time
    BCPStatementsValidated[] mStatementsHistory;

    // true if the Slot was fully validated
    bool mFullyValidated;

public:

    this(uint64 slotIndex, BCP cp)
    {
        mSlotIndex = slotIndex;
        mBCP = cp;

        mBallotProtocol = new BallotProtocol(this);
        mNominationProtocol = new NominationProtocol(this);

        mFullyValidated = mBCP.getLocalNode().isValidator;
    }

    uint64 getSlotIndex()
    {
        return mSlotIndex;
    }

    BCP getCP()
    {
        return mBCP;
    }

    BCPDriver getCPDriver()
    {
        return mBCP.getCPDriver();
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
    BCPEnvelope[] getLatestMessagesSend()
    {
        BCPEnvelope[] res;
        if (mFullyValidated)
        {
            BCPEnvelope* e;
            e = mNominationProtocol.getLastMessageSend();
            if (e)
            {
                res ~= *e;
            }

            BCPEnvelopePtr e1;
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
    void setStateFromEnvelope(ref BCPEnvelope e)
    {
        if (e.statement.nodeID == mBCP.getLocalNodeID()
                && e.statement.slotIndex == mSlotIndex)
        {
            if (e.statement.pledges.type == BCPStatementType.BCP_ST_NOMINATE)
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
            writefln("[DEBUG], BCP Slot.setStateFromEnvelope invalid envelope");
        }
    }

    // returns the latest messages known for this slot
    BCPEnvelope[] getCurrentState()
    {
        BCPEnvelope[] res;
        res = mNominationProtocol.getCurrentState();
        res ~= mBallotProtocol.getCurrentState();
        return res;
    }

    // returns messages that helped this slot externalize
    BCPEnvelope[] getExternalizingState()
    {
        return mBallotProtocol.getExternalizingState();
    }

    // records the statement in the historical record for this slot
    void recordStatement(ref BCPStatement st)
    {
        BCPStatementsValidated value;
        value.statement = st;
        value.fullyValidated = mFullyValidated;
        mStatementsHistory ~= value;
    }

    // Process a newly received envelope for this slot and update the state of the slot accordingly.
    // self: set to true when node wants to record its own messages (potentially triggering more transitions)
    BCP.EnvelopeState processEnvelope(ref BCPEnvelope envelope, bool self)
    {
        dbgAssert(envelope.statement.slotIndex == mSlotIndex);

        //if (Logging::logDebug("BCP"))
        //writefln("[DEBUG], BCP Slot.processEnvelope %d %s", mSlotIndex, mBCP.envToStr(envelope));

        BCP.EnvelopeState res;
        try
        {
            if (envelope.statement.pledges.type == BCPStatementType.BCP_ST_NOMINATE)
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
            writefln("[ERROR], BCP %s state: %s  processing envelope: %s",
                    "Exception in processEnvelope", info.toString(),
                    mBCP.envToStr(envelope));

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
    BCP.TriBool isNodeInQuorum(ref NodeID node)
    {
        // build the mapping between nodes and envelopes
        BCPStatement*[][NodeID] m;
        // this may be reduced to the pair (at most) of the latest
        // statements for each protocol
        for (int i = 0; i < mStatementsHistory.length; i++)
        {
            auto e = mStatementsHistory[i];
            if (!m.keys.canFind(e.statement.nodeID))
            {
                BCPStatement*[] v;
                v ~= &(e.statement);
                m[e.statement.nodeID] = v;
            }
            else
            {
                m[e.statement.nodeID] ~= &(e.statement);
            }
        }

        return mBCP.getLocalNode().isNodeInQuorum(
            node, 
            (ref BCPStatement st) 
            {
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

        BCPQuorumSet[Hash] qSetsUsed;
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
                qSetsUsed[qSetHash] = cast(BCPQuorumSet) qSet;
            }
        }

        JSONValue[string] qSetsObject;
        JSONValue quorumSets = qSetsObject;
        foreach (ref const Hash h, ref BCPQuorumSet q; qSetsUsed)
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

    // returns the hash of the BCPQuorumSet that should be downloaded
    // with the statement.
    // note: the companion hash for an EXTERNALIZE statement does
    // not match the hash of the QSet, but the hash of commitQuorumSetHash
    static Hash getCompanionQuorumSetHashFromStatement(ref BCPStatement st)
    {
        Hash h;
        switch (st.pledges.type)
        {
        case BCPStatementType.BCP_ST_PREPARE:
            h = st.pledges.prepare.quorumSetHash;
            break;
        case BCPStatementType.BCP_ST_CONFIRM:
            h = st.pledges.confirm.quorumSetHash;
            break;
        case BCPStatementType.BCP_ST_EXTERNALIZE:
            h = st.pledges.externalize.commitQuorumSetHash;
            break;
        case BCPStatementType.BCP_ST_NOMINATE:
            h = st.pledges.nominate.quorumSetHash;
            break;
        default:
            dbgAbort();
        }
        return h;
    }

    // returns the values associated with the statement
    static Value[] getStatementValues(ref BCPStatement st)
    {
        Value[] res;
        if (st.pledges.type == BCPStatementType.BCP_ST_NOMINATE)
        {
            res = NominationProtocol.getStatementValues(st);
        }
        else
        {
            res ~= (BallotProtocol.getWorkingBallot(st).value);
        }
        return res;
    }

    // returns the BCPQuorumSet that should be used for a node given the
    // statement (singleton for externalize)
    BCPQuorumSetPtr getQuorumSetFromStatement(ref BCPStatement st)
    {
        BCPQuorumSetPtr res;
        BCPStatementType t = st.pledges.type;

        if (t == BCPStatementType.BCP_ST_EXTERNALIZE)
        {
            res = LocalNode.getSingletonQSet(st.nodeID);
        }
        else
        {
            Hash h;
            if (t == BCPStatementType.BCP_ST_PREPARE)
            {
                h = st.pledges.prepare.quorumSetHash;
            }
            else if (t == BCPStatementType.BCP_ST_CONFIRM)
            {
                h = st.pledges.confirm.quorumSetHash;
            }
            else if (t == BCPStatementType.BCP_ST_NOMINATE)
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
    BCPEnvelope createEnvelope(ref BCPStatement statement)
    {
        BCPEnvelope envelope;
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
            ref BCPEnvelope[NodeID] envs)
    {
        // Checks if the nodes that claimed to accept the statement form a
        // v-blocking set
        if (getLocalNode().isVBlocking(getLocalNode().getQuorumSet(), envs, accepted))
        {
            return true;
        }

        if (LocalNode.isQuorum(getLocalNode().getQuorumSet(), envs, (ref BCPStatement st) {
                return getQuorumSetFromStatement(st);
            }, (ref BCPStatement st) {
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
    bool federatedRatify(StatementPredicate voted, ref BCPEnvelope[NodeID] envs)
    {
        return LocalNode.isQuorum(getLocalNode().getQuorumSet(), envs, (ref BCPStatement st) {
            return getQuorumSetFromStatement(st);
        }, voted);
    }

    ref LocalNode getLocalNode()
    {
        return getCP().getLocalNode();
    }

    enum int NOMINATION_TIMER = 0;
    enum int BALLOT_PROTOCOL_TIMER = 1;

    BCPEnvelope[] getEntireCurrentState()
    {
        bool old = mFullyValidated;
        // fake fully validated to force returning all envelopes
        mFullyValidated = true;
        auto r = getCurrentState();
        mFullyValidated = old;
        return r;
    }
}
