module owlchain.consensus.tests.quorumSetTest;

import std.stdio;
import std.conv;
import std.json;
import std.string;
import std.digest.sha;
import std.algorithm.comparison : equal;
import std.algorithm: canFind;
import deimos.sodium;

import owlchain.xdr.type;
import owlchain.xdr.publicKey;
import owlchain.xdr.publicKeyType;
import owlchain.xdr.nodeID;
import owlchain.xdr.quorumSet;

import owlchain.consensus.quorumSetUtils;

import owlchain.utils.globalChecks;

class QuorumSetTest
{

private :
    PublicKey [] mKeys;

    PublicKey makePublicKey(int i)
    {
        string seedStr = "NODE_SEED_"  ~  to!string(i, 10);
        uint256 seed = sha256Of(seedStr);
        uint256 pk;
        uint512 sk;

        crypto_sign_seed_keypair(pk.ptr, sk.ptr, seed.ptr);

        PublicKey pKey;
        pKey.ed25519 = pk;
    
        return pKey;
    }

    QuorumSet makeSingleton(PublicKey key)
    {
        QuorumSet qSet;
        qSet.threshold = 1;
        qSet.validators ~= key;
        return qSet;
    }

    void check(ref QuorumSet qSetCheck, bool expected, ref const QuorumSet expectedSelfQSet)
    {
        // first, without normalization
        REQUIRE(expected == isQuorumSetSane(qSetCheck, false));

        // secondary test: attempts to build local node with the set
        // (this normalizes the set)
        auto normalizedQSet = qSetCheck;
        normalizeQSet(normalizedQSet);
        auto selfIsSane = isQuorumSetSane(qSetCheck, false);

        REQUIRE(expected == selfIsSane);
        REQUIRE(expectedSelfQSet == normalizedQSet);
    }

public :

    this()
    {

    }

    void prepare()
    {
        for (int i = 0; i < 1001; i++)
        {
            mKeys ~= makePublicKey(i);
        }
    }

    void test()
    {
        SECTION("{ t: 0 }");
        {
            QuorumSet qSet;
            qSet.threshold = 0L;
            check(qSet, false, qSet);
        }

        QuorumSet validOneNode = makeSingleton(mKeys[0]);

        SECTION("{ t: 0, v0 }");
        {
            QuorumSet qSet = validOneNode;
            qSet.threshold = 0L;
            check(qSet, false, qSet);
        }

        SECTION("{ t: 2, v0 }");
        {
            QuorumSet qSet = validOneNode;
            qSet.threshold = 2;
            check(qSet, false, qSet);
        }

        SECTION("{ t: 1, v0 }");
        {
            QuorumSet qSet = validOneNode;
            qSet.threshold = 1;
            check(qSet, true, qSet);
        }

        SECTION("{ t: 1, v0, { t: 1, v1 } -> { t:1, v0, v1 }");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= mKeys[0];

            auto qSelfSet = qSet;
            qSelfSet.validators ~= mKeys[1];

            qSet.innerSets ~= QuorumSet();
            qSet.innerSets[0].threshold = 1;
            qSet.innerSets[0].validators ~= mKeys[1];

            check(qSet, true, qSelfSet);
        }

        SECTION("{ t: 1, v0, { t: 1, v1 }, { t: 2, v2 } } -> { t:1, v0, v1, { t:2, v2 } }");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= mKeys[0];

            qSet.innerSets ~= QuorumSet();
            qSet.innerSets[0].threshold = 2;
            qSet.innerSets[0].validators ~= mKeys[2];

            auto qSelfSet = qSet;
            qSelfSet.validators ~= mKeys[1];

            qSet.innerSets ~= QuorumSet();
            qSet.innerSets[qSet.innerSets.length-1].threshold = 1;
            qSet.innerSets[qSet.innerSets.length-1].validators ~= mKeys[1];

            check(qSet, false, qSelfSet);
        }

        QuorumSet validMultipleNodes;
        validMultipleNodes.threshold = 1;
        validMultipleNodes.validators ~= mKeys[0];
        validMultipleNodes.innerSets ~= QuorumSet();
        validMultipleNodes.innerSets[0].threshold = 1;
        validMultipleNodes.innerSets[0].validators ~= mKeys[1];
        validMultipleNodes.innerSets ~= QuorumSet();
        validMultipleNodes.innerSets[1].threshold = 1;
        validMultipleNodes.innerSets[1].validators ~= mKeys[2];
        validMultipleNodes.innerSets[1].validators ~= mKeys[3];

        QuorumSet validMultipleNodesNormalized;
        validMultipleNodesNormalized.threshold = 1;
        validMultipleNodesNormalized.validators ~= mKeys[0];
        validMultipleNodesNormalized.validators ~= mKeys[1];
        validMultipleNodesNormalized.innerSets ~= QuorumSet();
        validMultipleNodesNormalized.innerSets[0].threshold = 1;
        validMultipleNodesNormalized.innerSets[0].validators ~= mKeys[2];
        validMultipleNodesNormalized.innerSets[0].validators ~= mKeys[3];

        SECTION("{ t: 1, v0, { t: 1, v1 }, { t: 1, v2, v3 } } -> { t:1, v0, v1, { t: 1, v2, v3 } }");
        {
            QuorumSet temp = validMultipleNodes;
            check(temp, true, validMultipleNodesNormalized);
        }

        SECTION("{ t: 1, { t: 1, v0, { t: 1, v1 }, { t: 1, v2, v3 } } } -> { t:1, v0, v1, { t: 1, v2, v3 } }");
        {
            QuorumSet containingSet;
            containingSet.threshold = 1;
            containingSet.innerSets ~= validMultipleNodes;

            check(containingSet, true, validMultipleNodesNormalized);
        }

        SECTION("{ t: 1, v0, { t: 1, v1, { t: 1, v2 } } } -> { t: 1, v0, { t: 1, v1, v2 } }");
        {
            auto qSet = makeSingleton(mKeys[0]);
            auto qSet1 = makeSingleton(mKeys[1]);
            auto qSet2 = makeSingleton(mKeys[2]);
            qSet1.innerSets ~= qSet2;
            qSet.innerSets ~= qSet1;

            QuorumSet qSelfSet;
            qSelfSet.threshold = 1;
            qSelfSet.validators ~= mKeys[0];
            qSelfSet.innerSets ~= QuorumSet();
            qSelfSet.innerSets[0].threshold = 1;
            qSelfSet.innerSets[0].validators ~= mKeys[1];
            qSelfSet.innerSets[0].validators ~= mKeys[2];

            check(qSet, true, qSelfSet);
        }

        SECTION("{ t: 1, v0, { t: 1, v1, { t: 1, v2, { t: 1, v3 } } } } -> too deep");
        {
            auto qSet = makeSingleton(mKeys[0]);
            auto qSet1 = makeSingleton(mKeys[1]);
            auto qSet2 = makeSingleton(mKeys[2]);
            auto qSet3 = makeSingleton(mKeys[3]);

            qSet2.innerSets ~= (qSet3);
            qSet1.innerSets ~= (qSet2);
            qSet.innerSets ~= (qSet1);

            QuorumSet qSelfSet;
            qSelfSet.threshold = 1;
            qSelfSet.validators ~= (mKeys[0]);

            qSelfSet.innerSets ~= QuorumSet();
            qSelfSet.innerSets[0].threshold = 1;
            qSelfSet.innerSets[0].validators ~= (mKeys[1]);
            qSelfSet.innerSets[0].innerSets ~= QuorumSet();
            qSelfSet.innerSets[0].innerSets[0].threshold = 1;
            qSelfSet.innerSets[0].innerSets[0].validators ~= (mKeys[2]);
            qSelfSet.innerSets[0].innerSets[0].validators ~= (mKeys[3]);

            check(qSet, false, qSelfSet);
        }

        SECTION("{ t: 1, v0..v999 } -> { t: 1, v0..v999 }");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            for (auto i = 0; i < 1000; i++)
                qSet.validators ~= (mKeys[i]);

            check(qSet, true, qSet);
        }

        SECTION("{ t: 1, v0..v1000 } -> too big");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            for (auto i = 0; i < 1001; i++)
                qSet.validators ~= (mKeys[i]);

            check(qSet, true, qSet);
        }

        SECTION("{ t: 1, v0, { t: 1, v1..v100 }, { t: 1, v101..v200} ... { t: 1, v901..v1000} -> too big");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= (mKeys[0]);
            for (auto i = 0; i < 10; i++)
            {
                qSet.innerSets ~= QuorumSet();
                qSet.innerSets[qSet.innerSets.length-1].threshold = 1;
                for (auto j = i * 100 + 1; j <= (i + 1) * 100; j++)
                    qSet.innerSets[qSet.innerSets.length-1].validators ~= mKeys[j];
            }

            check(qSet, false, qSet);
        }

        SECTION("JSON");
        {
            JSONValue[string] jObject;
            JSONValue value = jObject;

            toJson(validMultipleNodesNormalized, value);

            string j = value.toPrettyString;
            writeln(j);
        }
    }

    void toJson(ref const QuorumSet qSet, ref JSONValue value)
    {
        import std.utf;
        JSONValue[] jArray;
        value.object["t"] = JSONValue(qSet.threshold);
        value.object["v"] = jArray;

        foreach (int i, const PublicKey pk; qSet.validators)
        {
            string pkStr = toHexString(pk.ed25519);
            value["v"].array ~= JSONValue(toUTF8(pkStr)[0..5]);
        }

        foreach (int i, const QuorumSet s; qSet.innerSets)
        {
            JSONValue[string] jObject;
            JSONValue iV = jObject;
            toJson(s, iV);
            value["v"].array ~= iV;
        }
    }
}