module owlchain.xdr.ledgerEntryType;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum LedgerEntryType  {
    ACCOUNT = 0,
    TRUSTLINE = 1,
    OFFER = 2,
    DATA = 3
}

static void encodeLedgerEntryType(XdrDataOutputStream stream, ref const LedgerEntryType encodedValue)
{
    int32 value = cast(int) encodedValue;
    stream.writeInt32(value);
}

static LedgerEntryType decodeLedgerEntryType(XdrDataInputStream stream)
{
    LedgerEntryType decodedValue;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedValue = LedgerEntryType.ACCOUNT;
            break;
        case 1:
            decodedValue = LedgerEntryType.TRUSTLINE;
            break;
        case 2:
            decodedValue = LedgerEntryType.OFFER;
            break;
        case 3:
            decodedValue = LedgerEntryType.DATA;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedValue;
}
