module owlchain.herder.txSetFrame;

import std.stdio;
import std.algorithm;

import owlchain.xdr;

import owlchain.consensus.slot;
import owlchain.crypto.sha;
import owlchain.crypto.hex;

import owlchain.main.application;
import owlchain.ledger.ledgerManager;
import owlchain.transaction.transactionFrame;

import owlchain.util.types;

class TxSetFrame
{

private:
    bool mHashIsValid;
    Hash mHash;

    Hash mPreviousLedgerHash;

public:
    TransactionFrame[] mTransactions;

    this(ref Hash previousLedgerHash)
    {
        mHashIsValid = false;
        mPreviousLedgerHash = previousLedgerHash;
    }

    // make it from the wire
    this(Hash networkID, TransactionSet xdrSet)
    {
        mHashIsValid = false;
        for (ulong i = 0; i < xdrSet.txs.length; i++)
        {
            mTransactions ~= new TransactionFrame(networkID, xdrSet.txs[i]);
        }
        mPreviousLedgerHash = xdrSet.previousLedgerHash;
    }

    // returns the hash of this tx set
    ref Hash getContentsHash()
    {
        if (!mHashIsValid)
        {
            sortForHash();
            auto hasher = SHA256.create();
            hasher.add(mPreviousLedgerHash.hash);
            for (uint n = 0; n < mTransactions.length; n++)
            {
                hasher.add(xdr!TransactionEnvelope.serialize(mTransactions[n].getEnvelope()));
            }
            mHash = Hash(hasher.finish());
            mHashIsValid = true;
        }
        return mHash;
    }

    ref Hash previousLedgerHash()
    {
        return mPreviousLedgerHash;
    }

    // order the txset correctly
    // must take into account multiple tx from same account
    void sortForHash()
    {
        // need to use the hash of whole tx here since multiple txs could have
        // the same Contents
        mTransactions.sort!((tx1, tx2) => tx1.getFullHash() < tx2.getFullHash()).release;
    }

    /*
    Build a list of transaction ready to be applied to the last closed ledger,
    based on the transaction set.

    The order satisfies:
    * transactions for an account are sorted by sequence number (ascending)
    * the order between accounts is randomized
    */
    TransactionFrame[] sortForApply()
    {
        TransactionFrame[] retList;

        TransactionFrame[][] txBatches;
        txBatches.length = 4;

        size_t[AccountID] accountTxCountMap;

        retList = mTransactions;

        // sort all the txs by seqnum
        retList.sort!((tx1, tx2) => tx1.getSeqNum() < tx2.getSeqNum()).release;

        // build the txBatches
        // batch[i] contains the i-th transaction for any account with
        // a transaction in the transaction set
        for (ulong i = 0; i < retList.length; i++)
        {
            auto p = retList[i].getSourceID() in accountTxCountMap;
            if (p is null)
            {
                accountTxCountMap[retList[i].getSourceID()] = 0;
            }
            auto v = accountTxCountMap[retList[i].getSourceID()];

            if (v >= txBatches.length)
            {
                txBatches.length = (v + 4);
            }
            txBatches[v] ~= retList[i];
            v++;
        }

        retList.length = 0;

        for (ulong n = 0; n < txBatches.length; n++)
        {
            // randomize each batch using the hash of the transaction set
            // as a way to randomize even more
            Hash hs = getContentsHash();
            txBatches[n].sort!((tx1, tx2) {
                return lessThanXored(tx1.getFullHash(), tx2.getFullHash(), hs);
            }).release;

            for (ulong m = 0; m < txBatches[n].length; m++)
            {
                retList ~= txBatches[n][m];
            }
        }

        return retList;
    }

    // need to make sure every account that is submitting a tx has enough to pay
    // the fees of all the tx it has submitted in this set
    // check seq num
    bool checkValid(Application app)
    {
        // Establish read-only transaction for duration of checkValid.
        //soci::transaction sqltx(app.getDatabase().getSession());
        app.getDatabase().setCurrentTransactionReadOnly();

        auto lcl = app.getLedgerManager().getLastClosedLedgerHeader();
        // Start by checking previousLedgerHash
        if (lcl.hash != mPreviousLedgerHash)
        {
            writefln("[DEBUG], Herder Got bad txSet: %s ; expected: %s", hexAbbrev(mPreviousLedgerHash),
                     hexAbbrev(app.getLedgerManager().getLastClosedLedgerHeader().hash));
            return false;
        }

        if (mTransactions.length > lcl.header.maxTxSetSize)
        {
            writefln("[DEBUG], Herder Got bad txSet: too many txs %d > %d",
                     mTransactions.length, lcl.header.maxTxSetSize);
            return false;
        }

        TransactionFrame[][AccountID] accountTxMap;

        Hash lastHash;
        for (ulong i = 0; i < mTransactions.length; i++)
        {
            // make sure the set is sorted correctly
            if (mTransactions[i].getFullHash() < lastHash)
            {
                writefln("[WARNING], Herder bad txSet: %s not sorted correctly",
                         hexAbbrev(mPreviousLedgerHash));
                return false;
            }
            auto p = mTransactions[i].getSourceID() in accountTxMap;
            if (p is null)
            {
                TransactionFrame[] array;
                accountTxMap[mTransactions[i].getSourceID()] = array;
            }
            accountTxMap[mTransactions[i].getSourceID()] ~= mTransactions[i];
            lastHash = mTransactions[i].getFullHash();
        }

        foreach (ref const AccountID account, ref TransactionFrame[] item; accountTxMap)
        {
            // order by sequence number
            item.sort!((tx1, tx2) => tx1.getSeqNum() < tx2.getSeqNum()).release;

            TransactionFrame lastTx;
            SequenceNumber lastSeq;
            lastSeq.number = 0;
            int64 totFee = 0;
            for (ulong i = 0; i < item.length; i++)
            {
                if (!item[i].checkValid(app, lastSeq))
                {
                    writefln("[DEBUG], Herder bad txSet: tx invalid lastSeq: %d tx: %s result: %s",
                             hexAbbrev(mPreviousLedgerHash),
                             lastSeq.number, xdr!TransactionEnvelope.print(item[i].getEnvelope()),
                             item[i].getResultCode());

                    return false;
                }
                totFee += item[i].getFee();

                lastTx = item[i];
                lastSeq = item[i].getSeqNum();
            }

            if (lastTx)
            {
                // make sure account can pay the fee for all these tx
                const int64 newBalance = lastTx.getSourceAccount().getBalance() - totFee;
                if (newBalance < lastTx.getSourceAccount()
                    .getMinimumBalance(app.getLedgerManager()))
                {
                    writefln("[DEBUG], Herder bad txSet: account can't pay fee tx: %s",
                             hexAbbrev(mPreviousLedgerHash),
                             xdr!TransactionEnvelope.print(lastTx.getEnvelope()),);
                    return false;
                }
            }
        }
        return true;
    }

    void trimInvalid(Application app, ref TransactionFrame[] trimmed)
    {
        //soci::transaction sqltx(app.getDatabase().getSession());
        app.getDatabase().setCurrentTransactionReadOnly();

        sortForHash();

        TransactionFrame[][AccountID] accountTxMap;

        for (ulong i = 0; i < mTransactions.length; i++)
        {
            /*
            auto p = mTransactions[i].getSourceID() in accountTxMap;
            if (p is null)
            {
            TransactionFrame[] array;
            accountTxMap[mTransactions[i].getSourceID()] = array;
            }
            */
            accountTxMap[mTransactions[i].getSourceID()] ~= mTransactions[i];
        }

        foreach (ref const AccountID account, ref TransactionFrame[] item; accountTxMap)
        {
            // order by sequence number
            alias comp = (tx1, tx2) => tx1.getSeqNum() < tx2.getSeqNum();
            item.sort!(comp).release;

            TransactionFrame lastTx;
            SequenceNumber lastSeq;
            lastSeq.number = 0;
            int64 totFee = 0;
            for (ulong i = 0; i < item.length; i++)
            {
                if (!item[i].checkValid(app, lastSeq))
                {
                    trimmed ~= item[i];
                    removeTx(item[i]);
                    continue;
                }
                totFee += item[i].getFee();

                lastTx = item[i];
                lastSeq = item[i].getSeqNum();
            }
            if (lastTx)
            {
                // make sure account can pay the fee for all these tx
                const int64 newBalance = lastTx.getSourceAccount().getBalance() - totFee;
                if (newBalance < lastTx.getSourceAccount()
                    .getMinimumBalance(app.getLedgerManager()))
                {
                    for (ulong i = 0; i < item.length; i++)
                    {
                        trimmed ~= item[i];
                        removeTx(item[i]);
                    }
                }
            }
        }
    }

    void surgePricingFilter(LedgerManager lm)
    {
        size_t max = lm.getMaxTxSetSize();
        if (mTransactions.length > max)
        {
            // surge pricing in effect!
            writefln("[WARNING], Herder surge pricing in effect! %d", mTransactions.length);

            // determine the fee ratio for each account
            double[AccountID] accountFeeMap;
            for (ulong i = 0; i < mTransactions.length; i++)
            {
                double r = mTransactions[i].getFeeRatio(lm);
                auto now = (mTransactions[i].getSourceID() in accountFeeMap);
                if (now is null)
                    accountFeeMap[mTransactions[i].getSourceID()] = r;
                else if (r < *now)
                    *now = r;
            }

            // sort tx by amount of fee they have paid
            // remove the bottom that aren't paying enough
            TransactionFrame[] tempList = mTransactions.dup;

            tempList.sort!((tx1, tx2) {
                if (tx1.getSourceID() == tx2.getSourceID())
                    return tx1.getSeqNum() < tx2.getSeqNum();
                double fee1 = accountFeeMap[tx1.getSourceID()];
                double fee2 = accountFeeMap[tx2.getSourceID()];
                if (fee1 == fee2)
                    return tx1.getSourceID() < tx2.getSourceID();
                return fee1 > fee2;
            }).release;

            for (ulong i = max; i < tempList.length; i++)
            {
                removeTx(tempList[i]);
            }
        }
    }

    void removeTx(TransactionFrame tx)
    {
        for (ulong i = 0; i < mTransactions.length; i++)
        {
            if (mTransactions[i] == tx)
            {
                mTransactions = mTransactions.remove(i);
                break;
            }
        }
        mHashIsValid = false;
    }

    void add(TransactionFrame tx)
    {
        mTransactions ~= (tx);
        mHashIsValid = false;
    }

    size_t size()
    {
        return mTransactions.length;
    }

    void toXDR(ref TransactionSet txSet)
    {
        txSet.txs.length = mTransactions.length;
        for (uint n = 0; n < mTransactions.length; n++)
        {
            txSet.txs[n] = mTransactions[n].getEnvelope();
        }
        txSet.previousLedgerHash = mPreviousLedgerHash;
    }
}
