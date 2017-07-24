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

import owlchain.consensus.localNode;
import owlchain.consensus.slot;
import owlchain.consensus.consensusProtocol;
import owlchain.consensus.consensusProtocolDriver;

import owlchain.util.globalChecks;

class NominationProtocol
{
private :
    Slot _slot;
    int32 _roundNumber;
    ValueSet _votes;                           // X
    ValueSet _accepted;                        // Y
    ValueSet _candidates;                      // Z
    Envelope[NodeID] _latestNominations;       // N

    // last envelope emitted by this node
    Envelope _lastEnvelope; 
    bool _enabledLastEnvelope; 

    // nodes from quorum set that have the highest priority this round
    NodeIDSet _roundLeaders;

    // true if 'nominate' was called
    bool _nominationStarted;

    // the latest (if any) candidate value
    Value _latestCompositeCandidate;

    // the value from the previous slot
    Value _previousValue;

public :
    this(Slot slot)
    {
        _votes = new ValueSet;
        _accepted = new ValueSet;
        _candidates = new ValueSet;

        _slot = slot;
        _roundNumber = 0;
        _nominationStarted = false;
        _enabledLastEnvelope = false;
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

                if (_nominationStarted)
                {
                    // tracks if we should emit a new nomination message
                    bool modified = false; 
                    bool newCandidates = false;

                    // attempts to promote some of the votes to accepted
                    int i;
                    for (i = 0; i < nom.votes.length; i++)
                    {
                        const auto v = &(nom.votes[i]);
                        if (!find(_accepted[], *v).empty)
                        { // v is already accepted
                            continue;
                        }
                        if (_slot.federatedAccept(
                            (ref const Statement st) {
                                auto const nom2 = &st.pledges.nominate;
                                bool res;
                                res = (nom2.votes.canFind(*v));
                                return res;
                            },    
                            (ref const Statement st) {
                                return NominationProtocol.acceptPredicate(*v, st);
                            },
                            _latestNominations))
                        {
                            auto vl = validateValue(*v);
                            if (vl == ConsensusProtocolDriver.ValidationLevel.kFullyValidatedValue)
                            {
                                _accepted.insert(cast(Value)(*v));
                                _votes.insert(cast(Value)(*v));
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
                                    if (_votes.insert(toVote))
                                    {
                                        modified = true;
                                    }
                                }
                            }
                        }
                    }

                    // attempts to promote accepted values to candidates
                    foreach (ref Value a; _accepted)
                    {
                        if (!find(_candidates[], a).empty)
                        {
                            continue;
                        }

                        if (_slot.federatedRatify(
                            (ref const Statement st) {
                                return NominationProtocol.acceptPredicate(a, st);
                            }
                            , _latestNominations))
                        {
                            _candidates.insert(a);
                            newCandidates = true;
                        }
                    }

                    // only take round leader votes if we're still looking for
                    // candidates
                    if (_candidates.empty && !find(_roundLeaders[], st.nodeID).empty)
                    {
                        Value newVote = getNewValueFromNomination(*nom);
                        if (!newVote.value.length != 0)
                        {
                            _votes.insert(newVote);
                            modified = true;
                        }
                    }

                    if (modified)
                    {
                        emitNomination();
                    }

                    if (newCandidates)
                    {
                        _latestCompositeCandidate = _slot.getCPDriver().combineCandidates(_slot.getSlotIndex(), _candidates);

                        _slot.getCPDriver().updatedCandidateValue(_slot.getSlotIndex(), _latestCompositeCandidate);

                        _slot.bumpState(_latestCompositeCandidate, false);
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
        writefln("[DEBUG], ConsensusProtocol NominationProtocol.nominate %s", _slot.getCP().getValueString(value));

        bool updated = false;

        if (timedout && !_nominationStarted)
        {
            writefln("[DEBUG], ConsensusProtocol NominationProtocol.nominate (TIMED OUT)");
            return false;
        }

        _nominationStarted = true;

        _previousValue = cast(Value)previousValue;

        _roundNumber++;
        updateRoundLeaders();

        Value nominatingValue;

        if (!find(_roundLeaders[], _slot.getLocalNode().getNodeID()).empty)
        {
            if (_votes.insert(cast(Value)value))
            {
                updated = true;
            }
            nominatingValue = cast(Value)value;
        }
        else
        {
            foreach (ref const NodeID leader; _roundLeaders)
            {
                if (_latestNominations.keys.canFind(leader))
                {
                    nominatingValue = getNewValueFromNomination(_latestNominations[leader].statement.pledges.nominate);
                    if (nominatingValue.value.length != 0)
                    {
                        _votes.insert(nominatingValue);
                        updated = true;
                    }
                }
            }
        }

        long timeout = _slot.getCPDriver().computeTimeout(_roundNumber);

        _slot.getCPDriver().nominatingValue(_slot.getSlotIndex(), nominatingValue);

        Slot * slot = &_slot;
        _slot.getCPDriver().setupTimer(_slot.getSlotIndex(), 
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
        _nominationStarted = false;
    }

    ref const(Value) getLatestCompositeCandidate()
    {
        return _latestCompositeCandidate;
    }

    void dumpInfo(ref JSONValue ret)
    {
        import std.utf;

        JSONValue[string] nomStateObject;
        JSONValue nomState = nomStateObject;
        nomState.object["roundnumber"] = JSONValue(_roundNumber);
        nomState.object["started"] = JSONValue(_nominationStarted);

        JSONValue[] state_X;
        nomState.object["X"] = state_X;
        foreach (ref const Value v; _votes)
        {
            nomState["X"] ~= JSONValue(toUTF8(_slot.getCP().getValueString(v)));
        }

        JSONValue[] state_Y;
        nomState.object["Y"] = state_Y;
        foreach (ref const Value v; _accepted)
        {
            nomState["Y"] ~= JSONValue(toUTF8(_slot.getCP().getValueString(v)));
        }

        JSONValue[] state_Z;
        nomState.object["Z"] = state_Z;
        foreach (ref const Value v; _candidates)
        {
            nomState["Z"] ~= JSONValue(toUTF8(_slot.getCP().getValueString(v)));
        }
        ret.object["nomination"] = nomState;
    }

    Envelope * getLastMessageSend()
    {
        if (_enabledLastEnvelope) return &_lastEnvelope;
        else return null;
    }

    void setStateFromEnvelope(ref const Envelope e)
    {
        if (_nominationStarted)
        {
            throw new Exception("Cannot set state after nomination is started");
        }
        recordEnvelope(e);
        
        int i;
        for (i = 0; i < e.statement.pledges.nominate.accepted.length; i++)
        {
            _accepted.insert(cast(Value)e.statement.pledges.nominate.accepted[i]);
        }
        for (i = 0; i < e.statement.pledges.nominate.votes.length; i++)
        {
            _votes.insert(cast(Value)e.statement.pledges.nominate.votes[i]);
        }

        _lastEnvelope = cast(Envelope)e;
        _enabledLastEnvelope = true;
    }

    Envelope[] getCurrentState()
    {
        Envelope[] res;
        res.reserve(_latestNominations.length);
        foreach (ref const NodeID n, ref const Envelope e; _latestNominations)
        {
            // only return messages for self if the slot is fully validated
            if (!(n == _slot.getCP().getLocalNodeID()) || _slot.isFullyValidated())
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

        if (_latestNominations.keys.canFind(nodeID)) {
            res = isNewerStatement(_latestNominations[nodeID].statement.pledges.nominate, st);
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
        return _slot.getCPDriver().validateValue(_slot.getSlotIndex(), v);
    }

    Value extractValidValue(ref const Value value)
    {
        return _slot.getCPDriver().extractValidValue(_slot.getSlotIndex(), value);
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
        _latestNominations[st.nodeID] = cast(Envelope)env;
        _slot.recordStatement(env.statement);
    }

    void emitNomination()
    {
        Statement st;
        st.nodeID = _slot.getLocalNode().getNodeID();
        st.pledges.type.val = StatementType.CP_ST_NOMINATE;

        st.pledges.nominate.quorumSetHash = cast(Hash)_slot.getLocalNode().getQuorumSetHash();

        int i;
        foreach (ref Value v; _votes)
        {
            st.pledges.nominate.votes ~= v;
        }

        foreach (ref Value v; _accepted)
        {
            st.pledges.nominate.accepted ~= v;
        }

        Envelope envelope = _slot.createEnvelope(st);

        if (_slot.processEnvelope(envelope, true) == ConsensusProtocol.EnvelopeState.VALID)
        {
            if (!_enabledLastEnvelope || isNewerStatement(_lastEnvelope.statement.pledges.nominate, st.pledges.nominate))
            {
                _enabledLastEnvelope = true;
                _lastEnvelope = envelope;
                if (_slot.isFullyValidated())
                {
                    _slot.getCPDriver().emitEnvelope(envelope);
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
        _roundLeaders.clear();
        uint64 topPriority = 0;
        const QuorumSet myQSet = _slot.getLocalNode().getQuorumSet();

        LocalNode.forAllNodes(myQSet, (ref const NodeID cur) {
            uint64 w = getNodePriority(cur, myQSet);
            if (w > topPriority)
            {
                topPriority = w;
                _roundLeaders.clear();
            }
            if (w == topPriority && w > 0)
            {
                _roundLeaders.insert(cur);
            }
        });

        writefln("[DEBUG], ConsensusProtocol updateRoundLeaders: %d", _roundLeaders.length);
        foreach (ref const NodeID n; _roundLeaders)
        {
            writefln("[DEBUG], ConsensusProtocol leader: %s", _slot.getCPDriver().toShortString(n.publicKey));
        }

        /*
        CLOG(DEBUG, "CP") << "updateRoundLeaders: " << mRoundLeaders.size();
        if (Logging::logDebug("CP"))
            for (auto const& rl : mRoundLeaders)
            {
                CLOG(DEBUG, "CP") << "    leader "
                    << mSlot.getCPDriver().toShortString(rl);
            }
        */
    }

    // computes Gi(isPriority?P:N, prevValue, mRoundNumber, nodeID)
    // from the paper
    uint64 hashNode(bool isPriority, ref const NodeID nodeID)
    {
        dbgAssert(_previousValue.value.length != 0);
        return _slot.getCPDriver().computeHashNode(_slot.getSlotIndex(), _previousValue, isPriority, _roundNumber, nodeID);
    }

    // computes Gi(K, prevValue, mRoundNumber, value)
    uint64 hashValue(ref const Value value)
    {
        dbgAssert(_previousValue.value.length != 0);
        return _slot.getCPDriver().computeValueHash(_slot.getSlotIndex(), _previousValue, _roundNumber, value);
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
                if (find(_votes[], valueToNominate).empty)
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
