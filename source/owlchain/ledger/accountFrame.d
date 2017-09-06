module owlchain.ledger.accountFrame;

import owlchain.xdr;
import owlchain.ledger.ledgerManager;

class AccountFrame
{
public:
    this()
    {

    }
    this(ref LedgerEntry from)
    {

    }

    this(AccountFrame from)
    {

    }
    this(ref AccountID id)
    {

    }
    // actual balance for the account
    int64 getBalance() const
    {
        return 0;
    }
    int64 getMinimumBalance(LedgerManager lm) const
    {
        return 0;
    }
}