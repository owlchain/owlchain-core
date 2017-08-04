module owlchain.consensus.nominationProtocol;

import std.stdio;
import std.container;
import std.json;
import std.algorithm: canFind;
import std.algorithm: find;
import std.algorithm: isSorted;
import std.typecons;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.envelope;
import owlchain.xdr.value;
import owlchain.xdr.quorumSet;
import owlchain.xdr.nodeID;
import owlchain.xdr.ballot;
import owlchain.xdr.nomination;
import owlchain.xdr.statement;
import owlchain.xdr.statementType;
import owlchain.xdr.signature;

import owlchain.consensus.localNode;
import owlchain.consensus.slot;
import owlchain.consensus.consensusProtocol;
import owlchain.consensus.consensusProtocolDriver;

import owlchain.utils.globalChecks;
import owlchain.utils.uniqueStruct;

class NominationProtocol
{
private :
    Slot mSlot;
    int32 mRoundNumber;
    ValueSet mVotes;                           // X
    ValueSet mAccepted;                        // Y
    ValueSet mCandidates;                      // Z
    Envelope[NodeID] mLatestNominations;       // N

    // last envelope emitted by this node
    UniqueStruct!Envelope mLastEnvelope; 

    // nodes from quorum set that have the highest priority this round
    NodeIDSet mRoundLeaders;

    // true if 'nominate' was called
    bool mNominationStarted;

    // the latest (if any) candidate value
    Value mLatestCompositeCandidate;

    // the value from the previous slot
    Value mPreviousValue;

public :
    this(Slot slot)
    {
        mVotes = new ValueSet;
        mAccepted = new ValueSet;
        mCandidates = new ValueSet;

        mRoundLeaders = new NodeIDSet;

        mSlot = slot;
        mRoundNumber = 0;
        mNominationStarted = false;
    }

    ~this()
    {
        mVotes = null;
        mAccepted = null;
        mCandidates = null;
        mRoundLeaders = null;
        mSlot = null;
    }

    ConsensusProtocol.EnvelopeState processEnvelope(ref const Envelope envelope)
    {
        auto const st = &envelope.statement;
        auto const nom = &st.pledges.nominate;

        ConsensusProtocol.EnvelopeState res = ConsensusProtocol.EnvelopeState.INVALID;

        if (isNewerStatement(st.nodeID, *nom))
        {
            if (isSane(*st))
            {
                recordEnvelope(envelope);
                res = ConsensusProtocol.EnvelopeState.VALID;

                if (mNominationStarted)
                {
                    // tracks if we should emit a new nomination message
                    bool modified = false; 
                    bool newCandidates = false;

                    // attempts to promote some of the votes to accepted
                    int i;
                    for (i = 0; i < nom.votes.length; i++)
                    {
                        const auto v = &(nom.votes[i]);
                        if (!find(mAccepted[], *v).empty)
                        { // v is already accepted
                            continue;
                        }
                        if (mSlot.federatedAccept(
                            (ref const Statement st) {
                                auto const nom2 = &st.pledges.nominate;
                                bool res;
                                res = (nom2.votes.canFind(*v));
                                return res;
                            },    
                            (ref const Statement st) {
                                return NominationProtocol.acceptPredicate(*v, st);
                            },
                            mLatestNominations))
                        {
                            auto vl = validateValue(*v);
                            if (vl == ConsensusProtocolDriver.ValidationLevel.kFullyValidatedValue)
                            {
                                mAccepted.insert(cast(Value)(*v));
                                mVotes.insert(cast(Value)(*v));
                                modified = true;
                            }
                            else
                            {
                                // the value made it pretty far:
                                // see if we can vote for a variation that
                                // we consider valid
                                Value toVote;
                                toVote = extractValidValue(*v);
                                if (toVote.value.length != 0)
                                {
                                    if (mVotes.insert(toVote))
                                    {
                                        modified = true;
                                    }
                                }
                            }
                        }
                    }

                    // attempts to promote accepted values to candidates
                    foreach (ref Value a; mAccepted)
                    {
                        if (!find(mCandidates[], a).empty)
                        {
                            continue;
                        }

                        if (mSlot.federatedRatify(
                            (ref const Statement st) {
                                return NominationProtocol.acceptPredicate(a, st);
                            }
                            , mLatestNominations))
                        {
                            mCandidates.insert(a);
                            newCandidates = true;
                        }
                    }

                    // only take round leader votes if we're still looking for
                    // candidates
                    if (mCandidates.empty && !find(mRoundLeaders[], st.nodeID).empty)
                    {
                        Value newVote = getNewValueFromNomination(*nom);
                        if (!newVote.value.length != 0)
                        {
                            mVotes.insert(newVote);
                            modified = true;
                        }
                    }

                    if (modified)
                    {
                        emitNomination();
                    }

                    if (newCandidates)
                    {
                        mLatestCompositeCandidate = mSlot.getCPDriver().combineCandidates(mSlot.getSlotIndex(), mCandidates);

                        mSlot.getCPDriver().updatedCandidateValue(mSlot.getSlotIndex(), mLatestCompositeCandidate);

                        mSlot.bumpState(mLatestCompositeCandidate, false);
                    }
                }
            }
            else
            {
                writeln("[DEBUG], CP NominationProtocol: message didn't pass sanity check");
            }
        }
        return ConsensusProtocol.EnvelopeState.INVALID;
    }

    static Value[] getStatementValues(ref const Statement st)
    {
        Value[] res;
        applyAll(st.pledges.nominate, (ref const Value v) { res ~= cast(Value)v; });
        return res;
    }

    // attempts to nominate a value for consensus
    bool nominate(ref const Value value, ref const Value previousValue, bool timedout)
    {
        //if (Logging::logDebug("ConsensusProtocol"))
        //writefln("[DEBUG], ConsensusProtocol NominationProtocol.nominate %s", mSlot.getCP().getValueString(value));

        bool updated = false;

        if (timedout && !mNominationStarted)
        {
            writefln("[DEBUG], ConsensusProtocol NominationProtocol.nominate (TIMED OUT)");
            return false;
        }

        mNominationStarted = true;

        mPreviousValue = cast(Value)previousValue;

        mRoundNumber++;
        updateRoundLeaders();

        Value nominatingValue;

        if (!find(mRoundLeaders[], mSlot.getLocalNode().getNodeID()).empty)
        {
            if (mVotes.insert(cast(Value)value))
            {
                updated = true;
            }
            nominatingValue = cast(Value)value;
        }
        else
        {
            foreach (ref const NodeID leader; mRoundLeaders)
            {
                if (mLatestNominations.keys.canFind(leader))
                {
                    nominatingValue = getNewValueFromNomination(mLatestNominations[leader].statement.pledges.nominate);
                    if (nominatingValue.value.length != 0)
                    {
                        mVotes.insert(nominatingValue);
                        updated = true;
                    }
                }
            }
        }

        long timeout = mSlot.getCPDriver().computeTimeout(mRoundNumber);

        mSlot.getCPDriver().nominatingValue(mSlot.getSlotIndex(), nominatingValue);

        Slot * slot = &mSlot;
        mSlot.getCPDriver().setupTimer(mSlot.getSlotIndex(), 
                                       Slot.NOMINATION_TIMER, 
                                       timeout,
                                       () {
                                            slot.nominate(value, previousValue, true);
                                        }
                                       );

        if (updated)
        {
            emitNomination();
        }
        else
        {
            writefln("[DEBUG], ConsensusProtocol NominationProtocol.nominate (SKIPPED)");
        }

        return updated;
    }

    // stops the nomination protocol
    void stopNomination()
    {
        mNominationStarted = false;
    }

    ref const(Value) getLatestCompositeCandidate()
    {
        return mLatestCompositeCandidate;
    }

    void dumpInfo(ref JSONValue ret)
    {
        import std.utf;

        JSONValue[string] nomStateObject;
        JSONValue nomState = nomStateObject;
        nomState.object["roundnumber"] = JSONValue(mRoundNumber);
        nomState.object["started"] = JSONValue(mNominationStarted);

        JSONValue[] state_X;
        nomState.object["X"] = state_X;
        foreach (ref const Value v; mVotes)
        {
            nomState["X"] ~= JSONValue(toUTF8(mSlot.getCP().getValueString(v)));
        }

        JSONValue[] state_Y;
        nomState.object["Y"] = state_Y;
        foreach (ref const Value v; mAccepted)
        {
            nomState["Y"] ~= JSONValue(toUTF8(mSlot.getCP().getValueString(v)));
        }

        JSONValue[] state_Z;
        nomState.object["Z"] = state_Z;
        foreach (ref const Value v; mCandidates)
        {
            nomState["Z"] ~= JSONValue(toUTF8(mSlot.getCP().getValueString(v)));
        }
        ret.object["nomination"] = nomState;
    }

    Envelope * getLastMessageSend()
    {
        if (!mLastEnvelope.isEmpty) return cast(Envelope *)mLastEnvelope;
        else return null;
    }

    void setStateFromEnvelope(ref const Envelope e)
    {
        if (mNominationStarted)
        {
            throw new Exception("Cannot set state after nomination is started");
        }
        recordEnvelope(e);
        
        int i;
        for (i = 0; i < e.statement.pledges.nominate.accepted.length; i++)
        {
            mAccepted.insert(cast(Value)e.statement.pledges.nominate.accepted[i]);
        }
        for (i = 0; i < e.statement.pledges.nominate.votes.length; i++)
        {
            mVotes.insert(cast(Value)e.statement.pledges.nominate.votes[i]);
        }

        mLastEnvelope = cast(UniqueStruct!Envelope)(new Envelope(cast(Statement)e.statement, cast(Signature)e.signature));
    }

    Envelope[] getCurrentState()
    {
        Envelope[] res;
        res.reserve(mLatestNominations.length);
        foreach (ref const NodeID n, ref const Envelope e; mLatestNominations)
        {
            // only return messages for self if the slot is fully validated
            if (!(n == mSlot.getCP().getLocalNodeID()) || mSlot.isFullyValidated())
            {
                res ~= cast(Envelope)e;
            }
        }
        return res;
    }

private :
    bool isNewerStatement(ref const NodeID nodeID, ref const Nomination st)
    {
        bool res = false;

        if (mLatestNominations.keys.canFind(nodeID)) {
            res = isNewerStatement(mLatestNominations[nodeID].statement.pledges.nominate, st);
        } else {
            res = true;
        }

        return res;
    }

    // returns true if 'p' is a subset of 'v'
    // also sets 'notEqual' if p and v differ
    // note: p and v must be sorted
    static bool isSubsetHelper(ref const Value[] p, ref const Value[] v, ref bool notEqual)
    {
        bool res;
        if (p.length <= v.length)
        {

            res = true;
            /*
            for (int i = 0; i < p.length; i++)
            {
                if (!v.canFind(p[i])) {
                    res = false;
                    break;
                }
            }
            */
            if (p.length > 0) {
                if (res) {
                    if (!v.canFind(p[0])) {
                        res = false;
                    }
                }
                if (res) {
                    if (!v.canFind(p[p.length-1])) {
                        res = false;
                    }
                }
            }

            if (res)
            {
                notEqual = p.length != v.length;
            }
            else
            {
                notEqual = true;
            }
        }
        else
        {
            notEqual = true;
            res = false;
        }
        return res;
    }

    ConsensusProtocolDriver.ValidationLevel validateValue(ref const Value v)
    {
        return mSlot.getCPDriver().validateValue(mSlot.getSlotIndex(), v);
    }

    Value extractValidValue(ref const Value value)
    {
        return mSlot.getCPDriver().extractValidValue(mSlot.getSlotIndex(), value);
    }

    static bool isNewerStatement(ref const Nomination oldst, ref const Nomination st)
    {
        bool res = false;
        bool grows;
        bool g = false;

        if (isSubsetHelper(oldst.votes, st.votes, g))
        {
            grows = g;
            if (isSubsetHelper(oldst.accepted, st.accepted, g))
            {
                grows = grows || g;
                res = grows; //  true only if one of the sets grew
            }
        }

        return res;
    }

    bool isSane(ref const Statement st)
    {
        auto nom = &(st.pledges.nominate);
        bool res = (nom.votes.length + nom.accepted.length) != 0;

        res = res && isSorted!"a.value < b.value"(nom.votes);
        res = res && isSorted!"a.value < b.value"(nom.accepted);

        return res;
    }

    void recordEnvelope(ref const Envelope env)
    {
        auto st = &env.statement;
        mLatestNominations[st.nodeID] = cast(Envelope)env;
        mSlot.recordStatement(env.statement);
    }

    void emitNomination()
    {
        Statement st;
        st.nodeID = mSlot.getLocalNode().getNodeID();
        st.pledges.type = StatementType.CP_ST_NOMINATE;

        st.pledges.nominate.quorumSetHash = cast(Hash)mSlot.getLocalNode().getQuorumSetHash();

        int i;
        foreach (ref Value v; mVotes)
        {
            st.pledges.nominate.votes ~= v;
        }

        foreach (ref Value v; mAccepted)
        {
            st.pledges.nominate.accepted ~= v;
        }

        Envelope envelope = mSlot.createEnvelope(st);

        if (mSlot.processEnvelope(envelope, true) == ConsensusProtocol.EnvelopeState.VALID)
        {
            if (mLastEnvelope.isEmpty || isNewerStatement(mLastEnvelope.statement.pledges.nominate, st.pledges.nominate))
            {
                mLastEnvelope = cast(UniqueStruct!Envelope)(new Envelope(cast(Statement)envelope.statement, cast(Signature)envelope.signature));
                if (mSlot.isFullyValidated())
                {
                    mSlot.getCPDriver().emitEnvelope(envelope);
                }
            }
        }
        else
        {
            // there is a bug in the application if it queued up
            // a statement for itself that it considers invalid
            throw new Exception("moved to a bad state (nomination)");
        }
    }

    // returns true if v is in the accepted list from the statement
    static bool acceptPredicate(ref const Value v, ref const Statement st)
    {
        bool res;
        res = st.pledges.nominate.accepted.canFind(v);
        return res;
    }

    // applies 'processor' to all values from the passed in nomination
    static void applyAll(ref const Nomination nom, void delegate(ref const Value) processor)
    {
        int i;
        for (i = 0; i < nom.votes.length; i++)
        {
            processor(nom.votes[i]);
        }
        for (i = 0; i < nom.accepted.length; i++)
        {
            processor(nom.accepted[i]);
        }
    }

    // updates the set of nodes that have priority over the others
    void updateRoundLeaders()
    {
        mRoundLeaders.clear();
        uint64 topPriority = 0;
        const QuorumSet myQSet = mSlot.getLocalNode().getQuorumSet();

        LocalNode.forAllNodes(myQSet, (ref const NodeID cur) {
            uint64 w = getNodePriority(cur, myQSet);
            if (w > topPriority)
            {
                topPriority = w;
                mRoundLeaders.clear();
            }
            if (w == topPriority && w > 0)
            {
                mRoundLeaders.insert(cur);
            }
        });

        writefln("[DEBUG], ConsensusProtocol updateRoundLeaders: %d", mRoundLeaders.length);
        //if (Logging::logDebug("CP"))
        foreach (ref const NodeID n; mRoundLeaders)
        {
            writefln("[DEBUG], ConsensusProtocol leader: %s", mSlot.getCPDriver().toShortString(n.publicKey));
        }
    }

    // computes Gi(isPriority?P:N, prevValue, mRoundNumber, nodeID)
    // from the paper
    uint64 hashNode(bool isPriority, ref const NodeID nodeID)
    {
        dbgAssert(mPreviousValue.value.length != 0);
        return mSlot.getCPDriver().computeHashNode(mSlot.getSlotIndex(), mPreviousValue, isPriority, mRoundNumber, nodeID);
    }

    // computes Gi(K, prevValue, mRoundNumber, value)
    uint64 hashValue(ref const Value value)
    {
        dbgAssert(mPreviousValue.value.length != 0);
        return mSlot.getCPDriver().computeValueHash(mSlot.getSlotIndex(), mPreviousValue, mRoundNumber, value);
    }

    uint64 getNodePriority(ref const NodeID nodeID, ref const QuorumSet qset)
    {
        uint64 res;
        uint64 w = LocalNode.getNodeWeight(nodeID, qset);

        if (hashNode(false, nodeID) < w)
        {
            res = hashNode(true, nodeID);
        }
        else
        {
            res = 0;
        }
        return res;
    }

    // returns the highest value that we don't have yet, that we should
    // vote for, extracted from a nomination.
    // returns the empty value if no new value was found
    Value getNewValueFromNomination(ref const Nomination nom)
    {
        // pick the highest value we don't have from the leader
        // sorted using hashValue.
        Value newVote;
        uint64 newHash = 0;

        applyAll(nom, (ref const Value value) {
            Value valueToNominate;
            auto vl = validateValue(value);
            if (vl == ConsensusProtocolDriver.ValidationLevel.kFullyValidatedValue)
            {
                valueToNominate = cast(Value)value;
            }
            else
            {
                valueToNominate = extractValidValue(value);
            }

            if (valueToNominate.value.length != 0)
            {
                if (find(mVotes[], valueToNominate).empty)
                {
                    uint64 curHash = hashValue(valueToNominate);
                    if (curHash >= newHash)
                    {
                        newHash = curHash;
                        newVote = valueToNominate;
                    }
                }
            }
        });
        return newVote;
    }

}
