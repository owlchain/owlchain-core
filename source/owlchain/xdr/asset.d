module owlchain.xdr.asset;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.assetType;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Asset
{
    AssetType type;
    AssetAlphaNum4 alphaNum4;
    AssetAlphaNum12 alphaNum12;

    static void encode(XdrDataOutputStream stream, ref const Asset encodedAsset)
    {
        stream.writeInt32(encodedAsset.type);
        switch (encodedAsset.type)
        {
            case AssetType.ASSET_TYPE_NATIVE :
                break;
            case AssetType.ASSET_TYPE_CREDIT_ALPHANUM4 :
                AssetAlphaNum4.encode(stream, encodedAsset.alphaNum4);
                break;
            case AssetType.ASSET_TYPE_CREDIT_ALPHANUM12 :
                AssetAlphaNum12.encode(stream, encodedAsset.alphaNum12);
                break;
            default:
                throw new Exception("Unknown enum value");
        }
    }

    static Asset decode(XdrDataInputStream stream)
    {
        Asset decodedAsset;

        decodedAsset.type = cast(AssetType)stream.readInt32();
        switch (decodedAsset.type)
        {
            case AssetType.ASSET_TYPE_NATIVE :
                break;
            case AssetType.ASSET_TYPE_CREDIT_ALPHANUM4 :
                decodedAsset.alphaNum4 = AssetAlphaNum4.decode(stream);
                break;
            case AssetType.ASSET_TYPE_CREDIT_ALPHANUM12 :
                decodedAsset.alphaNum12 = AssetAlphaNum12.decode(stream);
                break;
            default:
                throw new Exception("Unknown enum value");
        }
        return decodedAsset;
    }
}

struct AssetAlphaNum4
{
    ubyte[] assetCode;
    AccountID issuer;

    static void encode(XdrDataOutputStream stream, ref const AssetAlphaNum4 encodedAssetAlphaNum4)
    {
        int assetCodesize = cast(int32)encodedAssetAlphaNum4.assetCode.length;
        stream.writeInt32(assetCodesize);
        stream.write(encodedAssetAlphaNum4.assetCode);
        AccountID.encode(stream, encodedAssetAlphaNum4.issuer);
    }

    static AssetAlphaNum4 decode(XdrDataInputStream stream)
    {
        AssetAlphaNum4 decodedAssetAlphaNum4;

        const int assetCodesize = stream.readInt32();
        decodedAssetAlphaNum4.assetCode.length = assetCodesize;
        stream.read(decodedAssetAlphaNum4.assetCode);
        decodedAssetAlphaNum4.issuer = AccountID.decode(stream);

        return decodedAssetAlphaNum4;
    }
}

struct AssetAlphaNum12
{
    ubyte[] assetCode;
    AccountID issuer;

    static void encode(XdrDataOutputStream stream, ref const AssetAlphaNum12 encodedAssetAlphaNum12)
    {
        int assetCodesize = cast(int32)encodedAssetAlphaNum12.assetCode.length;
        stream.writeInt32(assetCodesize);
        stream.write(encodedAssetAlphaNum12.assetCode);
        AccountID.encode(stream, encodedAssetAlphaNum12.issuer);
    }

    static AssetAlphaNum12 decode(XdrDataInputStream stream)
    {
        AssetAlphaNum12 decodedAssetAlphaNum12;

        const int assetCodesize = stream.readInt32();
        decodedAssetAlphaNum12.assetCode.length = assetCodesize;
        stream.read(decodedAssetAlphaNum12.assetCode);
        decodedAssetAlphaNum12.issuer = AccountID.decode(stream);

        return decodedAssetAlphaNum12;
    }
}
