module owlchain.xdr.claimOfferAtom;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.asset;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct ClaimOfferAtom
{
    AccountID sellerID;
    uint64 offerID;
    Asset assetSold;
    int64 amountSold;
    Asset assetBought;
    int64 amountBought;

    static void encode(XdrDataOutputStream stream, ref const ClaimOfferAtom encodedValue)
    {
        AccountID.encode(stream, encodedValue.sellerID);
        stream.writeUint64(encodedValue.offerID);
        Asset.encode(stream, encodedValue.assetSold);
        stream.writeInt64(encodedValue.amountSold);
        Asset.encode(stream, encodedValue.assetBought);
        stream.writeInt64(encodedValue.amountBought);
    }

    static ClaimOfferAtom decode(XdrDataInputStream stream)
    {
        ClaimOfferAtom decodedValue;

        decodedValue.sellerID = AccountID.decode(stream);
        decodedValue.offerID = stream.readUint64();
        decodedValue.assetSold = Asset.decode(stream);
        decodedValue.amountSold = stream.readInt64();
        decodedValue.assetBought = Asset.decode(stream);
        decodedValue.amountBought = stream.readInt64();

        return decodedValue;
    }
}
