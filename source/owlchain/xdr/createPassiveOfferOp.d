module owlchain.xdr.createPassiveOfferOp;

import owlchain.xdr.type;
import owlchain.xdr.asset;
import owlchain.xdr.price;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct CreatePassiveOfferOp
{
    Asset selling;// A
    Asset buying;// B
    int64 amount;// amount taker gets. if set to 0, delete the offer
    Price price;// cost of A in terms of B

    static void encode(XdrDataOutputStream stream, ref const CreatePassiveOfferOp encodedValue)
    {
        Asset.encode(stream, encodedValue.selling);
        Asset.encode(stream, encodedValue.buying);
        stream.writeInt64(encodedValue.amount);
        Price.encode(stream, encodedValue.price);
    }

    static CreatePassiveOfferOp decode(XdrDataInputStream stream)
    {
        CreatePassiveOfferOp decodedValue;

        decodedValue.selling = Asset.decode(stream);
        decodedValue.buying = Asset.decode(stream);
        decodedValue.amount = stream.readInt64();
        decodedValue.price = Price.decode(stream);

        return decodedValue;
    }
}