module owlchain.overlay.tracker;

import owlchain.xdr;

import owlchain.herder.herderImpl;
import owlchain.overlay.peer;
import owlchain.main.application;
import owlchain.asio.ioService;
import owlchain.utils.globalChecks;

import owlchain.crypto.hex;

import owlchain.meterics;
import owlchain.util.timer;

import std.container.dlist;
import std.typecons;
import std.digest.sha;
import std.format;
import std.algorithm;
import std.datetime;
import core.time;

alias void delegate(Peer, ref Hash) AskPeer;
alias Tuple!(Hash, "hash", BCPEnvelope, "envelope") TupleHashEnvelop;

static const int MS_TO_WAIT_FOR_FETCH_REPLY = 1500;
static const int MAX_REBUILD_FETCH_LIST = 1000;

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

    BCPEnvelope mPopEnvelope;

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
    ref BCPEnvelope pop()
    {
        mPopEnvelope = mWaitingEnvelopes[$-1].envelope;
        mWaitingEnvelopes = mWaitingEnvelopes[0..$-1];

        return mPopEnvelope;
    }

    /**
    * Called periodically to remove old envelopes from list (with ledger id
    * below some @p slotIndex).
    *
    * Returns true if at least one envelope remained in list.
    */
    bool clearEnvelopesBelow(uint64 slotIndex)
    {
        size_t n = 0;
        while (n < mWaitingEnvelopes.length)
        {
            if (mWaitingEnvelopes[n].envelope.statement.slotIndex < slotIndex)
            {
                mWaitingEnvelopes = mWaitingEnvelopes[0..n] ~ mWaitingEnvelopes[n+1..$];
            }
            else
            {
                n++;
            }
        }
        if (mWaitingEnvelopes.length != 0)
        {
            return true;
        }

        mTimer.cancel();
        mLastAskedPeer = null;

        return false;
    }

    /**
    * Add @p env to list of envelopes that will be resend to Herder when data
    * is received.
    */
    void listen(ref BCPEnvelope env)
    {
        mLastSeenSlotIndex = max(env.statement.slotIndex, mLastSeenSlotIndex);

        BOSMessage m;
        m.type = MessageType.BCP_MESSAGE;
        m.envelope = env;
        mWaitingEnvelopes ~= TupleHashEnvelop(Hash(sha256Of(xdr!BOSMessage.serialize(m))), env);
    }

    /**
    * Stops tracking envelope @p env.
    */
    void discard(ref BCPEnvelope env)
    {
        size_t n = 0;
        while (n < mWaitingEnvelopes.length)
        {
            if (mWaitingEnvelopes[n].envelope == env)
            {
                mWaitingEnvelopes = mWaitingEnvelopes[0..n] ~ mWaitingEnvelopes[n+1..$];
            }
            else
            {
                n++;
            }
        }
    }

    /**
    * Stop the timer, stop requesting the item as we have it.
    */
    void cancel()
    {
        mTimer.cancel();
        mLastSeenSlotIndex = 0;
    }

    /**
    * Called when given @p peer informs that it does not have given data.
    * Next peer will be tried if available.
    */
    void doesntHave(Peer peer)
    {
        if (mLastAskedPeer == peer)
        {
            CLOG(LEVEL.TRACE, "Overlay", format("Does not have %s", hexAbbrev(mItemHash)));
            tryNextPeer();
        }
    }

    /**
    * Called either when @see doesntHave(Peer) was received or
    * request to peer timed out.
    */
    void tryNextPeer()
    {
        // will be called by some timer or when we get a
        // response saying they don't have it
        Peer peer;

        CLOG(LEVEL.TRACE, "Overlay", format("tryNextPeer %s last:", hexAbbrev(mItemHash),(mLastAskedPeer ? mLastAskedPeer.toString() : "<none>")));

        // if we don't have a list of peers to ask and we're not
        // currently asking peers, build a new list
        if (mPeersToAsk.empty() && !mLastAskedPeer)
        {
            PeerSet peersWithEnvelope = new PeerSet;
            for (size_t n; n < mWaitingEnvelopes.length; n++)
            {
                auto s = mApp.getOverlayManager().getPeersKnows(mWaitingEnvelopes[n].hash);
                foreach(ref Peer p; s)
                {
                    peersWithEnvelope.insert(p);
                }
            }

            // move the peers that have the envelope to the back,
            // to be processed first
            auto r = mApp.getOverlayManager().getRandomPeers();
            for (size_t m; m < r.length; m++)
            {
                if (!find(peersWithEnvelope[], r[m]).empty)
                {
                    mPeersToAsk.insertBack(r[m]);
                }
                else
                {
                    mPeersToAsk.insertFront(r[m]);
                }
            }

            mNumListRebuild++;

            import std.range : walkLength;

            CLOG(LEVEL.TRACE, "Overlay", format("tryNextPeer %s attempt %d reset to # %d", 
                                                hexAbbrev(mItemHash),
                                                mNumListRebuild,
                                                walkLength(mPeersToAsk[])
                                                ));
            mTryNextPeerReset.mark();
        }

        while (!peer && !mPeersToAsk.empty())
        {
            peer = mPeersToAsk.back();
            if (!peer.isAuthenticated())
            {
                peer = null;
            }
            mPeersToAsk.removeBack();
        }

        Duration nextTry;
        if (!peer)
        { 
            // we have asked all our peers
            // clear mLastAskedPeer so that we rebuild a new list
            mLastAskedPeer = null;
            if (mNumListRebuild > MAX_REBUILD_FETCH_LIST)
            {
                nextTry = dur!"msecs"(MS_TO_WAIT_FOR_FETCH_REPLY * MAX_REBUILD_FETCH_LIST);
            }
            else
            {
                nextTry = dur!"msecs"(MS_TO_WAIT_FOR_FETCH_REPLY * mNumListRebuild);
            }
        }
        else
        {
            mLastAskedPeer = peer;
            CLOG(LEVEL.TRACE, "Overlay", format("Asking for %s to %s", hexAbbrev(mItemHash), peer.toString()));
            mTryNextPeer.mark();
            mAskPeer(peer, mItemHash);
            nextTry = dur!"msecs"(MS_TO_WAIT_FOR_FETCH_REPLY);
        }

        mTimer.expires_from_now(nextTry);
        mTimer.async_wait(() {
            tryNextPeer();
        }, (IOErrorCode errorCode) {
            VirtualTimer.onFailureNoop(errorCode);
        });
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
