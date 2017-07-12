module owlchain.consensus.slot;

import std.stdio;
import std.conv;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.envelope;
import owlchain.xdr.value;
import owlchain.xdr.quorumSet;
import owlchain.xdr.nodeID;
import owlchain.xdr.ballot;
import owlchain.xdr.statement;
import owlchain.xdr.statementType;

import owlchain.consensus.consensusProtocol;
import owlchain.consensus.consensusProtocolDriver;
import owlchain.consensus.localNode;
import owlchain.consensus.ballotProtocol;
import owlchain.consensus.nominationProtocol;

import owlchain.xdr.statement;

import std.json;

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
    bool [Statement] _statementsHistory;

    // true if the Slot was fully validated
    bool _fullyValidated;

public:
    this(uint64 slotIndex, ConsensusProtocol cp)
    {
        _slotIndex = slotIndex;
        _consensusProtocol = cp;

        _ballotProtocol = new BallotProtocol(this);
        _nominationProtocol = new NominationProtocol(this);

        _fullyValidated = _consensusProtocol.localNode.isValidator;
    }

    @property uint64 slotIndex()
    {
        return _slotIndex;
    }

    @property ConsensusProtocol consensusProtocol()
    {
        return _consensusProtocol;
    }

    @property ConsensusProtocolDriver driver()
    {
        return _consensusProtocol.driver;
    }

    @property BallotProtocol ballotProtocol()
    {
        return _ballotProtocol;
    }

    Value getLatestCompositeCandidate()
    {
        //return _nominationProtocol.getLatestCompositeCandidate();

        Value v;
        return v;
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

            e = _ballotProtocol.getLastMessageSend();
            if (e)
            {
                res ~= *e;
            }
        }
        return res;
    }

    // forces the state to match the one in the envelope
    // this is used when rebuilding the state after a crash for example
    void setStateFromEnvelope(ref const Envelope e)
    {
        if (e.statement.nodeID == _consensusProtocol.localNodeID && e.statement.slotIndex == _slotIndex)
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
        _statementsHistory[cast(Statement)st] = _fullyValidated;
    }

    // Process a newly received envelope for this slot and update the state of the slot accordingly.
    // self: set to true when node wants to record its own messages (potentially triggering more transitions)
    ConsensusProtocol.EnvelopeState 
    processEnvelope(ref const Envelope envelope, bool self)
    {
        assert(envelope.statement.slotIndex == _slotIndex);

        writefln("[%s], %s, %s %d %s", "DEBUG", "ConsensusProtocol", "Slot.processEnvelope", _slotIndex, _consensusProtocol.envToStr(envelope));

        ConsensusProtocol.EnvelopeState res;
        try
        {
            if (envelope.statement.pledges.type.val == StatementType.CP_ST_NOMINATE)
            {
                //res = _nominationProtocol.processEnvelope(envelope);
            }
            else
            {
                //res = _ballotProtocol.processEnvelope(envelope, self);
            }
        }
        catch (Exception e)
        {
            JSONValue info;
            dumpInfo(info);
            writefln("[%s], %s, %s", "DEBUG", "ConsensusProtocol", "Exception in processEnvelope");

            //throw;
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
        //foreach (Statement e; _statementsHistory)
        //{
        //    ref auto n = m[e.nodeID];
        //    n ~= (&e);
        //}
        return ConsensusProtocol.TriBool.TB_TRUE;
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
        // incomplete

    }

    // returns information about the quorum for a given node
    void dumpQuorumInfo(ref JSONValue ret, ref const NodeID id, bool summary)
    {
        // incomplete
        string i = to!string(cast(uint32)(_slotIndex), 10);
        //_ballotProtocol.dumpQuorumInfo(ret[i], id, summary);
    }

    // returns the hash of the QuorumSet that should be downloaded
    // with the statement.
    // note: the companion hash for an EXTERNALIZE statement does
    // not match the hash of the QSet, but the hash of commitQuorumSetHash
    static Hash getCompanionQuorumSetHashFromStatement(ref const Statement st)
    {
        // incomplete
        return Hash();
    }

    // returns the values associated with the statement
    static Value[] getStatementValues(ref const Statement st)
    {
        // incomplete
        Value[] res;
        return res;
    }

    // returns the QuorumSet that should be used for a node given the
    // statement (singleton for externalize)
    QuorumSet getQuorumSetFromStatement(ref const Statement st)
    {
        // incomplete
        return QuorumSet();
    }

    // wraps a statement in an envelope (sign it, etc)
    Envelope createEnvelope(ref const Statement statement)
    {
        Envelope envelope;

        envelope.statement = cast(Statement)statement;
        auto mySt = envelope.statement;
        mySt.nodeID = consensusProtocol.localNodeID;
        mySt.slotIndex = slotIndex;

        consensusProtocol.driver.signEnvelope(envelope);

        return envelope;
    }

    // ** federated agreement helper functions

    // returns true if the statement defined by voted and accepted
    // should be accepted
    bool federatedAccept(ref const StatementPredicate voted, ref const StatementPredicate accepted, ref const Envelope [NodeID] envs)
    {
        // incomplete
        return false;
    }

    // returns true if the statement defined by voted
    // is ratified
    bool federatedRatify(ref const StatementPredicate voted, ref const Envelope [NodeID] envs)
    {
        // incomplete
        return false;
    }

    LocalNode getLocalNode()
    {
        // incomplete
        return null;
    }

    enum timerIDs
    {
        NOMINATION_TIMER = 0,
        BALLOT_PROTOCOL_TIMER = 1
    };

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