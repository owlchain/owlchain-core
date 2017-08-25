module owlchain.xdr.assetType;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum AssetType
{
    ASSET_TYPE_NATIVE = 0,
    ASSET_TYPE_CREDIT_ALPHANUM4 = 1,
    ASSET_TYPE_CREDIT_ALPHANUM12 = 2
}

static void encodeAssetType(XdrDataOutputStream stream, ref const AssetType encodedValue)
{
    int32 value = cast(int) encodedValue;
    stream.writeInt32(value);
}

static AssetType decodeAssetType(XdrDataInputStream stream)
{
    AssetType decodedValue;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedValue = AssetType.ASSET_TYPE_NATIVE;
            break;
        case 1:
            decodedValue = AssetType.ASSET_TYPE_CREDIT_ALPHANUM4;
            break;
        case 2:
            decodedValue = AssetType.ASSET_TYPE_CREDIT_ALPHANUM12;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value, 10));
    }
    return decodedValue;
}
