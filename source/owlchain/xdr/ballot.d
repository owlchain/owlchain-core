module owlchain.xdr.ballot;

import owlchain.xdr.type;
import owlchain.xdr.value;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Ballot
{
    uint32 counter;
    Value value;
    
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