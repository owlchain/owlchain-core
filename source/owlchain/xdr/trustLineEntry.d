module owlchain.xdr.trustLineEntry;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.asset;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TrustLineEntry
{
    AccountID accountID;
    Asset asset;
    int64 balance;
    int64 limit;
    uint32 flags;
    TrustLineEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const TrustLineEntry encoded)
    {
        AccountID.encode(stream, encoded.accountID);
        Asset.encode(stream, encoded.asset);
        stream.writeInt64(encoded.balance);
        stream.writeInt64(encoded.limit);
        stream.writeUint32(encoded.flags);
        TrustLineEntryExt.encode(stream, encoded.ext);
    }

    static TrustLineEntry decode(XdrDataInputStream stream)
    {
        TrustLineEntry decoded;
        decoded.accountID = AccountID.decode(stream);
        decoded.asset = Asset.decode(stream);
        decoded.balance = stream.readInt64();
        decoded.limit = stream.readInt64();
        decoded.flags = stream.readUint32();
        decoded.ext = TrustLineEntryExt.decode(stream);
        return decoded;
    }
}

struct TrustLineEntryExt
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const TrustLineEntryExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static TrustLineEntryExt decode(XdrDataInputStream stream)
    {
        TrustLineEntryExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}
