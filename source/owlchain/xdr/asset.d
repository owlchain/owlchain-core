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

    static void encode(XdrDataOutputStream stream, ref const Asset encodedValue)
    {
        encodeAssetType(stream, encodedValue.type);
        switch (encodedValue.type)
        {
        case AssetType.ASSET_TYPE_NATIVE:
            break;
        case AssetType.ASSET_TYPE_CREDIT_ALPHANUM4:
            AssetAlphaNum4.encode(stream, encodedValue.alphaNum4);
            break;
        case AssetType.ASSET_TYPE_CREDIT_ALPHANUM12:
            AssetAlphaNum12.encode(stream, encodedValue.alphaNum12);
            break;
        default:
            break;
        }
    }

    static Asset decode(XdrDataInputStream stream)
    {
        Asset decodedValue;

        decodedValue.type = decodeAssetType(stream);
        switch (decodedValue.type)
        {
        case AssetType.ASSET_TYPE_NATIVE:
            break;
        case AssetType.ASSET_TYPE_CREDIT_ALPHANUM4:
            decodedValue.alphaNum4 = AssetAlphaNum4.decode(stream);
            break;
        case AssetType.ASSET_TYPE_CREDIT_ALPHANUM12:
            decodedValue.alphaNum12 = AssetAlphaNum12.decode(stream);
            break;
        default:
            break;
        }
        return decodedValue;
    }
}

struct AssetAlphaNum4
{
    ubyte[] assetCode;
    AccountID issuer;

    ref AssetAlphaNum4 opAssign(AssetAlphaNum4 other)
    {
        assetCode = other.assetCode.dup;
        issuer = other.issuer;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const AssetAlphaNum4 encodedValue)
    {
        int assetCodesize = cast(int32) encodedValue.assetCode.length;
        stream.writeInt32(assetCodesize);
        stream.write(encodedValue.assetCode);
        AccountID.encode(stream, encodedValue.issuer);
    }

    static AssetAlphaNum4 decode(XdrDataInputStream stream)
    {
        AssetAlphaNum4 decodedValue;

        const int assetCodesize = stream.readInt32();
        decodedValue.assetCode.length = assetCodesize;
        stream.read(decodedValue.assetCode);
        decodedValue.issuer = AccountID.decode(stream);

        return decodedValue;
    }
}

struct AssetAlphaNum12
{
    ubyte[] assetCode;
    AccountID issuer;

    ref AssetAlphaNum12 opAssign(AssetAlphaNum12 other)
    {
        assetCode = other.assetCode.dup;
        issuer = other.issuer;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const AssetAlphaNum12 encodedValue)
    {
        int assetCodesize = cast(int32) encodedValue.assetCode.length;
        stream.writeInt32(assetCodesize);
        stream.write(encodedValue.assetCode);
        AccountID.encode(stream, encodedValue.issuer);
    }

    static AssetAlphaNum12 decode(XdrDataInputStream stream)
    {
        AssetAlphaNum12 decodedValue;

        const int assetCodesize = stream.readInt32();
        decodedValue.assetCode.length = assetCodesize;
        stream.read(decodedValue.assetCode);
        decodedValue.issuer = AccountID.decode(stream);

        return decodedValue;
    }
}
