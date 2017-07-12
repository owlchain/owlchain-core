module owlchain.xdr.quorumSet;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.publicKey;

struct QuorumSet
{
    uint32 threshold;
    PublicKey[] validators;
    QuorumSet[] innerSets;

    static QuorumSet opCall()
    {
        QuorumSet qSet;
        qSet.threshold = 1;
        return qSet;
    }

    static void encode(XdrDataOutputStream stream, ref const QuorumSet encodedQuorumSet)
    {
        stream.writeUint32(encodedQuorumSet.threshold);

        int validatorsSize = cast(int)(encodedQuorumSet.validators.length);
        stream.writeInt(validatorsSize);
        for (int i = 0; i < validatorsSize; i++)
        {
            PublicKey.encode(stream, encodedQuorumSet.validators[i]);
        }

        int innerSetsSize = cast(int)(encodedQuorumSet.innerSets.length);
        stream.writeInt(innerSetsSize);
        for (int i = 0; i < innerSetsSize; i++)
        {
            QuorumSet.encode(stream, encodedQuorumSet.innerSets[i]);
        }
    }

    static QuorumSet decode(XdrDataInputStream stream)
    {
        QuorumSet decodedQuorumSet;
        decodedQuorumSet.threshold = stream.readUint32();

        int validatorsSize = stream.readInt();
        decodedQuorumSet.validators.length = validatorsSize;
        for (int i = 0; i < validatorsSize; i++)
        {
            decodedQuorumSet.validators[i] = PublicKey.decode(stream);
        }

        int innerSetsSize = stream.readInt();
        decodedQuorumSet.innerSets.length = innerSetsSize;
        for (int i = 0; i < innerSetsSize; i++)
        {
            decodedQuorumSet.innerSets[i] = QuorumSet.decode(stream);
        }
        return decodedQuorumSet;
    }
}

