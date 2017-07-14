module owlchain.consensus.tests.quorumSetTest;

import std.stdio;
import std.conv;
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

class QuorumSetTest
{

private :
    PublicKey [] _keys;
    string _section;

    void require(bool condition)
    {
        if (!condition)
        {
            writefln("REQUIRE : Does not match.");
        }
    }

    void section(string value)
    {
        _section = value;
        writefln("SECTION : %s", _section);
    }

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
        require(expected == isQuorumSetSane(qSetCheck, false));

        // secondary test: attempts to build local node with the set
        // (this normalizes the set)
        auto normalizedQSet = qSetCheck;
        normalizeQSet(normalizedQSet);
        auto selfIsSane = isQuorumSetSane(qSetCheck, false);

        require(expected == selfIsSane);
        require(expectedSelfQSet == normalizedQSet);
        //require(isEqualQuorumSet(expectedSelfQSet, normalizedQSet));
    }

public :
    this()
    {

    }

    void prepare()
    {
        for (int i = 0; i < 1001; i++)
        {
            _keys ~= makePublicKey(i);
        }
    }

    void test()
    {
        section("{ t: 0 }");
        {
            QuorumSet qSet;
            qSet.threshold = 0L;
            check(qSet, false, qSet);
        }

        QuorumSet validOneNode = makeSingleton(_keys[0]);

        section("{ t: 0, v0 }");
        {
            QuorumSet qSet = validOneNode;
            qSet.threshold = 0L;
            check(qSet, false, qSet);
        }

        section("{ t: 2, v0 }");
        {
            QuorumSet qSet = validOneNode;
            qSet.threshold = 2;
            check(qSet, false, qSet);
        }

        section("{ t: 1, v0 }");
        {
            QuorumSet qSet = validOneNode;
            qSet.threshold = 1;
            check(qSet, true, qSet);
        }

        section("{ t: 1, v0, { t: 1, v1 } -> { t:1, v0, v1 }");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= _keys[0];

            auto qSelfSet = qSet;
            qSelfSet.validators ~= _keys[1];

            qSet.innerSets ~= QuorumSet();
            qSet.innerSets[0].threshold = 1;
            qSet.innerSets[0].validators ~= _keys[1];

            check(qSet, true, qSelfSet);
        }

        section("{ t: 1, v0, { t: 1, v1 }, { t: 2, v2 } } -> { t:1, v0, v1, { t:2, v2 } }");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= _keys[0];

            qSet.innerSets ~= QuorumSet();
            qSet.innerSets[0].threshold = 2;
            qSet.innerSets[0].validators ~= _keys[1];

            auto qSelfSet = qSet;
            qSelfSet.validators ~= _keys[2];

            qSet.innerSets ~= QuorumSet();
            qSet.innerSets[qSet.innerSets.length-1].threshold = 1;
            qSet.innerSets[qSet.innerSets.length-1].validators ~= _keys[2];

            check(qSet, false, qSelfSet);
        }

        QuorumSet validMultipleNodes;
        validMultipleNodes.threshold = 1;
        validMultipleNodes.validators ~= _keys[0];
        validMultipleNodes.innerSets ~= QuorumSet();
        validMultipleNodes.innerSets[0].threshold = 1;
        validMultipleNodes.innerSets[0].validators ~= _keys[1];
        validMultipleNodes.innerSets ~= QuorumSet();
        validMultipleNodes.innerSets[1].threshold = 1;
        validMultipleNodes.innerSets[1].validators ~= _keys[2];
        validMultipleNodes.innerSets[1].validators ~= _keys[3];

        QuorumSet validMultipleNodesNormalized;
        validMultipleNodesNormalized.threshold = 1;
        validMultipleNodesNormalized.validators ~= _keys[0];
        validMultipleNodesNormalized.validators ~= _keys[1];
        validMultipleNodesNormalized.innerSets ~= QuorumSet();
        validMultipleNodesNormalized.innerSets[0].threshold = 1;
        validMultipleNodesNormalized.innerSets[0].validators ~= _keys[2];
        validMultipleNodesNormalized.innerSets[0].validators ~= _keys[3];

        section("{ t: 1, v0, { t: 1, v1 }, { t: 1, v2, v3 } } -> { t:1, v0, v1, { t: 1, v2, v3 } }");
        {
            QuorumSet temp = validMultipleNodes;
            check(temp, true, validMultipleNodesNormalized);
        }

        section("{ t: 1, { t: 1, v0, { t: 1, v1 }, { t: 1, v2, v3 } } } -> { t:1, v0, v1, { t: 1, v2, v3 } }");
        {
            QuorumSet containingSet;
            containingSet.threshold = 1;
            containingSet.innerSets ~= validMultipleNodes;

            check(containingSet, true, validMultipleNodesNormalized);
        }

        section("{ t: 1, v0, { t: 1, v1, { t: 1, v2 } } } -> { t: 1, v0, { t: 1, v1, v2 } }");
        {
            auto qSet = makeSingleton(_keys[0]);
            auto qSet1 = makeSingleton(_keys[1]);
            auto qSet2 = makeSingleton(_keys[2]);
            qSet1.innerSets ~= qSet2;
            qSet.innerSets ~= qSet1;

            QuorumSet qSelfSet;
            qSelfSet.threshold = 1;
            qSelfSet.validators ~= _keys[0];
            qSelfSet.innerSets ~= QuorumSet();
            qSelfSet.innerSets[0].threshold = 1;
            qSelfSet.innerSets[0].validators ~= _keys[1];
            qSelfSet.innerSets[0].validators ~= _keys[2];

            check(qSet, true, qSelfSet);
        }

        section("{ t: 1, v0, { t: 1, v1, { t: 1, v2, { t: 1, v3 } } } } -> too deep");
        {
            auto qSet = makeSingleton(_keys[0]);
            auto qSet1 = makeSingleton(_keys[1]);
            auto qSet2 = makeSingleton(_keys[2]);
            auto qSet3 = makeSingleton(_keys[3]);

            qSet2.innerSets ~= (qSet3);
            qSet1.innerSets ~= (qSet2);
            qSet.innerSets ~= (qSet1);

            QuorumSet qSelfSet;
            qSelfSet.threshold = 1;
            qSelfSet.validators ~= (_keys[0]);

            qSelfSet.innerSets ~= QuorumSet();
            qSelfSet.innerSets[0].threshold = 1;
            qSelfSet.innerSets[0].validators ~= (_keys[1]);
            qSelfSet.innerSets[0].innerSets ~= QuorumSet();
            qSelfSet.innerSets[0].innerSets[0].threshold = 1;
            qSelfSet.innerSets[0].innerSets[0].validators ~= (_keys[2]);
            qSelfSet.innerSets[0].innerSets[0].validators ~= (_keys[3]);

            check(qSet, false, qSelfSet);
        }

        section("{ t: 1, v0..v999 } -> { t: 1, v0..v999 }");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            for (auto i = 0; i < 1000; i++)
                qSet.validators ~= (_keys[i]);

            check(qSet, true, qSet);
        }

        section("{ t: 1, v0..v1000 } -> too big");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            for (auto i = 0; i < 1001; i++)
                qSet.validators ~= (_keys[i]);

            check(qSet, true, qSet);
        }

        section("{ t: 1, v0, { t: 1, v1..v100 }, { t: 1, v101..v200} ... { t: 1, v901..v1000} -> too big");
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= (_keys[0]);
            for (auto i = 0; i < 10; i++)
            {
                qSet.innerSets ~= QuorumSet();
                qSet.innerSets[qSet.innerSets.length-1].threshold = 1;
                for (auto j = i * 100 + 1; j <= (i + 1) * 100; j++)
                    qSet.innerSets[qSet.innerSets.length-1].validators ~= _keys[j];
            }

            check(qSet, false, qSet);
        }
/*
        section("map");
        {
            int[QuorumSet] v1;

            QuorumSet qSet1;
            qSet1.threshold = 1;
            qSet1.validators ~= (_keys[0]);

            QuorumSet qSet2;
            qSet2.threshold = 1;
            qSet2.validators ~= (_keys[0]);

            QuorumSet qSet3;
            qSet3.threshold = 1;
            qSet3.validators ~= (_keys[1]);

            v1[qSet1] = 1;
            v1[qSet2] = 2;
            v1[qSet3] = 3;

            if (v1[qSet1] != 2)
            {
                writefln("Does not match %d", v1[qSet1]);
            } 
            else
            {
                writefln("Match %d", v1[qSet1]);
            }
            writefln("qSet3 = %d", v1[qSet3]);
        }

        section("array");
        {
            QuorumSet[] v1;

            QuorumSet qSet1;
            qSet1.threshold = 1;
            qSet1.validators ~= (_keys[0]);

            v1 ~= qSet1;
            qSet1.threshold = 2;

            writefln("v1[0].threshold = %d", v1[0].threshold);
            writefln("qSet1.threshold = %d", qSet1.threshold);
        }

        section("find in array");
        {
            NodeID[] nodeSet;

            NodeID validator = NodeID(_keys[3]);

            nodeSet ~= NodeID(_keys[0]);

            nodeSet ~= NodeID(_keys[1]);

            nodeSet ~= NodeID(_keys[2]);

            nodeSet ~= NodeID(_keys[3]);

            nodeSet ~= NodeID(_keys[4]);

            nodeSet ~= NodeID(_keys[5]);

            require(nodeSet.canFind(validator));
        }

        section("test of multiset");
        {
            import std.algorithm : sort;
            NodeID[][] nodeMultiSet;
            NodeID[] nodeSet;

            nodeSet.length = 0;
            nodeSet ~= NodeID(_keys[0]);
            nodeSet ~= NodeID(_keys[1]);
            nodeSet ~= NodeID(_keys[2]);
            nodeSet ~= NodeID(_keys[3]);
            nodeSet ~= NodeID(_keys[4]);
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= NodeID(_keys[0]);
            nodeSet ~= NodeID(_keys[1]);
            nodeSet ~= NodeID(_keys[2]);
            nodeSet ~= NodeID(_keys[3]);
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= NodeID(_keys[0]);
            nodeSet ~= NodeID(_keys[1]);
            nodeSet ~= NodeID(_keys[2]);
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= NodeID(_keys[0]);
            nodeSet ~= NodeID(_keys[1]);
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= NodeID(_keys[0]);
            nodeSet ~= NodeID(_keys[1]);
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= NodeID(_keys[0]);
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            for (int i = 0; i < nodeMultiSet.length; i++)
            {
                writefln("%d length = %d", i, nodeMultiSet[i].length);
            }

            alias myComp = (x, y) => x.length < y.length;
            nodeMultiSet.sort!(myComp).release;

            for (int i = 0; i < nodeMultiSet.length; i++)
            {
                writefln("%d length = %d", i, nodeMultiSet[i].length);
            }
        }

        section("test of multiset 2");
        {
            NodeID[] nodeSet1;
            NodeID[] nodeSet2;

            nodeSet1.length = 0;
            nodeSet1 ~= NodeID(_keys[0]);
            nodeSet1 ~= NodeID(_keys[1]);
            nodeSet1 ~= NodeID(_keys[2]);
            nodeSet1 ~= NodeID(_keys[3]);
            nodeSet1 ~= NodeID(_keys[4]);

            nodeSet2.length = 0;
            nodeSet2 ~= NodeID(_keys[0]);
            nodeSet2 ~= NodeID(_keys[1]);
            nodeSet2 ~= NodeID(_keys[2]);
            nodeSet2 ~= NodeID(_keys[3]);

            nodeSet1 ~= nodeSet2;

            for (int i = 0; i < nodeSet1.length; i++)
            {
                writefln("%d %s", i, toHexString(nodeSet1[i].publicKey.ed25519));
            }
        }
        */
    }
}