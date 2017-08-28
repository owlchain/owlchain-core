module owlchain.xdr.allowTrustOp;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.assetType;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct AllowTrustOp
{
    AccountID trustor;
    AllowTrustOpAsset asset;
    bool authorize;

    static void encode(XdrDataOutputStream stream, ref const AllowTrustOp encoded)
    {
        AccountID.encode(stream, encoded.trustor);
        AllowTrustOpAsset.encode(stream, encoded.asset);
        stream.writeInt32(encoded.authorize ? 1 : 0);
    }

    static AllowTrustOp decode(XdrDataInputStream stream)
    {
        AllowTrustOp decoded;

        decoded.trustor = AccountID.decode(stream);
        decoded.asset = AllowTrustOpAsset.decode(stream);
        decoded.authorize = stream.readInt32() == 1 ? true : false;

        return decoded;
    }
}

struct AllowTrustOpAsset
{
    AssetType type;
    ubyte[4] assetCode4;
    ubyte[12] assetCode12;

    static void encode(XdrDataOutputStream stream, ref const AllowTrustOpAsset encoded)
    {
        encodeAssetType(stream, encoded.type);
        switch (encoded.type)
        {
        case AssetType.ASSET_TYPE_NATIVE:
            break;
        case AssetType.ASSET_TYPE_CREDIT_ALPHANUM4:
            stream.write(encoded.assetCode4);
            break;
        case AssetType.ASSET_TYPE_CREDIT_ALPHANUM12:
            stream.write(encoded.assetCode12);
            break;
        default:
            break;
        }
    }

    static AllowTrustOpAsset decode(XdrDataInputStream stream)
    {
        AllowTrustOpAsset decoded;

        decoded.type = decodeAssetType(stream);
        switch (decoded.type)
        {
        case AssetType.ASSET_TYPE_NATIVE:
            break;
        case AssetType.ASSET_TYPE_CREDIT_ALPHANUM4:
            stream.read(decoded.assetCode4);
            break;
        case AssetType.ASSET_TYPE_CREDIT_ALPHANUM12:
            stream.read(decoded.assetCode12);
            break;
        default:
            break;
        }

        return decoded;
    }

}
