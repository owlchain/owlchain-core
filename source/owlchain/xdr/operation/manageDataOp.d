module owlchain.xdr.manageOfferOp;

import owlchain.xdr.type;
import owlchain.xdr.dataValue;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct ManageDataOp
{
    string dataName;
    DataValue dataValue;

    static void encode(XdrDataOutputStream stream, ref const ManageDataOp encodedValue)
    {
        stream.writeString(encodedValue.dataName);
        stream.writeInt32(1);
        DataValue.encode(stream, encodedValue.dataValue);
    }

    static ManageDataOp decode(XdrDataInputStream stream)
    {
        ManageDataOp decodedValue;

        decodedValue.dataName = stream.readString();

        const int dataValuePresent = stream.readInt32();
        if (dataValuePresent != 0)
        {
            decodedValue.dataValue = DataValue.decode(stream);
        }
        return decodedValue;
    }
}
