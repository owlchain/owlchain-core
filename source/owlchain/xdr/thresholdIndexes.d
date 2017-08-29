module owlchain.xdr.thresholdIndexes;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum ThresholdIndexes
{
    THRESHOLD_MASTER_WEIGHT = 0,
    THRESHOLD_LOW = 1,
    THRESHOLD_MED = 2,
    THRESHOLD_HIGH = 3,
}

static void encodeThresholdIndexes(XdrDataOutputStream stream, ref const ThresholdIndexes encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static ThresholdIndexes decodeThresholdIndexes(XdrDataInputStream stream)
{
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            return ThresholdIndexes.THRESHOLD_MASTER_WEIGHT;
        case 1:
            return ThresholdIndexes.THRESHOLD_LOW;
        case 2:
            return ThresholdIndexes.THRESHOLD_MED;
        case 3:
            return ThresholdIndexes.THRESHOLD_HIGH;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
}
