module owlchain.xdr.ledgerUpgradeType;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum LedgerUpgradeType
{
  LEDGER_UPGRADE_VERSION = 1,
  LEDGER_UPGRADE_BASE_FEE = 2,
  LEDGER_UPGRADE_MAX_TX_SET_SIZE = 3
}

static void encode(XdrDataOutputStream stream, ref const LedgerUpgradeType encodedLedgerUpgradeType)
{
    int32 value = cast(int)encodedLedgerUpgradeType;
    stream.writeInt32(value);
}

static LedgerUpgradeType decode(XdrDataInputStream stream)
{
    LedgerUpgradeType decodedLedgerUpgradeType;
    int32 value = stream.readInt32();
    switch (value) {
        case LedgerUpgradeType.LEDGER_UPGRADE_VERSION: 
            decodedLedgerUpgradeType = LedgerUpgradeType.LEDGER_UPGRADE_VERSION;
            break;
        case LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE: 
            decodedLedgerUpgradeType = LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE;
            break;
        case LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE: 
            decodedLedgerUpgradeType = LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE;
            break;
        default:
            throw new Exception("Unknown enum value");
    }
    return decodedLedgerUpgradeType;
}
