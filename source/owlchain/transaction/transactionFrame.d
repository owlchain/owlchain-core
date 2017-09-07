module owlchain.transaction.transactionFrame;

import owlchain.xdr;
import std.digest.sha;
import owlchain.util.types;

import owlchain.ledger.ledgerManager;
import owlchain.ledger.accountFrame;
import owlchain.main.application;

import std.container.rbtree;

alias RedBlackTree!(TransactionFrame, "(a < b)") TransactionFrameSet;


/*
A transaction in its exploded form.
We can get it in from the DB or from the wire
*/
class TransactionFrame
{
protected:
    TransactionEnvelope mEnvelope;
    TransactionResult mResult;
    owlchain.ledger.accountFrame.AccountFrame mSigningAccount;

    Hash mNetworkID;     // used to change the way we compute signatures
    Hash mContentsHash; // the hash of the contents
    Hash mFullHash;     // the hash of the contents and the sig.

public:
    this(ref Hash networkID, ref TransactionEnvelope envelope)
    {
        mNetworkID = networkID;
        mEnvelope = envelope;
    }

    override bool opEquals(const Object o) const
    {
        TransactionFrame other = cast(TransactionFrame) o;
        return (mNetworkID == other.mNetworkID) && (mEnvelope == other.mEnvelope);
    }

    override int opCmp(const Object o) const
    {
        TransactionFrame other = cast(TransactionFrame) o;

        if (mNetworkID < other.mNetworkID)
        {
            return -1;
        }
        else if (mNetworkID > other.mNetworkID)
        {
            return 1;
        }
        else
        {
            if (mEnvelope < other.mEnvelope)
            {
                return -1;
            }
            else if (mEnvelope > other.mEnvelope)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }
    }

    ref const(TransactionEnvelope) getEnvelope() const
    {
        return mEnvelope;
    }

    ref TransactionEnvelope getEnvelope()
    {
        return mEnvelope;
    }

    ref const(Hash) getFullHash() 
    {
        if (isZero(mFullHash.hash))
        {
            mFullHash = Hash(sha256Of(xdr!TransactionEnvelope.serialize(mEnvelope)));
        }
        return mFullHash;
    }

    double getFeeRatio(LedgerManager lm) const
    {
        return 0;
    }

    SequenceNumber getSeqNum() const
    {
        return mEnvelope.tx.seqNum;
    }

    const(AccountFrame) getSourceAccount() const
    {
        return mSigningAccount;
    }

    AccountID getSourceID()  const
    {
        return mEnvelope.tx.sourceAccount;
    }

    int64 getFee()  const
    {
        return 0;
    }

    int64 getMinFee(ref LedgerManager lm)  const
    {
        return 0;
    }

    double getFeeRatio(ref LedgerManager lm)  const
    {
        return 0;
    }

    bool checkValid(Application app, SequenceNumber current)
    {
        return false;
    }

    ref TransactionResult getResult()
    {
        return mResult;
    }

    ref TransactionResultCode getResultCode()
    {
        return getResult().result.code;
    }

}