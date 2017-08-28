module owlchain.xdr.ledgerUpgradeType;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum LedgerUpgradeType
{
    LEDGER_UPGRADE_VERSION = 1,
    LEDGER_UPGRADE_BASE_FEE = 2,
    LEDGER_UPGRADE_MAX_TX_SET_SIZE = 3
}

static void encodeLedgerUpgradeType(XdrDataOutputStream stream, ref const LedgerUpgradeType encodedLedgerUpgradeType)
{
    int32 value = cast(int) encodedLedgerUpgradeType;
    stream.writeInt32(value);
}

static LedgerUpgradeType decodeLedgerUpgradeType(XdrDataInputStream stream)
{
    LedgerUpgradeType decodedLedgerUpgradeType;
    const int32 value = stream.readInt32();
    switch (value)
    {
    case 1:
        decodedLedgerUpgradeType = LedgerUpgradeType.LEDGER_UPGRADE_VERSION;
        break;
    case 2:
        decodedLedgerUpgradeType = LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE;
        break;
    case 3:
        decodedLedgerUpgradeType = LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE;
        break;
    default:
        throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedLedgerUpgradeType;
}
