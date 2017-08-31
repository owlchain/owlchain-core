module owlchain.ledger.ledgerManager;


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
}
