module owlchain.xdr.nomination;

import owlchain.xdr.hash;
import owlchain.xdr.value;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Nomination
{
    Hash quorumSetHash;
    Value[] votes;
    Value[] accepted;

    ref Nomination opAssign(const Nomination s)
    {
        quorumSetHash = s.quorumSetHash;
        votes.length = 0;
        for (int i = 0; i < s.votes.length; i++)
        {
            votes ~= cast(Value)s.votes[i];
        }
        accepted.length = 0;
        for (int i = 0; i < s.accepted.length; i++)
        {
            accepted ~= cast(Value)s.accepted[i];
        }
        return this;
    }

    ref Nomination opAssign(ref const(Nomination) s)
    {
        quorumSetHash = s.quorumSetHash;
        votes.length = 0;
        for (int i = 0; i < s.votes.length; i++)
        {
            votes ~= cast(Value)s.votes[i];
        }
        accepted.length = 0;
        for (int i = 0; i < s.accepted.length; i++)
        {
            accepted ~= cast(Value)s.accepted[i];
        }
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const Nomination encodedNomination)
    {
        Hash.encode(stream, encodedNomination.quorumSetHash);
        int votesSize = cast(int)(encodedNomination.votes.length);
        stream.writeInt(votesSize);
        for (int i = 0; i < votesSize; i++)
        {
            Value.encode(stream, encodedNomination.votes[i]);
        }
        int acceptedSize = cast(int)(encodedNomination.accepted.length);
        stream.writeInt(acceptedSize);
        for (int i = 0; i < acceptedSize; i++)
        {
            Value.encode(stream, encodedNomination.accepted[i]);
        }
    }

    static Nomination decode(XdrDataInputStream stream)
    {
        Nomination decodedNomination;
        decodedNomination.quorumSetHash = Hash.decode(stream);

        int votesSize = stream.readInt();
        decodedNomination.votes.length = votesSize;
        for (int i = 0; i < votesSize; i++)
        {
            decodedNomination.votes[i] = Value.decode(stream);
        }

        int acceptedSize = stream.readInt();
        decodedNomination.accepted.length = acceptedSize;
        for (int i = 0; i < acceptedSize; i++)
        {
            decodedNomination.accepted[i] = Value.decode(stream);
        }
        return decodedNomination;
    }
}
