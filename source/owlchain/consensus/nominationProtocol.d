module owlchain.consensus.nominationProtocol;

import std.container;
import std.json;
import std.algorithm: canFind;
import std.algorithm: find;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.envelope;
import owlchain.xdr.value;
import owlchain.xdr.quorumSet;
import owlchain.xdr.nodeID;
import owlchain.xdr.ballot;
import owlchain.xdr.nomination;
import owlchain.xdr.statement;

import owlchain.consensus.slot;
import owlchain.consensus.consensusProtocol;
import owlchain.consensus.consensusProtocolDriver;

class NominationProtocol
{
private :
    Slot _slot;
    int32 _roundNumber;
    Value[] _votes;                           // X
    Value[] _accepted;                        // Y
    Value[] _candidates;                      // Z
    Envelope[NodeID] _latestNominations;      // N

    // last envelope emitted by this node
    Array!(Envelope *) _lastEnvelope; 

    // nodes from quorum set that have the highest priority this round
    NodeID[] _roundLeaders;

    // true if 'nominate' was called
    bool _nominationStarted;

    // the latest (if any) candidate value
    Value _latestCompositeCandidate;

    // the value from the previous slot
    Value _previousValue;

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
            //---------------------------------- 
            // incomplete
            //---------------------------------- 
            //res = std::includes(v.begin(), v.end(), p.begin(), p.end());
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
        return _slot.driver.validateValue(_slot.slotIndex, v);
    }

    Value extractValidValue(ref const Value value)
    {
        return _slot.driver.extractValidValue(_slot.slotIndex, value);
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
        auto nom = st.pledges.nominate;
        bool res = (nom.votes.length + nom.accepted.length) != 0;

        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        //res = res && std::is_sorted(nom.votes.begin(), nom.votes.end());
        //res = res && std::is_sorted(nom.accepted.begin(), nom.accepted.end());

        return res;
    }

    void recordEnvelope(ref const Envelope env)
    {
        auto st = env.statement;
        _latestNominations[st.nodeID] = cast(Envelope)env;
        _slot.recordStatement(env.statement);
    }

    void emitNomination()
    {

        //---------------------------------- 
        // incomplete
        //---------------------------------- 

    }

    // returns true if v is in the accepted list from the statement
    static bool acceptPredicate(ref const Value v, ref const Statement st)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        return false;
    }

    // applies 'processor' to all values from the passed in nomination
    static void applyAll(ref const Nomination nom, void function(ref const Value) processor)
    {

        //---------------------------------- 
        // incomplete
        //---------------------------------- 
    }

    // updates the set of nodes that have priority over the others
    void updateRoundLeaders()
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 

    }

    // computes Gi(isPriority?P:N, prevValue, mRoundNumber, nodeID)
    // from the paper
    uint64 hashNode(bool isPriority, ref const NodeID nodeID)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        return 0;
    }

    // computes Gi(K, prevValue, mRoundNumber, value)
    uint64 hashValue(ref Value value)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        return 0;
    }

    uint64 getNodePriority(ref const NodeID nodeID, ref const QuorumSet qset)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        return 0;
    }

    // returns the highest value that we don't have yet, that we should
    // vote for, extracted from a nomination.
    // returns the empty value if no new value was found
    Value getNewValueFromNomination(ref const Nomination nom)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        Value value;
        return value;
    }

public :
    this(Slot slot)
    {
        _slot = slot;
    }

    ConsensusProtocol.EnvelopeState processEnvelope(ref const Envelope envelope)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        return ConsensusProtocol.EnvelopeState.INVALID;
    }

    static Value[] getStatementValues(ref const Statement st)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        Value [] res;
        return res;
    }

    // attempts to nominate a value for consensus
    bool nominate(ref const Value value, ref const Value previousValue, bool timedout)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        return false;
    }

    // stops the nomination protocol
    void stopNomination()
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
    }

    ref Value getLatestCompositeCandidate()
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        return _latestCompositeCandidate;
    }

    void dumpInfo(ref JSONValue ret)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 

    }

    Envelope * getLastMessageSend()
    {
        Envelope * e;
        if (_lastEnvelope.length > 0)
        {
            e = _lastEnvelope.front;
            _lastEnvelope.linearRemove(_lastEnvelope[0..0]);
            return e;
        }
        else
        {
            return null;
        }
    }

    void setStateFromEnvelope(ref const Envelope envelope)
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
    }

    Envelope[] getCurrentState()
    {
        //---------------------------------- 
        // incomplete
        //---------------------------------- 
        Envelope[] res;
        return res;
    }

}
