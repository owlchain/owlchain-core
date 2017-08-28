module owlchain.xdr.bucketEntry;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.bucketEntryType;
import owlchain.xdr.ledgerEntry;
import owlchain.xdr.ledgerKey;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct BucketEntry
{
    BucketEntryType type;
    LedgerEntry liveEntry;
    LedgerKey deadEntry;

    static void encode(XdrDataOutputStream stream, ref const BucketEntry encoded)
    {
        encodeBucketEntryType(stream, encoded.type);
        switch (encoded.type)
        {
        case BucketEntryType.LIVEENTRY:
            LedgerEntry.encode(stream, encoded.liveEntry);
            break;
        case BucketEntryType.DEADENTRY:
            LedgerKey.encode(stream, encoded.deadEntry);
            break;
        default:
            break;
        }
    }

    static BucketEntry decode(XdrDataInputStream stream)
    {
        BucketEntry decoded;

        decoded.type = decodeBucketEntryType(stream);
        switch (decoded.type)
        {
        case BucketEntryType.LIVEENTRY:
            decoded.liveEntry = LedgerEntry.decode(stream);
            break;
        case BucketEntryType.DEADENTRY:
            decoded.deadEntry = LedgerKey.decode(stream);
            break;
        default:
            break;
        }
        return decoded;
    }
}
