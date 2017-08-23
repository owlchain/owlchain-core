module owlchain.xdr.xdrDataInputStream;

import std.string;
import std.conv;

import owlchain.core.stream;
import owlchain.xdr.type;

class XdrDataInputStream : InputStream
{
    ubyte[] data;
    size_t offset;

    this(ubyte [] source) 
    {
        data = source.dup();
        offset = 0;
    }

    this()
    {
        data.length = 0;
        offset = 0;
    }

    void assign(ubyte [] source)
    {
        data = source.dup();
        offset = 0;
    }

	bool empty() {
        return data.length == 0;
    }
	
    ulong leastSize() {

        return 0;
    }

	bool dataAvailableForRead()
    {
        return data.length-1 > offset;
    }

	bool dataAvailableForRead(int size)
    {
        return data.length >= (offset + size);
    }
	bool dataAvailableForRead(ulong size)
    {
        return data.length >= (offset + size);
    }

	const(ubyte)[] peek() 
    {
        return data;
    }

	void read(ubyte[] dst)
    {
        if (dataAvailableForRead(dst.length)) {
            dst[0..dst.length] = data[offset .. offset + dst.length];
            offset += dst.length;
        }
    }

	void read(byte[] dst)
    {
        read(cast(ubyte[])dst);
    }

    int readInt()
    {
        int value;
        if (dataAvailableForRead(int.sizeof)) {
            value = *cast(int *)&data[offset];
            offset += int.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    long readLong()
    {
        long value;
        if (dataAvailableForRead(long.sizeof)) {
            value = *cast(long *)&data[offset];
            offset += long.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    uint readUint()
    {
        uint value;
        if (dataAvailableForRead(uint.sizeof)) {
            value = *cast(uint *)&data[offset];
            offset += uint.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    ulong readUlong()
    {
        ulong value;
        if (dataAvailableForRead(ulong.sizeof)) {
            value = *cast(ulong *)&data[offset];
            offset += ulong.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    int32 readInt32()
    {
        int32 value;
        if (dataAvailableForRead(int32.sizeof)) {
            value = *cast(int32 *)&data[offset];
            offset += int32.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    int64 readInt64()
    {
        int64 value;
        if (dataAvailableForRead(int64.sizeof)) {
            value = *cast(int64 *)&data[offset];
            offset += int64.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    uint32 readUint32()
    {
        uint32 value;
        if (dataAvailableForRead(uint32.sizeof)) {
            value = *cast(uint32 *)&data[offset];
            offset += uint32.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    uint64 readUint64()
    {
        uint64 value;
        if (dataAvailableForRead(uint64.sizeof)) {
            value = *cast(uint64 *)&data[offset];
            offset += uint64.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    uint256 readUint256()
    {
        uint256 value;
        if (dataAvailableForRead(uint256.sizeof)) {
            value = *cast(uint256 *)&data[offset];
            offset += uint256.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    uint512 readUint512()
    {
        uint512 value;
        if (dataAvailableForRead(uint512.sizeof)) {
            value = *cast(uint512 *)&data[offset];
            offset += uint512.sizeof;
        } else {
            value = 0;
        }
        return value;
    }

    string readString()
    {
        int32 size = readInt32();
        byte[] ascii = new byte[size];
        read(ascii);
        string p = cast(string)(ascii);
        return p;
    }
}
