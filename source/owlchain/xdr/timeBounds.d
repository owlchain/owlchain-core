module owlchain.xdr.timeBounds;

import owlchain.xdr.type;
import owlchain.xdr.accountID;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TimeBounds
{
    uint64 minTime;
    uint64 maxTime;

    static void encode(XdrDataOutputStream stream, ref const TimeBounds encodedValue)
    {
        stream.writeUint64(encodedValue.minTime);
        stream.writeUint64(encodedValue.maxTime);
    }

    static TimeBounds decode(XdrDataInputStream stream)
    {
        TimeBounds decodedValue;

        decodedValue.minTime = stream.readUint64();
        decodedValue.maxTime = stream.readUint64();

        return decodedValue;
    }
}