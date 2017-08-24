module owlchain.consensus.tests.arrayTest;

import std.stdio;
import std.conv;
import std.math;
import std.digest.sha;
import std.algorithm.comparison : equal;
import std.algorithm: canFind;
import deimos.sodium;

import owlchain.xdr.type;
import owlchain.xdr.publicKey;
import owlchain.xdr.publicKeyType;
import owlchain.xdr.nodeID;
import owlchain.xdr.quorumSet;
import owlchain.xdr.ballot;
import owlchain.utils.uniqueStruct;

import owlchain.utils.globalChecks;

class ArrayTest
{
private:

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
        SECTION("envelope");
        {
            import owlchain.xdr.envelope;
            import owlchain.xdr.ballot;
            import owlchain.xdr.nomination;
            import owlchain.xdr.statement;
            import owlchain.xdr.statementType;

            Envelope envelope;
            auto st = &envelope.statement;
            auto nom = &st.pledges.nominate;

            st.slotIndex = 100;
            writefln("st.slotIndex = %d", st.slotIndex);
            writefln("envelope.statement.slotIndex = %d", envelope.statement.slotIndex);

        }

        SECTION("instance of array");
        {
            QuorumSet[] v1;

            QuorumSet qSet1;
            qSet1.threshold = 1;
            qSet1.validators ~= (mKeys[0]);

            v1 ~= qSet1;
            qSet1.threshold = 2;

            writefln("v1[0].threshold = %d", v1[0].threshold);
            writefln("qSet1.threshold = %d", qSet1.threshold);
        }

        SECTION("find in array");
        {
            NodeID[] nodeSet;

            NodeID validator = mKeys[3];

            nodeSet ~= mKeys[0];
            nodeSet ~= mKeys[1];
            nodeSet ~= mKeys[2];
            nodeSet ~= mKeys[3];
            nodeSet ~= mKeys[4];
            nodeSet ~= mKeys[5];

            REQUIRE(nodeSet.canFind(validator));
        }

        SECTION("merge of array");
        {
            NodeID[] nodeSet1;
            NodeID[] nodeSet2;
            NodeID[] nodeSet3;

            nodeSet1.length = 0;
            nodeSet1 ~= mKeys[0];
            nodeSet1 ~= mKeys[1];
            nodeSet1 ~= mKeys[2];
            nodeSet1 ~= mKeys[3];
            nodeSet1 ~= mKeys[4];

            nodeSet2.length = 0;
            nodeSet2 ~= mKeys[0];
            nodeSet2 ~= mKeys[1];
            nodeSet2 ~= mKeys[2];
            nodeSet2 ~= mKeys[3];

            nodeSet1 ~= nodeSet2;

            nodeSet3.length = 0;
            nodeSet3 ~= mKeys[0];
            nodeSet3 ~= mKeys[1];
            nodeSet3 ~= mKeys[2];
            nodeSet3 ~= mKeys[3];
            nodeSet3 ~= mKeys[4];
            nodeSet3 ~= mKeys[0];
            nodeSet3 ~= mKeys[1];
            nodeSet3 ~= mKeys[2];
            nodeSet3 ~= mKeys[3];

            REQUIRE(equal(nodeSet1, nodeSet3));
        }

        SECTION("array in map");
        {
            import std.algorithm : sort;
            NodeID[][] nodeMultiSet;
            NodeID[] nodeSet;

            nodeSet.length = 0;
            nodeSet ~= mKeys[0];
            nodeSet ~= mKeys[1];
            nodeSet ~= mKeys[2];
            nodeSet ~= mKeys[3];
            nodeSet ~= mKeys[4];
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= mKeys[0];
            nodeSet ~= mKeys[1];
            nodeSet ~= mKeys[2];
            nodeSet ~= mKeys[3];
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= mKeys[0];
            nodeSet ~= mKeys[1];
            nodeSet ~= mKeys[2];
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= mKeys[0];
            nodeSet ~= mKeys[1];
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            nodeSet.length = 0;
            nodeSet ~= mKeys[0];
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            for (int i = 0; i < nodeMultiSet.length; i++)
            {
                REQUIRE(nodeMultiSet[i].length == 5 - i);
            }

            alias myComp = (x, y) => x.length < y.length;
            nodeMultiSet.sort!(myComp).release;

            for (int i = 0; i < nodeMultiSet.length; i++)
            {
                REQUIRE(nodeMultiSet[i].length == i+1);
            }
        }

        SECTION("sort of array");
        {
            import std.algorithm;

            NodeID[] nodeSet;

            nodeSet ~= mKeys[0];
            nodeSet ~= mKeys[1];
            nodeSet ~= mKeys[2];
            nodeSet ~= mKeys[3];
            nodeSet ~= mKeys[4];
            nodeSet ~= mKeys[5];

            nodeSet.sort!("a.ed25519 > b.ed25519");

            for (int i = 0; i < nodeSet.length-1; i++)
            {
                REQUIRE(nodeSet[i].ed25519 > nodeSet[i+1].ed25519);
            }
        }

        SECTION("set of NodeID - RedBlackTree !(NodeID, \"a.publicKey.ed25519 < b.publicKey.ed25519\")");
        {
            import std.container.rbtree;
            ulong n;

            NodeIDSet nodeSet = new NodeIDSet;

            n = nodeSet.insert(mKeys[0]);
            REQUIRE(n == 1);

            n = nodeSet.insert(mKeys[1]);
            REQUIRE(n == 1);

            n = nodeSet.insert(mKeys[2]);
            REQUIRE(n == 1);

            n = nodeSet.insert(mKeys[3]);
            REQUIRE(n == 1);

            n = nodeSet.insert(mKeys[4]);
            REQUIRE(n == 1);

            n = nodeSet.insert(mKeys[0]);
            REQUIRE(n == 0);

            n = nodeSet.insert(mKeys[1]);
            REQUIRE(n == 0);

            n = nodeSet.insert(mKeys[2]);
            REQUIRE(n == 0);

            n = nodeSet.insert(mKeys[5]);
            REQUIRE(n == 1);
        }

        SECTION("DList!NodeID");
        {
            import std.container;
            import std.range;

            DList!NodeID backlog;

            backlog.insertBack(mKeys[0]);
            assert(walkLength(backlog[]) == 1);

            backlog.insertBack(mKeys[1]);
            assert(walkLength(backlog[]) == 2);

            backlog.insertBack(mKeys[2]);
            assert(walkLength(backlog[]) == 3);

            backlog.removeFront();
            assert(walkLength(backlog[]) == 2);

            foreach(NodeID n; backlog)
            {
                writefln("%s", toHexString(n.ed25519));
            }

        }

        SECTION("drop");
        {
            import std.range;
            writeln([0, 2, 1, 5, 0, 3].takeExactly(3)); // [5, 0, 3]
        }

        SECTION("sequence of map");
        {
            import std.algorithm : sort;
            int[string] set;

            set["2"] = 2;
            set["1"] = 1;
            set["4"] = 4;
            set["7"] = 7;
            set["6"] = 6;
            set["7"] = 7;
            set["8"] = 8;

            foreach (string key, int value; set)
            {
                writefln("%s %d", key, value);
            }
        }

        struct SampleData
        {
            int counter;

            ~this()
            {
                writeln("Free SampleData");
            }
        }

        SECTION("Unique!SampleData");
        {
            import std.typecons;
            Unique!SampleData u1;

            assert(u1.isEmpty);
            u1 = cast(Unique!SampleData)(new SampleData(1));
            assert(u1.counter == 1);

            u1 = cast(Unique!SampleData)(new SampleData(2));
            assert(u1.counter == 2);

        }
        SECTION("UniqueStruct!SampleData");
        {
            import std.typecons;
            UniqueStruct!SampleData u1;

            assert(u1.isEmpty);
            u1 = cast(UniqueStruct!SampleData)(new SampleData(1));
            assert(u1.counter == 1);

            u1 = cast(UniqueStruct!SampleData)(new SampleData(2));
            assert(u1.counter == 2);

        }
    }

}