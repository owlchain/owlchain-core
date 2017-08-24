module owlchain.consensus.tests.cpUnitTests;

import std.stdio;
import std.conv;
import std.math;
import std.digest.sha;
import core.stdc.stdint;
import std.digest.sha;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.publicKey;
import owlchain.xdr.nodeID;
import owlchain.xdr.quorumSet;

import owlchain.crypto.keyUtils;

import owlchain.consensus.localNode;

import owlchain.utils.globalChecks;

class CPUnitTest
{
private:
    Hash [] mHash;
    SecretKey [] mSecretKey;
    PublicKey [] mKeys;

    bool isNear(uint64 r, double target)
    {
        double v = cast(double)r / cast(double)UINT64_MAX;
        return (abs(v - target) < .01);
    }
    
    void makeNodeID(int i)
    {
        uint256 seed = sha256Of("NODE_SEED_" ~  to!string(i, 10));
        mSecretKey ~= SecretKey.fromSeed(seed);
        mKeys ~= mSecretKey[$-1].getPublicKey();
    }

public :
    this()
    {
    }

    void prepare()
    {
        for (int i = 0; i <= 5; i++)
        {
            makeNodeID(i);
        }
    }

    void test()
    {
        SECTION("nomination weight");
        {
            QuorumSet qSet;
            qSet.threshold = 3;
            qSet.validators ~= (mKeys[0]);
            qSet.validators ~= (mKeys[1]);
            qSet.validators ~= (mKeys[2]);
            qSet.validators ~= (mKeys[3]);

            uint64 result = LocalNode.getNodeWeight(mKeys[2], qSet);

            double v = cast(double)result/cast(double)UINT64_MAX;
            writefln("%.5f", v);
            REQUIRE(isNear(result, .75));

            result = LocalNode.getNodeWeight(mKeys[4], qSet);
            REQUIRE(result == 0);

            QuorumSet iQSet;
            iQSet.threshold = 1;
            iQSet.validators ~= (mKeys[4]);
            iQSet.validators ~= (mKeys[5]);
            qSet.innerSets ~= iQSet;

            result = LocalNode.getNodeWeight(mKeys[4], qSet);

            v = cast(double)result/cast(double)UINT64_MAX;
            writefln("%.5f", v);
            REQUIRE(isNear(result, .6 * .5));
        }
    }
}