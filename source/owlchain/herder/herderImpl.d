module owlchain.herder.herderImpl;

import std.stdio;
import std.container;
import core.time;
import std.json;

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
import owlchain.consensus.consensusProtocol;

import owlchain.util.xdrStream;

import owlchain.herder.txSetFrame;

import owlchain.consensus.consensusProtocolDriver;
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

/*
* Public Interface to the Herder module
*
* Drives the consensus protocol, is responsible for collecting Txs and
* TxSets from the network and making sure Txs aren't lost in ledger close
*
* LATER: These interfaces need cleaning up. We need to work out how to
* make the bidirectional interfaces
*/

class HerderImpl : ConsensusProtocolDriver, Herder
{
    private ConsensusProtocol mCP;

public:
    this(Application ap)
    {

    }

    ~this()
    {

    }

    Herder.State getState()
    {
        return Herder.State.HERDER_SYNCING_STATE;
    }

    string getStateHuman()
    {
        return "";
    }

    // Ensure any meterics that are "current state" gauge-like counters reflect
    // the current reality as best as possible.
    void syncMetrics()
    {

    }

    void bootstrap()
    {

    }

    // restores SCP state based on the last messages saved on disk
    void restoreCPState()
    {

    }

    ConsensusProtocol getCP()
    {
        return mCP;
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
    UniqueStruct!ConsensusData mTrackingCP;

    // when losing track of consensus, records where we left off so that we
    // ignore older ledgers (as we potentially receive old messages)
    UniqueStruct!ConsensusData mLastTrackingCP;

    // last slot that was persisted into the database
    // only keep track of the most recent slot
    uint64 mLastSlotSaved;

    // Mark changes to mTrackingCP in meterics.
    void stateChanged()
    {

    }
    /*
VirtualClock.time_point mLastStateChange;

    // the ledger index that was last externalized
    uint32
        lastConsensusLedgerIndex() const
        {
            assert(mTrackingCP->mConsensusIndex <= UINT32_MAX);
            return static_cast<uint32>(mTrackingCP->mConsensusIndex);
        }

    // the ledger index that we expect to externalize next
    uint32
        nextConsensusLedgerIndex() const
        {
            return lastConsensusLedgerIndex() + 1;
        }

    // timer that detects that we're stuck on an BCP slot
    VirtualTimer mTrackingTimer;

    // saves the BCP messages that the instance sent out last
    void persistCPState(uint64 slot);

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

    struct CPMetrics
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
            mValueValid = app.getMetrics().NewMeter(new MetricName("cp", "value", "valid"), "value");
            mValueInvalid = app.getMetrics().NewMeter(new MetricName("cp",
                    "value", "invalid"), "value");
            mNominatingValue = app.getMetrics().NewMeter(new MetricName("cp",
                    "value", "nominating"), "value");

            mValueExternalize = app.getMetrics().NewMeter(new MetricName("cp",
                    "value", "externalize"), "value");
            mUpdatedCandidate = app.getMetrics().NewMeter(new MetricName("cp",
                    "value", "candidate"), "value");

            mStartBallotProtocol = app.getMetrics()
                .NewMeter(new MetricName("cp", "ballot", "started"), "ballot");
            mAcceptedBallotPrepared = app.getMetrics().NewMeter(new MetricName("cp",
                    "ballot", "accepted-prepared"), "ballot");
            mConfirmedBallotPrepared = app.getMetrics().NewMeter(new MetricName("cp",
                    "ballot", "confirmed-prepared"), "ballot");
            mAcceptedCommit = app.getMetrics().NewMeter(new MetricName("cp",
                    "ballot", "accepted-commit"), "ballot");
            mBallotExpire = app.getMetrics().NewMeter(new MetricName("cp",
                    "ballot", "expire"), "ballot");

            mQuorumHeard = app.getMetrics().NewMeter(new MetricName("cp",
                    "quorum", "heard"), "quorum");
            mLostSync = app.getMetrics().NewMeter(new MetricName("cp", "sync", "lost"), "sync");

            mEnvelopeEmit = app.getMetrics().NewMeter(new MetricName("cp",
                    "envelope", "emit"), "envelope");
            mEnvelopeReceive = app.getMetrics().NewMeter(new MetricName("cp",
                    "envelope", "receive"), "envelope");
            mEnvelopeSign = app.getMetrics().NewMeter(new MetricName("cp",
                    "envelope", "sign"), "envelope");
            mEnvelopeValidSig = app.getMetrics().NewMeter(new MetricName("cp",
                    "envelope", "validsig"), "envelope");
            mEnvelopeInvalidSig = app.getMetrics().NewMeter(new MetricName("cp",
                    "envelope", "invalidsig"), "envelope");

            mKnownSlotsSize = app.getMetrics().NewCounter(new MetricName("cp",
                    "memory", "known-slots"));
            mCumulativeStatements = app.getMetrics()
                .NewCounter(new MetricName("cp", "memory", "cumulative-statements"));

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

    CPMetrics mCPMetrics;
}
