module owlchain.consensus.tests.cpTests;

import std.stdio;
import std.conv;
import std.typecons;
import std.digest.sha;
import std.algorithm : canFind;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.envelope;
import owlchain.xdr.value;
import owlchain.xdr.publicKey;
import owlchain.xdr.nodeID;
import owlchain.xdr.quorumSet;
import owlchain.xdr.ballot;
import owlchain.xdr.statement;
import owlchain.xdr.statementType;

import owlchain.crypto.keyUtils;

import owlchain.consensus.consensusProtocol;
import owlchain.consensus.consensusProtocolDriver;
import owlchain.consensus.slot;
import owlchain.consensus.localNode;

import owlchain.xdr.xdrDataOutputStream;

import owlchain.utils.globalChecks;

alias PriorityLookupDelegate = uint64 delegate(ref const NodeID);
alias HashCalculatorDelegate = uint64 delegate(ref const Value);

class TestCP : ConsensusProtocolDriver
{
public:
    ConsensusProtocol _CP;

    PriorityLookupDelegate _priorityLookup;
    HashCalculatorDelegate _hashValueCalculator;

    QuorumSetPtr[Hash] _quorumSets;
    Envelope[] _envs;
    Value[uint64] _externalizedValues;
    Ballot[][uint64] _heardFromQuorums;

    ValueSet _expectedCandidates;
    Value _compositeValue;

    this(SecretKey secretKey, ref QuorumSet qSetLocal, bool isValidator = true)
    {
        _CP = new ConsensusProtocol(this, secretKey, isValidator, qSetLocal);

        _priorityLookup = (ref const NodeID n) {
            return (n.publicKey == secretKey.getPublicKey()) ? 1000 : 1;
        };

        _hashValueCalculator = (ref const Value v)
        {
            return 0;
        };

        auto localQSet = refCounted(cast(QuorumSet)_CP.getLocalQuorumSet());
        storeQuorumSet(localQSet);
    }

    override void
    signEnvelope(ref Envelope)
    {

    }

    override bool
    verifyEnvelope(ref const Envelope envelope)
    {
        return true;
    }

    void
    storeQuorumSet(QuorumSetPtr qSet)
    {
        XdrDataOutputStream stream = new XdrDataOutputStream();
        QuorumSet.encode(stream, cast(QuorumSet)qSet);
        Hash qSetHash;
        qSetHash.hash = sha256Of(stream.data);
        _quorumSets[qSetHash] = qSet;
    }

    override ConsensusProtocolDriver.ValidationLevel
    validateValue(uint64 slotIndex, ref const Value value) 
    {
        return ConsensusProtocolDriver.ValidationLevel.kFullyValidatedValue;
    }

    override void
    ballotDidHearFromQuorum(uint64 slotIndex, ref const Ballot ballot) 
    {
        if (!_heardFromQuorums.keys.canFind(slotIndex))
        {
            Ballot[] v;
            v ~= cast(Ballot)(ballot);
            _heardFromQuorums[slotIndex] = v;
        } else
        {
            _heardFromQuorums[slotIndex] ~= cast(Ballot)(ballot);
        }
    }

    override void
    valueExternalized(uint64 slotIndex, ref const Value value) 
    {
        if (_externalizedValues.keys.canFind(slotIndex))
        {
            throw new Exception("Value already externalized");
        }
        _externalizedValues[slotIndex] = cast(Value)value;
    }

    override QuorumSetPtr
    getQSet(ref const Hash qSetHash) 
    {
        if (_quorumSets.keys.canFind(qSetHash))
        {
            return _quorumSets[cast(Hash)qSetHash];
        }
        RefCounted!(QuorumSet, RefCountedAutoInitialize.no) qSet; 
        return qSet;
    }

    override void
    emitEnvelope(ref const Envelope envelope) 
    {
        _envs ~= cast(Envelope)envelope;
    }

    // used to test BallotProtocol and bypass nomination
    bool
    bumpState(uint64 slotIndex, ref const Value v)
    {
        return _CP.getSlot(slotIndex, true).bumpState(v, true);
    }

    bool
    nominate(uint64 slotIndex, ref const Value value, bool timedout)
    {
        return _CP.getSlot(slotIndex, true).nominate(value, value, timedout);
    }

    // only used by nomination protocol
    override Value
    combineCandidates(uint64 slotIndex, ref const ValueSet candidates) 
    {
        if (!(candidates == _expectedCandidates)) 
        {
            writefln("REQUIRE : candidates != _expectedCandidates");
        }
        if (!(_compositeValue.value.length != 0))
        {
            writefln("REQUIRE : _compositeValue empty");
        }

        return _compositeValue;
    }

    // override the internal hashing scheme in order to make tests
    // more predictable.
    override uint64
    computeHashNode(uint64 slotIndex, ref const Value prev, bool isPriority, int roundNumber, ref const NodeID nodeID) 
    {
        uint64 res;
        if (isPriority)
        {
            res = _priorityLookup(nodeID);
        }
        else
        {
            res = 0;
        }
        return res;
    }

    // override the value hashing, to make tests more predictable.
    override uint64
    computeValueHash(uint64 slotIndex, ref const Value prev, int roundNumber, ref const Value value)
    {
        return _hashValueCalculator(value);
    }

    override void
    setupTimer(uint64 slotIndex, int timerID, long timeout, void delegate() cb) 
    {
    }

    ref const(Value) 
    getLatestCompositeCandidate(uint64 slotIndex)
    {
        return _CP.getSlot(slotIndex, true).getLatestCompositeCandidate();
    }

    void
    receiveEnvelope(ref const Envelope envelope)
    {
        _CP.receiveEnvelope(envelope);
    }

    Slot
    getSlot(uint64 index)
    {
        return _CP.getSlot(index, false);
    }

    Envelope []
    getEntireState(uint64 index)
    {
        auto v = _CP.getSlot(index, false).getEntireCurrentState();
        return v;
    }

    Envelope
    getCurrentEnvelope(uint64 index, ref const NodeID id)
    {
        Envelope [] envelopes = getEntireState(index);
        for (int idx = 0; idx < envelopes.length; idx++)
        {
            if (envelopes[idx].statement.nodeID == id) return envelopes[idx];
        }
        throw new Exception("not found");
    }
}

static Envelope
makeEnvelope(ref const SecretKey secretKey, uint64 slotIndex,
             ref const Statement statement)
{
    Envelope envelope;
    envelope.statement = cast(Statement)statement;
    envelope.statement.nodeID = NodeID(secretKey.getPublicKey());
    envelope.statement.slotIndex = slotIndex;

    XdrDataOutputStream stream = new XdrDataOutputStream();
    Statement.encode(stream, cast(Statement)envelope.statement);

    envelope.signature = secretKey.sign(stream.data);

    return envelope;
}

static Envelope
makeExternalize(ref const SecretKey secretKey, ref const Hash qSetHash,
                uint64 slotIndex, ref const Ballot commitBallot, uint32 nH)
{
    Statement st;
    st.pledges.type.val = StatementType.CP_ST_EXTERNALIZE;
    auto ext = &st.pledges.externalize;
    ext.commit = cast(Ballot)commitBallot;
    ext.nH = nH;
    ext.commitQuorumSetHash = cast(Hash)qSetHash;

    return makeEnvelope(secretKey, slotIndex, st);
}

static Envelope
makeConfirm(ref const SecretKey secretKey, ref const Hash qSetHash, uint64 slotIndex,
            uint32 prepareCounter, ref const Ballot b, uint32 nC, uint32 nH)
{
    Statement st;
    st.pledges.type.val = StatementType.CP_ST_CONFIRM;
    auto con = &st.pledges.confirm;
    con.ballot = cast(Ballot)b;
    con.nPrepared = prepareCounter;
    con.nCommit = nC;
    con.nH = nH;
    con.quorumSetHash = cast(Hash)qSetHash;

    return makeEnvelope(secretKey, slotIndex, st);
}

static Envelope
makePrepare(ref const SecretKey secretKey, ref const Hash qSetHash, uint64 slotIndex,
            ref const Ballot  ballot, Ballot* prepared = null,
            uint32 nC = 0, uint32 nH = 0, Ballot* preparedPrime = null)
{
    Statement st;
    st.pledges.type.val = StatementType.CP_ST_PREPARE;
    auto p = &st.pledges.prepare;
    p.ballot = cast(Ballot)ballot;
    p.quorumSetHash = cast(Hash)qSetHash;
    if (prepared)
    {
        p.prepared = *prepared;
    }

    p.nC = nC;
    p.nH = nH;

    if (preparedPrime)
    {
        p.preparedPrime = *preparedPrime;
    }

    return makeEnvelope(secretKey, slotIndex, st);
}

static Envelope
makeNominate(ref const SecretKey secretKey, ref const Hash qSetHash, uint64 slotIndex,
             Value[] votes, Value[] accepted)
{
    import std.algorithm;

    alias comp = (x, y) => x.value < y.value;
    votes.sort!(comp).release;
    accepted.sort!(comp).release;

    Statement st;
    st.pledges.type.val = StatementType.CP_ST_NOMINATE;
    auto nom = &st.pledges.nominate;
    nom.quorumSetHash =cast(Hash) qSetHash;

    int idx;
    for (idx = 0; idx < votes.length; idx++)
    {
        nom.votes ~= (votes[idx]);
    }
    for (idx = 0; idx < accepted.length; idx++)
    {
        nom.accepted ~= (accepted[idx]);
    }
    return makeEnvelope(secretKey, slotIndex, st);
}

void
verifyPrepare(ref const Envelope actual, ref const SecretKey secretKey,
              ref const Hash qSetHash, uint64 slotIndex, ref const Ballot  ballot,
              Ballot* prepared = null, uint32 nC = 0, uint32 nH = 0,
              Ballot* preparedPrime = null)
{
    auto exp = makePrepare(secretKey, qSetHash, slotIndex, ballot, prepared, nC,
                           nH, preparedPrime);
    REQUIRE(exp.statement == actual.statement);
}

void
verifyConfirm(ref const Envelope actual, ref const SecretKey secretKey,
              ref const Hash qSetHash, uint64 slotIndex, uint32 nPrepared,
              ref const Ballot  b, uint32 nC, uint32 nH)
{
    auto exp =
        makeConfirm(secretKey, qSetHash, slotIndex, nPrepared, b, nC, nH);
    REQUIRE(exp.statement == actual.statement);
}

void
verifyExternalize(ref const Envelope actual, ref const SecretKey secretKey,
                  ref const Hash qSetHash, uint64 slotIndex,
                  ref const Ballot  commit, uint32 nH)
{
    auto exp = makeExternalize(secretKey, qSetHash, slotIndex, commit, nH);
    REQUIRE(exp.statement == actual.statement);
}

void
verifyNominate(ref const Envelope actual, ref const SecretKey secretKey,
               ref const Hash qSetHash, uint64 slotIndex, Value[] votes,
               Value[] accepted)
{
    auto exp = makeNominate(secretKey, qSetHash, slotIndex, votes, accepted);
    REQUIRE(exp.statement == actual.statement);
}

class ConsensusProtocolTest
{
private:

    Hash [int] valueHash;
    Value [int] value;

    Hash [int] hash;
    SecretKey [int] secretKey;
    PublicKey [int] key;
    NodeID [int] nodeID;

    void CREATE_VALUE(int i)
    {
        Hash h;
        h.hash = sha256Of("SEED_VALUE_HASH_" ~  to!string(i, 10));
        valueHash[i] = h;

        Value v;
        XdrDataOutputStream stream = new XdrDataOutputStream();
        Hash.encode(stream, cast(Hash)h);
        v.value = stream.data;
        value[i] = v;
    }

    void SIMULATION_CREATE_NODE(int i)
    {
        uint256 seed = sha256Of("NODE_SEED_" ~  to!string(i, 10));
        secretKey[i] = SecretKey.fromSeed(seed);
        key[i] = secretKey[i].getPublicKey();
        nodeID[i] = NodeID(key[i]);
    }

public :
    this()
    {

    }

    void prepare()
    {
        for (int i = 0; i <= 3; i++)
        {
            CREATE_VALUE(i);
        }
    }

    void test1()
    {
        TEST_CASE("vblocking and quorum", "[scp]");
        {
            SIMULATION_CREATE_NODE(0);
            SIMULATION_CREATE_NODE(1);
            SIMULATION_CREATE_NODE(2);
            SIMULATION_CREATE_NODE(3);

            //  number of validator is 4
            //  threshold is 3
            QuorumSet qSet;
            qSet.threshold = 3;
            qSet.validators ~= nodeID[0].publicKey;
            qSet.validators ~= nodeID[1].publicKey;
            qSet.validators ~= nodeID[2].publicKey;
            qSet.validators ~= nodeID[3].publicKey;

            NodeID[] nodeSet;
            nodeSet ~= (nodeID[0]);

            //  nodeSet size is 1
            REQUIRE(LocalNode.isQuorumSlice(qSet, nodeSet) == false);
            REQUIRE(LocalNode.isVBlocking(qSet, nodeSet) == false);

            nodeSet ~= (nodeID[2]);

            //  nodeSet size is 2
            REQUIRE(LocalNode.isQuorumSlice(qSet, nodeSet) == false);
            REQUIRE(LocalNode.isVBlocking(qSet, nodeSet) == true);

            nodeSet ~= (nodeID[3]);

            //  nodeSet size is 3
            REQUIRE(LocalNode.isQuorumSlice(qSet, nodeSet) == true);
            REQUIRE(LocalNode.isVBlocking(qSet, nodeSet) == true);

            nodeSet ~= (nodeID[1]);

            //  nodeSet size is 4
            REQUIRE(LocalNode.isQuorumSlice(qSet, nodeSet) == true);
            REQUIRE(LocalNode.isVBlocking(qSet, nodeSet) == true);
        }

        TEST_CASE("v-blocking distance", "[scp]");
        {
            SIMULATION_CREATE_NODE(0);
            SIMULATION_CREATE_NODE(1);
            SIMULATION_CREATE_NODE(2);
            SIMULATION_CREATE_NODE(3);
            SIMULATION_CREATE_NODE(4);
            SIMULATION_CREATE_NODE(5);
            SIMULATION_CREATE_NODE(6);
            SIMULATION_CREATE_NODE(7);

            QuorumSet qSet;
            qSet.threshold = 2;
            qSet.validators ~= (nodeID[0].publicKey);
            qSet.validators ~= (nodeID[1].publicKey);
            qSet.validators ~= (nodeID[2].publicKey);

            auto check = (ref const QuorumSet qSetCheck, ref const NodeIDSet s, int expected) 
            {
                auto r = LocalNode.findClosestVBlocking(qSetCheck, s, null);
                REQUIRE(expected == r.length);
            };

            NodeIDSet good = new NodeIDSet;

            good.insert(nodeID[0]); //1 + V - T = 4 - 2 = 2;
            // already v-blocking
            check(qSet, good, 0);

            good.insert(nodeID[1]);
            // either v0 or v1
            check(qSet, good, 1);

            good.insert(nodeID[2]);
            // any 2 of v0..v2
            check(qSet, good, 2);

            QuorumSet qSubSet1;
            qSubSet1.threshold = 1;
            qSubSet1.validators ~= (nodeID[3].publicKey);
            qSubSet1.validators ~= (nodeID[4].publicKey);
            qSubSet1.validators ~= (nodeID[5].publicKey);
            qSet.innerSets ~= (qSubSet1);

            good.insert(nodeID[3]);
            // any 3 of v0..v3
            check(qSet, good, 3);

            good.insert(nodeID[4]);
            // v0..v2
            check(qSet, good, 3);

            qSet.threshold = 1;  //1 + V - T = 1 + 4 - 1 = 4;
            // v0..v4
            check(qSet, good, 5);

            good.insert(nodeID[5]);
            // v0..v5
            check(qSet, good, 6);

            QuorumSet qSubSet2;
            qSubSet2.threshold = 2;
            qSubSet2.validators ~= (nodeID[6].publicKey);
            qSubSet2.validators ~= (nodeID[7].publicKey);

            qSet.innerSets ~= (qSubSet2);
            // v0..v5
            check(qSet, good, 6);

            good.insert(nodeID[6]);
            // v0..v5
            check(qSet, good, 6);

            good.insert(nodeID[7]);
            // v0..v5 and one of 6,7
            check(qSet, good, 7);

            qSet.threshold = 4;
            // v6, v7
            check(qSet, good, 2);

            qSet.threshold = 3;
            // v0..v2
            check(qSet, good, 3);

            qSet.threshold = 2;
            // v0..v2 and one of v6,v7
            check(qSet, good, 4);
        }
    }
    
    alias genEnvelope = Envelope delegate (ref const SecretKey sk);

    static genEnvelope
        makePrepareGen(ref const Hash qSetHash, ref const Ballot ballot,
                       Ballot* prepared = null, uint32 nC = 0, uint32 nH = 0,
                       Ballot* preparedPrime = null)
    {
        return delegate(ref const SecretKey sk) {
            return makePrepare(sk, qSetHash, 0, ballot, prepared, nC, nH, preparedPrime);
        };
    }

    static genEnvelope
        makeConfirmGen(ref const Hash qSetHash, uint32 prepareCounter, ref const Ballot b, uint32 nC, uint32 nH)
    {
        return delegate(ref const SecretKey sk) {
            return makeConfirm(sk, qSetHash, 0, prepareCounter, b, nC, nH);
        };
    }

    static genEnvelope
        makeExternalizeGen(ref const Hash qSetHash, ref const Ballot commitBallot, uint32 nH)
    {
        return delegate(ref const SecretKey sk) {
            return makeExternalize(sk, qSetHash, 0, commitBallot, nH);
        };
    }

    void test2()
    {
        TEST_CASE("ballot protocol core5", "[scp][ballotprotocol]");
        {
            SIMULATION_CREATE_NODE(0);
            SIMULATION_CREATE_NODE(1);
            SIMULATION_CREATE_NODE(2);
            SIMULATION_CREATE_NODE(3);
            SIMULATION_CREATE_NODE(4);

            // we need 5 nodes to avoid sharing various thresholds:
            // v-blocking set size: 2 = 1 + 5 - 4 = 2;  
            // threshold: 4 = 3 + self or 4 others ; 1 + 5 - 2 = 4
            QuorumSet qSet;
            qSet.threshold = 4;
            qSet.validators ~= (nodeID[0].publicKey);
            qSet.validators ~= (nodeID[1].publicKey);
            qSet.validators ~= (nodeID[2].publicKey);
            qSet.validators ~= (nodeID[3].publicKey);
            qSet.validators ~= (nodeID[4].publicKey);

            uint256 qSetHash = sha256Of(xdr!QuorumSet.serialize(qSet));
            TestCP cp = new TestCP(secretKey[0], qSet);
            cp.storeQuorumSet(refCounted(qSet));
            uint256 qSetHash0 = cp._CP.getLocalNode().getQuorumSetHash().hash;

            REQUIRE(value[0].value < value[1].value);

            writefln("[INFO], ConsensusProtocol");
            writefln("[INFO], ConsensusProtocol BEGIN TEST");

            auto recvVBlockingChecks = (genEnvelope gen, bool withChecks) 
            {
                Envelope e1 = gen(secretKey[0]);
                Envelope e2 = gen(secretKey[1]);

                // nothing should happen with first message
                size_t i = cp._envs.length;
                cp.receiveEnvelope(e1);
                if (withChecks)
                {
                    REQUIRE(cp._envs.length == i);
                }
                i++;
                cp.receiveEnvelope(e2);
                if (withChecks)
                {
                    REQUIRE(cp._envs.length == i);
                }
            };

            auto recvVBlocking = (genEnvelope gen)
            {
                recvVBlockingChecks(gen, true);
            };

            auto recvQuorumChecks = (genEnvelope gen, bool withChecks, bool delayedQuorum) 
            {

            };
        }
    }

    void test()
    {
        test1();
        test2();
    }
}
