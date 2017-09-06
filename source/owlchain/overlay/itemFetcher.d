module owlchain.overlay.itemFetcher;

import owlchain.xdr;
import owlchain.herder.txSetFrame;
import owlchain.overlay.peer;
import owlchain.overlay.tracker;
import owlchain.main.application;

import owlchain.meterics;

import std.typecons;
alias RefCounted!(BCPQuorumSet, RefCountedAutoInitialize.no) BCPQuorumSetPtr;
alias void delegate (Peer, Hash) AskPeer;

class ItemFetcher
{
public:

    /**
    * Create ItemFetcher that fetches data using @p askPeer delegate.
    */
    this(Application app, AskPeer askPeer)
    {
        mApp = app;
        mItemMapSize = app.getMetrics().NewCounter(new MetricName("overlay", "memory", "item-fetch-map"));
        mAskPeer = askPeer;
    }

    /**
    * Fetch data identified by @p hash and needed by @p envelope. Multiple
    * envelopes may require one set of data.
    */
    void fetch(Hash itemHash, ref BCPEnvelope envelope)
    {

    }

    /**
    * Stops fetching data identified by @p hash for @p envelope. If other
    * envelopes requires this data, it is still being fetched, but
    * @p envelope will not be notified about it.
    */
    void stopFetch(Hash itemHash, ref BCPEnvelope envelope)
    {

    }

    /**
    * Return biggest slot index seen for given hash. If 0, then given hash
    * is not being fetched.
    */
    uint64 getLastSeenSlotIndex(Hash itemHash)
    {
        return 0L;
    }

    /**
    * Return envelopes that require data identified by @p hash.
    */
    BCPEnvelope[] fetchingFor(Hash itemHash)
    {
        BCPEnvelope[] temp;

        return temp;
    }

    /**
    * Called periodically to remove old envelopes from list (with ledger id
    * below some @p slotIndex). Can also remove @see Tracker instances when
    * non needed anymore.
    */
    void stopFetchingBelow(uint64 slotIndex)
    {

    }

    /**
    * Called when given @p peer informs that it does not have data identified
    * by @p itemHash.
    */
    void doesntHave(Hash itemHash, Peer peer)
    {

    }

    /**
    * Called when data with given @p itemHash was received. All envelopes
    * added before with @see fetch and the same @p itemHash will be resent
    * to Herder, matching @see Tracker will be cleaned up.
    */
    void recv(Hash itemHash)
    {

    }

protected:
    void stopFetchingBelowInternal(uint64 slotIndex)
    {

    }

    Application mApp;
    Tracker[Hash] mTrackers;

    // NB: There are many ItemFetchers in the system at once, but we are sharing
    // a single counter for all the items being fetched by all of them. Be
    // careful, therefore, to only increment and decrement this counter, not set
    // it absolutely.
    Counter mItemMapSize;

private:
    AskPeer mAskPeer;
    
}