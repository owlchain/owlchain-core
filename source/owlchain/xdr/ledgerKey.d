module owlchain.xdr.ledgerKey;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.asset;
import owlchain.xdr.ledgerEntryType;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct LedgerKey
{
    LedgerEntryType type;
    LedgerKeyAccount account;
    LedgerKeyTrustLine trustLine;
    LedgerKeyOffer offer;
    LedgerKeyData data;

    static void encode(XdrDataOutputStream stream, ref const LedgerKey encodedLedgerKey)
    {
        stream.writeInt32(encodedLedgerKey.type);
        switch (encodedLedgerKey.type)
        {
            case LedgerEntryType.ACCOUNT :
                LedgerKeyAccount.encode(stream, encodedLedgerKey.account);
                break;
            case LedgerEntryType.TRUSTLINE :
                LedgerKeyTrustLine.encode(stream, encodedLedgerKey.trustLine);
                break;
            case LedgerEntryType.OFFER :
                LedgerKeyOffer.encode(stream, encodedLedgerKey.offer);
                break;
            case LedgerEntryType.DATA :
                LedgerKeyData.encode(stream, encodedLedgerKey.data);
                break;
            default:
                throw new Exception("Unknown enum value");
        }
    }

    static LedgerKey decode(XdrDataInputStream stream)
    {
        LedgerKey decodedLedgerKey;

        decodedLedgerKey.type = cast(LedgerEntryType)stream.readInt32();
        switch (decodedLedgerKey.type)
        {
            case LedgerEntryType.ACCOUNT :
                decodedLedgerKey.account = LedgerKeyAccount.decode(stream);
                break;
            case LedgerEntryType.TRUSTLINE :
                decodedLedgerKey.trustLine = LedgerKeyTrustLine.decode(stream);
                break;
            case LedgerEntryType.OFFER :
                decodedLedgerKey.offer = LedgerKeyOffer.decode(stream);
                break;
            case LedgerEntryType.DATA :
                decodedLedgerKey.data = LedgerKeyData.decode(stream);
                break;
            default:
                throw new Exception("Unknown enum value");
        }
        return decodedLedgerKey;
    }
}

struct LedgerKeyAccount
{
    AccountID accountID;

    static void encode(XdrDataOutputStream stream, ref const LedgerKeyAccount encoded)
    {
        AccountID.encode(stream, encoded.accountID);
    }

    static LedgerKeyAccount decode(XdrDataInputStream stream)
    {
        LedgerKeyAccount decoded;

        decoded.accountID = AccountID.decode(stream);
        return decoded;
    }
}

struct LedgerKeyTrustLine
{
    AccountID accountID;
    Asset asset;

    static void encode(XdrDataOutputStream stream, ref const LedgerKeyTrustLine encoded)
    {
        AccountID.encode(stream, encoded.accountID);
        Asset.encode(stream, encoded.asset);
    }

    static LedgerKeyTrustLine decode(XdrDataInputStream stream)
    {
        LedgerKeyTrustLine decoded;
        
        decoded.accountID = AccountID.decode(stream);
        decoded.asset = Asset.decode(stream);
        
        return decoded;
    }
}

struct LedgerKeyOffer
{
    AccountID sellerID;
    uint64 offerID;

    static void encode(XdrDataOutputStream stream, ref const LedgerKeyOffer encoded)
    {
        AccountID.encode(stream, encoded.sellerID);
        stream.writeUint64(encoded.offerID);
    }

    static LedgerKeyOffer decode(XdrDataInputStream stream)
    {
        LedgerKeyOffer decoded;
        
        decoded.sellerID = AccountID.decode(stream);
        decoded.offerID = stream.readUint64();

        return decoded;
    }
}

struct LedgerKeyData
{
    AccountID accountID;
    string dataName;

    static void encode(XdrDataOutputStream stream, ref const LedgerKeyData encoded)
    {
        AccountID.encode(stream, encoded.accountID);
        stream.writeString(encoded.dataName);
    }

    static LedgerKeyData decode(XdrDataInputStream stream)
    {
        LedgerKeyData decoded;
        decoded.accountID = AccountID.decode(stream);
        decoded.dataName = stream.readString();
        return decoded;
    }
}