module owlchain.xdr.accountEntry;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.signer;
import owlchain.xdr.sequenceNumber;
import owlchain.xdr.thresholds;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct AccountEntry
{
    AccountID accountID;
    int64 balance;
    SequenceNumber seqNum;
    uint32 numSubEntries;

    AccountID inflationDest;
    uint32 flags;
    string homeDomain;
    Thresholds thresholds;
    Signer[] signers;
    AccountEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const AccountEntry encoded)
    {
        AccountID.encode(stream, encoded.accountID);
        stream.writeInt64(encoded.balance);
        SequenceNumber.encode(stream, encoded.seqNum);

        if (encoded.inflationDest.ed25519 != uint256_zero)
        {
            stream.writeInt(1);
            AccountID.encode(stream, encoded.inflationDest);
        }
        else
        {
            stream.writeInt(0);
        }

        stream.writeUint32(encoded.flags);
        stream.writeString(encoded.homeDomain);

        Thresholds.encode(stream, encoded.thresholds);

        const int signerssize = cast(int) encoded.signers.length;
        stream.writeInt32(signerssize);
        for (int i = 0; i < signerssize; i++)
        {
            Signer.encode(stream, encoded.signers[i]);
        }

        AccountEntryExt.encode(stream, encoded.ext);
    }

    static AccountEntry decode(XdrDataInputStream stream)
    {
        AccountEntry decoded;

        decoded.accountID = AccountID.decode(stream);
        decoded.balance = stream.readInt64();
        decoded.seqNum = SequenceNumber.decode(stream);

        const int inflationDestPresent = stream.readInt32();
        if (inflationDestPresent != 0)
        {
            decoded.inflationDest = AccountID.decode(stream);
        }

        decoded.flags = stream.readUint32();
        decoded.homeDomain = stream.readString();

        decoded.thresholds = Thresholds.decode(stream);

        const int signerssize = stream.readInt32();
        decoded.signers.length = 0;
        for (int i = 0; i < signerssize; i++)
        {
            decoded.signers ~= Signer.decode(stream);
        }

        decoded.ext = AccountEntryExt.decode(stream);
        return decoded;
    }
}

struct AccountEntryExt
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const AccountEntryExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static AccountEntryExt decode(XdrDataInputStream stream)
    {
        AccountEntryExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}
