module owlchain.xdr.xdr;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;
import std.traits;

template xdr(T)
{
    ubyte[] serialize(ref const T from)
    {
        XdrDataOutputStream stream = new XdrDataOutputStream();
        T.encode(stream, from);
        return stream.data;
    }
    string print(ref const T from)
    {
        import std.digest.sha;
        XdrDataOutputStream stream = new XdrDataOutputStream();
        T.encode(stream, from);
        return toHexString(stream.data)[0 .. 9];
    }
    void decode(XdrDataInputStream stream, ref T[] to)
    {
        int size = stream.readInt();
        to.length = size;
        for (int i = 0; i < size; i++)
        {
            to[i] = T.decode(stream);
        }
    }
    void decode(XdrDataInputStream stream, ref T to)
    {
        to = T.decode(stream);
    }
    XdrDataInputStream decode(ref ubyte[] source, ref T[] to)
    {
        XdrDataInputStream stream = new XdrDataInputStream(source);
        int size = stream.readInt();
        to.length = size;
        for (int i = 0; i < size; i++)
        {
            to[i] = T.decode(stream);
        }
        return stream;
    }
    XdrDataInputStream decode(ref ubyte[] source, ref T to)
    {
        XdrDataInputStream stream = new XdrDataInputStream(source);
        to = T.decode(stream);
        return stream;
    }
}
