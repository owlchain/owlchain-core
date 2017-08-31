module owlchain.herder.herderImpl;

import std.stdio;
import std.container;
import core.time;
import std.json;
import std.datetime;

import std.typecons;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.bcpQuorumSet;
import owlchain.xdr.accountID;
import owlchain.xdr.bcpEnvelope;
import owlchain.xdr.publicKey;
import owlchain.xdr.nodeID;
import owlchain.xdr.messageType;
import owlchain.xdr.upgradeType;
import owlchain.xdr.ledgerUpgradeType;
import owlchain.xdr.sequenceNumber;

import owlchain.xdr.value;
import owlchain.xdr.hash;
import owlchain.xdr.bcpBallot;
import owlchain.xdr.bosValue;
import owlchain.crypto.keyUtils;
import owlchain.consensus.bcp;

import owlchain.util.xdrStream;
import owlchain.util.timer;

import owlchain.herder.txSetFrame;

import owlchain.consensus.bcpDriver;
import owlchain.main.application;
import owlchain.database.database;
import owlchain.overlay.peer;
import owlchain.transaction.transactionFrame;

import owlchain.utils.uniqueStruct;
import owlchain.meterics;

import owlchain.main.application;

import owlchain.herder.herder;
import owlchain.herder.pendingEnvelopes;

import owlchain.ledger.ledgerManager;
import core.stdc.stdint;

/*
* Public Interface to the Herder module
*
* Drives the consensus protocol, is responsible for collecting Txs and
* TxSets from the network and making sure Txs aren't lost in ledger close
*
* LATER: These interfaces need cleaning up. We need to work out how to
* make the bidirectional interfaces
*/

class HerderImpl : BCPDriver, Herder
{
    private BCP mBCP;

public:
    this(Application app)
    {
        mApp = app;
        mBCPMetrics = BCPMetrics(app);
        mBCP = new BCP(this, app.getConfig().NODE_SEED, app.getConfig().NODE_IS_VALIDATOR, app.getConfig().QUORUM_SET);
    }

    ~this()
    {

    }

    Herder.State getState()
    {
        return (mTrackingBCP && mLastTrackingBCP) ? State.HERDER_TRACKING_STATE
            : State.HERDER_SYNCING_STATE;
    }

    string getStateHuman()
    {
        static string[State.HERDER_NUM_STATE] stateStrings = 
        ["HERDER_SYNCING_STATE", "HERDER_TRACKING_STATE"];
        return stateStrings[getState()];
    }

    // Ensure any meterics that are "current state" gauge-like counters reflect
    // the current reality as best as possible.
    void syncMetrics()
    {
        int64 c = mBCPMetrics.mHerderStateCurrent.count();
        int64 n = cast(int64)(getState());
        if (c != n)
        {
            mBCPMetrics.mHerderStateCurrent.setCount(n);
        }
    }

    void bootstrap()
    {
        //CLOG(INFO, "Herder") << "Force joining BCP with local state";
        assert(mBCP.isValidator());
        //assert(mApp.getConfig().FORCE_BCP);

        mLedgerManager.setState(LedgerManager.State.LM_SYNCED_STATE);
        stateChanged();

        mLastTrigger = mApp.getClock().now() - Herder.EXP_LEDGER_TIMESPAN_SECONDS;
        ledgerClosed();
    }

    // restores SCP state based on the last messages saved on disk
    void restoreCPState()
    {

    }

    BCP getBCP()
    {
        return mBCP;
    }

    // Interface of BCP Driver
    override BCPQuorumSetPtr getQSet(ref Hash qSetHash)
    {
        RefCounted!(BCPQuorumSet, RefCountedAutoInitialize.no) qSet;

        return qSet;
    }

    override void signEnvelope(ref BCPEnvelope envelope)
    {

    }

    override bool verifyEnvelope(ref BCPEnvelope envelope)
    {
        return false;
    }

    override ValidationLevel validateValue(uint64 slotIndex, ref Value value)
    {
        return ValidationLevel.kMaybeValidValue;
    }

    override Value extractValidValue(uint64 slotIndex, ref Value value)
    {
        return Value();
    }

    override string getValueString(ref Value v)
    {
        return "";
    }

    override string toShortString(ref PublicKey pk)
    {
        return "";
    }

    override uint64 computeHashNode(uint64 slotIndex, ref Value prev,
            bool isPriority, int roundNumber, ref NodeID nodeID)
    {
        return 0L;
    }

    override uint64 computeValueHash(uint64 slotIndex, ref Value prev,
            int roundNumber, ref Value value)
    {
        return 0L;
    }

    override void ballotDidHearFromQuorum(uint64 slotIndex, ref BCPBallot ballot)
    {

    }

    override void valueExternalized(uint64 slotIndex, ref Value value)
    {

    }

    override void nominatingValue(uint64 slotIndex, ref Value value)
    {

    }

    override Value combineCandidates(uint64 slotIndex, ref ValueSet candidates)
    {
        return Value();
    }

    override void setupTimer(uint64 slotIndex, int timerID, Duration timeout, void delegate() cb)
    {

    }

    override void emitEnvelope(ref BCPEnvelope envelope)
    {

    }

    // Extra BCP methods overridden solely to increment meterics.

    override void updatedCandidateValue(uint64 slotIndex, ref Value value)
    {

    }

    override void startedBallotProtocol(uint64 slotIndex, ref BCPBallot ballot)
    {
    }

    override void acceptedBallotPrepared(uint64 slotIndex, ref BCPBallot ballot)
    {

    }

    override void confirmedBallotPrepared(uint64 slotIndex, ref BCPBallot ballot)
    {

    }

    override void acceptedCommit(uint64 slotIndex, ref BCPBallot ballot)
    {

    }

    // Herder

    bool recvCPQuorumSet(ref Hash hash, ref BCPQuorumSet qset)
    {
        return false;
    }

    bool recvTxSet(ref Hash hash, ref TxSetFrame txset)
    {
        return false;
    }

    // We are learning about a new transaction.
    TransactionSubmitStatus recvTransaction(TransactionFrame tx)
    {
        return TransactionSubmitStatus.TX_STATUS_PENDING;
    }

    void peerDoesntHave(MessageType type, ref uint256 itemID, Peer peer)
    {

    }

    TxSetFrame getTxSet(ref Hash hash)
    {
        return null;
    }

    // We are learning about a new envelope.
    EnvelopeStatus recvEnvelope(ref BCPEnvelope envelope)
    {
        return EnvelopeStatus.ENVELOPE_STATUS_READY;
    }

    // a peer needs our SCP state
    void sendCPStateToPeer(uint ledgerSeq, Peer peer)
    {

    }

    // returns the latest known ledger seq using consensus information
    // and local state
    uint getCurrentLedgerSeq()
    {
        return 0;
    }

    // Return the maximum sequence number for any tx (or 0 if none) from a given
    // sender in the pending or recent tx sets.
    SequenceNumber getMaxSeqInPendingTxs(ref AccountID)
    {
        return SequenceNumber(0);
    }

    void triggerNextLedger(uint ledgerSeqToTrigger)
    {

    }

    // lookup a nodeID in config and in SCP messages
    bool resolveNodeID(ref string s, ref PublicKey retKey)
    {
        return false;
    }

    void dumpInfo(ref JSONValue ret, size_t limit)
    {

    }

    void dumpQuorumInfo(ref JSONValue ret, ref NodeID id, bool summary, uint64 index = 0)
    {

    }

    static size_t copyCPHistoryToStream(ref Database db, uint32 ledgerSeq,
            uint32 ledgerCount, ref XDROutputFileStream cpHistory)
    {
        return 0L;
    }

    static void dropAll(ref Database db)
    {

    }

    static void deleteOldEntries(ref Database db, uint32 ledgerSeq)
    {

    }

    struct TxMap
    {
        SequenceNumber mMaxSeq;
        int64 mTotalFees;
        TransactionFrame[Hash] mTransactions;
        void addTx(TransactionFrame);
        void recalculate();
    };
    alias TxMap[AccountID] AccountTxMap;

private:
    void logQuorumInformation(uint64 index)
    {

    }

    void ledgerClosed()
    {

    }

    void removeReceivedTxs(TransactionFrame[] txs)
    {

    }

    void saveCPHistory(uint64 index)
    {

    }

    // returns true if upgrade is a valid upgrade step
    // in which case it also sets upgradeType
    bool validateUpgradeStep(uint64 slotIndex, ref UpgradeType upgrade,
            ref LedgerUpgradeType upgradeType)
    {
        return false;
    }

    ValidationLevel validateValueHelper(uint64 slotIndex, ref BOSValue sv)
    {
        return ValidationLevel.kInvalidValue;
    }

    void startRebroadcastTimer()
    {

    }

    void rebroadcast()
    {

    }

    void broadcast(ref BCPEnvelope e)
    {

    }

    void updateCPCounters()
    {

    }

    void processCPQueueUpToIndex(uint64 slotIndex)
    {

    }

    // returns true if the local instance is in a state compatible with
    // this slot
    bool isSlotCompatibleWithCurrentState(uint64 slotIndex)
    {
        return false;
    }

    // 0- tx we got during ledger close
    // 1- one ledger ago. rebroadcast
    // 2- two ledgers ago. rebroadcast
    // ...
    AccountTxMap[] mPendingTransactions;

    void updatePendingTransactions(TransactionFrame[] applied)
    {

    }

    PendingEnvelopes mPendingEnvelopes;

    void herderOutOfSync()
    {

    }

    struct ConsensusData
    {
        uint64 mConsensusIndex;
        BOSValue mConsensusValue;

        this(uint64 index, ref BOSValue b)
        {
            mConsensusIndex = index;
            mConsensusValue = b;
        }
    };

    // if the local instance is tracking the current state of BCP
    // herder keeps track of the consensus index and ballot
    // when not set, it just means that herder will try to snap to any slot that
    // reached consensus
    UniqueStruct!ConsensusData mTrackingBCP;

    // when losing track of consensus, records where we left off so that we
    // ignore older ledgers (as we potentially receive old messages)
    UniqueStruct!ConsensusData mLastTrackingBCP;

    // last slot that was persisted into the database
    // only keep track of the most recent slot
    uint64 mLastSlotSaved;

    // Mark changes to mTrackingCP in meterics.
    void stateChanged()
    {
        mBCPMetrics.mHerderStateCurrent.setCount(cast(int64)(getState()));
        //auto now = mApp.getClock().now();
        auto now = Clock.currTime();
        mBCPMetrics.mHerderStateChanges.update(now - mLastStateChange);
        mLastStateChange = now;
        mApp.syncOwnMetrics();

    }
    
    SysTime mLastStateChange;

    // the ledger index that was last externalized
    uint32 lastConsensusLedgerIndex() const
    {
        assert(mTrackingBCP.mConsensusIndex <= UINT32_MAX);
        return cast(uint32)(mTrackingBCP.mConsensusIndex);
    }

    // the ledger index that we expect to externalize next
    uint32 nextConsensusLedgerIndex() const
    {
        return lastConsensusLedgerIndex() + 1;
    }

    VirtualClock.time_point mLastTrigger;

    // timer that detects that we're stuck on an BCP slot
    VirtualTimer mTrackingTimer;

    /*
    // saves the BCP messages that the instance sent out last
    void persistBCPState(uint64 slot);

    // create upgrades for given ledger
    LedgerUpgrade[] prepareUpgrades(ref LedgerHeader header) 
    {

    }

    // called every time we get ledger externalized
    // ensures that if we don't hear from the network, we throw the herder into
    // indeterminate mode
    void trackingHeartBeat();

    VirtualClock::time_point mLastTrigger;
    VirtualTimer mTriggerTimer;

    VirtualTimer mRebroadcastTimer;

    uint32_t mLedgerSeqNominating;
    Value mCurrentValue;

    // timers used by BCP
    // indexed by slotIndex, timerID
    std::map<uint64, std::map<int, std::unique_ptr<VirtualTimer>>> mCPTimers;
*/
    Application mApp;
    LedgerManager mLedgerManager;

    struct BCPMetrics
    {
        Meter mValueValid;
        Meter mValueInvalid;
        Meter mNominatingValue;
        Meter mValueExternalize;

        Meter mUpdatedCandidate;
        Meter mStartBallotProtocol;
        Meter mAcceptedBallotPrepared;
        Meter mConfirmedBallotPrepared;
        Meter mAcceptedCommit;

        Meter mBallotExpire;

        Meter mQuorumHeard;

        Meter mLostSync;

        Meter mEnvelopeEmit;
        Meter mEnvelopeReceive;
        Meter mEnvelopeSign;
        Meter mEnvelopeValidSig;
        Meter mEnvelopeInvalidSig;

        // Counters for stuff in parent class (BCP)
        // that we monitor on a best-effort basis from
        // here.
        Counter mKnownSlotsSize;

        // Counters for things reached-through the
        // BCP maps: Slots and Nodes
        Counter mCumulativeStatements;

        // State transition meterics
        Counter mHerderStateCurrent;
        Timer mHerderStateChanges;

        // Pending tx buffer sizes
        Counter mHerderPendingTxs0;
        Counter mHerderPendingTxs1;
        Counter mHerderPendingTxs2;
        Counter mHerderPendingTxs3;

        this(Application app)
        {
            mValueValid = app.getMetrics().NewMeter(new MetricName("bcp", "value", "valid"), "value");
            mValueInvalid = app.getMetrics().NewMeter(new MetricName("bcp",
                    "value", "invalid"), "value");
            mNominatingValue = app.getMetrics().NewMeter(new MetricName("bcp",
                    "value", "nominating"), "value");

            mValueExternalize = app.getMetrics().NewMeter(new MetricName("bcp",
                    "value", "externalize"), "value");
            mUpdatedCandidate = app.getMetrics().NewMeter(new MetricName("bcp",
                    "value", "candidate"), "value");

            mStartBallotProtocol = app.getMetrics()
                .NewMeter(new MetricName("bcp", "ballot", "started"), "ballot");
            mAcceptedBallotPrepared = app.getMetrics().NewMeter(new MetricName("bcp",
                    "ballot", "accepted-prepared"), "ballot");
            mConfirmedBallotPrepared = app.getMetrics().NewMeter(new MetricName("bcp",
                    "ballot", "confirmed-prepared"), "ballot");
            mAcceptedCommit = app.getMetrics().NewMeter(new MetricName("bcp",
                    "ballot", "accepted-commit"), "ballot");
            mBallotExpire = app.getMetrics().NewMeter(new MetricName("bcp",
                    "ballot", "expire"), "ballot");

            mQuorumHeard = app.getMetrics().NewMeter(new MetricName("bcp",
                    "quorum", "heard"), "quorum");
            mLostSync = app.getMetrics().NewMeter(new MetricName("bcp", "sync", "lost"), "sync");

            mEnvelopeEmit = app.getMetrics().NewMeter(new MetricName("bcp",
                    "envelope", "emit"), "envelope");
            mEnvelopeReceive = app.getMetrics().NewMeter(new MetricName("bcp",
                    "envelope", "receive"), "envelope");
            mEnvelopeSign = app.getMetrics().NewMeter(new MetricName("bcp",
                    "envelope", "sign"), "envelope");
            mEnvelopeValidSig = app.getMetrics().NewMeter(new MetricName("bcp",
                    "envelope", "validsig"), "envelope");
            mEnvelopeInvalidSig = app.getMetrics().NewMeter(new MetricName("bcp",
                    "envelope", "invalidsig"), "envelope");

            mKnownSlotsSize = app.getMetrics().NewCounter(new MetricName("bcp",
                    "memory", "known-slots"));
            mCumulativeStatements = app.getMetrics()
                .NewCounter(new MetricName("bcp", "memory", "cumulative-statements"));

            mHerderStateCurrent = app.getMetrics()
                .NewCounter(new MetricName("herder", "state", "current"));
            mHerderStateChanges = app.getMetrics()
                .NewTimer(new MetricName("herder", "state", "changes"));

            mHerderPendingTxs0 = app.getMetrics()
                .NewCounter(new MetricName("herder", "pending-txs", "age0"));
            mHerderPendingTxs1 = app.getMetrics()
                .NewCounter(new MetricName("herder", "pending-txs", "age1"));
            mHerderPendingTxs2 = app.getMetrics()
                .NewCounter(new MetricName("herder", "pending-txs", "age2"));
            mHerderPendingTxs3 = app.getMetrics()
                .NewCounter(new MetricName("herder", "pending-txs", "age3"));
        }
    };

    BCPMetrics mBCPMetrics;
}
