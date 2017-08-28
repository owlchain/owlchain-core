module owlchain.xdr.setOptionsOp;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.signer;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct SetOptionsOp
{
    AccountID inflationDest; // sets the inflation destination
    uint32 clearFlags; // which flags to clear
    uint32 setFlags; // which flags to set

    // account threshold manipulation
    uint32 masterWeight;    // weight of the master account
    uint32 lowThreshold;
    uint32 medThreshold;
    uint32 highThreshold;
    string homeDomain;  // sets the home domain
    
    // Add, update or remove a signer for the account
    // signer is deleted if the weight is 0
    Signer signer;

    static void encode(XdrDataOutputStream stream, ref const SetOptionsOp encodedValue)
    {
        AccountID.encode(stream, encodedValue.inflationDest);
        stream.writeUint32(encodedValue.clearFlags);
        stream.writeUint32(encodedValue.setFlags);
        stream.writeUint32(encodedValue.masterWeight);
        stream.writeUint32(encodedValue.lowThreshold);
        stream.writeUint32(encodedValue.medThreshold);
        stream.writeUint32(encodedValue.highThreshold);
        stream.writeString(encodedValue.homeDomain);
        Signer.encode(stream, encodedValue.signer);
    }

    static SetOptionsOp decode(XdrDataInputStream stream)
    {
        SetOptionsOp decodedValue;
        decodedValue.inflationDest = AccountID.decode(stream);
        decodedValue.clearFlags = stream.readUint32();
        decodedValue.setFlags = stream.readUint32();
        decodedValue.masterWeight = stream.readUint32();
        decodedValue.lowThreshold = stream.readUint32();
        decodedValue.medThreshold = stream.readUint32();
        decodedValue.highThreshold = stream.readUint32();
        decodedValue.homeDomain = stream.readString();
        decodedValue.signer = Signer.decode(stream);

        return decodedValue;
    }
}
