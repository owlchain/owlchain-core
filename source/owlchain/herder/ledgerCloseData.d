module owlchain.herder.ledgerCloseData;

import owlchain.xdr;

import owlchain.herder.txSetFrame;

/**
* Helper class that describes a single ledger-to-close -- a set of transactions
* and auxiliary values -- as decided by the Herder (and ultimately: BCP). This
* does not include the effects of _performing_ any transactions, merely the
* values that the network has agreed _to apply_ to the current ledger,
* atomically, in order to produce the next ledger.
*/
class LedgerCloseData
{
public:
    this(uint32 ledgerSeq, TxSetFrame txSet, ref BOSValue v)
    {
        mLedgerSeq = ledgerSeq;
        mTxSet = txSet;
        mValue = v;
    };

    @property uint32 getLedgerSeq()
    {
        return mLedgerSeq;
    }

    @property TxSetFrame getTxSet()
    {
        return mTxSet;
    }

    @property ref BOSValue getValue()
    {
        return mValue;
    }

private:
    uint32 mLedgerSeq;
    TxSetFrame mTxSet;
    BOSValue mValue;
}

string bosValueToString(ref BOSValue v)
{
    import std.digest.sha;
    import std.outbuffer;

    XdrDataInputStream stream = new XdrDataInputStream();
    OutBuffer oBuffer = new OutBuffer();

    oBuffer.writef("[ txH: %s, ct: %d, upgrades: [",
            toHexString(v.txSetHash.hash)[0 .. 5], v.closeTime);

    for (int i = 0; i < v.upgrades.length; i++)
    {
        if (v.upgrades[i].value.length == 0)
        {
            // should not happen as this is not valid
            oBuffer.write("<empty>");
        }
        else
        {
            try
            {
                LedgerUpgrade lupgrade;

                stream.assign(xdr!UpgradeType.serialize(v.upgrades[i]));
                lupgrade = LedgerUpgrade.decode(stream);

                switch (lupgrade.type)
                {
                case LedgerUpgradeType.LEDGER_UPGRADE_VERSION:
                    oBuffer.writef("VERSION=%d", lupgrade.newLedgerVersion);
                    break;
                case LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE:
                    oBuffer.writef("BASE_FEE=%d", lupgrade.newBaseFee);
                    break;
                case LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE:
                    oBuffer.writef("MAX_TX_SET_SIZE=%d", lupgrade.newMaxTxSetSize);
                    break;
                default:
                    oBuffer.write("<unsupported>");
                }
            }
            catch (Exception e)
            {
                oBuffer.write("<unknown>");
            }
        }
        oBuffer.write(", ");
    }
    oBuffer.write(" ] ]");

    return oBuffer.toString();

}
