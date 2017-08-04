module owlchain.xdr.hash;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Hash
{
    ubyte[] hash;

    static Hash opCall(const ubyte[] v)
    {
        Hash h;
        h.hash = v.dup;
        return h;
    }

    static Hash opCall(ref const Hash s)
    {
        Hash t;
        t.hash = s.hash.dup;
        return t;
    }

    ref Hash opAssign(const Hash s)
    {
        hash = s.hash.dup;
        return this;
    }

    ref Hash opAssign(ref const Hash s)
    {
        hash = s.hash.dup;
        return this;
    }

    size_t toHash() const @safe pure nothrow
    {
        size_t h;
        foreach (ubyte c; hash) {
            h = (h * 9) + c;
        }
        return h;
    }

    bool opEquals(ref const Hash s) const @safe pure nothrow
    {
        if (this.hash.length != s.hash.length) return false;
        for (int idx = 0; idx < this.hash.length; idx++)
        {
            if (this.hash[idx] != s.hash[idx])
            {
                return false;
            }
        }
        return true;
    }

    static void encode(XdrDataOutputStream stream, ref const Hash encodedHash)
    {
        stream.write(encodedHash.hash);
    }

    static Hash decode(XdrDataInputStream stream)
    {
        Hash decodedHash;
        ubyte[] temp;
        temp.length = 32;
        stream.read(temp);
        decodedHash.hash = temp;
        return decodedHash;
    }
}