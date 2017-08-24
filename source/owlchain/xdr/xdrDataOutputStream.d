module owlchain.xdr.xdrDataOutputStream;

import std.string;
import std.conv;

import owlchain.core.stream;
import owlchain.xdr.type;

class XdrDataOutputStream : OutputStream
{
    ubyte[] data;
    size_t offset;

    this()
    {
        data.length = 0;
        offset = 0;
    }

    invariant()
    {
        assert(offset <= data.length);
    }

    ubyte[] toBytes()
    {
        return data[0 .. offset];
    }

    void reserve(size_t nbytes) @trusted
    in
    {
        assert(offset + nbytes >= offset);
    }
    out
    {
        assert(offset + nbytes <= data.length);
    }
    body
    {
        if (data.length < offset + nbytes)
        {
            void[] vdata = data;
            vdata.length = (offset + nbytes + 256);
            data = cast(ubyte[]) vdata;
        }
    }

    void write(in ubyte[] bytes)
    {
        reserve(bytes.length);
        data[offset .. offset + bytes.length] = bytes[];
        offset += bytes.length;
    }

    void write(in byte[] bytes)
    {
        write(cast(ubyte[]) bytes);
    }

    void writeInt(in int value)
    {
        reserve(int.sizeof);
        *cast(int*)&data[offset] = value;
        offset += int.sizeof;
    }

    void writeLong(in long value)
    {
        reserve(long.sizeof);
        *cast(long*)&data[offset] = value;
        offset += long.sizeof;
    }

    void writeUint(in uint value)
    {
        reserve(uint.sizeof);
        *cast(uint*)&data[offset] = value;
        offset += uint.sizeof;
    }

    void writeUlong(in ulong value)
    {
        reserve(ulong.sizeof);
        *cast(ulong*)&data[offset] = value;
        offset += ulong.sizeof;
    }

    void writeInt32(in int32 value)
    {
        reserve(int32.sizeof);
        *cast(int32*)&data[offset] = value;
        offset += int32.sizeof;
    }

    void writeInt64(in int64 value)
    {
        reserve(int64.sizeof);
        *cast(int64*)&data[offset] = value;
        offset += int64.sizeof;
    }

    void writeUint32(in uint32 value)
    {
        reserve(uint32.sizeof);
        *cast(uint32*)&data[offset] = value;
        offset += uint32.sizeof;
    }

    void writeUint64(in uint64 value)
    {
        reserve(uint64.sizeof);
        *cast(uint64*)&data[offset] = value;
        offset += uint64.sizeof;
    }

    void writeUint256(in uint256 value)
    {
        reserve(uint256.sizeof);
        *cast(uint256*)&data[offset] = value;
        offset += uint256.sizeof;
    }

    void writeUint512(in uint512 value)
    {
        reserve(uint512.sizeof);
        *cast(uint512*)&data[offset] = value;
        offset += uint512.sizeof;
    }

    void writeString(string value)
    {
        ubyte[] ascii = cast(ubyte[]) value;
        writeInt32(cast(int32) ascii.length);
        write(ascii);
    }

    void write(InputStream stream, ulong nbytes = 0)
    {

    }

    void flush()
    {
        data.length = 0;
        offset = 0;
    }

    void finalize()
    {
        data.length = 0;
        offset = 0;
    }
}

template xdr(T)
{
    ubyte[] serialize(ref const T from)
    {
        XdrDataOutputStream stream = new XdrDataOutputStream();
        T.encode(stream, from);
        return stream.data;
    }
}
