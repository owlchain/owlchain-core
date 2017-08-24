module owlchain.xdr.offerEntry;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.asset;
import owlchain.xdr.price;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct OfferEntry
{
    AccountID sellerID;
    uint64 offerID;
    Asset selling;
    Asset buying;
    int64 amount;
    Price price;
    uint32 flags;
    OfferEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const OfferEntry encoded)
    {
        AccountID.encode(stream, encoded.sellerID);
        stream.writeUint64(encoded.offerID);
        Asset.encode(stream, encoded.selling);
        Asset.encode(stream, encoded.buying);
        stream.writeInt64(encoded.amount);
        Price.encode(stream, encoded.price);
        stream.writeUint32(encoded.flags);
        OfferEntryExt.encode(stream, encoded.ext);
    }

    static OfferEntry decode(XdrDataInputStream stream)
    {
        OfferEntry decoded;
        decoded.sellerID = AccountID.decode(stream);
        decoded.offerID = stream.readUint64();
        decoded.selling = Asset.decode(stream);
        decoded.buying = Asset.decode(stream);
        decoded.amount = stream.readInt64();
        decoded.price = Price.decode(stream);
        decoded.flags = stream.readUint32();
        decoded.ext = OfferEntryExt.decode(stream);
        return decoded;
    }
}

struct OfferEntryExt
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const OfferEntryExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static OfferEntryExt decode(XdrDataInputStream stream)
    {
        OfferEntryExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}
