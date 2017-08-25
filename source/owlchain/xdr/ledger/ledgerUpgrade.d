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

    static void encode(XdrDataOutputStream stream, ref const LedgerUpgrade encodedValue)
    {
        encodeLedgerUpgradeType(stream, encodedValue.type);
        switch (encodedValue.type)
        {
        case LedgerUpgradeType.LEDGER_UPGRADE_VERSION:
            stream.writeUint32(encodedValue.newLedgerVersion);
            break;
        case LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE:
            stream.writeUint32(encodedValue.newBaseFee);
            break;
        case LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE:
            stream.writeUint32(encodedValue.newMaxTxSetSize);
            break;
        default:
            break;
        }
    }

    static LedgerUpgrade decode(XdrDataInputStream stream)
    {
        LedgerUpgrade decodedValue;
        decodedValue.type = decodeLedgerUpgradeType(stream);
        switch (decodedValue.type)
        {
        case LedgerUpgradeType.LEDGER_UPGRADE_VERSION:
            decodedValue.newLedgerVersion = stream.readUint32();
            break;
        case LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE:
            decodedValue.newBaseFee = stream.readUint32();
            break;
        case LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE:
            decodedValue.newMaxTxSetSize = stream.readUint32();
            break;
        default:
            break;
        }
        return decodedValue;
    }
}
