module owlchain.xdr.bcpEnvelope;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.bcpStatement;
import owlchain.xdr.signature;
import owlchain.xdr.xdr;

import std.container.rbtree;

alias RedBlackTree!(BCPEnvelope, "(a < b)") BCPEnvelopeSet;

struct BCPEnvelope
{
    BCPStatement statement;
    Signature signature;

    int opCmp(ref const (BCPEnvelope) other) const
    {
        ubyte[] i, j;
        i = xdr!BCPEnvelope.serialize(this);
        j = xdr!BCPEnvelope.serialize(other);

        if (i < j)
        {
            return -1;
        }
        else if (i > j)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    bool opEquals(const BCPEnvelope other) const 
    {
        ubyte[] i, j;
        i = xdr!BCPEnvelope.serialize(this);
        j = xdr!BCPEnvelope.serialize(other);
        if (i == j)
        {
            return true;
        }
        else 
        {
            return false;
        }
    }
    /*
    int opCmp(ref const (BCPEnvelope) other) const
    {
    if (this.statement < other.statement)
    {
    return -1;
    } 
    else if (this.statement > other.statement)
    {
    return 1;
    }
    else
    {
    if (this.signature < other.signature)
    {
    return -1;
    }
    else if (this.signature > other.signature)
    {
    return 1;
    }
    else 
    {
    return 0;
    }
    }
    }

    bool opEquals(const BCPEnvelope other) const 
    {
    if (this.statement == other.statement && this.signature == other.signature)
    {
    return true;
    }
    else 
    {
    return false;
    }
    }
    */
    static void encode(XdrDataOutputStream stream, ref const BCPEnvelope encodedEnvelope)
    {
        BCPStatement.encode(stream, encodedEnvelope.statement);
        Signature.encode(stream, encodedEnvelope.signature);
    }

    static BCPEnvelope decode(XdrDataInputStream stream)
    {
        BCPEnvelope decodedEnvelope;
        decodedEnvelope.statement = BCPStatement.decode(stream);
        decodedEnvelope.signature = Signature.decode(stream);
        return decodedEnvelope;
    }
}
