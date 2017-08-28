module owlchain.xdr.inflationPayout;

import owlchain.xdr.type;
import owlchain.xdr.accountID;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct InflationPayout
{
    AccountID destination;
    int64 amount;
    
    static void encode(XdrDataOutputStream stream, ref const InflationPayout encodedValue)
    {
        AccountID.encode(stream, encodedValue.destination);
        stream.writeInt64(encodedValue.amount);
    }

    static InflationPayout decode(XdrDataInputStream stream)
    {
        InflationPayout decodedValue;

        decodedValue.destination = AccountID.decode(stream);
        decodedValue.amount = stream.readInt64();

        return decodedValue;
    }
}
