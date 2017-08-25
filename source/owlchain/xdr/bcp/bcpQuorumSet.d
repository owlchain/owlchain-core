module owlchain.xdr.bcpQuorumSet;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.publicKey;

struct BCPQuorumSet
{
    uint32 threshold;
    PublicKey[] validators;
    BCPQuorumSet[] innerSets;

    static BCPQuorumSet opCall()
    {
        BCPQuorumSet qSet;
        qSet.threshold = 1;
        return qSet;
    }

    ref BCPQuorumSet opAssign(BCPQuorumSet s)
    {
        threshold = s.threshold;

        validators.length = 0;
        for (int i = 0; i < s.validators.length; i++)
        {
            validators ~= s.validators[i];
        }

        innerSets.length = 0;
        for (int i = 0; i < s.innerSets.length; i++)
        {
            innerSets ~= cast(BCPQuorumSet) s.innerSets[i];
        }
        return this;
    }

    ref BCPQuorumSet opAssign(ref BCPQuorumSet s)
    {
        threshold = s.threshold;

        validators.length = 0;
        for (int i = 0; i < s.validators.length; i++)
        {
            validators ~= s.validators[i];
        }

        innerSets.length = 0;
        for (int i = 0; i < s.innerSets.length; i++)
        {
            innerSets ~= cast(BCPQuorumSet) s.innerSets[i];
        }
        return this;
    }

    ref BCPQuorumSet opAssign(ref const(BCPQuorumSet) s)
    {
        threshold = s.threshold;

        validators.length = 0;
        for (int i = 0; i < s.validators.length; i++)
        {
            validators ~= s.validators[i];
        }

        innerSets.length = 0;
        for (int i = 0; i < s.innerSets.length; i++)
        {
            innerSets ~= cast(BCPQuorumSet) s.innerSets[i];
        }
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const BCPQuorumSet encodedQuorumSet)
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
            BCPQuorumSet.encode(stream, encodedQuorumSet.innerSets[i]);
        }
    }

    static BCPQuorumSet decode(XdrDataInputStream stream)
    {
        BCPQuorumSet decodedQuorumSet;
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
            decodedQuorumSet.innerSets[i] = BCPQuorumSet.decode(stream);
        }
        return decodedQuorumSet;
    }
}
