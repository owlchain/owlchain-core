module owlchain.xdr.manageDataOp;

import owlchain.xdr.type;
import owlchain.xdr.asset;
import owlchain.xdr.price;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct ManageOfferOp
{
    Asset selling;
    Asset buying;
    int64 amount;
    Price price;
    uint64 offerID;

    static void encode(XdrDataOutputStream stream, ref const ManageOfferOp encodedValue)
    {
        Asset.encode(stream, encodedValue.selling);
        Asset.encode(stream, encodedValue.buying);
        stream.writeInt64(encodedValue.amount);
        Price.encode(stream, encodedValue.price);
        stream.writeUint64(encodedValue.offerID);
    }

    static ManageOfferOp decode(XdrDataInputStream stream)
    {
        ManageOfferOp decodedValue;

        decodedValue.selling = Asset.decode(stream);
        decodedValue.buying = Asset.decode(stream);
        decodedValue.amount = stream.readInt64();
        decodedValue.price = Price.decode(stream);
        decodedValue.offerID = stream.readUint64();

        return decodedValue;
    }
}
