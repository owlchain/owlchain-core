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

class ArrayTest
{
private:

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
        section("envelope");
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

        section("instance of array");
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

        section("merge of array");
        {
            NodeID[] nodeSet1;
            NodeID[] nodeSet2;
            NodeID[] nodeSet3;

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

            nodeSet3.length = 0;
            nodeSet3 ~= NodeID(_keys[0]);
            nodeSet3 ~= NodeID(_keys[1]);
            nodeSet3 ~= NodeID(_keys[2]);
            nodeSet3 ~= NodeID(_keys[3]);
            nodeSet3 ~= NodeID(_keys[4]);
            nodeSet3 ~= NodeID(_keys[0]);
            nodeSet3 ~= NodeID(_keys[1]);
            nodeSet3 ~= NodeID(_keys[2]);
            nodeSet3 ~= NodeID(_keys[3]);

            require(equal(nodeSet1, nodeSet3));
        }

        section("array in map");
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
            if (!nodeMultiSet.canFind(nodeSet)) nodeMultiSet ~= nodeSet;

            for (int i = 0; i < nodeMultiSet.length; i++)
            {
                require(nodeMultiSet[i].length == 5 - i);
            }

            alias myComp = (x, y) => x.length < y.length;
            nodeMultiSet.sort!(myComp).release;

            for (int i = 0; i < nodeMultiSet.length; i++)
            {
                require(nodeMultiSet[i].length == i+1);
            }
        }

        section("sort of array");
        {
            import std.algorithm;

            NodeID[] nodeSet;

            nodeSet ~= NodeID(_keys[0]);
            nodeSet ~= NodeID(_keys[1]);
            nodeSet ~= NodeID(_keys[2]);
            nodeSet ~= NodeID(_keys[3]);
            nodeSet ~= NodeID(_keys[4]);
            nodeSet ~= NodeID(_keys[5]);

            nodeSet.sort!("a > b");

            for (int i = 0; i < nodeSet.length-1; i++)
            {
                require(nodeSet[i].publicKey.ed25519 > nodeSet[i+1].publicKey.ed25519);
            }
        }

        section("set of NodeID");
        {
            import std.container.rbtree;
            ulong n;

            NodeIDSet nodeSet = new NodeIDSet;

            n = nodeSet.insert(NodeID(_keys[0]));
            require(n == 1);

            n = nodeSet.insert(NodeID(_keys[1]));
            require(n == 1);

            n = nodeSet.insert(NodeID(_keys[2]));
            require(n == 1);

            n = nodeSet.insert(NodeID(_keys[3]));
            require(n == 1);

            n = nodeSet.insert(NodeID(_keys[4]));
            require(n == 1);

            n = nodeSet.insert(NodeID(_keys[0]));
            require(n == 0);

            n = nodeSet.insert(NodeID(_keys[1]));
            require(n == 0);

            n = nodeSet.insert(NodeID(_keys[2]));
            require(n == 0);

            n = nodeSet.insert(NodeID(_keys[5]));
            require(n == 1);
        }

        section("list of NodeID");
        {
            import std.container;
            import std.range;

            DList!NodeID backlog;

            backlog.insertBack(NodeID(_keys[0]));
            assert(walkLength(backlog[]) == 1);

            backlog.insertBack(NodeID(_keys[1]));
            assert(walkLength(backlog[]) == 2);

            backlog.insertBack(NodeID(_keys[2]));
            assert(walkLength(backlog[]) == 3);

            //assert(backlog[2] == NodeID(_keys[2]));

            backlog.removeFront();
            assert(walkLength(backlog[]) == 2);

            foreach(NodeID n; backlog)
            {
                writefln("%s", toHexString(n.publicKey.ed25519));
            }

        }

        section("drop");
        {
            import std.range;
            writeln([0, 2, 1, 5, 0, 3].takeExactly(3)); // [5, 0, 3]
        }

        section("order of map");
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

        section("Unique");
        {
            import std.typecons;

            Unique!NodeID uN1, uN2;

            assert(uN1.isEmpty);
            NodeID n = NodeID(_keys[0]);
            uN1 = cast(Unique!NodeID)(&n);
            writeln(toHexString(uN1.publicKey.ed25519));

            uN2 = cast(Unique!NodeID)(&n);
            //writeln(toHexString(uN1.publicKey.ed25519));
            //writeln(toHexString(uN2.publicKey.ed25519));

            NodeID *n2 = cast(NodeID *)uN2;
            writeln(toHexString(uN2.publicKey.ed25519));
            writeln(toHexString((*n2).publicKey.ed25519));


            uN2 = test2();
            writeln(toHexString(uN2.publicKey.ed25519));
        }

        section("Unique2");
        {
            import std.typecons;
            NodeID * n1 = new NodeID(_keys[0]);
            NodeID * n2 = new NodeID(_keys[1]);
            Unique!NodeID N1;
            N1 = cast(Unique!NodeID)n1;
            writeln(toHexString(N1.publicKey.ed25519));
            N1 = cast(Unique!NodeID)n2;
            writeln(toHexString(N1.publicKey.ed25519));
        }
    }

    import std.typecons;
    Unique!NodeID test2() {
        NodeID n = NodeID(_keys[3]);
        Unique!NodeID uN;
        uN = cast(Unique!NodeID)(&n);

        return uN;
    }
}