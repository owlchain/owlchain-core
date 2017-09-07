module owlchain.util.types;

import owlchain.xdr;

bool isZero(ref const ubyte[] b)
{
    for (int i = 0; i < b.length; i++)
    {
        if (b[i] != 0) return false;
    }

    return true;
}

bool isZero(ref const uint256 b)
{
    for (int i = 0; i < b.length; i++)
    {
        if (b[i] != 0) return false;
    }

    return true;
}


bool
lessThanXored(ref const(Hash) l, ref const(Hash) r, ref const(Hash) x)
{
    Hash v1, v2;
    v1.hash.length = l.hash.length;
    v2.hash.length = l.hash.length;
    for (size_t i = 0; i < l.hash.length; i++)
    {
        v1.hash[i] = x.hash[i] ^ l.hash[i];
        v2.hash[i] = x.hash[i] ^ r.hash[i];
    }

    return v1.hash < v2.hash;
}

void xorValue(ref ubyte[] l, const ubyte[] x)
{
    size_t length;
    if (l.length < x.length) 
    {
        length = l.length;
    }
    else
    {
        length = x.length;
    }
    for (size_t i = 0; i < length; i++)
    {
        l[i] ^= x[i];
    }
}
