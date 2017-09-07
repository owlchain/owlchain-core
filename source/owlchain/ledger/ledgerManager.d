module owlchain.ledger.ledgerManager;

import owlchain.xdr;
import owlchain.herder.ledgerCloseData;

class LedgerManager
{
public:
    enum State
    {
        // Loading state from database, not yet active
        LM_BOOTING_STATE,

        // local state is in sync with view of consensus coming from herder
        // desynchronization will cause transition to CATCHING_UP_STATE.
        LM_SYNCED_STATE,

        // local state doesn't match view of consensus from herder
        // catchup is in progress
        LM_CATCHING_UP_STATE,

        LM_NUM_STATE
    };

    this()
    {

    }

    void setState(State s)
    {

    }

    uint32 getMaxTxSetSize()
    {
        return 0;
    }

    LedgerHeaderHistoryEntry mLastClosedLedger;

    ref LedgerHeaderHistoryEntry getLastClosedLedgerHeader()
    {
        return mLastClosedLedger;
    }

    void valueExternalized(LedgerCloseData ledgerData)
    {

    }

    uint32 getLedgerNum() const
    {
        return 0;
    }


    uint32 getLastClosedLedgerNum() const
    {
        return 0;
    }

    State getState() const
    {
        return State.LM_SYNCED_STATE;
    }

    bool isSynced() const
    {
        return getState() == State.LM_SYNCED_STATE;
    }

}
