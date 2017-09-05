module owlchain.consensus.tests.bcpTests;

import core.time;

import std.stdio;
import std.conv;
import std.typecons;
import std.digest.sha;
import std.algorithm : canFind;

import owlchain.xdr;
import owlchain.crypto.keyUtils;

import owlchain.consensus.bcp;
import owlchain.consensus.bcpDriver;
import owlchain.consensus.slot;
import owlchain.consensus.localNode;

import owlchain.xdr.xdrDataOutputStream;

import owlchain.utils.globalChecks;

import core.stdc.stdint;

alias PriorityLookupDelegate = uint64 delegate(ref const NodeID);
alias HashCalculatorDelegate = uint64 delegate(ref const Value);
alias BallotArray = BCPBallot[];
class TestCP : BCPDriver
{
public:
    BCP mBCP;

    PriorityLookupDelegate mPriorityLookup;
    HashCalculatorDelegate mHashValueCalculator;

    BCPQuorumSet[Hash] mQuorumSets;
    BCPEnvelope[] mEnvs;
    Value[uint64] mExternalizedValues;
    BallotArray[uint64] mHeardFromQuorums;

    ValueSet mExpectedCandidates;
    Value mCompositeValue;

    this(SecretKey secretKey, ref BCPQuorumSet qSetLocal, bool isValidator = true)
    {
        mBCP = new BCP(this, secretKey, isValidator, qSetLocal);

        mPriorityLookup = (ref const NodeID n) {
            return (n == secretKey.getPublicKey()) ? 1000 : 1;
        };

        mHashValueCalculator = (ref const Value v) { return 0; };

        auto localQSet = mBCP.getLocalQuorumSet();
        storeQuorumSet(cast(BCPQuorumSet) localQSet);

        BCPBallot[] v;
        mHeardFromQuorums[0] = v;
        mExpectedCandidates = new ValueSet;
    }

    override void signEnvelope(ref BCPEnvelope)
    {

    }

    override bool verifyEnvelope(ref BCPEnvelope envelope)
    {
        return true;
    }

    void storeQuorumSet(BCPQuorumSet qSet)
    {
        Hash mQSetHash = Hash(sha256Of(xdr!BCPQuorumSet.serialize(qSet)));
        mQuorumSets[mQSetHash] = qSet;
    }

    override BCPDriver.ValidationLevel validateValue(uint64 slotIndex, ref Value value)
    {
        return BCPDriver.ValidationLevel.kFullyValidatedValue;
    }

    override void ballotDidHearFromQuorum(uint64 slotIndex, ref BCPBallot ballot)
    {
        auto p = (slotIndex in mHeardFromQuorums);
        if (p is null)
        {
            BCPBallot[] v;
            v ~= ballot;
            mHeardFromQuorums[slotIndex] = v;
        }
        else
        {
            mHeardFromQuorums[slotIndex] ~= ballot;
        }
    }

    override void valueExternalized(uint64 slotIndex, ref Value value)
    {
        auto p = (slotIndex in mExternalizedValues);
        if (p !is null)
        {
            throw new Exception("Value already externalized");
        }
        mExternalizedValues[slotIndex] = value;
    }

    override BCPQuorumSetPtr getQSet(ref Hash mQSetHash)
    {
        auto p = (mQSetHash in mQuorumSets);
        if (p !is null)
        {
            return refCounted(mQuorumSets[mQSetHash]);
        }
        RefCounted!(BCPQuorumSet, RefCountedAutoInitialize.no) qSet;
        return qSet;
    }

    override void emitEnvelope(ref BCPEnvelope envelope)
    {
        mEnvs ~= envelope;
    }

    // used to test BallotProtocol and bypass nomination
    bool bumpState(uint64 slotIndex, ref Value v)
    {
        return mBCP.getSlot(slotIndex, true).bumpState(v, true);
    }

    bool nominate(uint64 slotIndex, ref Value value, bool timedout)
    {
        return mBCP.getSlot(slotIndex, true).nominate(value, value, timedout);
    }

    // only used by nomination protocol
    override Value combineCandidates(uint64 slotIndex, ref ValueSet candidates)
    {
        if (!(candidates == mExpectedCandidates))
        {
            writefln("REQUIRE : candidates != mExpectedCandidates");
        }
        if (!(mCompositeValue.value.length != 0))
        {
            writefln("REQUIRE : mCompositeValue empty");
        }

        return mCompositeValue;
    }

    // override the internal hashing scheme in order to make tests
    // more predictable.
    override uint64 computeHashNode(uint64 slotIndex, ref Value prev,
            bool isPriority, int roundNumber, ref NodeID nodeID)
    {
        uint64 res;
        if (isPriority)
        {
            res = mPriorityLookup(nodeID);
        }
        else
        {
            res = 0;
        }
        return res;
    }

    // override the value hashing, to make tests more predictable.
    override uint64 computeValueHash(uint64 slotIndex, ref Value prev,
            int roundNumber, ref Value value)
    {
        return mHashValueCalculator(value);
    }

    override void setupTimer(uint64 slotIndex, int timerID, Duration timeout, void delegate() cb)
    {
    }

    ref const(Value) getLatestCompositeCandidate(uint64 slotIndex)
    {
        return mBCP.getSlot(slotIndex, true).getLatestCompositeCandidate();
    }

    void receiveEnvelope(ref BCPEnvelope envelope)
    {
        mBCP.receiveEnvelope(envelope);
    }

    Slot getSlot(uint64 index)
    {
        return mBCP.getSlot(index, false);
    }

    BCPEnvelope[] getEntireState(uint64 index)
    {
        auto v = mBCP.getSlot(index, false).getEntireCurrentState();
        return v;
    }

    BCPEnvelope getCurrentEnvelope(uint64 index, ref NodeID id)
    {
        BCPEnvelope[] envelopes = getEntireState(index);
        for (int idx = 0; idx < envelopes.length; idx++)
        {
            if (envelopes[idx].statement.nodeID == id)
                return envelopes[idx];
        }
        throw new Exception("not found");
    }

    override string getValueString(ref Value v)
    {
        Hash h;

        h = Hash(sha256Of("SEED_VALUE_HASH_0"));
        if (v.value == xdr!Hash.serialize(h))
        {
            return "x";
        }

        h = Hash(sha256Of("SEED_VALUE_HASH_1"));
        if (v.value == xdr!Hash.serialize(h))
        {
            return "y";
        }

        h = Hash(sha256Of("SEED_VALUE_HASH_2"));
        if (v.value == xdr!Hash.serialize(h))
        {
            return "z";
        }
        else
        {
            return "_";
        }
    }

    override string toShortString(ref PublicKey pk)
    {
        uint256 seed;
        SecretKey secretKey;
        PublicKey publickey;

        for (int idx = 0; idx < 10; idx++)
        {
            seed = sha256Of("NODE_SEED_" ~ to!string(idx, 10));
            secretKey = SecretKey.fromSeed(seed);
            publickey = secretKey.getPublicKey();

            if (publickey == pk)
            {
                return "N" ~ to!string(idx, 10);
            }
        }

        return "NN";
    }
}

static BCPEnvelope makeEnvelope(ref SecretKey secretKey, uint64 slotIndex, ref BCPStatement statement)
{
    BCPEnvelope envelope;
    envelope.statement = statement;
    envelope.statement.nodeID = secretKey.getPublicKey();
    envelope.statement.slotIndex = slotIndex;

    envelope.signature = secretKey.sign(xdr!BCPStatement.serialize(envelope.statement));

    return envelope;
}

static BCPEnvelope makeExternalize(ref SecretKey secretKey, ref Hash mQSetHash,
        uint64 slotIndex, ref BCPBallot commitBallot, uint32 nH)
{
    BCPStatement st;
    st.pledges.type = BCPStatementType.BCP_ST_EXTERNALIZE;
    auto ext = &st.pledges.externalize;
    ext.commit = commitBallot;
    ext.nH = nH;
    ext.commitQuorumSetHash = mQSetHash;

    return makeEnvelope(secretKey, slotIndex, st);
}

static BCPEnvelope makeConfirm(ref SecretKey secretKey, ref Hash mQSetHash,
        uint64 slotIndex, uint32 prepareCounter, ref BCPBallot b, uint32 nC, uint32 nH)
{
    BCPStatement st;
    st.pledges.type = BCPStatementType.BCP_ST_CONFIRM;
    auto con = &st.pledges.confirm;
    con.ballot = b;
    con.nPrepared = prepareCounter;
    con.nCommit = nC;
    con.nH = nH;
    con.quorumSetHash = mQSetHash;

    return makeEnvelope(secretKey, slotIndex, st);
}

static BCPEnvelope makePrepare(ref SecretKey secretKey, ref Hash mQSetHash, uint64 slotIndex,
        ref BCPBallot ballot, BCPBallot* prepared = null, uint32 nC = 0, uint32 nH = 0,
        BCPBallot* preparedPrime = null)
{
    BCPStatement st;
    st.pledges.type = BCPStatementType.BCP_ST_PREPARE;
    auto p = &st.pledges.prepare;
    p.ballot = ballot;
    p.quorumSetHash = mQSetHash;
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

static BCPEnvelope makeNominate(ref SecretKey secretKey, ref Hash mQSetHash,
        uint64 slotIndex, Value[] votes, Value[] accepted)
{
    import std.algorithm;

    alias comp = (x, y) => x.value < y.value;
    votes.sort!(comp).release;
    accepted.sort!(comp).release;

    BCPStatement st;
    st.pledges.type = BCPStatementType.BCP_ST_NOMINATE;
    auto nom = &st.pledges.nominate;
    nom.quorumSetHash = mQSetHash;

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

void verifyPrepare(ref BCPEnvelope actual, ref SecretKey secretKey, ref Hash mQSetHash,
        uint64 slotIndex, ref BCPBallot ballot, BCPBallot* prepared = null, uint32 nC = 0,
        uint32 nH = 0, BCPBallot* preparedPrime = null)
{
    auto exp = makePrepare(secretKey, mQSetHash, slotIndex, ballot, prepared,
            nC, nH, preparedPrime);
    REQUIRE(exp.statement == actual.statement);
}

void verifyConfirm(ref BCPEnvelope actual, ref SecretKey secretKey, ref Hash mQSetHash,
        uint64 slotIndex, uint32 nPrepared, ref BCPBallot b, uint32 nC, uint32 nH)
{
    auto exp = makeConfirm(secretKey, mQSetHash, slotIndex, nPrepared, b, nC, nH);
    REQUIRE(exp.statement == actual.statement);
}

void verifyExternalize(ref BCPEnvelope actual, ref SecretKey secretKey,
        ref Hash mQSetHash, uint64 slotIndex, ref BCPBallot commit, uint32 nH)
{
    auto exp = makeExternalize(secretKey, mQSetHash, slotIndex, commit, nH);
    REQUIRE(exp.statement == actual.statement);
}

void verifyNominate(ref BCPEnvelope actual, ref SecretKey secretKey, ref Hash mQSetHash,
        uint64 slotIndex, Value[] votes, Value[] accepted)
{
    auto exp = makeNominate(secretKey, mQSetHash, slotIndex, votes, accepted);
    REQUIRE(exp.statement == actual.statement);
}

class ConsensusProtocolTest
{
private:

    Hash[int] mValueHash;
    Value[int] mValue;

    Hash[int] mHash;
    SecretKey[int] mSecretKey;
    PublicKey[int] mKey;

    void CREATE_VALUE(int i)
    {
        Hash h;
        h = Hash(sha256Of("SEED_VALUE_HASH_" ~ to!string(i, 10)));
        mValueHash[i] = h;

        Value v;
        v.value = xdr!Hash.serialize(h);
        mValue[i] = v;
    }

    void SIMULATION_CREATE_NODE(int i)
    {
        uint256 seed = sha256Of("NODE_SEED_" ~ to!string(i, 10));
        mSecretKey[i] = SecretKey.fromSeed(seed);
        mKey[i] = mSecretKey[i].getPublicKey();
    }

public:
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

    alias genEnvelope = BCPEnvelope delegate(ref SecretKey sk);

    static genEnvelope makePrepareGen(ref Hash mQSetHash, ref BCPBallot ballot,
            BCPBallot* prepared = null, uint32 nC = 0, uint32 nH = 0, BCPBallot* preparedPrime = null)
    {
        return delegate(ref SecretKey sk) {
            return makePrepare(sk, mQSetHash, 0, ballot, prepared, nC, nH, preparedPrime);
        };
    }

    static genEnvelope makeConfirmGen(ref Hash mQSetHash, uint32 prepareCounter,
            ref BCPBallot b, uint32 nC, uint32 nH)
    {
        return delegate(ref SecretKey sk) {
            return makeConfirm(sk, mQSetHash, 0, prepareCounter, b, nC, nH);
        };
    }

    static genEnvelope makeExternalizeGen(ref Hash mQSetHash, ref BCPBallot commitBallot, uint32 nH)
    {
        return delegate(ref SecretKey sk) {
            return makeExternalize(sk, mQSetHash, 0, commitBallot, nH);
        };
    }

    BCPQuorumSet mQSet;
    Hash mQSetHash;
    Hash mQSetHash0;
    TestCP mBCP;

    void Init()
    {
        BCPQuorumSet qSet;
        qSet.threshold = 4;
        qSet.validators ~= (mKey[0]);
        qSet.validators ~= (mKey[1]);
        qSet.validators ~= (mKey[2]);
        qSet.validators ~= (mKey[3]);
        qSet.validators ~= (mKey[4]);

        mQSet = qSet;
        mQSetHash = Hash(sha256Of(xdr!BCPQuorumSet.serialize(mQSet)));

        mBCP = new TestCP(mSecretKey[0], mQSet);

        mQSetHash0 = cast(Hash) mBCP.mBCP.getLocalNode().getQuorumSetHash();

    }

    auto recvVBlockingChecks(genEnvelope gen, bool withChecks)
    {
        BCPEnvelope e1 = gen(mSecretKey[1]);
        BCPEnvelope e2 = gen(mSecretKey[2]);

        // nothing should happen with first message
        size_t i = mBCP.mEnvs.length;
        mBCP.receiveEnvelope(e1);
        if (withChecks)
        {
            REQUIRE(mBCP.mEnvs.length == i);
        }

        i++;
        mBCP.receiveEnvelope(e2);
        if (withChecks)
        {
            REQUIRE(mBCP.mEnvs.length == i);
        }
    };

    auto recvVBlocking(genEnvelope gen)
    {
        recvVBlockingChecks(gen, true);
    };

    auto recvQuorumChecks(genEnvelope gen, bool withChecks, bool delayedQuorum)
    {
        BCPEnvelope e1 = gen(mSecretKey[1]);
        BCPEnvelope e2 = gen(mSecretKey[2]);
        BCPEnvelope e3 = gen(mSecretKey[3]);
        BCPEnvelope e4 = gen(mSecretKey[4]);

        mBCP.receiveEnvelope(e1);
        mBCP.receiveEnvelope(e2);

        size_t i = mBCP.mEnvs.length + 1;

        mBCP.receiveEnvelope(e3);

        if (withChecks && !delayedQuorum)
        {
            REQUIRE(mBCP.mEnvs.length == i);
        }

        // nothing happens with an extra vote (unless we're in delayedQuorum)
        mBCP.receiveEnvelope(e4);
        if (withChecks && delayedQuorum)
        {
            REQUIRE(mBCP.mEnvs.length == i);
        }

    };

    auto recvQuorum(genEnvelope gen)
    {
        recvQuorumChecks(gen, true, false);
    };

    auto nodesAllPledgeToCommit()
    {
        BCPBallot b = BCPBallot(1, mValue[0]);
        BCPEnvelope prepare1 = makePrepare(mSecretKey[1], mQSetHash, 0, b);
        BCPEnvelope prepare2 = makePrepare(mSecretKey[2], mQSetHash, 0, b);
        BCPEnvelope prepare3 = makePrepare(mSecretKey[3], mQSetHash, 0, b);
        BCPEnvelope prepare4 = makePrepare(mSecretKey[4], mQSetHash, 0, b);

        REQUIRE(mBCP.bumpState(0, mValue[0]));
        REQUIRE(mBCP.mEnvs.length == 1);

        verifyPrepare(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, b);

        mBCP.receiveEnvelope(prepare1);
        REQUIRE(mBCP.mEnvs.length == 1);
        REQUIRE(mBCP.mHeardFromQuorums[0].length == 0);

        mBCP.receiveEnvelope(prepare2);
        REQUIRE(mBCP.mEnvs.length == 1);
        REQUIRE(mBCP.mHeardFromQuorums[0].length == 0);

        mBCP.receiveEnvelope(prepare3);
        REQUIRE(mBCP.mEnvs.length == 2);
        REQUIRE(mBCP.mHeardFromQuorums[0].length == 1);
        REQUIRE(mBCP.mHeardFromQuorums[0][0] == b);

        // We have a quorum including us
        verifyPrepare(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, b, &b);

        mBCP.receiveEnvelope(prepare4);
        REQUIRE(mBCP.mEnvs.length == 2);

        BCPEnvelope prepared1 = makePrepare(mSecretKey[1], mQSetHash, 0, b, &b);
        BCPEnvelope prepared2 = makePrepare(mSecretKey[2], mQSetHash, 0, b, &b);
        BCPEnvelope prepared3 = makePrepare(mSecretKey[3], mQSetHash, 0, b, &b);
        BCPEnvelope prepared4 = makePrepare(mSecretKey[4], mQSetHash, 0, b, &b);

        mBCP.receiveEnvelope(prepared4);
        mBCP.receiveEnvelope(prepared3);
        REQUIRE(mBCP.mEnvs.length == 2);

        mBCP.receiveEnvelope(prepared2);
        REQUIRE(mBCP.mEnvs.length == 3);

        // confirms prepared
        verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0, b, &b, b.counter, b.counter);

        // extra statement doesn't do anything
        mBCP.receiveEnvelope(prepared1);
        REQUIRE(mBCP.mEnvs.length == 3);
    };

    void ballotProtocolTest1()
    {
        TEST_CASE("vblocking and quorum", "[mBCP]");
        {
            SIMULATION_CREATE_NODE(0);
            SIMULATION_CREATE_NODE(1);
            SIMULATION_CREATE_NODE(2);
            SIMULATION_CREATE_NODE(3);

            //  number of validator is 4
            //  threshold is 3
            BCPQuorumSet qSet;
            qSet.threshold = 3;
            qSet.validators ~= mKey[0];
            qSet.validators ~= mKey[1];
            qSet.validators ~= mKey[2];
            qSet.validators ~= mKey[3];

            NodeID[] nodeSet;
            nodeSet ~= (mKey[0]);

            //  nodeSet size is 1
            REQUIRE(LocalNode.isQuorumSlice(qSet, nodeSet) == false);
            REQUIRE(LocalNode.isVBlocking(qSet, nodeSet) == false);

            nodeSet ~= (mKey[2]);

            //  nodeSet size is 2
            REQUIRE(LocalNode.isQuorumSlice(qSet, nodeSet) == false);
            REQUIRE(LocalNode.isVBlocking(qSet, nodeSet) == true);

            nodeSet ~= (mKey[3]);

            //  nodeSet size is 3
            REQUIRE(LocalNode.isQuorumSlice(qSet, nodeSet) == true);
            REQUIRE(LocalNode.isVBlocking(qSet, nodeSet) == true);

            nodeSet ~= (mKey[1]);

            //  nodeSet size is 4
            REQUIRE(LocalNode.isQuorumSlice(qSet, nodeSet) == true);
            REQUIRE(LocalNode.isVBlocking(qSet, nodeSet) == true);
        }

        TEST_CASE("v-blocking distance", "[mBCP]");
        {
            SIMULATION_CREATE_NODE(0);
            SIMULATION_CREATE_NODE(1);
            SIMULATION_CREATE_NODE(2);
            SIMULATION_CREATE_NODE(3);
            SIMULATION_CREATE_NODE(4);
            SIMULATION_CREATE_NODE(5);
            SIMULATION_CREATE_NODE(6);
            SIMULATION_CREATE_NODE(7);

            BCPQuorumSet qSet;
            qSet.threshold = 2;
            qSet.validators ~= (mKey[0]);
            qSet.validators ~= (mKey[1]);
            qSet.validators ~= (mKey[2]);

            auto check = (ref BCPQuorumSet qSetCheck, ref NodeIDSet s, int expected) {
                auto r = LocalNode.findClosestVBlocking(qSetCheck, s, null);
                REQUIRE(expected == r.length);
            };

            NodeIDSet good = new NodeIDSet;

            good.insert(mKey[0]); //1 + V - T = 4 - 2 = 2;
            // already v-blocking
            check(qSet, good, 0);

            good.insert(mKey[1]);
            // either v0 or v1
            check(qSet, good, 1);

            good.insert(mKey[2]);
            // any 2 of v0..v2
            check(qSet, good, 2);

            BCPQuorumSet qSubSet1;
            qSubSet1.threshold = 1;
            qSubSet1.validators ~= (mKey[3]);
            qSubSet1.validators ~= (mKey[4]);
            qSubSet1.validators ~= (mKey[5]);
            qSet.innerSets ~= (qSubSet1);

            good.insert(mKey[3]);
            // any 3 of v0..v3
            check(qSet, good, 3);

            good.insert(mKey[4]);
            // v0..v2
            check(qSet, good, 3);

            qSet.threshold = 1; //1 + V - T = 1 + 4 - 1 = 4;
            // v0..v4
            check(qSet, good, 5);

            good.insert(mKey[5]);
            // v0..v5
            check(qSet, good, 6);

            BCPQuorumSet qSubSet2;
            qSubSet2.threshold = 2;
            qSubSet2.validators ~= (mKey[6]);
            qSubSet2.validators ~= (mKey[7]);

            qSet.innerSets ~= (qSubSet2);
            // v0..v5
            check(qSet, good, 6);

            good.insert(mKey[6]);
            // v0..v5
            check(qSet, good, 6);

            good.insert(mKey[7]);
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

    //  ballot protocol", "[BCP][ballotprotocol]
    //  bumpState x
    void ballotProtocolTest2()
    {
        TEST_CASE("ballot protocol", "[BCP][ballotprotocol]");
        {
            SIMULATION_CREATE_NODE(0);
            SIMULATION_CREATE_NODE(1);
            SIMULATION_CREATE_NODE(2);
            SIMULATION_CREATE_NODE(3);
            SIMULATION_CREATE_NODE(4);

            Init();

            mBCP.storeQuorumSet(mQSet);

            REQUIRE(mValue[0].value < mValue[1].value);

            writefln("[INFO], BCP");
            writefln("[INFO], BCP BEGIN TEST");

            SECTION("bumpState x");
            {
                REQUIRE(mBCP.bumpState(0, mValue[0]));
                REQUIRE(mBCP.mEnvs.length == 1);

                BCPBallot expectedBallot = BCPBallot(1, mValue[0]);

                verifyPrepare(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, expectedBallot);
            }
        }
    }

    //  start <1,x>
    void ballotProtocolTest3()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();

        REQUIRE(mValue[0].value < mValue[1].value);

        SECTION("start <1,x>");
        {
            Value aValue = mValue[0];
            Value bValue = mValue[1];

            BCPBallot A1 = BCPBallot(1, aValue);
            BCPBallot B1 = BCPBallot(1, bValue);

            BCPBallot A2 = A1;
            A2.counter++;

            BCPBallot A3 = A2;
            A3.counter++;

            BCPBallot A4 = A3;
            A4.counter++;

            BCPBallot A5 = A4;
            A5.counter++;

            BCPBallot AInf = BCPBallot(UINT32_MAX, aValue);
            BCPBallot BInf = BCPBallot(UINT32_MAX, bValue);

            BCPBallot B2 = B1;
            B2.counter++;

            BCPBallot B3 = B2;
            B3.counter++;

            auto TEST_Start1X = () {
                REQUIRE(mBCP.bumpState(0, aValue));
                REQUIRE(mBCP.mEnvs.length == 1);
            };

            TEST_Start1X();

            SECTION("prepared A1");
            {
                auto TEST_PreparedA1 = () {

                    recvQuorum(makePrepareGen(mQSetHash, A1));
                    REQUIRE(mBCP.mEnvs.length == 2);
                    verifyPrepare(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, A1, &A1);

                };
                TEST_PreparedA1();

                SECTION("bump prepared A2");
                {
                    auto TEST_BumpPreparedA2 = () {

                        // bump to (2,a)
                        REQUIRE(mBCP.bumpState(0, aValue));
                        REQUIRE(mBCP.mEnvs.length == 3);
                        verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0, A2, &A1);

                        recvQuorum(makePrepareGen(mQSetHash, A2));
                        REQUIRE(mBCP.mEnvs.length == 4);
                        verifyPrepare(mBCP.mEnvs[3], mSecretKey[0], mQSetHash0, 0, A2, &A2);

                    };
                    TEST_BumpPreparedA2();

                    SECTION("Confirm prepared A2");
                    {
                        auto TEST_ConfirmPreparedA2()
                        {

                            recvQuorum(makePrepareGen(mQSetHash, A2, &A2));
                            REQUIRE(mBCP.mEnvs.length == 5);
                            verifyPrepare(mBCP.mEnvs[4], mSecretKey[0],
                                    mQSetHash0, 0, A2, &A2, 2, 2);

                        }

                        TEST_ConfirmPreparedA2();

                        SECTION("Accept commit");
                        {
                            SECTION("Quorum A2");
                            {
                                auto TEST_QuorumA2 = () {

                                    recvQuorum(makePrepareGen(mQSetHash, A2, &A2, 2, 2));
                                    REQUIRE(mBCP.mEnvs.length == 6);
                                    verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                            mQSetHash0, 0, 2, A2, 2, 2);

                                };
                                TEST_QuorumA2();

                                SECTION("Quorum prepared A3");
                                {
                                    auto TEST_QuorumPreparedA3 = () {

                                        recvVBlocking(makePrepareGen(mQSetHash, A3, &A2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 7);
                                        verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                                mQSetHash0, 0, 2, A3, 2, 2);

                                        recvQuorum(makePrepareGen(mQSetHash, A3, &A2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 8);
                                        verifyConfirm(mBCP.mEnvs[7], mSecretKey[0],
                                                mQSetHash0, 0, 3, A3, 2, 2);

                                    };

                                    TEST_QuorumPreparedA3();

                                    SECTION("Accept more commit A3");
                                    {
                                        auto TEST_AcceptMoreCommitA3 = () {

                                            recvQuorum(makePrepareGen(mQSetHash, A3, &A3, 2, 3));
                                            REQUIRE(mBCP.mEnvs.length == 9);
                                            verifyConfirm(mBCP.mEnvs[8], mSecretKey[0],
                                                    mQSetHash0, 0, 3, A3, 2, 3);

                                            REQUIRE(mBCP.mExternalizedValues.length == 0);

                                        };

                                        TEST_AcceptMoreCommitA3();

                                        SECTION("Quorum externalize A3");
                                        {
                                            auto TEST_QuorumExternalizeA3 = {

                                                recvQuorum(makeConfirmGen(mQSetHash, 3, A3, 2, 3));
                                                REQUIRE(mBCP.mEnvs.length == 10);
                                                verifyExternalize(mBCP.mEnvs[9],
                                                        mSecretKey[0], mQSetHash0, 0, A2, 3);

                                                REQUIRE(mBCP.mExternalizedValues.length == 1);
                                                REQUIRE(mBCP.mExternalizedValues[0] == aValue);

                                            };

                                            TEST_QuorumExternalizeA3();

                                        }
                                    }

                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();
                                    TEST_QuorumA2();
                                    TEST_QuorumPreparedA3();

                                    SECTION("v-blocking accept more A3");
                                    {
                                        SECTION("Confirm A3");
                                        {
                                            auto TEST_ConfirmA3 = () {
                                                recvVBlocking(makeConfirmGen(mQSetHash,
                                                        3, A3, 2, 3));
                                                REQUIRE(mBCP.mEnvs.length == 9);
                                                verifyConfirm(mBCP.mEnvs[8], mSecretKey[0],
                                                        mQSetHash0, 0, 3, A3, 2, 3);
                                            };
                                            TEST_ConfirmA3();
                                        }

                                        Init();
                                        TEST_Start1X();
                                        TEST_PreparedA1();
                                        TEST_BumpPreparedA2();
                                        TEST_ConfirmPreparedA2();
                                        TEST_QuorumA2();
                                        TEST_QuorumPreparedA3();

                                        SECTION("Externalize A3");
                                        {
                                            recvVBlocking(makeExternalizeGen(mQSetHash, A2, 3));
                                            REQUIRE(mBCP.mEnvs.length == 9);
                                            verifyConfirm(mBCP.mEnvs[8], mSecretKey[0], mQSetHash0,
                                                    0, UINT32_MAX, AInf, 2, UINT32_MAX);
                                        }

                                        SECTION("other nodes moved to c=A4 h=A5");
                                        {
                                            Init();
                                            TEST_Start1X();
                                            TEST_PreparedA1();
                                            TEST_BumpPreparedA2();
                                            TEST_ConfirmPreparedA2();
                                            TEST_QuorumA2();
                                            TEST_QuorumPreparedA3();

                                            SECTION("Confirm A4..5");
                                            {
                                                recvVBlocking(makeConfirmGen(mQSetHash,
                                                        3, A5, 4, 5));
                                                REQUIRE(mBCP.mEnvs.length == 9);
                                                verifyConfirm(mBCP.mEnvs[8], mSecretKey[0],
                                                        mQSetHash0, 0, 3, A5, 4, 5);
                                            }

                                            Init();
                                            TEST_Start1X();
                                            TEST_PreparedA1();
                                            TEST_BumpPreparedA2();
                                            TEST_ConfirmPreparedA2();
                                            TEST_QuorumA2();
                                            TEST_QuorumPreparedA3();

                                            SECTION("Externalize A4..5");
                                            {
                                                recvVBlocking(makeExternalizeGen(mQSetHash, A4, 5));
                                                REQUIRE(mBCP.mEnvs.length == 9);
                                                verifyConfirm(mBCP.mEnvs[8], mSecretKey[0], mQSetHash0, 0,
                                                        UINT32_MAX, AInf, 4, UINT32_MAX);
                                            }
                                        }
                                    }
                                }
                                SECTION("v-blocking prepared A3");
                                {
                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();
                                    TEST_QuorumA2();

                                    recvVBlocking(makePrepareGen(mQSetHash, A3, &A3, 2, 2));
                                    REQUIRE(mBCP.mEnvs.length == 7);
                                    verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                            mQSetHash0, 0, 3, A3, 2, 2);
                                }
                                SECTION("v-blocking prepared A3+B3");
                                {

                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();
                                    TEST_QuorumA2();

                                    recvVBlocking(makePrepareGen(mQSetHash, A3, &B3, 2, 2, &A3));
                                    REQUIRE(mBCP.mEnvs.length == 7);
                                    verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                            mQSetHash0, 0, 3, A3, 2, 2);
                                }
                                SECTION("v-blocking confirm A3");
                                {

                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();
                                    TEST_QuorumA2();

                                    recvVBlocking(makeConfirmGen(mQSetHash, 3, A3, 2, 2));
                                    REQUIRE(mBCP.mEnvs.length == 7);
                                    verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                            mQSetHash0, 0, 3, A3, 2, 2);
                                }

                                SECTION("Hang - does not switch to B in CONFIRM");
                                {
                                    SECTION("Network EXTERNALIZE");
                                    {
                                        Init();
                                        TEST_Start1X();
                                        TEST_PreparedA1();
                                        TEST_BumpPreparedA2();
                                        TEST_ConfirmPreparedA2();
                                        TEST_QuorumA2();

                                        // externalize messages have a counter at
                                        // infinite
                                        recvVBlocking(makeExternalizeGen(mQSetHash, B2, 3));
                                        REQUIRE(mBCP.mEnvs.length == 7);
                                        verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                                mQSetHash0, 0, 2, AInf, 2, 2);
                                        // stuck
                                        recvQuorumChecks(makeExternalizeGen(mQSetHash,
                                                B2, 3), false, false);
                                        REQUIRE(mBCP.mEnvs.length == 7);
                                        REQUIRE(mBCP.mExternalizedValues.length == 0);
                                    }

                                    SECTION("Network CONFIRMS other ballot");
                                    {
                                        SECTION("at same counter");
                                        {
                                            Init();
                                            TEST_Start1X();
                                            TEST_PreparedA1();
                                            TEST_BumpPreparedA2();
                                            TEST_ConfirmPreparedA2();
                                            TEST_QuorumA2();

                                            // nothing should happen here, in
                                            // particular, node should not attempt
                                            // to switch 'p'
                                            recvQuorumChecks(makeConfirmGen(mQSetHash,
                                                    3, B2, 2, 3), false, false);
                                            REQUIRE(mBCP.mEnvs.length == 6);
                                            REQUIRE(mBCP.mExternalizedValues.length == 0);
                                        }

                                        SECTION("at a different counter");
                                        {
                                            Init();
                                            TEST_Start1X();
                                            TEST_PreparedA1();
                                            TEST_BumpPreparedA2();
                                            TEST_ConfirmPreparedA2();
                                            TEST_QuorumA2();

                                            recvVBlocking(makeConfirmGen(mQSetHash, 3, B3, 3, 3));
                                            REQUIRE(mBCP.mEnvs.length == 7);
                                            verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                                    mQSetHash0, 0, 2, A3, 2, 2);

                                            recvQuorumChecks(makeConfirmGen(mQSetHash,
                                                    3, B3, 3, 3), false, false);
                                            REQUIRE(mBCP.mEnvs.length == 7);
                                            REQUIRE(mBCP.mExternalizedValues.length == 0);
                                        }
                                    }
                                }
                            }

                            SECTION("v-blocking");
                            {
                                SECTION("CONFIRM");
                                {
                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("CONFIRM A2");
                                    {
                                        recvVBlocking(makeConfirmGen(mQSetHash, 2, A2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, 2, A2, 2, 2);
                                    }

                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("CONFIRM A3..4");
                                    {
                                        recvVBlocking(makeConfirmGen(mQSetHash, 4, A4, 3, 4));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, 4, A4, 3, 4);
                                    }

                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("CONFIRM B2");
                                    {
                                        recvVBlocking(makeConfirmGen(mQSetHash, 2, B2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, 2, B2, 2, 2);
                                    }
                                }
                                SECTION("EXTERNALIZE");
                                {
                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("EXTERNALIZE A2");
                                    {
                                        recvVBlocking(makeExternalizeGen(mQSetHash, A2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, UINT32_MAX, AInf, 2, UINT32_MAX);
                                    }

                                    Init();
                                    TEST_Start1X();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("EXTERNALIZE B2");
                                    {
                                        recvVBlocking(makeExternalizeGen(mQSetHash, B2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, UINT32_MAX, BInf, 2, UINT32_MAX);
                                    }
                                }
                            }
                        }
                    }

                    SECTION("Confirm prepared mixed");
                    {
                        auto TEST_ConfirmPreparedMixed = () {
                            // a few nodes prepared B2
                            recvVBlocking(makePrepareGen(mQSetHash, B2, &B2, 0, 0, &A2));
                            REQUIRE(mBCP.mEnvs.length == 5);
                            verifyPrepare(mBCP.mEnvs[4], mSecretKey[0],
                                    mQSetHash0, 0, A2, &B2, 0, 0, &A2);
                        };

                        Init();
                        TEST_Start1X();
                        TEST_PreparedA1();
                        TEST_BumpPreparedA2();
                        TEST_ConfirmPreparedMixed();

                        SECTION("mixed A2");
                        {
                            // causes h=A2
                            // but c = 0, as p >!~ h
                            BCPEnvelope envelope;
                            envelope = makePrepare(mSecretKey[3], mQSetHash, 0, A2, &A2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 6);
                            verifyPrepare(mBCP.mEnvs[5], mSecretKey[0],
                                    mQSetHash0, 0, A2, &B2, 0, 2, &A2);

                            envelope = makePrepare(mSecretKey[4], mQSetHash, 0, A2, &A2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 6);
                        }

                        Init();
                        TEST_Start1X();
                        TEST_PreparedA1();
                        TEST_BumpPreparedA2();
                        TEST_ConfirmPreparedMixed();

                        SECTION("mixed B2");
                        {
                            // causes h=B2, c=B2
                            BCPEnvelope envelope;
                            envelope = makePrepare(mSecretKey[3], mQSetHash, 0, B2, &B2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 6);
                            verifyPrepare(mBCP.mEnvs[5], mSecretKey[0],
                                    mQSetHash0, 0, B2, &B2, 2, 2, &A2);

                            envelope = makePrepare(mSecretKey[4], mQSetHash, 0, B2, &B2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 6);
                        }
                    }
                }

                SECTION("switch prepared B1");
                {
                    Init();
                    TEST_Start1X();
                    TEST_PreparedA1();

                    recvVBlocking(makePrepareGen(mQSetHash, B1, &B1));
                    REQUIRE(mBCP.mEnvs.length == 3);
                    verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0,
                            A1, &B1, 0, 0, &A1);
                }
            }
            SECTION("prepared B (v-blocking)");
            {
                Init();
                TEST_Start1X();

                recvVBlocking(makePrepareGen(mQSetHash, B1, &B1));
                REQUIRE(mBCP.mEnvs.length == 2);
                verifyPrepare(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, A1, &B1);
            }
            SECTION("confirm (v-blocking)");
            {

                Init();
                TEST_Start1X();

                SECTION("via CONFIRM");
                {
                    BCPEnvelope envelope;

                    envelope = makeConfirm(mSecretKey[1], mQSetHash, 0, 3, A3, 3, 3);
                    mBCP.receiveEnvelope(envelope);

                    envelope = makeConfirm(mSecretKey[2], mQSetHash, 0, 4, A4, 2, 4);
                    mBCP.receiveEnvelope(envelope);

                    REQUIRE(mBCP.mEnvs.length == 2);
                    verifyConfirm(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, 3, A3, 3, 3);
                }

                Init();
                TEST_Start1X();

                SECTION("via EXTERNALIZE");
                {
                    BCPEnvelope envelope;

                    envelope = makeExternalize(mSecretKey[1], mQSetHash, 0, A2, 4);
                    mBCP.receiveEnvelope(envelope);
                    envelope = makeExternalize(mSecretKey[2], mQSetHash, 0, A3, 5);
                    mBCP.receiveEnvelope(envelope);
                    REQUIRE(mBCP.mEnvs.length == 2);
                    verifyConfirm(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0,
                            UINT32_MAX, AInf, 3, UINT32_MAX);
                }
            }
        }
    }

    //  start <1,y>
    void ballotProtocolTest4()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();

        SECTION("start <1,y>");
        {
            Value aValue = mValue[1];
            Value bValue = mValue[0];

            BCPBallot A1 = BCPBallot(1, aValue);
            BCPBallot B1 = BCPBallot(1, bValue);

            BCPBallot A2 = A1;
            A2.counter++;

            BCPBallot A3 = A2;
            A3.counter++;

            BCPBallot A4 = A3;
            A4.counter++;

            BCPBallot A5 = A4;
            A5.counter++;

            BCPBallot AInf = BCPBallot(UINT32_MAX, aValue);
            BCPBallot BInf = BCPBallot(UINT32_MAX, bValue);

            BCPBallot B2 = B1;
            B2.counter++;

            BCPBallot B3 = B2;
            B3.counter++;

            auto TEST_Start1Y = () {
                REQUIRE(mBCP.bumpState(0, aValue));
                REQUIRE(mBCP.mEnvs.length == 1);
            };

            TEST_Start1Y();

            SECTION("prepared A1");
            {
                auto TEST_PreparedA1 = () {
                    recvQuorum(makePrepareGen(mQSetHash, A1));
                    REQUIRE(mBCP.mEnvs.length == 2);
                    verifyPrepare(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, A1, &A1);
                };
                TEST_PreparedA1();

                SECTION("bump prepared A2");
                {
                    auto TEST_BumpPreparedA2 = () {
                        // bump to (2,a)
                        REQUIRE(mBCP.bumpState(0, aValue));
                        REQUIRE(mBCP.mEnvs.length == 3);
                        verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0, A2, &A1);

                        recvQuorum(makePrepareGen(mQSetHash, A2));
                        REQUIRE(mBCP.mEnvs.length == 4);
                        verifyPrepare(mBCP.mEnvs[3], mSecretKey[0], mQSetHash0, 0, A2, &A2);
                    };

                    TEST_BumpPreparedA2();

                    SECTION("Confirm prepared A2");
                    {
                        auto TEST_ConfirmPreparedA2()
                        {
                            recvQuorum(makePrepareGen(mQSetHash, A2, &A2));
                            REQUIRE(mBCP.mEnvs.length == 5);
                            verifyPrepare(mBCP.mEnvs[4], mSecretKey[0],
                                    mQSetHash0, 0, A2, &A2, 2, 2);
                        }

                        TEST_ConfirmPreparedA2();

                        SECTION("Accept commit");
                        {

                            SECTION("Quorum A2");
                            {
                                auto TEST_QuorumA2 = () {
                                    recvQuorum(makePrepareGen(mQSetHash, A2, &A2, 2, 2));
                                    REQUIRE(mBCP.mEnvs.length == 6);
                                    verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                            mQSetHash0, 0, 2, A2, 2, 2);
                                };

                                TEST_QuorumA2();

                                SECTION("Quorum prepared A3");
                                {
                                    auto TEST_QuorumPreparedA3 = () {
                                        recvVBlocking(makePrepareGen(mQSetHash, A3, &A2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 7);
                                        verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                                mQSetHash0, 0, 2, A3, 2, 2);

                                        recvQuorum(makePrepareGen(mQSetHash, A3, &A2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 8);
                                        verifyConfirm(mBCP.mEnvs[7], mSecretKey[0],
                                                mQSetHash0, 0, 3, A3, 2, 2);
                                    };

                                    TEST_QuorumPreparedA3();

                                    SECTION("Accept more commit A3");
                                    {
                                        auto TEST_AcceptMoreCommitA3 = () {
                                            recvQuorum(makePrepareGen(mQSetHash, A3, &A3, 2, 3));
                                            REQUIRE(mBCP.mEnvs.length == 9);
                                            verifyConfirm(mBCP.mEnvs[8], mSecretKey[0],
                                                    mQSetHash0, 0, 3, A3, 2, 3);

                                            REQUIRE(mBCP.mExternalizedValues.length == 0);
                                        };

                                        TEST_AcceptMoreCommitA3();

                                        SECTION("Quorum externalize A3");
                                        {
                                            auto TEST_QuorumExternalizeA3 = {
                                                recvQuorum(makeConfirmGen(mQSetHash, 3, A3, 2, 3));
                                                REQUIRE(mBCP.mEnvs.length == 10);
                                                verifyExternalize(mBCP.mEnvs[9],
                                                        mSecretKey[0], mQSetHash0, 0, A2, 3);

                                                REQUIRE(mBCP.mExternalizedValues.length == 1);
                                                REQUIRE(mBCP.mExternalizedValues[0] == aValue);
                                            };

                                            TEST_QuorumExternalizeA3();
                                        }
                                    }

                                    Init();
                                    TEST_Start1Y();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();
                                    TEST_QuorumA2();
                                    TEST_QuorumPreparedA3();

                                    SECTION("v-blocking accept more A3");
                                    {
                                        SECTION("Confirm A3");
                                        {
                                            auto TEST_ConfirmA3 = () {
                                                recvVBlocking(makeConfirmGen(mQSetHash,
                                                        3, A3, 2, 3));
                                                REQUIRE(mBCP.mEnvs.length == 9);
                                                verifyConfirm(mBCP.mEnvs[8], mSecretKey[0],
                                                        mQSetHash0, 0, 3, A3, 2, 3);
                                            };
                                            TEST_ConfirmA3();
                                        }

                                        Init();
                                        TEST_Start1Y();
                                        TEST_PreparedA1();
                                        TEST_BumpPreparedA2();
                                        TEST_ConfirmPreparedA2();
                                        TEST_QuorumA2();
                                        TEST_QuorumPreparedA3();

                                        SECTION("Externalize A3");
                                        {
                                            recvVBlocking(makeExternalizeGen(mQSetHash, A2, 3));
                                            REQUIRE(mBCP.mEnvs.length == 9);
                                            verifyConfirm(mBCP.mEnvs[8], mSecretKey[0], mQSetHash0,
                                                    0, UINT32_MAX, AInf, 2, UINT32_MAX);
                                        }

                                        SECTION("other nodes moved to c=A4 h=A5");
                                        {
                                            Init();
                                            TEST_Start1Y();
                                            TEST_PreparedA1();
                                            TEST_BumpPreparedA2();
                                            TEST_ConfirmPreparedA2();
                                            TEST_QuorumA2();
                                            TEST_QuorumPreparedA3();

                                            SECTION("Confirm A4..5");
                                            {
                                                recvVBlocking(makeConfirmGen(mQSetHash,
                                                        3, A5, 4, 5));
                                                REQUIRE(mBCP.mEnvs.length == 9);
                                                verifyConfirm(mBCP.mEnvs[8], mSecretKey[0],
                                                        mQSetHash0, 0, 3, A5, 4, 5);
                                            }

                                            Init();
                                            TEST_Start1Y();
                                            TEST_PreparedA1();
                                            TEST_BumpPreparedA2();
                                            TEST_ConfirmPreparedA2();
                                            TEST_QuorumA2();
                                            TEST_QuorumPreparedA3();

                                            SECTION("Externalize A4..5");
                                            {
                                                recvVBlocking(makeExternalizeGen(mQSetHash, A4, 5));
                                                REQUIRE(mBCP.mEnvs.length == 9);
                                                verifyConfirm(mBCP.mEnvs[8], mSecretKey[0], mQSetHash0, 0,
                                                        UINT32_MAX, AInf, 4, UINT32_MAX);
                                            }
                                        }
                                    }
                                }

                                Init();
                                TEST_Start1Y();
                                TEST_PreparedA1();
                                TEST_BumpPreparedA2();
                                TEST_ConfirmPreparedA2();
                                TEST_QuorumA2();

                                SECTION("v-blocking prepared A3");
                                {
                                    recvVBlocking(makePrepareGen(mQSetHash, A3, &A3, 2, 2));
                                    REQUIRE(mBCP.mEnvs.length == 7);
                                    verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                            mQSetHash0, 0, 3, A3, 2, 2);
                                }

                                Init();
                                TEST_Start1Y();
                                TEST_PreparedA1();
                                TEST_BumpPreparedA2();
                                TEST_ConfirmPreparedA2();
                                TEST_QuorumA2();

                                SECTION("v-blocking prepared A3+B3");
                                {
                                    recvVBlocking(makePrepareGen(mQSetHash, A3, &A3, 2, 2, &B3));
                                    REQUIRE(mBCP.mEnvs.length == 7);
                                    verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                            mQSetHash0, 0, 3, A3, 2, 2);
                                }

                                Init();
                                TEST_Start1Y();
                                TEST_PreparedA1();
                                TEST_BumpPreparedA2();
                                TEST_ConfirmPreparedA2();
                                TEST_QuorumA2();

                                SECTION("v-blocking confirm A3");
                                {
                                    recvVBlocking(makeConfirmGen(mQSetHash, 3, A3, 2, 2));
                                    REQUIRE(mBCP.mEnvs.length == 7);
                                    verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                            mQSetHash0, 0, 3, A3, 2, 2);
                                }

                                SECTION("Hang - does not switch to B in CONFIRM");
                                {
                                    Init();
                                    TEST_Start1Y();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();
                                    TEST_QuorumA2();

                                    SECTION("Network EXTERNALIZE");
                                    {
                                        // externalize messages have a counter at
                                        // infinite
                                        recvVBlocking(makeExternalizeGen(mQSetHash, B2, 3));
                                        REQUIRE(mBCP.mEnvs.length == 7);
                                        verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                                mQSetHash0, 0, 2, AInf, 2, 2);
                                        // stuck
                                        recvQuorumChecks(makeExternalizeGen(mQSetHash,
                                                B2, 3), false, false);
                                        REQUIRE(mBCP.mEnvs.length == 7);
                                        REQUIRE(mBCP.mExternalizedValues.length == 0);
                                    }

                                    SECTION("Network CONFIRMS other ballot");
                                    {
                                        Init();
                                        TEST_Start1Y();
                                        TEST_PreparedA1();
                                        TEST_BumpPreparedA2();
                                        TEST_ConfirmPreparedA2();
                                        TEST_QuorumA2();

                                        SECTION("at same counter");
                                        {
                                            // nothing should happen here, in
                                            // particular, node should not attempt
                                            // to switch 'p'
                                            recvQuorumChecks(makeConfirmGen(mQSetHash,
                                                    3, B2, 2, 3), false, false);
                                            REQUIRE(mBCP.mEnvs.length == 6);
                                            REQUIRE(mBCP.mExternalizedValues.length == 0);
                                        }

                                        Init();
                                        TEST_Start1Y();
                                        TEST_PreparedA1();
                                        TEST_BumpPreparedA2();
                                        TEST_ConfirmPreparedA2();
                                        TEST_QuorumA2();

                                        SECTION("at a different counter");
                                        {
                                            recvVBlocking(makeConfirmGen(mQSetHash, 3, B3, 3, 3));
                                            REQUIRE(mBCP.mEnvs.length == 7);
                                            verifyConfirm(mBCP.mEnvs[6], mSecretKey[0],
                                                    mQSetHash0, 0, 2, A3, 2, 2);

                                            recvQuorumChecks(makeConfirmGen(mQSetHash,
                                                    3, B3, 3, 3), false, false);
                                            REQUIRE(mBCP.mEnvs.length == 7);
                                            REQUIRE(mBCP.mExternalizedValues.length == 0);
                                        }
                                    }
                                }
                            }

                            SECTION("v-blocking");
                            {
                                SECTION("CONFIRM");
                                {
                                    Init();
                                    TEST_Start1Y();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("CONFIRM A2");
                                    {
                                        recvVBlocking(makeConfirmGen(mQSetHash, 2, A2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, 2, A2, 2, 2);
                                    }

                                    Init();
                                    TEST_Start1Y();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("CONFIRM A3..4");
                                    {
                                        recvVBlocking(makeConfirmGen(mQSetHash, 4, A4, 3, 4));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, 4, A4, 3, 4);
                                    }

                                    Init();
                                    TEST_Start1Y();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("CONFIRM B2");
                                    {
                                        recvVBlocking(makeConfirmGen(mQSetHash, 2, B2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, 2, B2, 2, 2);
                                    }
                                }
                                SECTION("EXTERNALIZE");
                                {
                                    Init();
                                    TEST_Start1Y();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("EXTERNALIZE A2");
                                    {
                                        recvVBlocking(makeExternalizeGen(mQSetHash, A2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, UINT32_MAX, AInf, 2, UINT32_MAX);
                                    }

                                    Init();
                                    TEST_Start1Y();
                                    TEST_PreparedA1();
                                    TEST_BumpPreparedA2();
                                    TEST_ConfirmPreparedA2();

                                    SECTION("EXTERNALIZE B2");
                                    {
                                        recvVBlocking(makeExternalizeGen(mQSetHash, B2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 6);
                                        verifyConfirm(mBCP.mEnvs[5], mSecretKey[0],
                                                mQSetHash0, 0, UINT32_MAX, BInf, 2, UINT32_MAX);
                                    }
                                }
                            }
                        }
                    }

                    SECTION("Confirm prepared mixed");
                    {
                        auto TEST_ConfirmPreparedMixed = () {
                            // a few nodes prepared B2
                            recvVBlocking(makePrepareGen(mQSetHash, A2, &A2, 0, 0, &B2));
                            REQUIRE(mBCP.mEnvs.length == 5);
                            verifyPrepare(mBCP.mEnvs[4], mSecretKey[0],
                                    mQSetHash0, 0, A2, &A2, 0, 0, &B2);
                        };

                        Init();
                        TEST_Start1Y();
                        TEST_PreparedA1();
                        TEST_BumpPreparedA2();
                        TEST_ConfirmPreparedMixed();

                        SECTION("mixed A2");
                        {
                            // causes h=A2, c=A2
                            BCPEnvelope envelope;
                            envelope = makePrepare(mSecretKey[3], mQSetHash, 0, A2, &A2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 6);
                            verifyPrepare(mBCP.mEnvs[5], mSecretKey[0],
                                    mQSetHash0, 0, A2, &A2, 2, 2, &B2);

                            envelope = makePrepare(mSecretKey[4], mQSetHash, 0, A2, &A2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 6);
                        }

                        Init();
                        TEST_Start1Y();
                        TEST_PreparedA1();
                        TEST_BumpPreparedA2();
                        TEST_ConfirmPreparedMixed();

                        SECTION("mixed B2");
                        {
                            // causes h=B2
                            // but c = 0, as p >!~ h
                            BCPEnvelope envelope;
                            envelope = makePrepare(mSecretKey[3], mQSetHash, 0, A2, &B2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 6);
                            verifyPrepare(mBCP.mEnvs[5], mSecretKey[0],
                                    mQSetHash0, 0, A2, &A2, 0, 2, &B2);

                            envelope = makePrepare(mSecretKey[4], mQSetHash, 0, B2, &B2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 6);
                        }
                    }
                }

                SECTION("switch prepared B1");
                {
                    Init();
                    TEST_Start1Y();
                    TEST_PreparedA1();

                    // can't switch to B1
                    recvQuorumChecks(makePrepareGen(mQSetHash0, B1, &B1), false, false);
                    REQUIRE(mBCP.mEnvs.length == 2);
                }
            }
            SECTION("prepared B (v-blocking)");
            {
                Init();
                TEST_Start1Y();

                recvVBlocking(makePrepareGen(mQSetHash, B1, &B1));
                REQUIRE(mBCP.mEnvs.length == 2);
                verifyPrepare(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, A1, &B1);
            }
            SECTION("confirm (v-blocking)");
            {

                Init();
                TEST_Start1Y();

                SECTION("via CONFIRM");
                {
                    BCPEnvelope envelope;

                    envelope = makeConfirm(mSecretKey[1], mQSetHash, 0, 3, A3, 3, 3);
                    mBCP.receiveEnvelope(envelope);

                    envelope = makeConfirm(mSecretKey[2], mQSetHash, 0, 4, A4, 2, 4);
                    mBCP.receiveEnvelope(envelope);

                    REQUIRE(mBCP.mEnvs.length == 2);
                    verifyConfirm(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, 3, A3, 3, 3);
                }

                Init();
                TEST_Start1Y();

                SECTION("via EXTERNALIZE");
                {
                    BCPEnvelope envelope;

                    envelope = makeExternalize(mSecretKey[1], mQSetHash, 0, A2, 4);
                    mBCP.receiveEnvelope(envelope);
                    envelope = makeExternalize(mSecretKey[2], mQSetHash, 0, A3, 5);
                    mBCP.receiveEnvelope(envelope);
                    REQUIRE(mBCP.mEnvs.length == 2);
                    verifyConfirm(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0,
                            UINT32_MAX, AInf, 3, UINT32_MAX);
                }
            }
        }
    }

    //  start from pristine
    void ballotProtocolTest5()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();

        SECTION("start from pristine");
        {
            Value aValue = mValue[0];
            Value bValue = mValue[1];

            BCPBallot A1 = BCPBallot(1, aValue);
            BCPBallot B1 = BCPBallot(1, bValue);

            BCPBallot A2 = A1;
            A2.counter++;

            BCPBallot A3 = A2;
            A3.counter++;

            BCPBallot A4 = A3;
            A4.counter++;

            BCPBallot A5 = A4;
            A5.counter++;

            BCPBallot AInf = BCPBallot(UINT32_MAX, aValue);
            BCPBallot BInf = BCPBallot(UINT32_MAX, bValue);

            BCPBallot B2 = B1;
            B2.counter++;

            BCPBallot B3 = B2;
            B3.counter++;

            REQUIRE(mBCP.mEnvs.length == 0);

            SECTION("prepared A1");
            {
                auto TEST_PreparedA1 = () {
                    recvQuorumChecks(makePrepareGen(mQSetHash, A1), false, false);
                    REQUIRE(mBCP.mEnvs.length == 0);
                };
                TEST_PreparedA1();

                SECTION("bump prepared A2");
                {
                    SECTION("Confirm prepared A2");
                    {
                        auto TEST_ConfirmPreparedA2 = () {
                            recvVBlockingChecks(makePrepareGen(mQSetHash, A2, &A2), false);
                            REQUIRE(mBCP.mEnvs.length == 0);
                        };
                        TEST_ConfirmPreparedA2();

                        SECTION("Quorum A2");
                        {
                            recvVBlockingChecks(makePrepareGen(mQSetHash, A2, &A2), false);
                            REQUIRE(mBCP.mEnvs.length == 0);

                            recvQuorum(makePrepareGen(mQSetHash, A2, &A2));
                            REQUIRE(mBCP.mEnvs.length == 1);

                            verifyPrepare(mBCP.mEnvs[0], mSecretKey[0],
                                    mQSetHash0, 0, A2, &A2, 1, 2);

                        }

                        SECTION("Quorum B2");
                        {
                            Init();
                            TEST_PreparedA1();
                            TEST_ConfirmPreparedA2();

                            recvVBlockingChecks(makePrepareGen(mQSetHash, B2, &B2), false);
                            REQUIRE(mBCP.mEnvs.length == 0);

                            recvQuorum(makePrepareGen(mQSetHash, B2, &B2));
                            REQUIRE(mBCP.mEnvs.length == 1);
                            verifyPrepare(mBCP.mEnvs[0], mSecretKey[0],
                                    mQSetHash0, 0, B2, &B2, 2, 2, &A2);

                        }
                        SECTION("Accept commit");
                        {
                            SECTION("Quorum A2");
                            {
                                Init();
                                TEST_PreparedA1();
                                TEST_ConfirmPreparedA2();

                                recvQuorum(makePrepareGen(mQSetHash, A2, &A2, 2, 2));
                                REQUIRE(mBCP.mEnvs.length == 1);
                                verifyConfirm(mBCP.mEnvs[0], mSecretKey[0],
                                        mQSetHash0, 0, 2, A2, 2, 2);
                            }
                            SECTION("Quorum B2");
                            {
                                Init();
                                TEST_PreparedA1();
                                TEST_ConfirmPreparedA2();

                                recvQuorum(makePrepareGen(mQSetHash, B2, &B2, 2, 2));
                                REQUIRE(mBCP.mEnvs.length == 1);
                                verifyConfirm(mBCP.mEnvs[0], mSecretKey[0],
                                        mQSetHash0, 0, 2, B2, 2, 2);
                            }
                            SECTION("v-blocking");
                            {
                                SECTION("CONFIRM");
                                {
                                    SECTION("CONFIRM A2");
                                    {
                                        Init();
                                        TEST_PreparedA1();
                                        TEST_ConfirmPreparedA2();

                                        recvVBlocking(makeConfirmGen(mQSetHash, 2, A2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 1);
                                        verifyConfirm(mBCP.mEnvs[0], mSecretKey[0],
                                                mQSetHash0, 0, 2, A2, 2, 2);
                                    }
                                    SECTION("CONFIRM A3..4");
                                    {
                                        Init();
                                        TEST_PreparedA1();
                                        TEST_ConfirmPreparedA2();

                                        recvVBlocking(makeConfirmGen(mQSetHash, 4, A4, 3, 4));
                                        REQUIRE(mBCP.mEnvs.length == 1);
                                        verifyConfirm(mBCP.mEnvs[0], mSecretKey[0],
                                                mQSetHash0, 0, 4, A4, 3, 4);
                                    }
                                    SECTION("CONFIRM B2");
                                    {
                                        Init();
                                        TEST_PreparedA1();
                                        TEST_ConfirmPreparedA2();

                                        recvVBlocking(makeConfirmGen(mQSetHash, 2, B2, 2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 1);
                                        verifyConfirm(mBCP.mEnvs[0], mSecretKey[0],
                                                mQSetHash0, 0, 2, B2, 2, 2);
                                    }
                                }

                                SECTION("EXTERNALIZE");
                                {
                                    SECTION("EXTERNALIZE A2");
                                    {
                                        Init();
                                        TEST_PreparedA1();
                                        TEST_ConfirmPreparedA2();

                                        recvVBlocking(makeExternalizeGen(mQSetHash, A2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 1);
                                        verifyConfirm(mBCP.mEnvs[0], mSecretKey[0],
                                                mQSetHash0, 0, UINT32_MAX, AInf, 2, UINT32_MAX);
                                    }
                                    SECTION("EXTERNALIZE B2");
                                    {
                                        Init();
                                        TEST_PreparedA1();
                                        TEST_ConfirmPreparedA2();

                                        recvVBlocking(makeExternalizeGen(mQSetHash, B2, 2));
                                        REQUIRE(mBCP.mEnvs.length == 1);
                                        verifyConfirm(mBCP.mEnvs[0], mSecretKey[0],
                                                mQSetHash0, 0, UINT32_MAX, BInf, 2, UINT32_MAX);
                                    }
                                }
                            }
                        }
                    }

                    Init();
                    TEST_PreparedA1();

                    SECTION("Confirm prepared mixed");
                    {
                        auto TEST_ConfirmPreparedMixed = () {
                            // a few nodes prepared A2
                            // causes p=A2
                            recvVBlockingChecks(makePrepareGen(mQSetHash, A2, &A2), false);
                            REQUIRE(mBCP.mEnvs.length == 0);

                            // a few nodes prepared B2
                            // causes p=B2, p'=A2
                            recvVBlockingChecks(makePrepareGen(mQSetHash, A2,
                                    &B2, 0, 0, &A2), false);
                            REQUIRE(mBCP.mEnvs.length == 0);
                        };
                        TEST_ConfirmPreparedMixed();

                        SECTION("mixed A2");
                        {
                            // causes h=A2
                            // but c = 0, as p >!~ h

                            BCPEnvelope envelope;

                            envelope = makePrepare(mSecretKey[3], mQSetHash, 0, A2, &A2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 1);
                            verifyPrepare(mBCP.mEnvs[0], mSecretKey[0],
                                    mQSetHash0, 0, A2, &B2, 0, 2, &A2);

                            envelope = makePrepare(mSecretKey[4], mQSetHash, 0, A2, &A2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 1);
                        }
                        SECTION("mixed B2");
                        {
                            Init();
                            TEST_PreparedA1();
                            TEST_ConfirmPreparedMixed();

                            BCPEnvelope envelope;

                            // causes h=B2, c=B2
                            envelope = makePrepare(mSecretKey[3], mQSetHash, 0, B2, &B2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 1);
                            verifyPrepare(mBCP.mEnvs[0], mSecretKey[0],
                                    mQSetHash0, 0, B2, &B2, 2, 2, &A2);

                            envelope = makePrepare(mSecretKey[4], mQSetHash, 0, B2, &B2);
                            mBCP.receiveEnvelope(envelope);

                            REQUIRE(mBCP.mEnvs.length == 1);
                        }
                    }
                }

                SECTION("switch prepared B1");
                {
                    Init();
                    TEST_PreparedA1();

                    recvVBlockingChecks(makePrepareGen(mQSetHash, B1, &B1), false);
                    REQUIRE(mBCP.mEnvs.length == 0);
                }
            }
            SECTION("prepared B (v-blocking)");
            {
                Init();

                recvVBlockingChecks(makePrepareGen(mQSetHash, B1, &B1), false);
                REQUIRE(mBCP.mEnvs.length == 0);
            }
            SECTION("confirm (v-blocking)");
            {
                Init();
                SECTION("via CONFIRM");
                {
                    BCPEnvelope envelope;

                    envelope = makeConfirm(mSecretKey[1], mQSetHash, 0, 3, A3, 3, 3);
                    mBCP.receiveEnvelope(envelope);
                    envelope = makeConfirm(mSecretKey[2], mQSetHash, 0, 4, A4, 2, 4);
                    mBCP.receiveEnvelope(envelope);
                    REQUIRE(mBCP.mEnvs.length == 1);
                    verifyConfirm(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, 3, A3, 3, 3);
                }
                Init();
                SECTION("via EXTERNALIZE");
                {
                    BCPEnvelope envelope;

                    envelope = makeExternalize(mSecretKey[1], mQSetHash, 0, A2, 4);
                    mBCP.receiveEnvelope(envelope);
                    envelope = makeExternalize(mSecretKey[2], mQSetHash, 0, A3, 5);
                    mBCP.receiveEnvelope(envelope);
                    REQUIRE(mBCP.mEnvs.length == 1);
                    verifyConfirm(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0,
                            UINT32_MAX, AInf, 3, UINT32_MAX);
                }
            }
        }
    }

    //  normal round (1,x)
    void ballotProtocolTest6()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();
        SECTION("normal round (1,x)");
        {
            auto TEST_NormalRound = () {
                nodesAllPledgeToCommit();
                REQUIRE(mBCP.mEnvs.length == 3);

                BCPBallot b = BCPBallot(1, mValue[0]);

                // bunch of prepare messages with "commit b"
                BCPEnvelope preparedC1 = makePrepare(mSecretKey[1], mQSetHash, 0,
                        b, &b, b.counter, b.counter);
                BCPEnvelope preparedC2 = makePrepare(mSecretKey[2], mQSetHash, 0,
                        b, &b, b.counter, b.counter);
                BCPEnvelope preparedC3 = makePrepare(mSecretKey[3], mQSetHash, 0,
                        b, &b, b.counter, b.counter);
                BCPEnvelope preparedC4 = makePrepare(mSecretKey[4], mQSetHash, 0,
                        b, &b, b.counter, b.counter);

                // those should not trigger anything just yet
                mBCP.receiveEnvelope(preparedC1);
                mBCP.receiveEnvelope(preparedC2);
                REQUIRE(mBCP.mEnvs.length == 3);

                // this should cause the node to accept 'commit b' (quorum)
                // and therefore send a "CONFIRM" message
                mBCP.receiveEnvelope(preparedC3);
                REQUIRE(mBCP.mEnvs.length == 4);

                verifyConfirm(mBCP.mEnvs[3], mSecretKey[0], mQSetHash0, 0, 1, b,
                        b.counter, b.counter);

                // bunch of confirm messages
                BCPEnvelope confirm1 = makeConfirm(mSecretKey[1], mQSetHash, 0,
                        b.counter, b, b.counter, b.counter);
                BCPEnvelope confirm2 = makeConfirm(mSecretKey[2], mQSetHash, 0,
                        b.counter, b, b.counter, b.counter);
                BCPEnvelope confirm3 = makeConfirm(mSecretKey[3], mQSetHash, 0,
                        b.counter, b, b.counter, b.counter);
                BCPEnvelope confirm4 = makeConfirm(mSecretKey[4], mQSetHash, 0,
                        b.counter, b, b.counter, b.counter);

                // those should not trigger anything just yet
                mBCP.receiveEnvelope(confirm1);
                mBCP.receiveEnvelope(confirm2);
                REQUIRE(mBCP.mEnvs.length == 4);

                mBCP.receiveEnvelope(confirm3);
                // this causes our node to
                // externalize (confirm commit c)
                REQUIRE(mBCP.mEnvs.length == 5);

                // The slot should have externalized the value
                REQUIRE(mBCP.mExternalizedValues.length == 1);
                REQUIRE(mBCP.mExternalizedValues[0] == mValue[0]);

                verifyExternalize(mBCP.mEnvs[4], mSecretKey[0], mQSetHash0, 0, b, b.counter);

                // extra vote should not do anything
                mBCP.receiveEnvelope(confirm4);
                REQUIRE(mBCP.mEnvs.length == 5);
                REQUIRE(mBCP.mExternalizedValues.length == 1);

                // duplicate should just no-op
                mBCP.receiveEnvelope(confirm2);
                REQUIRE(mBCP.mEnvs.length == 5);
                REQUIRE(mBCP.mExternalizedValues.length == 1);

            };
            TEST_NormalRound();

            SECTION("bumpToBallot prevented once committed");
            {
                auto TEST_Commit = (ref BCPBallot b2) {
                    BCPEnvelope confirm1b2, confirm2b2, confirm3b2, confirm4b2;
                    confirm1b2 = makeConfirm(mSecretKey[1], mQSetHash, 0,
                            b2.counter, b2, b2.counter, b2.counter);
                    confirm2b2 = makeConfirm(mSecretKey[2], mQSetHash, 0,
                            b2.counter, b2, b2.counter, b2.counter);
                    confirm3b2 = makeConfirm(mSecretKey[3], mQSetHash, 0,
                            b2.counter, b2, b2.counter, b2.counter);
                    confirm4b2 = makeConfirm(mSecretKey[4], mQSetHash, 0,
                            b2.counter, b2, b2.counter, b2.counter);

                    mBCP.receiveEnvelope(confirm1b2);
                    mBCP.receiveEnvelope(confirm2b2);
                    mBCP.receiveEnvelope(confirm3b2);
                    mBCP.receiveEnvelope(confirm4b2);
                    REQUIRE(mBCP.mEnvs.length == 5);
                    REQUIRE(mBCP.mExternalizedValues.length == 1);
                };

                SECTION("bumpToBallot prevented once committed (by value)");
                {
                    BCPBallot b2;
                    b2 = BCPBallot(1, mValue[1]);

                    TEST_Commit(b2);
                }
                SECTION("bumpToBallot prevented once committed (by counter)");
                {
                    Init();
                    TEST_NormalRound();

                    BCPBallot b2;
                    b2 = BCPBallot(2, mValue[0]);

                    TEST_Commit(b2);
                }
                SECTION("bumpToBallot prevented once committed (by value and counter)");
                {
                    Init();
                    TEST_NormalRound();

                    BCPBallot b2;
                    b2 = BCPBallot(2, mValue[1]);

                    TEST_Commit(b2);
                }

            }
        }

    }

    //  range check
    void ballotProtocolTest7()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();

        SECTION("range check");
        {
            nodesAllPledgeToCommit();
            REQUIRE(mBCP.mEnvs.length == 3);

            BCPBallot b = BCPBallot(1, mValue[0]);

            // bunch of prepare messages with "commit b"
            BCPEnvelope preparedC1 = makePrepare(mSecretKey[1], mQSetHash, 0, b,
                    &b, b.counter, b.counter);
            BCPEnvelope preparedC2 = makePrepare(mSecretKey[2], mQSetHash, 0, b,
                    &b, b.counter, b.counter);
            BCPEnvelope preparedC3 = makePrepare(mSecretKey[3], mQSetHash, 0, b,
                    &b, b.counter, b.counter);
            BCPEnvelope preparedC4 = makePrepare(mSecretKey[4], mQSetHash, 0, b,
                    &b, b.counter, b.counter);

            // those should not trigger anything just yet
            mBCP.receiveEnvelope(preparedC1);
            mBCP.receiveEnvelope(preparedC2);
            REQUIRE(mBCP.mEnvs.length == 3);

            // this should cause the node to accept 'commit b' (quorum)
            // and therefore send a "CONFIRM" message
            mBCP.receiveEnvelope(preparedC3);
            REQUIRE(mBCP.mEnvs.length == 4);

            verifyConfirm(mBCP.mEnvs[3], mSecretKey[0], mQSetHash0, 0, 1, b, b.counter, b.counter);

            // bunch of confirm messages with different ranges
            BCPBallot b3 = BCPBallot(3, mValue[0]);
            BCPBallot b4 = BCPBallot(4, mValue[0]);
            BCPBallot b5 = BCPBallot(5, mValue[0]);
            BCPBallot b6 = BCPBallot(6, mValue[0]);

            BCPEnvelope confirm1 = makeConfirm(mSecretKey[1], mQSetHash, 0, 4, b4, 2, 4);
            BCPEnvelope confirm2 = makeConfirm(mSecretKey[2], mQSetHash, 0, 6, b6, 2, 6);
            BCPEnvelope confirm3 = makeConfirm(mSecretKey[3], mQSetHash, 0, 5, b5, 3, 5);
            BCPEnvelope confirm4 = makeConfirm(mSecretKey[4], mQSetHash, 0, 6, b6, 3, 6);

            // this should not trigger anything just yet
            mBCP.receiveEnvelope(confirm1);

            // v-blocking
            //   * b gets bumped to (4,x)
            //   * p gets bumped to (4,x)
            //   * (c,h) gets bumped to (2,4)
            mBCP.receiveEnvelope(confirm2);
            REQUIRE(mBCP.mEnvs.length == 5);
            verifyConfirm(mBCP.mEnvs[4], mSecretKey[0], mQSetHash0, 0, 4, b4, 2, 4);

            // this causes to externalize
            // range is [3,4]
            mBCP.receiveEnvelope(confirm4);
            REQUIRE(mBCP.mEnvs.length == 6);

            // The slot should have externalized the value
            REQUIRE(mBCP.mExternalizedValues.length == 1);
            REQUIRE(mBCP.mExternalizedValues[0] == mValue[0]);

            verifyExternalize(mBCP.mEnvs[5], mSecretKey[0], mQSetHash0, 0, b3, 4);
        }
    }

    //  timeout when h is set . stay locked on h
    void ballotProtocolTest8()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();

        SECTION("timeout when h is set . stay locked on h");
        {
            BCPBallot bx = BCPBallot(1, mValue[0]);
            REQUIRE(mBCP.bumpState(0, mValue[0]));
            REQUIRE(mBCP.mEnvs.length == 1);

            // v-blocking . prepared
            // quorum . confirm prepared
            recvQuorum(makePrepareGen(mQSetHash, bx, &bx));
            REQUIRE(mBCP.mEnvs.length == 3);
            verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0, bx, &bx,
                    bx.counter, bx.counter);

            // now, see if we can timeout and move to a different value
            REQUIRE(mBCP.bumpState(0, mValue[1]));
            REQUIRE(mBCP.mEnvs.length == 4);
            BCPBallot newbx = BCPBallot(2, mValue[0]);
            verifyPrepare(mBCP.mEnvs[3], mSecretKey[0], mQSetHash0, 0, newbx,
                    &bx, bx.counter, bx.counter);
        }

    }

    //  timeout from multiple nodes
    void ballotProtocolTest9()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();

        SECTION("timeout from multiple nodes");
        {
            REQUIRE(mBCP.bumpState(0, mValue[0]));

            BCPBallot x1 = BCPBallot(1, mValue[0]);

            REQUIRE(mBCP.mEnvs.length == 1);
            verifyPrepare(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, x1);

            recvQuorum(makePrepareGen(mQSetHash, x1));
            // quorum . prepared (1,x)
            REQUIRE(mBCP.mEnvs.length == 2);
            verifyPrepare(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, x1, &x1);

            BCPBallot x2 = BCPBallot(2, mValue[0]);
            // timeout from local node
            REQUIRE(mBCP.bumpState(0, mValue[0]));
            // prepares (2,x)
            REQUIRE(mBCP.mEnvs.length == 3);
            verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0, x2, &x1);

            recvQuorum(makePrepareGen(mQSetHash, x1, &x1));
            // quorum . set nH=1
            REQUIRE(mBCP.mEnvs.length == 4);
            verifyPrepare(mBCP.mEnvs[3], mSecretKey[0], mQSetHash0, 0, x2, &x1, 0, 1);
            REQUIRE(mBCP.mEnvs.length == 4);

            recvVBlocking(makePrepareGen(mQSetHash, x2, &x2, 1, 1));
            // v-blocking prepared (2,x) . prepared (2,x)
            REQUIRE(mBCP.mEnvs.length == 5);
            verifyPrepare(mBCP.mEnvs[4], mSecretKey[0], mQSetHash0, 0, x2, &x2, 0, 1);

            recvQuorum(makePrepareGen(mQSetHash, x2, &x2, 1, 1));
            // quorum (including us) confirms (2,x) prepared . set h=c=x2
            // we also get extra message: a quorum not including us confirms (1,x)
            // prepared
            //  . we confirm c=h=x1
            REQUIRE(mBCP.mEnvs.length == 7);
            verifyPrepare(mBCP.mEnvs[5], mSecretKey[0], mQSetHash0, 0, x2, &x2, 2, 2);
            verifyConfirm(mBCP.mEnvs[6], mSecretKey[0], mQSetHash0, 0, 2, x2, 1, 1);
        }
    }

    //  timeout after prepare, receive old messages to prepare
    void ballotProtocolTest10()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();

        SECTION("timeout after prepare, receive old messages to prepare");
        {
            REQUIRE(mBCP.bumpState(0, mValue[0]));

            BCPBallot x1 = BCPBallot(1, mValue[0]);

            REQUIRE(mBCP.mEnvs.length == 1);
            verifyPrepare(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, x1);

            BCPEnvelope envelope;

            envelope = makePrepare(mSecretKey[1], mQSetHash, 0, x1);
            mBCP.receiveEnvelope(envelope);

            envelope = makePrepare(mSecretKey[2], mQSetHash, 0, x1);
            mBCP.receiveEnvelope(envelope);

            envelope = makePrepare(mSecretKey[3], mQSetHash, 0, x1);
            mBCP.receiveEnvelope(envelope);

            // quorum . prepared (1,x)
            REQUIRE(mBCP.mEnvs.length == 2);
            verifyPrepare(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, x1, &x1);

            BCPBallot x2 = BCPBallot(2, mValue[0]);
            // timeout from local node
            REQUIRE(mBCP.bumpState(0, mValue[0]));
            // prepares (2,x)
            REQUIRE(mBCP.mEnvs.length == 3);
            verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0, x2, &x1);

            BCPBallot x3 = BCPBallot(3, mValue[0]);
            // timeout again
            REQUIRE(mBCP.bumpState(0, mValue[0]));
            // prepares (3,x)
            REQUIRE(mBCP.mEnvs.length == 4);
            verifyPrepare(mBCP.mEnvs[3], mSecretKey[0], mQSetHash0, 0, x3, &x1);

            // other nodes moved on with x2
            envelope = makePrepare(mSecretKey[1], mQSetHash, 0, x2, &x2, 1, 2);
            mBCP.receiveEnvelope(envelope);
            envelope = makePrepare(mSecretKey[2], mQSetHash, 0, x2, &x2, 1, 2);
            mBCP.receiveEnvelope(envelope);
            // v-blocking . prepared x2
            REQUIRE(mBCP.mEnvs.length == 5);
            verifyPrepare(mBCP.mEnvs[4], mSecretKey[0], mQSetHash0, 0, x3, &x2);

            envelope = makePrepare(mSecretKey[3], mQSetHash, 0, x2, &x2, 1, 2);
            mBCP.receiveEnvelope(envelope);
            // quorum . set nH=2
            REQUIRE(mBCP.mEnvs.length == 6);
            verifyPrepare(mBCP.mEnvs[5], mSecretKey[0], mQSetHash0, 0, x3, &x2, 0, 2);
        }
    }

    //  non validator watching the network
    void ballotProtocolTest11()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Init();

        SECTION("non validator watching the network");
        {
            SIMULATION_CREATE_NODE(5);
            TestCP cpNV = new TestCP(mSecretKey[5], mQSet, false);
            cpNV.storeQuorumSet(mQSet);
            Hash mQSetHashNV = cpNV.mBCP.getLocalNode().getQuorumSetHash();

            BCPBallot b = BCPBallot(1, mValue[0]);
            REQUIRE(cpNV.bumpState(0, mValue[0]));
            REQUIRE(cpNV.mEnvs.length == 0);

            BCPEnvelope envelope = cpNV.getCurrentEnvelope(0, mKey[5]);
            verifyPrepare(envelope, mSecretKey[5], mQSetHashNV, 0, b);

            auto ext1 = makeExternalize(mSecretKey[1], mQSetHash, 0, b, 1);
            auto ext2 = makeExternalize(mSecretKey[2], mQSetHash, 0, b, 1);
            auto ext3 = makeExternalize(mSecretKey[3], mQSetHash, 0, b, 1);
            auto ext4 = makeExternalize(mSecretKey[4], mQSetHash, 0, b, 1);
            cpNV.receiveEnvelope(ext1);
            cpNV.receiveEnvelope(ext2);
            cpNV.receiveEnvelope(ext3);

            REQUIRE(cpNV.mEnvs.length == 0);
            envelope = cpNV.getCurrentEnvelope(0, mKey[5]);
            BCPBallot bmax = BCPBallot(UINT32_MAX, mValue[0]);
            verifyConfirm(envelope, mSecretKey[5], mQSetHashNV, 0,
                    UINT32_MAX, bmax, 1, UINT32_MAX);

            cpNV.receiveEnvelope(ext4);
            REQUIRE(cpNV.mEnvs.length == 0);

            envelope = cpNV.getCurrentEnvelope(0, mKey[5]);
            verifyExternalize(envelope, mSecretKey[5], mQSetHashNV, 0, b, UINT32_MAX);

            REQUIRE(cpNV.mExternalizedValues[0] == mValue[0]);
        }

    }

    //  restore ballot protocol
    void ballotProtocolTest12()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        SECTION("restore ballot protocol");
        {
            SECTION("prepare");
            {
                BCPQuorumSet qSet;
                qSet.threshold = 4;
                qSet.validators ~= (mKey[0]);
                qSet.validators ~= (mKey[1]);
                qSet.validators ~= (mKey[2]);
                qSet.validators ~= (mKey[3]);
                qSet.validators ~= (mKey[4]);

                mQSet = qSet;
                mQSetHash = Hash(sha256Of(xdr!BCPQuorumSet.serialize(mQSet)));

                TestCP cp2 = new TestCP(mSecretKey[0], mQSet);
                mQSetHash0 = cast(Hash) cp2.mBCP.getLocalNode().getQuorumSetHash();

                cp2.storeQuorumSet(mQSet);
                BCPBallot b = BCPBallot(2, mValue[0]);
                BCPEnvelope env = makePrepare(mSecretKey[0], mQSetHash0, 0, b);
                cp2.mBCP.setStateFromEnvelope(0, env);
            }
            SECTION("confirm");
            {
                BCPQuorumSet qSet;
                qSet.threshold = 4;
                qSet.validators ~= (mKey[0]);
                qSet.validators ~= (mKey[1]);
                qSet.validators ~= (mKey[2]);
                qSet.validators ~= (mKey[3]);
                qSet.validators ~= (mKey[4]);

                mQSet = qSet;
                mQSetHash = Hash(sha256Of(xdr!BCPQuorumSet.serialize(mQSet)));

                TestCP cp2 = new TestCP(mSecretKey[0], mQSet);
                mQSetHash0 = cast(Hash) cp2.mBCP.getLocalNode().getQuorumSetHash();

                cp2.storeQuorumSet(mQSet);
                BCPBallot b = BCPBallot(2, mValue[0]);
                BCPEnvelope env = makeConfirm(mSecretKey[0], mQSetHash0, 0, 2, b, 1, 2);
                cp2.mBCP.setStateFromEnvelope(0, env);
            }
            SECTION("externalize");
            {
                BCPQuorumSet qSet;
                qSet.threshold = 4;
                qSet.validators ~= (mKey[0]);
                qSet.validators ~= (mKey[1]);
                qSet.validators ~= (mKey[2]);
                qSet.validators ~= (mKey[3]);
                qSet.validators ~= (mKey[4]);

                mQSet = qSet;
                mQSetHash = Hash(sha256Of(xdr!BCPQuorumSet.serialize(mQSet)));

                TestCP cp2 = new TestCP(mSecretKey[0], mQSet);
                mQSetHash0 = cast(Hash) cp2.mBCP.getLocalNode().getQuorumSetHash();

                cp2.storeQuorumSet(mQSet);
                BCPBallot b = BCPBallot(2, mValue[0]);
                BCPEnvelope env = makeExternalize(mSecretKey[0], mQSetHash0, 0, b, 2);
                cp2.mBCP.setStateFromEnvelope(0, env);
            }
        }
    }

    void nominationProtocolTest1()
    {
        TEST_CASE("nomination tests core5", "[scp][nominationprotocol]");

        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Value[] votes, accepted, votes2;
        BCPEnvelope nom1, nom2, nom3, nom4;
        BCPEnvelope acc1, acc2, acc3, acc4;

        Init();

        auto TEST_initVotes = () {
            votes.length = 0;
            accepted.length = 0;
            votes2.length = 0;
        };
        TEST_initVotes();

        REQUIRE(mValue[0].value < mValue[1].value);

        SECTION("others nominate what v0 says (x) -> prepare x");
        {
            auto TEST_nomiate_x = () {
                REQUIRE(mBCP.nominate(0, mValue[0], false));

                votes ~= mValue[0];

                REQUIRE(mBCP.mEnvs.length == 1);
                verifyNominate(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, votes, accepted);

                nom1 = makeNominate(mSecretKey[1], mQSetHash, 0, votes, accepted);
                nom2 = makeNominate(mSecretKey[2], mQSetHash, 0, votes, accepted);
                nom3 = makeNominate(mSecretKey[3], mQSetHash, 0, votes, accepted);
                nom4 = makeNominate(mSecretKey[4], mQSetHash, 0, votes, accepted);

                // nothing happens yet
                mBCP.receiveEnvelope(nom1);
                mBCP.receiveEnvelope(nom2);
                REQUIRE(mBCP.mEnvs.length == 1);

                // this causes 'x' to be accepted (quorum)
                mBCP.receiveEnvelope(nom3);
                REQUIRE(mBCP.mEnvs.length == 2);

                mBCP.mExpectedCandidates.insert(mValue[0]);
                mBCP.mCompositeValue = mValue[0];

                accepted ~= mValue[0];
                verifyNominate(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, votes, accepted);

                // extra message doesn't do anything
                mBCP.receiveEnvelope(nom4);
                REQUIRE(mBCP.mEnvs.length == 2);

                acc1 = makeNominate(mSecretKey[1], mQSetHash, 0, votes, accepted);
                acc2 = makeNominate(mSecretKey[2], mQSetHash, 0, votes, accepted);
                acc3 = makeNominate(mSecretKey[3], mQSetHash, 0, votes, accepted);
                acc4 = makeNominate(mSecretKey[4], mQSetHash, 0, votes, accepted);

                // nothing happens yet
                mBCP.receiveEnvelope(acc1);
                mBCP.receiveEnvelope(acc2);
                REQUIRE(mBCP.mEnvs.length == 2);

                mBCP.mCompositeValue = mValue[0];
                // this causes the node to send a prepare message (quorum)
                mBCP.receiveEnvelope(acc3);
                REQUIRE(mBCP.mEnvs.length == 3);

                BCPBallot b = BCPBallot(1, mValue[0]);
                verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0, b);

                mBCP.receiveEnvelope(acc4);
                REQUIRE(mBCP.mEnvs.length == 3);

                votes2 = votes.dup;
                votes2 ~= (mValue[1]);
            };

            TEST_nomiate_x();
            SECTION(
                    "nominate x -> accept x -> prepare (x) ; others accepted y -> update latest to (z=x+y)");
            {
                BCPEnvelope acc1_2 = makeNominate(mSecretKey[1], mQSetHash, 0, votes2, votes2);
                BCPEnvelope acc2_2 = makeNominate(mSecretKey[2], mQSetHash, 0, votes2, votes2);
                BCPEnvelope acc3_2 = makeNominate(mSecretKey[3], mQSetHash, 0, votes2, votes2);
                BCPEnvelope acc4_2 = makeNominate(mSecretKey[4], mQSetHash, 0, votes2, votes2);

                mBCP.receiveEnvelope(acc1_2);
                REQUIRE(mBCP.mEnvs.length == 3);

                // v-blocking
                mBCP.receiveEnvelope(acc2_2);
                REQUIRE(mBCP.mEnvs.length == 4);
                verifyNominate(mBCP.mEnvs[3], mSecretKey[0], mQSetHash0, 0, votes2, votes2);

                mBCP.mExpectedCandidates.insert(mValue[1]);
                mBCP.mCompositeValue = mValue[2];
                // this updates the composite value to use next time
                // but does not prepare it
                mBCP.receiveEnvelope(acc3_2);
                REQUIRE(mBCP.mEnvs.length == 4);

                REQUIRE(mBCP.getLatestCompositeCandidate(0) == mValue[2]);

                mBCP.receiveEnvelope(acc4_2);
                REQUIRE(mBCP.mEnvs.length == 4);

            }

            SECTION("nomination - restored state");
            {
                TestCP cp2;
                auto createCP = () {
                    cp2 = new TestCP(mSecretKey[0], mQSet);
                    cp2.storeQuorumSet(mQSet);
                };

                // at this point
                // votes = { x }
                // accepted = { x }

                // tests if nomination proceeds like normal
                // nominates x
                auto nominationRestore = () {
                    // restores from the previous state
                    BCPEnvelope envelope = makeNominate(mSecretKey[0], mQSetHash0, 0, votes, accepted);
                    cp2.mBCP.setStateFromEnvelope(0, envelope);
                    // tries to start nomination with mValue[1]
                    REQUIRE(cp2.nominate(0, mValue[1], false));

                    REQUIRE(cp2.mEnvs.length == 1);
                    verifyNominate(cp2.mEnvs[0], mSecretKey[0], mQSetHash0, 0, votes2, accepted);

                    // other nodes vote for 'x'
                    cp2.receiveEnvelope(nom1);
                    cp2.receiveEnvelope(nom2);
                    REQUIRE(cp2.mEnvs.length == 1);
                    // 'x' is accepted (quorum)
                    // but because the restored state already included
                    // 'x' in the accepted set, no new message is emitted
                    cp2.receiveEnvelope(nom3);

                    cp2.mExpectedCandidates.insert(mValue[0]);
                    cp2.mCompositeValue = mValue[0];

                    // other nodes not emit 'x' as accepted
                    cp2.receiveEnvelope(acc1);
                    cp2.receiveEnvelope(acc2);
                    REQUIRE(cp2.mEnvs.length == 1);

                    cp2.mCompositeValue = mValue[0];
                    // this causes the node to update its composite value to x
                    cp2.receiveEnvelope(acc3);
                };

                SECTION("ballot protocol not started");
                {
                    createCP();
                    nominationRestore();
                    // nomination ended up starting the ballot protocol
                    REQUIRE(cp2.mEnvs.length == 2);

                    BCPBallot b = BCPBallot(1, mValue[0]);
                    verifyPrepare(cp2.mEnvs[1], mSecretKey[0], mQSetHash0, 0, b);
                }

                SECTION("ballot protocol started (on value z)");
                {
                    BCPBallot b = BCPBallot(1, mValue[2]);
                    createCP();
                    BCPEnvelope envelope = makePrepare(mSecretKey[0], mQSetHash0, 0, b);
                    cp2.mBCP.setStateFromEnvelope(0, envelope);

                    nominationRestore();
                    // nomination didn't do anything (already working on z)
                    REQUIRE(cp2.mEnvs.length == 1);
                }
            }
        }
    }

    void nominationProtocolTest2()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        SECTION("self nominates 'x', others nominate y -> prepare y");
        {
            SECTION("others only vote for y");
            {
                Init();
                Value[] myVotes, accepted, votes, acceptedY;
                myVotes ~= (mValue[0]);

                mBCP.mExpectedCandidates.insert(mValue[0]);
                mBCP.mCompositeValue = mValue[0];
                REQUIRE(mBCP.nominate(0, mValue[0], false));

                REQUIRE(mBCP.mEnvs.length == 1);
                verifyNominate(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, myVotes, accepted);

                votes ~= (mValue[1]);
                acceptedY = accepted.dup;
                acceptedY ~= (mValue[1]);

                BCPEnvelope nom1 = makeNominate(mSecretKey[1], mQSetHash, 0, votes, accepted);
                BCPEnvelope nom2 = makeNominate(mSecretKey[2], mQSetHash, 0, votes, accepted);
                BCPEnvelope nom3 = makeNominate(mSecretKey[3], mQSetHash, 0, votes, accepted);
                BCPEnvelope nom4 = makeNominate(mSecretKey[4], mQSetHash, 0, votes, accepted);

                // nothing happens yet
                mBCP.receiveEnvelope(nom1);
                mBCP.receiveEnvelope(nom2);
                mBCP.receiveEnvelope(nom3);
                REQUIRE(mBCP.mEnvs.length == 1);

                // 'y' is accepted (quorum)
                mBCP.receiveEnvelope(nom4);
                REQUIRE(mBCP.mEnvs.length == 2);
                myVotes ~= (mValue[1]);
                verifyNominate(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, myVotes, acceptedY);
            }

            SECTION("others accepted y");
            {
                Init();
                Value[] myVotes, accepted, votes, acceptedY;
                myVotes ~= (mValue[0]);

                mBCP.mExpectedCandidates.insert(mValue[0]);
                mBCP.mCompositeValue = mValue[0];
                REQUIRE(mBCP.nominate(0, mValue[0], false));

                REQUIRE(mBCP.mEnvs.length == 1);
                verifyNominate(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, myVotes, accepted);

                votes ~= (mValue[1]);
                acceptedY = accepted.dup;
                acceptedY ~= (mValue[1]);

                BCPEnvelope acc1 = makeNominate(mSecretKey[1], mQSetHash, 0, votes, acceptedY);
                BCPEnvelope acc2 = makeNominate(mSecretKey[2], mQSetHash, 0, votes, acceptedY);
                BCPEnvelope acc3 = makeNominate(mSecretKey[3], mQSetHash, 0, votes, acceptedY);
                BCPEnvelope acc4 = makeNominate(mSecretKey[4], mQSetHash, 0, votes, acceptedY);

                mBCP.receiveEnvelope(acc1);
                REQUIRE(mBCP.mEnvs.length == 1);

                // this causes 'y' to be accepted (v-blocking)
                mBCP.receiveEnvelope(acc2);
                REQUIRE(mBCP.mEnvs.length == 2);

                myVotes ~= (mValue[1]);
                verifyNominate(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, myVotes, acceptedY);

                mBCP.mExpectedCandidates.clear();
                mBCP.mExpectedCandidates.insert(mValue[1]);
                mBCP.mCompositeValue = mValue[1];

                // this causes the node to send a prepare message (quorum)
                mBCP.receiveEnvelope(acc3);
                REQUIRE(mBCP.mEnvs.length == 3);

                BCPBallot b = BCPBallot(1, mValue[1]);
                verifyPrepare(mBCP.mEnvs[2], mSecretKey[0], mQSetHash0, 0, b);

                mBCP.receiveEnvelope(acc4);
                REQUIRE(mBCP.mEnvs.length == 3);
            }
        }

    }

    void nominationProtocolTest3()
    {
        SIMULATION_CREATE_NODE(0);
        SIMULATION_CREATE_NODE(1);
        SIMULATION_CREATE_NODE(2);
        SIMULATION_CREATE_NODE(3);
        SIMULATION_CREATE_NODE(4);

        Value[] votesX, votesY, votesZ, votesXY, votesYZ, votesXZ, emptyV;
        Value[] valuesHash;
        BCPEnvelope nom1, nom2, nom3, nom4;

        Init();

        auto InitVotes = () {
            votesX.length = 0;
            votesY.length = 0;
            votesZ.length = 0;

            votesXY.length = 0;
            votesYZ.length = 0;
            votesXZ.length = 0;

            emptyV.length = 0;

            valuesHash.length = 0;

            votesX ~= mValue[0];
            votesY ~= mValue[1];
            votesZ ~= mValue[2];

            votesXY ~= mValue[0];
            votesXY ~= mValue[1];

            votesYZ ~= mValue[1];
            votesYZ ~= mValue[2];

            votesXZ ~= mValue[0];
            votesXZ ~= mValue[2];

            valuesHash ~= mValue[0];
            valuesHash ~= mValue[1];
            valuesHash ~= mValue[2];
        };
        InitVotes();

        SECTION("v1 is top node");
        {
            auto InitDelegate = () {
                mBCP.mPriorityLookup = (ref const NodeID n) {
                    return (n == mKey[1]) ? 1000 : 1;
                };

                mBCP.mHashValueCalculator = (ref const Value v) {
                    for (int idx = 0; idx < valuesHash.length; idx++)
                    {
                        if (valuesHash[idx] == v)
                        {
                            return idx + 1;
                        }
                    }
                    return 0;
                };

                nom1 = makeNominate(mSecretKey[1], mQSetHash, 0, votesXY, emptyV);
                nom2 = makeNominate(mSecretKey[2], mQSetHash, 0, votesXZ, emptyV);

            };

            InitDelegate();

            SECTION("nomination waits for v1");
            {
                nom3 = makeNominate(mSecretKey[3], mQSetHash, 0, votesYZ, emptyV);
                nom4 = makeNominate(mSecretKey[4], mQSetHash, 0, votesXZ, emptyV);

                REQUIRE(!mBCP.nominate(0, mValue[0], false));

                REQUIRE(mBCP.mEnvs.length == 0);

                // nothing happens with non top nodes
                mBCP.receiveEnvelope(nom2);
                mBCP.receiveEnvelope(nom3);
                REQUIRE(mBCP.mEnvs.length == 0);

                mBCP.receiveEnvelope(nom1);
                REQUIRE(mBCP.mEnvs.length == 1);
                verifyNominate(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, votesY, emptyV);

                mBCP.receiveEnvelope(nom4);
                REQUIRE(mBCP.mEnvs.length == 1);

                SECTION("timeout -> pick another value from v1");
                {
                    mBCP.mExpectedCandidates.insert(mValue[0]);
                    mBCP.mCompositeValue = mValue[0];

                    // note: value passed in here should be ignored
                    REQUIRE(mBCP.nominate(0, mValue[2], true));

                    // picks up 'x' from v1 (as we already have 'y')
                    // which also happens to causes 'x' to be accepted
                    REQUIRE(mBCP.mEnvs.length == 2);
                    verifyNominate(mBCP.mEnvs[1], mSecretKey[0], mQSetHash0, 0, votesXY, votesX);
                }
            }

            SECTION("v1 dead, timeout");
            {
                auto TEST_vi_dead_timeout = () {
                    REQUIRE(!mBCP.nominate(0, mValue[0], false));
                    REQUIRE(mBCP.mEnvs.length == 0);
                    mBCP.receiveEnvelope(nom2);
                    REQUIRE(mBCP.mEnvs.length == 0);
                };

                Init();
                InitVotes();
                InitDelegate();
                TEST_vi_dead_timeout();

                SECTION("v0 is new top node");
                {
                    mBCP.mPriorityLookup = (ref const NodeID n) {
                        return (n == mKey[0]) ? 1000 : 1;
                    };
                    REQUIRE(mBCP.nominate(0, mValue[0], true));
                    REQUIRE(mBCP.mEnvs.length == 1);
                    verifyNominate(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, votesX, emptyV);
                }

                Init();
                InitVotes();
                InitDelegate();
                TEST_vi_dead_timeout();

                SECTION("v2 is new top node");
                {
                    mBCP.mPriorityLookup = (ref const NodeID n) {
                        return (n == mKey[2]) ? 1000 : 1;
                    };
                    REQUIRE(mBCP.nominate(0, mValue[0], true));
                    REQUIRE(mBCP.mEnvs.length == 1);
                    verifyNominate(mBCP.mEnvs[0], mSecretKey[0], mQSetHash0, 0, votesZ, emptyV);
                }

                Init();
                InitVotes();
                InitDelegate();
                TEST_vi_dead_timeout();

                SECTION("v3 is new top node");
                {
                    mBCP.mPriorityLookup = (ref const NodeID n) {
                        return (n == mKey[3]) ? 1000 : 1;
                    };
                    // nothing happens, we don't have any message for v3
                    REQUIRE(!mBCP.nominate(0, mValue[0], true));
                    REQUIRE(mBCP.mEnvs.length == 0);
                }
            }
        }
    }

    void test()
    {
        ballotProtocolTest1();
        ballotProtocolTest2();
        ballotProtocolTest3();
        ballotProtocolTest4();
        ballotProtocolTest5();
        ballotProtocolTest6();
        ballotProtocolTest7();
        ballotProtocolTest8();
        ballotProtocolTest9();
        ballotProtocolTest10();
        ballotProtocolTest11();
        ballotProtocolTest12();
        nominationProtocolTest1();
        nominationProtocolTest2();
        nominationProtocolTest3();
        dump();
        dumpEnv();
    }

    void dump()
    {
        import std.json;

        JSONValue[string] jsonObject;
        JSONValue info = jsonObject;

        mBCP.mBCP.dumpInfo(info, 1);
        writeln(info.toPrettyString());
    }

    void dumpEnv()
    {
        import std.json;

        JSONValue[string] jsonObject;
        JSONValue info = jsonObject;

        writefln("%s", "mBCP.mEnvs");
        for (int idx = 0; idx < mBCP.mEnvs.length; idx++)
        {
            writefln("%s", mBCP.mBCP.envToStr(mBCP.mEnvs[idx].statement));
        }
    }
}
