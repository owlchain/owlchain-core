module owlchain.xdr.ballot;

import owlchain.xdr.type;
import owlchain.xdr.value;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import std.container.rbtree;

alias RedBlackTree !(Ballot, "(a.counter < b.counter) || ((a.counter == b.counter) && (a.value.value < b.value.value))") BallotSet;

struct Ballot
{
    uint32 counter;
    Value value;

    int opCmp(ref Ballot other)
    {
        if (counter < other.counter)
        {
            return -1;
        }
        else if (counter > other.counter)
        {
            return 1;
        }
        if (value.value < other.value.value)
        {
            return -1;
        }
        else if (value.value > other.value.value)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    static void encode(XdrDataOutputStream stream, ref const Ballot encodedBallot)
    {
        stream.writeUint32(encodedBallot.counter);
        if (encodedBallot.counter > 0) Value.encode(stream, encodedBallot.value);
    }

    static Ballot decode(XdrDataInputStream stream)
    {
        Ballot decodedBallot;
        decodedBallot.counter = stream.readUint32();
        if (decodedBallot.counter > 0) decodedBallot.value = Value.decode(stream);
        return decodedBallot;
    }
}
