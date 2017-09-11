module owlchain.herder.herderImpl;

import std.stdio;
import std.container;
import std.array;
import std.json;
import std.datetime;
import std.digest.sha;
import std.typecons;
import std.base64;
import std.format;
import std.algorithm;
import core.time;

import owlchain.xdr;

import owlchain.crypto.keyUtils;
import owlchain.crypto.secretKey;
import owlchain.crypto.hex;
import owlchain.consensus.bcp;

import owlchain.util.xdrStream;
import owlchain.util.timer;
import owlchain.util.types;

import owlchain.herder.txSetFrame;

import owlchain.consensus.bcpDriver;
import owlchain.consensus.slot;

import owlchain.main.application;
import owlchain.main.persistentState;

import owlchain.database.database;
import owlchain.overlay.peer;
import owlchain.overlay.overlayManager;
import owlchain.transaction.transactionFrame;

import owlchain.utils.uniqueStruct;
import owlchain.meterics;

import owlchain.main.application;

import owlchain.herder.herder;
import owlchain.herder.pendingEnvelopes;
import owlchain.herder.ledgerCloseData;

import owlchain.ledger.ledgerManager;
import core.stdc.stdint;

import owlchain.asio.ioService;

import owlchain.utils.globalChecks;


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
        mBCP = new BCP(this, app.getConfig().NODE_SEED, app.getConfig()
                .NODE_IS_VALIDATOR, app.getConfig().QUORUM_SET);
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
        static string[State.HERDER_NUM_STATE] stateStrings = [
            "HERDER_SYNCING_STATE", "HERDER_TRACKING_STATE"
        ];
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
        CLOG(LEVEL.INFO, "Herder", "Force joining BCP with local state");
        assert(mBCP.isValidator());
        //assert(mApp.getConfig().FORCE_BCP);

        mLedgerManager.setState(LedgerManager.State.LM_SYNCED_STATE);
        stateChanged();

        mLastTrigger = mApp.getClock().now() - Herder.EXP_LEDGER_TIMESPAN_SECONDS;
        ledgerClosed();
    }

    // restores BCP state based on the last messages saved on disk
    void restoreBCPState()
    {
        // setup a sufficient state that we can participate in consensus
        auto lcl = mLedgerManager.getLastClosedLedgerHeader();
        mTrackingBCP = UniqueStruct!ConsensusData(new ConsensusData(lcl.header.ledgerSeq,
                lcl.header.bcpValue));

        trackingHeartBeat();

        // load saved state from database
        auto latest64 = mApp.getPersistentState().getState(PersistentState.Entry.kLastBCPData);

        if (latest64.empty)
            return;

        ubyte[] buffer = Base64.decode(latest64);

        BCPEnvelope[] latestEnvs;
        TransactionSet[] latestTxSets;
        BCPQuorumSet[] latestQSets;

        try
        {
            XdrDataInputStream stream = new XdrDataInputStream(buffer);
            xdr!BCPEnvelope.decode(stream, latestEnvs);
            xdr!TransactionSet.decode(stream, latestTxSets);
            xdr!BCPQuorumSet.decode(stream, latestQSets);

            for (int i = 0; i < latestTxSets.length; i++)
            {
                TxSetFrame cur = new TxSetFrame(cast(Hash)(mApp.getNetworkID()), latestTxSets[i]);
                Hash h = cur.getContentsHash();
                mPendingEnvelopes.addTxSet(h, 0, cur);
            }

            for (int i = 0; i < latestQSets.length; i++)
            {
                Hash hash = Hash(sha256Of(xdr!BCPQuorumSet.serialize(latestQSets[i])));
                mPendingEnvelopes.addBCPQuorumSet(hash, 0, latestQSets[i]);
            }

            for (int i = 0; i < latestEnvs.length; i++)
            {
                mBCP.setStateFromEnvelope(latestEnvs[i].statement.slotIndex, latestEnvs[i]);
            }

            if (latestEnvs.length != 0)
            {
                mLastSlotSaved = latestEnvs[$ - 1].statement.slotIndex;
                startRebroadcastTimer();
            }
        }
        catch (Exception e)
        {
            // we may have exceptions when upgrading the protocol
            // this should be the only time we get exceptions decoding old messages.
            CLOG(LEVEL.INFO, "Herder",
                    format("Error while restoring old scp messages, proceeding without them : ", e));
        }
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
        mBCPMetrics.mEnvelopeSign.mark();

        XdrDataOutputStream stream = new XdrDataOutputStream();
        xdr!Hash.serialize(stream, mApp.getNetworkID());
        encodeEnvelopeType(stream, EnvelopeType.ENVELOPE_TYPE_BCP);
        xdr!BCPEnvelope.serialize(stream, envelope);

        envelope.signature = mBCP.getSecretKey().sign(stream.data);
    }

    override bool verifyEnvelope(ref BCPEnvelope envelope)
    {

        XdrDataOutputStream stream = new XdrDataOutputStream();
        xdr!Hash.serialize(stream, mApp.getNetworkID());
        encodeEnvelopeType(stream, EnvelopeType.ENVELOPE_TYPE_BCP);
        xdr!BCPEnvelope.serialize(stream, envelope);

        bool b = PubKeyUtils.verifySig(envelope.statement.nodeID, envelope.signature, stream.data);
        if (b)
        {
            mBCPMetrics.mEnvelopeValidSig.mark();
        }
        else
        {
            mBCPMetrics.mEnvelopeInvalidSig.mark();
        }

        return b;
    }

    override ValidationLevel validateValue(uint64 slotIndex, ref Value value)
    {
        BOSValue b;
        try
        {
            xdr!BOSValue.decode(value.value, b);
        }
        catch (Exception e)
        {
            mBCPMetrics.mValueInvalid.mark();
            return BCPDriver.ValidationLevel.kInvalidValue;
        }

        BCPDriver.ValidationLevel res = validateValueHelper(slotIndex, b);
        if (res != BCPDriver.ValidationLevel.kInvalidValue)
        {
            LedgerUpgradeType lastUpgradeType = LedgerUpgradeType.LEDGER_UPGRADE_VERSION;
            // check upgrades
            for (size_t i = 0; i < b.upgrades.length; i++)
            {
                LedgerUpgradeType thisUpgradeType;
                if (!validateUpgradeStep(slotIndex, b.upgrades[i], thisUpgradeType))
                {
                    CLOG(LEVEL.TRACE, "Herder",
                            format("HerderImpl.validateValue invalid step at index %d", i));
                    res = BCPDriver.ValidationLevel.kInvalidValue;
                }
                if (i != 0 && (lastUpgradeType >= thisUpgradeType))
                {
                    CLOG(LEVEL.TRACE, "Herder",
                            format("HerderImpl.validateValue  out of order upgrade step at index %d",
                                i));
                    res = BCPDriver.ValidationLevel.kInvalidValue;
                }

                lastUpgradeType = thisUpgradeType;
            }
        }

        if (res)
        {
            mBCPMetrics.mValueValid.mark();
        }
        else
        {
            mBCPMetrics.mValueInvalid.mark();
        }
        return res;
    }

    override Value extractValidValue(uint64 slotIndex, ref Value value)
    {
        BOSValue b;
        try
        {
            xdr!BOSValue.decode(value.value, b);
        }
        catch (Exception e)
        {
            return Value();
        }
        Value res;
        if (validateValueHelper(slotIndex, b) == BCPDriver.ValidationLevel.kFullyValidatedValue)
        {
            // remove the upgrade steps we don't like
            LedgerUpgradeType thisUpgradeType;
            int i = 0;
            while (i < b.upgrades.length)
            {
                if (!validateUpgradeStep(slotIndex, b.upgrades[i], thisUpgradeType))
                {
                    b.upgrades.remove(i);
                }
                else
                {
                    i++;
                }
            }

            res = Value(xdr!BOSValue.serialize(b));
        }

        return res;
    }

    override string getValueString(ref Value v)
    {
        BOSValue b;
        if (v.value.empty)
        {
            return "[:empty:]";
        }

        try
        {
            xdr!BOSValue.decode(v.value, b);
            return bosValueToString(b);
        }
        catch (Exception e)
        {
            return "[:invalid:]";
        }
    }

    override string toShortString(ref PublicKey pk)
    {
        return mApp.getConfig().toShortString(pk);
    }

    override void ballotDidHearFromQuorum(uint64 slotIndex, ref BCPBallot ballot)
    {
        mBCPMetrics.mQuorumHeard.mark();
    }

    override void valueExternalized(uint64 slotIndex, ref Value value)
    {
        updateBCPCounters();
        mBCPMetrics.mValueExternalize.mark();

        // cancel all timers below this slot
        auto keys = mBCPTimers.keys;
        keys.sort();
        for (int i = 0; i < keys.length; i++)
        {
            if (keys[i] <= slotIndex)
            {
                mBCPTimers.remove(keys[i]);
            } else {
                break;
            }
        }

        if (slotIndex <= getCurrentLedgerSeq())
        {
            // externalize may trigger on older slots:
            //  * when the current instance starts up
            //  * when getting back in sync (a gap potentially opened)
            // in both cases it's safe to just ignore those as we're already
            // tracking a more recent state
            CLOG(LEVEL.DEBUG, "Herder", format("Ignoring old ledger externalize %d", slotIndex));
            return;
        }

        BOSValue b;
        try
        {
            xdr!BOSValue.decode(value.value, b);
        }
        catch (Exception e)
        {
            // This may not be possible as all messages are validated and should
            // therefore contain a valid BOSValue.
            CLOG(LEVEL.ERROR, "Herder",
                    "HerderImpl::valueExternalized Externalized BOSValue malformed");
            // no point in continuing as 'b' contains garbage at this point
            //abort();
        }

        //if (Logging::logDebug("Herder"))
        CLOG(LEVEL.DEBUG, "Herder",
                format("HerderImpl::valueExternalized txSet: %s", hexAbbrev(b.txSetHash)));

        // log information from older ledger to increase the chances that
        // all messages made it
        if (slotIndex > 2)
        {
            logQuorumInformation(slotIndex - 2);
        }

        if (!mCurrentValue.value.empty())
        {
            // stop nomination
            // this may or may not be the ledger that is currently externalizing
            // in both cases, we want to stop nomination as:
            // either we're closing the current ledger (typical case)
            // or we're going to trigger catchup from history
            mBCP.stopNomination(mLedgerSeqNominating);
            mCurrentValue.value.length = 0;
        }

        if (!mTrackingBCP)
        {
            stateChanged();
        }

        mTrackingBCP = UniqueStruct!ConsensusData(new ConsensusData(slotIndex, b));

        if (!mLastTrackingBCP)
        {
            uint64 mConsensusIndex;
            BOSValue mConsensusValue;
            mLastTrackingBCP = UniqueStruct!ConsensusData(new ConsensusData(
                    mTrackingBCP.mConsensusIndex, mTrackingBCP.mConsensusValue));
        }

        trackingHeartBeat();

        TxSetFrame externalizedSet = mPendingEnvelopes.getTxSet(b.txSetHash);

        // trigger will be recreated when the ledger is closed
        // we do not want it to trigger while downloading the current set
        // and there is no point in taking a position after the round is over
        mTriggerTimer.cancel();

        // save the BCP messages in the database
        saveBCPHistory(slotIndex);

        // tell the LedgerManager that this value got externalized
        // LedgerManager will perform the proper action based on its internal
        // state: apply, trigger catchup, etc
        LedgerCloseData ledgerData = new LedgerCloseData(lastConsensusLedgerIndex(),
                externalizedSet, b);
        mLedgerManager.valueExternalized(ledgerData);

        // perform cleanups
        updatePendingTransactions(externalizedSet.mTransactions);

        // Evict slots that are outside of our ledger validity bracket
        if (slotIndex > MAX_SLOTS_TO_REMEMBER)
        {
            mBCP.purgeSlots(slotIndex - MAX_SLOTS_TO_REMEMBER);
        }

        ledgerClosed();
    }

    override void nominatingValue(uint64 slotIndex, ref Value value)
    {
        //if (Logging::logDebug("Herder"))
        CLOG(LEVEL.DEBUG, "Herder", format("nominatingValue i:%d v:%s",
                slotIndex, getValueString(value)));

        if (!value.value.empty)
        {
            mBCPMetrics.mNominatingValue.mark();
        }
    }

    override Value combineCandidates(uint64 slotIndex, ref ValueSet candidates)
    {
        Hash h;

        BOSValue comp;
        comp.txSetHash = h;

        LedgerUpgrade[LedgerUpgradeType] upgrades;

        TransactionFrameSet aggSet;
        auto lcl = mLedgerManager.getLastClosedLedgerHeader();

        Hash candidatesHash;

        BOSValue[] candidateValues;

        foreach (ref Value c; candidates)
        {
            BOSValue sv;

            xdr!BOSValue.decode(c.value, sv);

            xorValue(candidatesHash.hash, sha256Of(c.value));

            // max closeTime
            if (comp.closeTime < sv.closeTime)
            {
                comp.closeTime = sv.closeTime;
            }

            for (int i = 0; i < sv.upgrades.length; i++)
            {

                LedgerUpgrade lupgrade;

                xdr2!(UpgradeType, LedgerUpgrade).convert(sv.upgrades[i], lupgrade);

                auto p = lupgrade.type in upgrades;
                if (p is null)
                {
                    upgrades[lupgrade.type] = lupgrade;
                }
                else
                {
                    switch (lupgrade.type)
                    {
                    case LedgerUpgradeType.LEDGER_UPGRADE_VERSION:
                        // pick the highest version
                        if (upgrades[lupgrade.type].newLedgerVersion < lupgrade.newLedgerVersion)
                        {
                            upgrades[lupgrade.type].newLedgerVersion = lupgrade.newLedgerVersion;
                        }
                        break;
                    case LedgerUpgradeType.LEDGER_UPGRADE_BASE_FEE:
                        // take the max fee
                        if (upgrades[lupgrade.type].newBaseFee < lupgrade.newBaseFee)
                        {
                            upgrades[lupgrade.type].newBaseFee = lupgrade.newBaseFee;
                        }
                        break;
                    case LedgerUpgradeType.LEDGER_UPGRADE_MAX_TX_SET_SIZE:
                        // take the max tx set size
                        if (upgrades[lupgrade.type].newMaxTxSetSize < lupgrade.newMaxTxSetSize)
                        {
                            upgrades[lupgrade.type].newMaxTxSetSize = lupgrade.newMaxTxSetSize;
                        }
                        break;
                    default:
                        // should never get there with values that are not valid
                        throw new Exception("invalid upgrade step");
                    }
                }
            }
            candidateValues ~= (sv);
        }

        // take the txSet with the highest number of transactions,
        // highest xored hash that we have
        TxSetFrame bestTxSet;
        {
            Hash highest;
            TxSetFrame highestTxSet;
            bool isFirst = true;
            foreach (ref sv; candidateValues)
            {
                TxSetFrame cTxSet = getTxSet(sv.txSetHash);

                if (cTxSet && (cTxSet.previousLedgerHash == lcl.hash))
                {
                    if (isFirst || (cTxSet.mTransactions.length > highestTxSet.mTransactions.length)
                            || ((cTxSet.mTransactions.length == highestTxSet.mTransactions.length)
                                && lessThanXored(highest, sv.txSetHash, candidatesHash)))
                    {
                        isFirst = false;
                        highestTxSet = cTxSet;
                        highest = sv.txSetHash;
                    }
                }
            }
            // make a copy as we're about to modify it and we don't want to mess
            // with the txSet cache
            bestTxSet = highestTxSet;
        }

        foreach (const ref LedgerUpgradeType lupgradetype, ref LedgerUpgrade lupgrade;
                upgrades)
        {
            UpgradeType upgradeType;
            xdr2!(LedgerUpgrade, UpgradeType).convert(lupgrade, upgradeType);
            comp.upgrades ~= upgradeType;
        }

        TransactionFrame[] removed;

        // just to be sure
        bestTxSet.trimInvalid(mApp, removed);
        comp.txSetHash = bestTxSet.getContentsHash();

        if (removed.length != 0)
        {
            CLOG(LEVEL.WARNING, "Herder",
                    format("Candidate set had %d invalid transactions", removed.length));

            // post to avoid triggering BCP handling code recursively
            mApp.getClock().getIOService().post(() {
                mPendingEnvelopes.recvTxSet(bestTxSet.getContentsHash(), bestTxSet);
            });
        }

        Value res;
        xdr2!(BOSValue, Value).convert(comp, res);
        return res;
    }

    override void setupTimer(uint64 slotIndex, int timerID, Duration timeout, void delegate() cb)
    {
        // don't setup timers for old slots
        if (slotIndex <= getCurrentLedgerSeq())
        {
            mBCPTimers.remove(slotIndex);
            return;
        }

        auto slotTimers = slotIndex in mBCPTimers;

        if (slotTimers is null)
            return;

        auto p = timerID in mBCPTimers[slotIndex];
        if (p is null)
        {
            mBCPTimers[slotIndex][timerID] = new VirtualTimer(mApp);
        }
        mBCPTimers[slotIndex][timerID].cancel();
        mBCPTimers[slotIndex][timerID].expires_from_now(timeout);
        mBCPTimers[slotIndex][timerID].async_wait(cb, (IOErrorCode errorCode) {
            VirtualTimer.onFailureNoop(errorCode);
        });
    }

    override void emitEnvelope(ref BCPEnvelope envelope)
    {
        uint64 slotIndex = envelope.statement.slotIndex;

        //if (Logging::logDebug("Herder"))
        CLOG(LEVEL.DEBUG, "Herder", format("emitEnvelope s:%d i: %d %a %s",
                envelope.statement.pledges.type, slotIndex, mApp.getStateHuman()));

        persistBCPState(slotIndex);

        broadcast(envelope);

        // this resets the re-broadcast timer
        startRebroadcastTimer();
    }

    // Extra BCP methods overridden solely to increment meterics.

    override void updatedCandidateValue(uint64 slotIndex, ref Value value)
    {
        mBCPMetrics.mUpdatedCandidate.mark();
    }

    override void startedBallotProtocol(uint64 slotIndex, ref BCPBallot ballot)
    {
        mBCPMetrics.mStartBallotProtocol.mark();
    }

    override void acceptedBallotPrepared(uint64 slotIndex, ref BCPBallot ballot)
    {
        mBCPMetrics.mAcceptedBallotPrepared.mark();
    }

    override void confirmedBallotPrepared(uint64 slotIndex, ref BCPBallot ballot)
    {
        mBCPMetrics.mConfirmedBallotPrepared.mark();
    }

    override void acceptedCommit(uint64 slotIndex, ref BCPBallot ballot)
    {
        mBCPMetrics.mAcceptedCommit.mark();
    }

    // Herder

    bool recvBCPQuorumSet(ref Hash hash, ref BCPQuorumSet qset)
    {
        return mPendingEnvelopes.recvBCPQuorumSet(hash, qset);
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
        mPendingEnvelopes.peerDoesntHave(type, Hash(itemID), peer);
    }

    TxSetFrame getTxSet(ref Hash hash)
    {
        return mPendingEnvelopes.getTxSet(hash);
    }

    // We are learning about a new envelope.
    EnvelopeStatus recvBCPEnvelope(ref BCPEnvelope envelope)
    {
        if (mApp.getConfig().MANUAL_CLOSE)
        {
            return EnvelopeStatus.ENVELOPE_STATUS_DISCARDED;
        }
        //if (Logging::logDebug("Herder"))
        CLOG(LEVEL.DEBUG, "Herder", format("recvBCPEnvelope from %s s:%d i: %d %a %s", mApp.getConfig()
                .toShortString(envelope.statement.nodeID),
                envelope.statement.pledges.type, envelope.statement.slotIndex, mApp.getStateHuman()));

        if (envelope.statement.nodeID == mBCP.getLocalNode().getNodeID())
        {
            CLOG(LEVEL.DEBUG, "Herder", "recvBCPEnvelope: skipping own message");
            return EnvelopeStatus.ENVELOPE_STATUS_DISCARDED;
        }

        mBCPMetrics.mEnvelopeReceive.mark();

        uint32_t minLedgerSeq = getCurrentLedgerSeq();
        if (minLedgerSeq > MAX_SLOTS_TO_REMEMBER)
        {
            minLedgerSeq -= MAX_SLOTS_TO_REMEMBER;
        }

        uint32 maxLedgerSeq = UINT32_MAX;

        if (mTrackingBCP)
        {
            // when tracking, we can filter messages based on the information we got
            // from consensus for the max ledger

            // note that this filtering will cause a node on startup
            // to potentially drop messages outside of the bracket
            // causing it to discard CONSENSUS_STUCK_TIMEOUT_SECONDS worth of
            // ledger closing
            maxLedgerSeq = nextConsensusLedgerIndex() + LEDGER_VALIDITY_BRACKET;
        }

        // If envelopes are out of our validity brackets, we just ignore them.
        if (envelope.statement.slotIndex > maxLedgerSeq
                || envelope.statement.slotIndex < minLedgerSeq)
        {
            CLOG(LEVEL.DEBUG, "Herder", format("Ignoring BCPEnvelope outside of range: %s (%d,%d)",
                    envelope.statement.slotIndex, minLedgerSeq, maxLedgerSeq));
            return Herder.EnvelopeStatus.ENVELOPE_STATUS_DISCARDED;
        }

        auto status = mPendingEnvelopes.recvBCPEnvelope(envelope);
        if (status == EnvelopeStatus.ENVELOPE_STATUS_READY)
        {
            processBCPQueue();
        }
        return status;
    }

    void processBCPQueue()
    {
		if (mTrackingBCP)
		{
			// drop obsolete slots
			if (nextConsensusLedgerIndex() > MAX_SLOTS_TO_REMEMBER)
			{
				mPendingEnvelopes.eraseBelow(nextConsensusLedgerIndex() - MAX_SLOTS_TO_REMEMBER);
			}

			processBCPQueueUpToIndex(nextConsensusLedgerIndex());
		}
		else
		{
			// we don't know which ledger we're in
			// try to consume the messages from the queue
			// starting from the smallest slot
			foreach (size_t i, ref uint64 slot; mPendingEnvelopes.readySlots())
			{
				processBCPQueueUpToIndex(slot);
				if (mTrackingBCP)
				{
					// one of the slots externalized
					// we go back to regular flow
					break;
				}
			}
		}
    }

    // a peer needs our SCP state
    void sendBCPStateToPeer(uint ledgerSeq, Peer peer)
    {
        uint32 minSeq, maxSeq;

        if (ledgerSeq == 0)
        {
            const uint32 nbLedgers = 3;
            const uint32 minLedger = 2;

            // include the most recent slot
            maxSeq = getCurrentLedgerSeq() + 1;

            if (maxSeq >= minLedger + nbLedgers)
            {
                minSeq = maxSeq - nbLedgers;
            }
            else
            {
                minSeq = minLedger;
            }
        }
        else
        {
            minSeq = maxSeq = ledgerSeq;
        }

        // use uint64 for seq to prevent overflows
        for (uint64 seq = minSeq; seq <= maxSeq; seq++)
        {
            BCPEnvelope[] envelopes = mBCP.getCurrentState(seq);

            if (envelopes.length != 0)
            {
                CLOG(LEVEL.DEBUG, "Herder",
                        format("Send state %d for ledger %d", envelopes.length, seq));

                foreach (int i, ref BCPEnvelope e; envelopes)
                {
                    BOSMessage m;
                    m.type = MessageType.BCP_MESSAGE;
                    m.envelope = e;
                    peer.sendMessage(m);
                }
            }
        }
    }

    // returns the latest known ledger seq using consensus information
    // and local state
    uint32 getCurrentLedgerSeq()
    {
        uint32 res = mLedgerManager.getLastClosedLedgerNum();

        if (mTrackingBCP && res < mTrackingBCP.mConsensusIndex)
        {
            res = cast(uint32)(mTrackingBCP.mConsensusIndex);
        }
        if (mLastTrackingBCP && res < mLastTrackingBCP.mConsensusIndex)
        {
            res = cast(uint32)(mLastTrackingBCP.mConsensusIndex);
        }
        return res;
    }

    // Return the maximum sequence number for any tx (or 0 if none) from a given
    // sender in the pending or recent tx sets.
    SequenceNumber getMaxSeqInPendingTxs(ref AccountID acc)
    {
        import std.algorithm.comparison;
        SequenceNumber highSeq;
        highSeq.number = 0;
        for (int i = 0; i < mPendingTransactions.length; i++)
        {
            auto p = acc in mPendingTransactions[i];
            if (p is null)
            {
                continue;
            }
            highSeq.number = max((*p).mMaxSeq.number, highSeq.number);
        }
        return highSeq;
    }

    void triggerNextLedger(uint ledgerSeqToTrigger)
    {
		if (!mTrackingBCP || !mLedgerManager.isSynced())
		{
            CLOG(LEVEL.DEBUG, "Herder",
                 format("triggerNextLedger: skipping (out of sync) : %s", mApp.getStateHuman()));
			return;
		}
		updateBCPCounters();

		// our first choice for this round's set is all the tx we have collected
		// during last ledger close
		auto lcl = mLedgerManager.getLastClosedLedgerHeader();
		TxSetFrame proposedSet = new TxSetFrame(lcl.hash);

        for (int i = 0; i < mPendingTransactions.length; i++)
        {
			foreach (const AccountID id, ref TxMap txMap; mPendingTransactions[i])
			{
                TransactionFrame[Hash] mTransactions;

				foreach (ref TransactionFrame txFrame; txMap.mTransactions)
				{
					proposedSet.add(txFrame);
				}
			}
		}

        TransactionFrame[] removed;
		proposedSet.trimInvalid(mApp, removed);
		removeReceivedTxs(removed);

		proposedSet.surgePricingFilter(mLedgerManager);

		if (!proposedSet.checkValid(mApp))
		{
			throw new Exception("wanting to emit an invalid txSet");
		}

		auto txSetHash = proposedSet.getContentsHash();

		// use the slot index from ledger manager here as our vote is based off
		// the last closed ledger stored in ledger manager
		uint32 slotIndex = lcl.header.ledgerSeq + 1;

		// Inform the item fetcher so queries from other peers about his txSet
		// can be answered. Note this can trigger BCP callbacks, externalize, etc
		// if we happen to build a txset that we were trying to download.
		mPendingEnvelopes.addTxSet(txSetHash, slotIndex, proposedSet);

		// no point in sending out a prepare:
		// externalize was triggered on a more recent ledger
		if (ledgerSeqToTrigger != slotIndex)
		{
			return;
		}

		// We store at which time we triggered consensus
		mLastTrigger = mApp.getClock().now();

		// We pick as next close time the current time unless it's before the last
		// close time. We don't know how much time it will take to reach consensus
		// so this is the most appropriate value to use as closeTime.
		uint64 nextCloseTime = VirtualClock.to_time_t(mLastTrigger);
		if (nextCloseTime <= lcl.header.bcpValue.closeTime)
		{
			nextCloseTime = lcl.header.bcpValue.closeTime + 1;
		}

		BOSValue newProposedValue;
        newProposedValue.txSetHash = txSetHash;
        newProposedValue.closeTime = nextCloseTime;

		// see if we need to include some upgrades
		LedgerUpgrade[] upgrades = prepareUpgrades(lcl.header);
 
		foreach (int i, ref LedgerUpgrade upgrade; upgrades)
		{
			Value v;
            xdr2!(LedgerUpgrade, Value).convert(upgrade, v);
			if (v.value.length >= UpgradeType.MAX_SIZE)
			{
                CLOG(LEVEL.ERROR, "Herder",
                     format("HerderImpl.triggerNextLedger " ~
                            "exceeded size for upgrade step " ~
                            "(got %d) for upgrade type %d", 
                            v.value.length, upgrade.type));
			}
			else
			{
                UpgradeType upgradeType;
                xdr2!(Value, UpgradeType).convert(v, upgradeType);
				newProposedValue.upgrades ~= upgradeType;
			}
		}

        xdr2!(BOSValue, Value).convert(newProposedValue, mCurrentValue);
		mLedgerSeqNominating = slotIndex;

		uint256 valueHash = sha256Of(xdr!Value.serialize(mCurrentValue));
        CLOG(LEVEL.DEBUG, "Herder",
             format("HerderImpl.triggerNextLedger " ~
    			    "txSet.size: %d " ~
                    "previousLedgerHash: %s " ~
                    "value: %s " ~
                    "slot: %d", 
                    proposedSet.mTransactions.length,
                    hexAbbrev(proposedSet.previousLedgerHash()),
                    hexAbbrev(valueHash),
                    slotIndex));

		Value prevValue;
        xdr2!(BOSValue, Value).convert(lcl.header.bcpValue, prevValue);

		mBCP.nominate(slotIndex, mCurrentValue, prevValue);
    }

    // lookup a nodeID in config and in SCP messages
    bool resolveNodeID(ref string s, ref PublicKey retKey)
    {
        import std.range;

		bool r = mApp.getConfig().resolveNodeID(s, retKey);
		if (!r)
		{
			if (s.length > 1 && s[0..1] == "@")
			{
                string arg = s[0..1];
				// go through BCP messages of the previous ledger
				// (to increase the chances of finding the node)
				uint32 seq = getCurrentLedgerSeq();
				if (seq > 2)
				{
					seq--;
				}
				BCPEnvelope[] envelopes = mBCP.getCurrentState(seq);
				foreach (int i, ref BCPEnvelope e; envelopes)
				{
                    /*
                    string curK = KeyUtils.toStrKey(e.statement.nodeID);
					if (curK.compare(0, arg.length, arg) == 0)
					{
						retKey = e.statement.nodeID;
						r = true;
						break;
					}
                    */
                    break;
				}
			}
		}
		return r;
    }

    void dumpInfo(ref JSONValue ret, size_t limit)
    {
        PublicKey pk = mBCP.getSecretKey().getPublicKey();
		ret.object["you"] = JSONValue(mApp.getConfig().toStrKey(pk));

		mBCP.dumpInfo(ret, limit);

		mPendingEnvelopes.dumpInfo(ret, limit);
    }

    void dumpQuorumInfo(ref JSONValue ret, ref NodeID id, bool summary, uint64 index = 0)
    {
		ret.object["node"] = JSONValue(mApp.getConfig().toStrKey(id));

        JSONValue[string] slotsObject;
        JSONValue slotsInfo = slotsObject;

		mBCP.dumpQuorumInfo(slotsInfo, id, summary, index);
        ret.object["slots"] = slotsInfo;
    }

    static size_t copyBCPHistoryToStream(ref Database db, uint32 ledgerSeq,
            uint32 ledgerCount, ref XDROutputFileStream bcpHistory)
    {
		uint32 begin = ledgerSeq, end = ledgerSeq + ledgerCount;
		size_t n = 0;

		// all known quorum sets
        BCPQuorumSet[Hash] qSets;

		for (uint32 curLedgerSeq = begin; curLedgerSeq < end; curLedgerSeq++)
		{
			// BCP envelopes for this ledger
			// quorum sets missing in this batch of envelopes
            HashSet missingQSets = new HashSet;

			BCPHistoryEntry hEntryV;

			auto hEntry = &hEntryV.v0;
			auto lm = &hEntry.ledgerMessages;
			lm.ledgerSeq = curLedgerSeq;

			auto curEnvs = &lm.messages;

			// fetch BCP messages from history
			{
                string envB64 = "";

                /*
				auto timer = db.getSelectTimer("scphistory");

                statement st =
					(sess.prepare << "SELECT envelope FROM scphistory "
                     "WHERE ledgerseq = :cur ORDER BY nodeid",
                     into(envB64), use(curLedgerSeq));

				st.execute(true);
                */

				//while (st.got_data())
				{
					BCPEnvelope env;

                    ubyte[] envBytes = Base64.decode(envB64);

                    xdr!BCPEnvelope.decode(envBytes, env);
                    *curEnvs ~= env;

					// record new quorum sets encountered
					Hash qSetHash = Slot.getCompanionQuorumSetHashFromStatement(env.statement);
                    auto p = qSetHash in qSets;
					if (p is null)
					{
						missingQSets.insert(qSetHash);
					}

					n++;


					//st.fetch();
				}
			}

			// fetch the quorum sets from the db
			foreach (ref Hash q; missingQSets)
			{
                string qset64, qSetHashHex;

				BCPQuorumSet qset;

				qSetHashHex = binToHex(q.hash);
/*
				auto timer = db.getSelectTimer("scpquorums");

                soci::statement st = (sess.prepare << "SELECT qset FROM scpquorums "
                                  "WHERE qsethash = :h",
                                  into(qset64), use(qSetHashHex));
				st.execute(true);
                */

				//if (!st.got_data())
				//{
				//	throw new Exception("corrupt database state: missing quorum set");
				//}

                ubyte[] qSetBytes = Base64.decode(qset64);
                xdr!BCPQuorumSet.decode(qSetBytes, qset);

                hEntry.quorumSets ~= qset;

			}

			if (curEnvs.length != 0)
			{
				bcpHistory.M!(BCPHistoryEntry).writeOne(hEntryV);
			}
		}

		return n;
    }

    static void dropAll(ref Database db)
    {
        /*
		db.getSession() << "DROP TABLE IF EXISTS scphistory";

		db.getSession() << "DROP TABLE IF EXISTS scpquorums";

		db.getSession() << "CREATE TABLE scphistory ("
			"nodeid      CHARACTER(56) NOT NULL,"
			"ledgerseq   INT NOT NULL CHECK (ledgerseq >= 0),"
			"envelope    TEXT NOT NULL"
			")";

		db.getSession() << "CREATE INDEX scpenvsbyseq ON scphistory(ledgerseq)";

		db.getSession() << "CREATE TABLE scpquorums ("
			"qsethash      CHARACTER(64) NOT NULL,"
			"lastledgerseq INT NOT NULL CHECK (lastledgerseq >= 0),"
			"qset          TEXT NOT NULL,"
			"PRIMARY KEY (qsethash)"
			")";
        */
    }

    static void deleteOldEntries(ref Database db, uint32 ledgerSeq)
    {
        /*
		db.getSession() << "DELETE FROM scphistory WHERE ledgerseq <= "
			<< ledgerSeq;
		db.getSession() << "DELETE FROM scpquorums WHERE lastledgerseq <= "
			<< ledgerSeq;
        */
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

    void saveBCPHistory(uint64 index)
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
        mRebroadcastTimer.expires_from_now(dur!"seconds"(2));

        mRebroadcastTimer.async_wait(() { this.rebroadcast(); }, (IOErrorCode errorCode) {
            VirtualTimer.onFailureNoop(errorCode);
        });
    }

    void rebroadcast()
    {
        foreach (int i, ref BCPEnvelope e; mBCP.getLatestMessagesSend(mLedgerManager.getLedgerNum()))
        {
            broadcast(e);
        }
        startRebroadcastTimer();
    }

    void broadcast(ref BCPEnvelope e)
    {
        if (!mApp.getConfig().MANUAL_CLOSE)
        {
            BOSMessage m;
            m.type = MessageType.BCP_MESSAGE;
            m.envelope = e;

            CLOG(LEVEL.DEBUG, "Herder",
                 format("broadcast s: %d i: %d", e.statement.pledges.type, e.statement.slotIndex));

            mBCPMetrics.mEnvelopeEmit.mark();
            mApp.getOverlayManager().broadcastMessage(m, true);
        }
    }

    void updateBCPCounters()
    {
        mBCPMetrics.mKnownSlotsSize.setCount(mBCP.getKnownSlotsCount());
        mBCPMetrics.mCumulativeStatements.setCount(mBCP.getCumulativeStatemtCount());
    }

    void processBCPQueueUpToIndex(uint64 slotIndex)
    {
		while (true)
		{
			BCPEnvelope env;
			if (mPendingEnvelopes.pop(slotIndex, env))
			{
				mBCP.receiveEnvelope(env);
			}
			else
			{
				return;
			}
		}
    }

    // returns true if the local instance is in a state compatible with
    // this slot
    bool isSlotCompatibleWithCurrentState(uint64 slotIndex)
    {
		bool res = false;
		if (mLedgerManager.isSynced())
		{
			auto lcl = mLedgerManager.getLastClosedLedgerHeader();
			res = (slotIndex == (lcl.header.ledgerSeq + 1));
		}

		return res;
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
        CLOG(LEVEL.INFO, "Herder", "Lost track of consensus");

        JSONValue[string] jsonObject;
        JSONValue info = jsonObject;

		dumpInfo(info, 20);
        
        string s = info.toPrettyString();
        CLOG(LEVEL.INFO, "Herder", "Out of sync context: " ~ s);

		mBCPMetrics.mLostSync.mark();
		stateChanged();

		// transfer ownership to mLastTrackingBCP
		mLastTrackingBCP = mTrackingBCP.release();

		processBCPQueue();
    }

    struct ConsensusData
    {
        uint64 mConsensusIndex;
        BOSValue mConsensusValue;

        this(const uint64 index, ref const BOSValue b)
        {
            mConsensusIndex = index;
            mConsensusValue = cast(BOSValue) b;
        }

        this(uint64 index, ref BOSValue b)
        {
            mConsensusIndex = index;
            mConsensusValue = cast(BOSValue) b;
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

    // timer that detects that we're stuck on an BCP slot
    VirtualTimer mTrackingTimer;

    // saves the BCP messages that the instance sent out last
    void persistBCPState(uint64 slot)
    {

    }

    // create upgrades for given ledger
    LedgerUpgrade[] prepareUpgrades(ref LedgerHeader header)
    {
        LedgerUpgrade[] res;

        return res;
    }

    // called every time we get ledger externalized
    // ensures that if we don't hear from the network, we throw the herder into
    // indeterminate mode

    void trackingHeartBeat()
    {

    }

    VirtualClock.time_point mLastTrigger;
    VirtualTimer mTriggerTimer;

    VirtualTimer mRebroadcastTimer;

    uint32 mLedgerSeqNominating;
    Value mCurrentValue;

    // timers used by BCP
    // indexed by slotIndex, timerID

    VirtualTimer[int][uint64] mBCPTimers;

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
            mValueValid = app.getMetrics().NewMeter(new MetricName("bcp",
                    "value", "valid"), "value");
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
