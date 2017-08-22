module owlchain.xdr.ledgerUpgrade;

import owlchain.xdr.type;
import owlchain.xdr.ledgerUpgradeType;


import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct LedgerUpgrade
{
    LedgerUpgradeType type;
    uint32 newLedgerVersion;
    uint32 newBaseFee;
    uint32 newMaxTxSetSize;

    static void encode(XdrDataOutputStream stream, ref const LedgerUpgrade encodedLedgerUpgrade)
    {
        stream.writeInt32(encodedLedgerUpgrade.type);
        switch (encodedLedgerUpgrade.type) {
            case LedgerUpgradeType.LEDGER_UPGRADE_VERSION:
                stream.writeUint32(encodedLedgerUpgrade.newLedgerVersion);
                break;
            case LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE:
                stream.writeUint32(encodedLedgerUpgrade.newBaseFee);
                break;
            case LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE:
                stream.writeUint32(encodedLedgerUpgrade.newMaxTxSetSize);
                break;
            default:
                throw new Exception("Unknown enum value");
        }
    }

    static LedgerUpgrade decode(XdrDataInputStream stream)
    {
        LedgerUpgrade decodedLedgerUpgrade;
        decodedLedgerUpgrade.type = cast(LedgerUpgradeType)stream.readInt32();
        switch (decodedLedgerUpgrade.type) {
            case LedgerUpgradeType.LEDGER_UPGRADE_VERSION: 
                decodedLedgerUpgrade.newLedgerVersion = stream.readUint32();
                break;
            case LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE: 
                decodedLedgerUpgrade.newBaseFee = stream.readUint32();
                break;
            case LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE: 
                decodedLedgerUpgrade.newMaxTxSetSize = stream.readUint32();
                break;
            default:
                throw new Exception("Unknown enum value");
        }
        return decodedLedgerUpgrade;
    }
}