module owlchain.overlay.tracker;

import owlchain.xdr;

import owlchain.herder.herderImpl;
import owlchain.overlay.peer;
import owlchain.main.application;

import owlchain.meterics;
import owlchain.util.timer;
import std.container.dlist;
import std.typecons;

alias void delegate(Peer, Hash) AskPeer;
alias Tuple!(Hash, "hash", BCPEnvelope, "envelope") TupleHashEnvelop;

class Tracker
{
private:
    AskPeer mAskPeer;
    Application mApp;
    Peer mLastAskedPeer;
    int mNumListRebuild;

    DList!Peer mPeersToAsk;

    VirtualTimer mTimer;
    TupleHashEnvelop[] mWaitingEnvelopes;
    Hash mItemHash;
    Meter mTryNextPeerReset;
    Meter mTryNextPeer;
    uint64 mLastSeenSlotIndex = 0;

public:
    /**
    * Create Tracker that tracks data identified by @p hash. @p askPeer
    * delegate is used to fetch the data.
    */
    this(Application app, ref Hash hash, AskPeer askPeer)
    {
        mApp = app;
        mAskPeer = askPeer;
        mNumListRebuild = 0;
        mTimer = new VirtualTimer(app);
        mItemHash = hash;

        mTryNextPeerReset = app.getMetrics().NewMeter(new MetricName("overlay", "item-fetcher", "reset-fetcher"), "item-fetcher");
        mTryNextPeer = app.getMetrics().NewMeter(new MetricName("overlay", "item-fetcher", "next-peer"), "item-fetcher");
        
        mPeersToAsk = DList!Peer();

        assert(mAskPeer);
    }

    ~this()
    {
        cancel();
        mPeersToAsk.clear();
    }

    /**
    * Return true if does not wait for any envelope.
    */
    bool empty() const
    {
        return mWaitingEnvelopes.length == 0;
    }

    /**
    * Return list of envelopes this tracker is waiting for.
    */
    ref TupleHashEnvelop[] waitingEnvelopes()
    {
        return mWaitingEnvelopes;
    }

    /**
    * Return count of envelopes it is waiting for.
    */
    size_t size() const
    {
        return mWaitingEnvelopes.length;
    }

    /**
    * Pop envelope from stack.
    */
    BCPEnvelope pop()
    {
        BCPEnvelope temp;

        return temp;
    }

    /**
    * Called periodically to remove old envelopes from list (with ledger id
    * below some @p slotIndex).
    *
    * Returns true if at least one envelope remained in list.
    */
    bool clearEnvelopesBelow(uint64 slotIndex)
    {
        return false;
    }

    /**
    * Add @p env to list of envelopes that will be resend to Herder when data
    * is received.
    */
    void listen(ref BCPEnvelope env)
    {
        return;
    }

    /**
    * Stops tracking envelope @p env.
    */
    void discard(ref BCPEnvelope env)
    {

    }

    /**
    * Stop the timer, stop requesting the item as we have it.
    */
    void cancel()
    {

    }

    /**
    * Called when given @p peer informs that it does not have given data.
    * Next peer will be tried if available.
    */
    void doesntHave(Peer peer)
    {

    }

    /**
    * Called either when @see doesntHave(Peer) was received or
    * request to peer timed out.
    */
    void tryNextPeer()
    {

    }

    /**
    * Return biggest slot index seen since last reset.
    */
    uint64 getLastSeenSlotIndex() const
    {
        return mLastSeenSlotIndex;
    }

    /**
    * Reset value of biggest slot index seen.
    */
    void resetLastSeenSlotIndex()
    {
        mLastSeenSlotIndex = 0;
    }
}
