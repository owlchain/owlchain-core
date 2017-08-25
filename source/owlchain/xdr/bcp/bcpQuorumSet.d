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

    ref BCPQuorumSet opAssign(BCPQuorumSet other)
    {
        threshold = other.threshold;

        validators.length = 0;
        for (int i = 0; i < other.validators.length; i++)
        {
            validators ~= other.validators[i];
        }

        innerSets.length = 0;
        for (int i = 0; i < other.innerSets.length; i++)
        {
            innerSets ~= cast(BCPQuorumSet)other.innerSets[i];
        }
        return this;
    }

    ref BCPQuorumSet opAssign(ref BCPQuorumSet other)
    {
        threshold = other.threshold;

        validators.length = 0;
        for (int i = 0; i < other.validators.length; i++)
        {
            validators ~= other.validators[i];
        }

        innerSets.length = 0;
        for (int i = 0; i < other.innerSets.length; i++)
        {
            innerSets ~= cast(BCPQuorumSet)other.innerSets[i];
        }
        return this;
    }

    ref BCPQuorumSet opAssign(ref const(BCPQuorumSet) other)
    {
        threshold = other.threshold;

        validators.length = 0;
        for (int i = 0; i < other.validators.length; i++)
        {
            validators ~= other.validators[i];
        }

        innerSets.length = 0;
        for (int i = 0; i < other.innerSets.length; i++)
        {
            innerSets ~= cast(BCPQuorumSet)other.innerSets[i];
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
