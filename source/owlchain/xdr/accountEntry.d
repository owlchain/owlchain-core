module owlchain.xdr.accountEntry;

import owlchain.utils.uniqueStruct;

import owlchain.xdr.type;
import owlchain.xdr.accountID;
import owlchain.xdr.signer;
import owlchain.xdr.sequenceNumber;
import owlchain.xdr.thresholds;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct AccountEntry
{
    // master public key for this account
    AccountID accountID;

    // in stroops
    int64 balance;

    // last sequence number used for this account
    SequenceNumber seqNum;

    // number of sub-entries this account has drives the reserve
    uint32 numSubEntries;

    // Account to vote for during inflation
    UniqueStruct!AccountID inflationDest;

    // see AccountFlags
    uint32 flags;   

    // can be used for reverse federation and memo lookup
    string homeDomain;

    // fields used for signatures
    // thresholds stores unsigned bytes: [weight of master|low|medium|high]
    Thresholds thresholds;
    
    // possible signers for this account
    Signer[] signers;
    AccountEntryExt ext;

    static void encode(XdrDataOutputStream stream, ref const AccountEntry encoded)
    {
        AccountID.encode(stream, encoded.accountID);
        stream.writeInt64(encoded.balance);
        SequenceNumber.encode(stream, encoded.seqNum);

        if (encoded.inflationDest != null)
        {
            stream.writeInt(1);
            AccountID.encode(stream, *encoded.inflationDest);
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
            decoded.inflationDest = cast(UniqueStruct!AccountID)(new AccountID());
            *decoded.inflationDest = AccountID.decode(stream);
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
