module owlchain.xdr.dataEntry;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.dataValue;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct DataEntry
{
    AccountID accountID;
    string dataName;
    DataValue dataValue;
    DataEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const DataEntry encoded)
    {
        AccountID.encode(stream, encoded.accountID);
        stream.writeString(encoded.dataName);
        DataValue.encode(stream, encoded.dataValue);
        DataEntryExt.encode(stream, encoded.ext);
    }

    static DataEntry decode(XdrDataInputStream stream)
    {
        DataEntry decoded;
        decoded.accountID = AccountID.decode(stream);
        decoded.dataName = stream.readString();
        decoded.dataValue = DataValue.decode(stream);
        decoded.ext = DataEntryExt.decode(stream);
        return decoded;
    }
}

struct DataEntryExt
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const DataEntryExt encoded)
    {
        stream.writeInt32(encoded.v);
    }
    
    static DataEntryExt decode(XdrDataInputStream stream)
    {
        DataEntryExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}