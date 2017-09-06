module owlchain.herder.pendingEnvelopes;

import owlchain.xdr;

import owlchain.herder.herder;
import owlchain.herder.herderImpl;
import owlchain.herder.txSetFrame;

import owlchain.overlay.peer;
import owlchain.overlay.itemFetcher;
import owlchain.main.application;

import owlchain.meterics;

import std.typecons;
import std.json;

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
alias Tuple!(uint32, "slotIndex", BCPQuorumSetPtr, "quorumSet") BCPQuorumSetCacheItem;
alias Tuple!(uint32, "slotIndex", TxSetFrame, "TxSetFrame") TxSetFramCacheItem;

class PendingEnvelopes
{
private:
    Application mApp;
    HerderImpl mHerder;

    // ledger# and list of envelopes in various states
    SlotEnvelopes[uint64] mEnvelopes;

    // all the quorum sets we have learned about
    BCPQuorumSetCacheItem[Hash] mQsetCache;

    ItemFetcher mTxSetFetcher;
    ItemFetcher mQuorumSetFetcher;

    // all the txsets we have learned about per ledger#
    TxSetFramCacheItem[Hash] mTxSetCache;

    // NodeIDs that are in quorum
    bool[NodeID] mNodesInQuorum;

    Counter mReadyEnvelopesSize;

    // returns true if we think that the node is in quorum
    bool isNodeInQuorum(ref NodeID node)
    {
        return false;
    }

    // discards all BCP envelopes thats use QSet with given hash,
    // as it is not sane QSet
    void discardBCPEnvelopesWithQSet(Hash hash)
    {

    }

public:
    this(Application app, HerderImpl herder)
    {

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
        return Herder.EnvelopeStatus.ENVELOPE_STATUS_DISCARDED;
    }

    /**
    * Add @p qset identified by @p hash to local cache. Notifies
    * @see ItemFetcher about that event - it may cause calls to Herder's
    * recvBCPEnvelope which in turn may cause calls to @see recvBCPEnvelope
    * in PendingEnvelopes.
    */
    void addBCPQuorumSet(Hash hash, uint64 lastSeenSlotIndex, const BCPQuorumSet qset)
    {

    }

    /**
    * Check if @p qset identified by @p hash was requested before from peers.
    * If not, ignores that @p qset. If it was requested, calls
    * @see addBCPQuorumSet.
    *
    * Return true if BCPQuorumSet is sane and useful (was asked for).
    */
    bool recvBCPQuorumSet(Hash hash, const BCPQuorumSet qset)
    {
        return false;
    }

    /**
    * Add @p txset identified by @p hash to local cache. Notifies
    * @see ItemFetcher about that event - it may cause calls to Herder's
    * recvBCPEnvelope which in turn may cause calls to @see recvBCPEnvelope
    * in PendingEnvelopes.
    */
    void addTxSet(Hash hash, uint64 lastSeenSlotIndex, TxSetFrame txset)
    {

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
        return false;
    }

    void discardBCPEnvelope(ref BCPEnvelope envelope)
    {

    }

    void peerDoesntHave(MessageType type, ref Hash itemID, Peer peer)
    {

    }

    bool isDiscarded(ref BCPEnvelope envelope)
    {
        return false;
    }

    bool isFullyFetched(ref BCPEnvelope envelope)
    {
        return false;
    }

    void startFetch(ref BCPEnvelope envelope)
    {

    }

    void stopFetch(ref BCPEnvelope envelope)
    {

    }

    void touchFetchCache(ref BCPEnvelope envelope)
    {

    }

    void envelopeReady(ref BCPEnvelope envelope)
    {

    }

    bool pop(uint64 slotIndex, ref BCPEnvelope ret)
    {
        return false;
    }

    void eraseBelow(uint64 slotIndex)
    {

    }

    void slotClosed(uint64 slotIndex)
    {

    }

    uint64[] readySlots()
    {
        uint64[] temp;

        return temp;
    }

    void dumpInfo(JSONValue ret, size_t limit)
    {

    }

    TxSetFrame getTxSet(ref Hash hash)
    {
        return null;
    }

    BCPQuorumSetPtr getQSet(ref Hash hash)
    {
        RefCounted!(BCPQuorumSet, RefCountedAutoInitialize.no) qSet;

        return qSet;
    }
}
