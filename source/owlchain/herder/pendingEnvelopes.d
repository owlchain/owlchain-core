module owlchain.herder.pendingEnvelopes;

import owlchain.xdr;

import owlchain.herder.herder;
import owlchain.herder.herderImpl;
import owlchain.herder.txSetFrame;
import owlchain.herder.herderUtils;

import owlchain.overlay.peer;
import owlchain.overlay.itemFetcher;
import owlchain.main.application;

import owlchain.meterics;

import std.typecons;
import std.conv;
import std.json;
import std.format;
import std.algorithm;

import owlchain.utils.globalChecks;
import owlchain.consensus.quorumSetUtils;
import owlchain.consensus.slot;
import owlchain.consensus.bcp;
import owlchain.crypto.hex;
import owlchain.util.cache;

/*
BCP messages that you have received but are waiting to get the info of
before feeding into BCP
*/

class SlotEnvelopes
{
    // list of envelopes we have processed already
    BCPEnvelope[] mProcessedEnvelopes;
    // list of envelopes we have discarded already
    BCPEnvelopeSet mDiscardedEnvelopes;
    // list of envelopes we are fetching right now
    BCPEnvelopeSet mFetchingEnvelopes;
    // list of ready envelopes that haven't been sent to BCP yet
    BCPEnvelope[] mReadyEnvelopes;

    this()
    {
        mDiscardedEnvelopes = new BCPEnvelopeSet;
        mFetchingEnvelopes = new BCPEnvelopeSet;
    }

    ~this()
    {
        mDiscardedEnvelopes.clear();
        mDiscardedEnvelopes = null;
        mFetchingEnvelopes.clear();
        mFetchingEnvelopes = null;
    }
}

alias RefCounted!(BCPQuorumSet, RefCountedAutoInitialize.no) BCPQuorumSetPtr;
alias Tuple!(uint64, "slotIndex", BCPQuorumSet, "quorumSet") BCPQuorumSetCacheItem;
alias Tuple!(uint64, "slotIndex", TxSetFrame, "txSetFrame") TxSetFramCacheItem;

class PendingEnvelopes
{
private:
    Application mApp;
    HerderImpl mHerder;

    // ledger# and list of envelopes in various states
    SlotEnvelopes[uint64] mEnvelopes;

    // all the quorum sets we have learned about
    //BCPQuorumSetCacheItem[Hash] mQsetCache;
    Cache!(Hash, BCPQuorumSetCacheItem) mQsetCache;

    ItemFetcher mTxSetFetcher;
    ItemFetcher mQuorumSetFetcher;

    // all the txsets we have learned about per ledger# 
    // lru_cache
    Cache!(Hash, TxSetFramCacheItem) mTxSetCache;

    // NodeIDs that are in quorum
    // lru_cache
    Cache!(NodeID, bool) mNodesInQuorum;

    Counter mReadyEnvelopesSize;

    // returns true if we think that the node is in quorum
    bool isNodeInQuorum(ref NodeID node)
    {
        bool res;

        res = mNodesInQuorum.exists(node);
        if (res)
        {
            res = mNodesInQuorum.get(node);
        }

        if (!res)
        {
            // search through the known slots
            BCP.TriBool r = mHerder.getBCP().isNodeInQuorum(node);
            if (r == BCP.TriBool.TB_TRUE)
            {
                // only cache positive answers
                // so that nodes can be added during rounds
                mNodesInQuorum.put(node, true);
                res = true;
            }
            else if (r == BCP.TriBool.TB_FALSE)
            {
                res = false;
            }
            else
            {
                // MAYBE -> return true, but don't cache
                res = true;
            }
        }

        return res;
    }

    // discards all BCP envelopes thats use QSet with given hash,
    // as it is not sane QSet
    void discardBCPEnvelopesWithQSet(Hash hash)
    {
        CLOG(LEVEL.TRACE, "Herder", format("Discarding BCP Envelopes with BCPQSet", hexAbbrev(hash)));

        auto envelopes = mQuorumSetFetcher.fetchingFor(hash);
        for (size_t i; i < envelopes.length; i++)
        {
            discardBCPEnvelope(envelopes[i]);
        }
    }

public:

    this(Application app, HerderImpl herder)
    {
        mApp = app;
        mHerder = herder;
        mTxSetFetcher = new ItemFetcher(app, (Peer peer, ref Hash hash) {
            peer.sendGetTxSet(hash.getId());
        });
        mQuorumSetFetcher = new ItemFetcher(app, (Peer peer, ref Hash hash) {
            peer.sendGetTxSet(hash.getId());
        });
        mReadyEnvelopesSize = app.getMetrics().NewCounter(new MetricName("bcp", "memory", "pending-envelopes"));
    }

    ~this()
    {

    }

    /**
    * Process received @p envelope.
    *
    * Return status of received envelope.
    */
    Herder.EnvelopeStatus recvBCPEnvelope(ref BCPEnvelope envelope)
    {
        auto nodeID = &envelope.statement.nodeID;
        if (!isNodeInQuorum(*nodeID))
        {
            CLOG(LEVEL.DEBUG, "Herder",
                 format("Dropping envelope from %s (not in quorum)", mApp.getConfig().toShortString(*nodeID)));
            return Herder.EnvelopeStatus.ENVELOPE_STATUS_DISCARDED;
        }

        // did we discard this envelope?
        // do we already have this envelope?
        // do we have the qset
        // do we have the txset

        try
        {
            if (isDiscarded(envelope))
            {
                return Herder.EnvelopeStatus.ENVELOPE_STATUS_DISCARDED;
            }

            touchFetchCache(envelope);

            auto set = mEnvelopes[envelope.statement.slotIndex].mFetchingEnvelopes;
            auto processedList = mEnvelopes[envelope.statement.slotIndex].mProcessedEnvelopes;

            if (find(set[], envelope).empty)
            { 
                bool serch = false;
                for (size_t n = 0; n < processedList.length; n++)
                {
                    if (processedList[n] == envelope) {
                        serch = true;
                    }
                }

                // we aren't fetching this envelope
                if (!serch)
                { 
                    // we haven't seen this envelope before
                    // insert it into the fetching set
                    set.insert(envelope);
                    startFetch(envelope);
                }
                else
                {
                    // we already have this one
                    return Herder.EnvelopeStatus.ENVELOPE_STATUS_PROCESSED;
                }
            }

            // we are fetching this envelope
            // check if we are done fetching it
            if (isFullyFetched(envelope))
            {
                // move the item from fetching to processed
                processedList ~= envelope;
                set.remove(find(set[], envelope));
                envelopeReady(envelope);
                return Herder.EnvelopeStatus.ENVELOPE_STATUS_READY;
            } // else just keep waiting for it to come in

            return Herder.EnvelopeStatus.ENVELOPE_STATUS_FETCHING;
        }
        catch (Exception e)
        {
            CLOG(LEVEL.TRACE, "Herder", format("PendingEnvelopes.recvBCPEnvelope got corrupt message: ", e));
            return Herder.EnvelopeStatus.ENVELOPE_STATUS_DISCARDED;
        }
    }

    /**
    * Add @p qset identified by @p hash to local cache. Notifies
    * @see ItemFetcher about that event - it may cause calls to Herder's
    * recvBCPEnvelope which in turn may cause calls to @see recvBCPEnvelope
    * in PendingEnvelopes.
    */
    void addBCPQuorumSet(Hash hash, uint64 lastSeenSlotIndex, ref BCPQuorumSet qset)
    {
        assert(isQuorumSetSane(qset, false));

        CLOG(LEVEL.TRACE, "Herder", format("Add BCPQSet %s", hexAbbrev(hash)));

        BCPQuorumSetCacheItem cacheItem;
        cacheItem.slotIndex = lastSeenSlotIndex;
        cacheItem.quorumSet = qset;
        mQsetCache.put(hash, cacheItem);
        mQuorumSetFetcher.recv(hash);
    }

    /**
    * Check if @p qset identified by @p hash was requested before from peers.
    * If not, ignores that @p qset. If it was requested, calls
    * @see addBCPQuorumSet.
    *
    * Return true if BCPQuorumSet is sane and useful (was asked for).
    */
    bool recvBCPQuorumSet(Hash hash, ref BCPQuorumSet qset)
    {
        CLOG(LEVEL.TRACE, "Herder", format("Got BCPQSet %s", hexAbbrev(hash)));

        auto lastSeenSlotIndex = mQuorumSetFetcher.getLastSeenSlotIndex(hash);
        if (lastSeenSlotIndex <= 0)
        {
            return false;
        }

        if (isQuorumSetSane(qset, false))
        {
            addBCPQuorumSet(hash, lastSeenSlotIndex, qset);
            return true;
        }
        else
        {
            discardBCPEnvelopesWithQSet(hash);
            return false;
        }
    }

    /**
    * Add @p txset identified by @p hash to local cache. Notifies
    * @see ItemFetcher about that event - it may cause calls to Herder's
    * recvBCPEnvelope which in turn may cause calls to @see recvBCPEnvelope
    * in PendingEnvelopes.
    */
    void addTxSet(Hash hash, uint64 lastSeenSlotIndex, TxSetFrame txset)
    {
        CLOG(LEVEL.TRACE, "Herder", format("Add TxSet %s", hexAbbrev(hash)));

        TxSetFramCacheItem cacheItem;
        cacheItem.slotIndex = lastSeenSlotIndex;
        cacheItem.txSetFrame = txset;

        mTxSetCache.put(hash, cacheItem);
        mTxSetFetcher.recv(hash);
    }

    /**
    * Check if @p txset identified by @p hash was requested before from peers.
    * If not, ignores that @p txset. If it was requested, calls
    * @see addTxSet.
    *
    * Return true if TxSet useful (was asked for).
    */
    bool recvTxSet(Hash hash, TxSetFrame txset)
    {
        CLOG(LEVEL.TRACE, "Herder", format("Got TxSet %s", hexAbbrev(hash)));

        auto lastSeenSlotIndex = mTxSetFetcher.getLastSeenSlotIndex(hash);
        if (lastSeenSlotIndex == 0)
        {
            return false;
        }

        addTxSet(hash, lastSeenSlotIndex, txset);
        return true;
    }

    void discardBCPEnvelope(ref BCPEnvelope envelope)
    {
        try
        {
            if (isDiscarded(envelope))
            {
                return;
            }

            auto discardedSet = &mEnvelopes[envelope.statement.slotIndex].mDiscardedEnvelopes;
            (*discardedSet).insert(envelope);

            auto fetchingSet = &mEnvelopes[envelope.statement.slotIndex].mFetchingEnvelopes;
            (*fetchingSet).remove(find((*fetchingSet)[], envelope));

            stopFetch(envelope);
        }
        catch (Exception e)
        {
            CLOG(LEVEL.TRACE, "Herder", format("PendingEnvelopes.discardBCPEnvelope got corrupt message:  %s", e));
        }
    }

    void peerDoesntHave(MessageType type, ref Hash itemID, Peer peer)
    {
        switch (type)
        {
            case MessageType.TX_SET:
                mTxSetFetcher.doesntHave(itemID, peer);
                break;
            case MessageType.BCP_QUORUMSET:
                mQuorumSetFetcher.doesntHave(itemID, peer);
                break;
            default:
                CLOG(LEVEL.TRACE, "Herder", format("Unknown Type in peerDoesntHave: %d", type));
                break;
        }
    }

    void peerDoesntHave(MessageType type, Hash itemID, Peer peer)
    {
        switch (type)
        {
            case MessageType.TX_SET:
                mTxSetFetcher.doesntHave(itemID, peer);
                break;
            case MessageType.BCP_QUORUMSET:
                mQuorumSetFetcher.doesntHave(itemID, peer);
                break;
            default:
                CLOG(LEVEL.TRACE, "Herder", format("Unknown Type in peerDoesntHave: %d", type));
                break;
        }
    }

    bool isDiscarded(ref BCPEnvelope envelope)
    {
        auto envelopes = envelope.statement.slotIndex in mEnvelopes;
        if (envelopes is null)
        {
            return false;
        }

        return (!find((*envelopes).mDiscardedEnvelopes[], envelope).empty);
    }

    bool isFullyFetched(ref BCPEnvelope envelope)
    {
        if (!mQsetCache.exists(Slot.getCompanionQuorumSetHashFromStatement(envelope.statement)))
            return false;

        Hash[] txSetHashes = getTxSetHashes(envelope);

        bool allExists = true;
        foreach(size_t i, ref Hash h; txSetHashes)
        {
            if (!mTxSetCache.exists(h)) {
                allExists = false;
            }
        }
        return allExists;
    }

    void startFetch(ref BCPEnvelope envelope)
    {
        Hash h = Slot.getCompanionQuorumSetHashFromStatement(envelope.statement);

        if (!mQsetCache.exists(h))
        {
            mQuorumSetFetcher.fetch(h, envelope);
        }

        foreach (size_t i, ref Hash hash; getTxSetHashes(envelope))
        {
            if (!mTxSetCache.exists(hash))
            {
                mTxSetFetcher.fetch(hash, envelope);
            }
        }

        CLOG(LEVEL.TRACE, "Herder", format("StartFetch i:%d t:%d", 
            envelope.statement.slotIndex, envelope.statement.pledges.type));
    }

    void stopFetch(ref BCPEnvelope envelope)
    {
        Hash h = Slot.getCompanionQuorumSetHashFromStatement(envelope.statement);
        mQuorumSetFetcher.stopFetch(h, envelope);

        foreach (size_t i, ref Hash hash; getTxSetHashes(envelope))
        {
            mTxSetFetcher.stopFetch(hash, envelope);
        }

        CLOG(LEVEL.TRACE, "Herder", format("StopFetch i:%d t:%d", 
            envelope.statement.slotIndex, envelope.statement.pledges.type));
    }

    void touchFetchCache(ref BCPEnvelope envelope)
    {
        auto qsetHash = Slot.getCompanionQuorumSetHashFromStatement(envelope.statement);
        if (mQsetCache.exists(qsetHash))
        {
            BCPQuorumSetCacheItem qCacheItem = mQsetCache.get(qsetHash);
            qCacheItem.slotIndex = max(qCacheItem.slotIndex, envelope.statement.slotIndex);
            //mQsetCache.update(qsetHash, qCacheItem);
        }

        foreach (size_t i, ref Hash h; getTxSetHashes(envelope))
        {
            if (mTxSetCache.exists(h))
            {
                TxSetFramCacheItem xCacheItem = mTxSetCache.get(h);
                xCacheItem.slotIndex = max(xCacheItem.slotIndex, envelope.statement.slotIndex);
                //mTxSetCache.update(h, xCacheItem);
            }
        }
    }

    void envelopeReady(ref BCPEnvelope envelope)
    {
        BOSMessage msg;
        msg.type = MessageType.BCP_MESSAGE;
        msg.envelope = envelope;
        mApp.getOverlayManager().broadcastMessage(msg);

        mEnvelopes[envelope.statement.slotIndex].mReadyEnvelopes ~= envelope;

        CLOG(LEVEL.TRACE, "Herder", format("Envelope ready i:%d t:%d", 
                                           envelope.statement.slotIndex, envelope.statement.pledges.type));
    }

    bool pop(uint64 slotIndex, ref BCPEnvelope ret)
    {
        uint64[] keys = mEnvelopes.keys.dup;
        keys.sort();
        for (int i = 0; i < keys.length; i++)
        {
            uint64 n = keys[i];
            if (n > slotIndex) break;
            if (mEnvelopes[n].mReadyEnvelopes.length != 0)
            {
                ret = mEnvelopes[n].mReadyEnvelopes[$-1];

                mEnvelopes[n].mReadyEnvelopes = mEnvelopes[n].mReadyEnvelopes[0 .. $-1];

                return true;
            }
        }
        return false;
    }

    void eraseBelow(uint64 slotIndex)
    {
        uint64[] keys = mEnvelopes.keys.dup;
        keys.sort();
        for (int i = 0; i < keys.length; i++)
        {
            if (keys[i] < slotIndex)
            {
                mEnvelopes.remove(keys[i]);
            }
            else
            {
                break;
            }
        }
    }

    void slotClosed(uint64 slotIndex)
    {
        // stop processing envelopes & downloads for the slot falling off the
        // window
        if (slotIndex > Herder.MAX_SLOTS_TO_REMEMBER)
        {
            slotIndex -= Herder.MAX_SLOTS_TO_REMEMBER;

            mEnvelopes.remove(slotIndex);

            mTxSetFetcher.stopFetchingBelow(slotIndex + 1);
            mQuorumSetFetcher.stopFetchingBelow(slotIndex + 1);

            mQsetCache.eraseIf((ref BCPQuorumSetCacheItem item) {
                return item.slotIndex == slotIndex;
            });
            mTxSetCache.eraseIf((ref TxSetFramCacheItem item) {
                return item.slotIndex == slotIndex; 
            });
        }

    }

    uint64[] readySlots()
    {
        uint64[] result;
        uint64[] keys = mEnvelopes.keys.dup;
        keys.sort();
        for (int i = 0; i < keys.length; i++)
        {
            uint64 n = keys[i];
            if (mEnvelopes[n].mReadyEnvelopes.length != 0)
            {
                result ~= n;
            }
        }
        return result;
    }

    void dumpInfo(ref JSONValue ret, size_t limit)
    {
        JSONValue[string] quoueObject;
        JSONValue quoueJValue = quoueObject;

        uint64[] keys = mEnvelopes.keys.dup;
        keys.sort();
        size_t l = limit;
        for (size_t i = cast(size_t)keys.length-1; i >= 0 && l-- >= 0; i--)
        {
            uint64 n = keys[i];
            JSONValue[string] slotIndexObject;
            JSONValue slotIndexJValue = slotIndexObject;
            bool enabled = false;

            if (mEnvelopes[n].mFetchingEnvelopes.length != 0)
            {
                JSONValue[] fetchingArray;
                slotIndexJValue.object["fetching"] = fetchingArray;
 
                foreach (ref BCPEnvelope e; mEnvelopes[n].mFetchingEnvelopes)
                {
                    slotIndexJValue["fetching"].array ~= JSONValue(mHerder.getBCP().envToStr(e));
                }

                enabled = true;
            }

            if (mEnvelopes[n].mReadyEnvelopes.length != 0)
            {
                JSONValue[] pendingArray;
                slotIndexJValue.object["pending"] = pendingArray;

                foreach (ref BCPEnvelope e; mEnvelopes[n].mReadyEnvelopes)
                {
                    slotIndexJValue["pending"].array ~= JSONValue(mHerder.getBCP().envToStr(e));
                }

                enabled = true;
            }

            if (enabled) quoueJValue.object[to!string(n, 10)] = slotIndexJValue;
        }
        ret.object["queue"] = quoueJValue;
    }

    TxSetFrame getTxSet(ref Hash hash)
    {
        if (mTxSetCache.exists(hash))
        {
            return mTxSetCache.get(hash).txSetFrame;
        }

        return null;
    }

    BCPQuorumSetPtr getQSet(ref Hash hash)
    {
        if (mQsetCache.exists(hash))
        {
            return refCounted(mQsetCache.get(hash).quorumSet);
        }

        RefCounted!(BCPQuorumSet, RefCountedAutoInitialize.no) qSet;
        return qSet;
    }
}
