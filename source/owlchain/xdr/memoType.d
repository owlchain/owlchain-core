module owlchain.xdr.memoType;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum MemoType
{
    MEMO_NONE = 0,
    MEMO_TEXT = 1,
    MEMO_ID = 2,
    MEMO_HASH = 3,
    MEMO_RETURN = 4
}

static void encodeMemoType(XdrDataOutputStream stream, ref const MemoType encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static MemoType decodeMemoType(XdrDataInputStream stream)
{
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            return MemoType.MEMO_NONE;
        case 1:
            return MemoType.MEMO_TEXT;
        case 2:
            return MemoType.MEMO_ID;
        case 3:
            return MemoType.MEMO_HASH;
        case 4:
            return MemoType.MEMO_RETURN;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
}
