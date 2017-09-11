module owlchain.overlay.itemFetcher;

import owlchain.xdr;
import owlchain.herder.txSetFrame;
import owlchain.overlay.peer;
import owlchain.overlay.tracker;
import owlchain.main.application;

import owlchain.meterics;

import owlchain.crypto.hex;
import owlchain.utils.globalChecks;

import std.format;
import std.typecons;

alias RefCounted!(BCPQuorumSet, RefCountedAutoInitialize.no) BCPQuorumSetPtr;

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
    void fetch(ref Hash itemHash, ref BCPEnvelope envelope)
    {
        CLOG(LEVEL.TRACE, "Overlay", format("fetch %s", hexAbbrev(itemHash)));

        auto entryIt = itemHash in mTrackers;
        if (entryIt is null)
        { 
            // not being tracked
            Tracker tracker = new Tracker(mApp, itemHash, mAskPeer);
            mTrackers[itemHash] = tracker;
            mItemMapSize.inc();

            tracker.listen(envelope);
            tracker.tryNextPeer();
        }
        else
        {
            mTrackers[itemHash].listen(envelope);
        }
    }

    /**
    * Stops fetching data identified by @p hash for @p envelope. If other
    * envelopes requires this data, it is still being fetched, but
    * @p envelope will not be notified about it.
    */
    void stopFetch(ref Hash itemHash, ref BCPEnvelope envelope)
    {
        CLOG(LEVEL.TRACE, "Overlay", format("stopFetch %s", hexAbbrev(itemHash)));

        auto entryIt = itemHash in mTrackers;
        if (entryIt !is null)
        { 
            CLOG(LEVEL.TRACE, "Overlay", format("stopFetch %s : %d", hexAbbrev(itemHash), mTrackers[itemHash].size));

            mTrackers[itemHash].discard(envelope);
            if (mTrackers[itemHash].empty())
            {
                // stop the timer, stop requesting the item as no one is waiting for
                // it
                mTrackers[itemHash].cancel();
            }
        }
    }

    /**
    * Return biggest slot index seen for given hash. If 0, then given hash
    * is not being fetched.
    */
    uint64 getLastSeenSlotIndex(ref Hash itemHash)
    {
        auto entryIt = itemHash in mTrackers;
        if (entryIt is null)
        { 
            return 0L;
        }

        return mTrackers[itemHash].getLastSeenSlotIndex();
    }

    /**
    * Return envelopes that require data identified by @p hash.
    */
    BCPEnvelope[] fetchingFor(ref Hash itemHash)
    {
        BCPEnvelope[] result;
        auto entryIt = itemHash in mTrackers;
        if (entryIt is null)
        { 
            return result;
        }

        auto waiting = mTrackers[itemHash].waitingEnvelopes();
        for (size_t i; i < waiting.length; i++)
        {
            result ~= waiting[i].envelope;
        }

        return result;
    }

    /**
    * Called periodically to remove old envelopes from list (with ledger id
    * below some @p slotIndex). Can also remove @see Tracker instances when
    * non needed anymore.
    */
    void stopFetchingBelow(uint64 slotIndex)
    {
        // only perform this cleanup from the top of the stack as it causes
        // all sorts of evil side effects
        mApp.getClock().getIOService().post(() {
            stopFetchingBelowInternal(slotIndex); 
        });
    }

    /**
    * Called when given @p peer informs that it does not have data identified
    * by @p itemHash.
    */
    void doesntHave(ref Hash itemHash, Peer peer)
    {
        auto entryIt = itemHash in mTrackers;
        if (entryIt !is null)
        {
            mTrackers[itemHash].doesntHave(peer);
        }
    }

    /**
    * Called when data with given @p itemHash was received. All envelopes
    * added before with @see fetch and the same @p itemHash will be resent
    * to Herder, matching @see Tracker will be cleaned up.
    */
    void recv(ref Hash itemHash)
    {
        CLOG(LEVEL.TRACE, "Overlay", format("Recv %s", hexAbbrev(itemHash)));

        auto entryIt = itemHash in mTrackers;
        if (entryIt !is null)
        {
            // this code can safely be called even if recvBCPEnvelope ends up
            // calling recv on the same itemHash

            CLOG(LEVEL.TRACE, "Overlay", format("Recv %s : %d", hexAbbrev(itemHash), mTrackers[itemHash].size()));

            while (!mTrackers[itemHash].empty())
            {
                mApp.getHerder().recvBCPEnvelope(mTrackers[itemHash].pop());
            }
            // stop the timer, stop requesting the item as we have it
            mTrackers[itemHash].resetLastSeenSlotIndex();
            mTrackers[itemHash].cancel();
        }
    }

protected:

    void stopFetchingBelowInternal(uint64 slotIndex)
    {
        auto keys = mTrackers.keys.dup;

        for (size_t i; i < keys.length; i++)
        {
            if (!mTrackers[keys[i]].clearEnvelopesBelow(slotIndex))
            {
                mTrackers.remove(keys[i]);
                mItemMapSize.dec();
            }
        }
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