module owlchain.xdr.thresholdIndices;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum ThresholdIndices
{
    THRESHOLD_MASTER_WEIGHT = 0,
    THRESHOLD_LOW = 1,
    THRESHOLD_MED = 2,
    THRESHOLD_HIGH = 3,
}

static void encodeThresholdIndices(XdrDataOutputStream stream, ref const ThresholdIndices encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static ThresholdIndices decodeThresholdIndices(XdrDataInputStream stream)
{
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            return ThresholdIndices.THRESHOLD_MASTER_WEIGHT;
        case 1:
            return ThresholdIndices.THRESHOLD_LOW;
        case 2:
            return ThresholdIndices.THRESHOLD_MED;
        case 3:
            return ThresholdIndices.THRESHOLD_HIGH;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
}
