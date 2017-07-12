module owlchain.xdr.tests.streamTest;

import std.stdio;
import std.conv;
import std.digest.sha;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.nodeID;
import owlchain.xdr.quorumSet;
class StreamTest
{

private :
    XdrDataInputStream inputStream;
    XdrDataOutputStream outputStream;

    void require(bool condition)
    {
        if (!condition)
        {
            writefln("REQUIRE Does not match.");
        }
    }

    void section(string value)
    {
        writefln("SECTION %s", value);
    }

public :
    this()
    {
    }

    void prepare()
    {
    }

    void test()
    {
        section("int32");
        {
            int v1, v2;
            v1 = 5;
            inputStream = new XdrDataInputStream();
            outputStream = new XdrDataOutputStream();

            outputStream.writeInt32(v1);
            inputStream.assign(outputStream.toBytes());
            v2 = inputStream.readInt32();
            require(v1 == v2);
        }
        section("uint32");
        {
            uint32 v1, v2;
            v1 = 5;
            inputStream = new XdrDataInputStream();
            outputStream = new XdrDataOutputStream();

            outputStream.writeUint32(v1);
            inputStream.assign(outputStream.toBytes());
            v2 = inputStream.readUint32();
            require(v1 == v2);
        }
        section("int64");
        {
            int64 v1, v2;
            v1 = 5;
            inputStream = new XdrDataInputStream();
            outputStream = new XdrDataOutputStream();

            outputStream.writeInt64(v1);
            inputStream.assign(outputStream.toBytes());
            v2 = inputStream.readInt64();
            require(v1 == v2);
        }
        section("uint64");
        {
            uint64 v1, v2;
            v1 = 5;
            inputStream = new XdrDataInputStream();
            outputStream = new XdrDataOutputStream();

            outputStream.writeUint64(v1);
            inputStream.assign(outputStream.toBytes());
            v2 = inputStream.readUint64();
            require(v1 == v2);
        }
        section("uint256");
        {
            uint256 v1, v2;

            v1 = sha256Of("NODE_SEED_5");
            inputStream = new XdrDataInputStream();
            outputStream = new XdrDataOutputStream();

            outputStream.writeUint256(v1);
            inputStream.assign(outputStream.toBytes());
            v2 = inputStream.readUint256();
            require(v1 == v2);
        }

/*
        QuorumSet qSet = new QuorumSet();
        qSet.threshold = 1;
        qSet.validators ~= nodeID.publicKey;
        */
    }
}