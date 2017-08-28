module owlchain.xdr.bucketEntryType;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum BucketEntryType  {
    LIVEENTRY = 0,
    DEADENTRY = 1
}

static void encodeBucketEntryType(XdrDataOutputStream stream, ref const BucketEntryType encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static BucketEntryType decodeBucketEntryType(XdrDataInputStream stream)
{
    const int32 value = stream.readInt32();
    switch (value)
    {
    case 0:
        return BucketEntryType.LIVEENTRY;
    case 1:
        return BucketEntryType.DEADENTRY;
    default:
        throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
}
