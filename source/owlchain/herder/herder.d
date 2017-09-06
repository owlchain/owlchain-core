module owlchain.herder.herder;

import std.stdio;
import std.container;
import core.time;
import std.json;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.bcpQuorumSet;
import owlchain.xdr.accountID;
import owlchain.xdr.bcpEnvelope;
import owlchain.xdr.publicKey;
import owlchain.xdr.nodeID;
import owlchain.xdr.sequenceNumber;
import owlchain.xdr.messageType;

import owlchain.util.xdrStream;

import owlchain.herder.txSetFrame;

import owlchain.consensus.bcpDriver;
import owlchain.main.application;
import owlchain.database.database;
import owlchain.overlay.peer;
import owlchain.transaction.transactionFrame;

/*
* Public Interface to the Herder module
*
* Drives the consensus protocol, is responsible for collecting Txs and
* TxSets from the network and making sure Txs aren't lost in ledger close
*
* LATER: These interfaces need cleaning up. We need to work out how to
* make the bidirectional interfaces
*/

interface Herder
{
public:
    // Expected time between two ledger close.
    static Duration EXP_LEDGER_TIMESPAN_SECONDS = dur!"seconds"(5);

    // Maximum timeout for SCP consensus.
    static Duration MAX_SCP_TIMEOUT_SECONDS = dur!"seconds"(240);

    // timeout before considering the node out of sync
    static Duration CONSENSUS_STUCK_TIMEOUT_SECONDS = dur!"seconds"(35);

    // Maximum time slip between nodes.
    static Duration MAX_TIME_SLIP_SECONDS = dur!"seconds"(60);

    // How many seconds of inactivity before evicting a node.
    static Duration NODE_EXPIRATION_SECONDS = dur!"seconds"(240);

    // How many ledger in the future we consider an envelope viable.
    static uint32 LEDGER_VALIDITY_BRACKET = 100;

    // How many ledgers in the past we keep track of
    static uint32 MAX_SLOTS_TO_REMEMBER = 4;

    enum State
    {
        HERDER_SYNCING_STATE,
        HERDER_TRACKING_STATE,
        HERDER_NUM_STATE
    }

    enum TransactionSubmitStatus
    {
        TX_STATUS_PENDING = 0,
        TX_STATUS_DUPLICATE,
        TX_STATUS_ERROR,
        TX_STATUS_COUNT
    }

    enum EnvelopeStatus
    {
        // for some reason this envelope was discarded - either is was invalid,
        // used unsane qset or was coming from node that is not in quorum
        ENVELOPE_STATUS_DISCARDED,
        // envelope data is currently being fetched
        ENVELOPE_STATUS_FETCHING,
        // current call to recvEnvelope() was the first when the envelope
        // was fully fetched so it is ready for processing
        ENVELOPE_STATUS_READY,
        // envelope was already processed
        ENVELOPE_STATUS_PROCESSED,
    }

    Herder.State getState();
    string getStateHuman();

    // Ensure any meterics that are "current state" gauge-like counters reflect
    // the current reality as best as possible.
    void syncMetrics();

    void bootstrap();

    // restores SCP state based on the last messages saved on disk
    void restoreBCPState();

    bool recvBCPQuorumSet(ref Hash hash, ref BCPQuorumSet qset);
    bool recvTxSet(ref Hash hash, ref TxSetFrame txset);
    // We are learning about a new transaction.
    TransactionSubmitStatus recvTransaction(TransactionFrame tx);
    void peerDoesntHave(MessageType type, ref uint256 itemID, Peer peer);
    TxSetFrame getTxSet(ref Hash hash);

    // We are learning about a new envelope.
    EnvelopeStatus recvEnvelope(ref BCPEnvelope envelope);

    // a peer needs our BCP state
    void sendBCPStateToPeer(uint ledgerSeq, Peer peer);

    // returns the latest known ledger seq using consensus information
    // and local state
    uint getCurrentLedgerSeq();

    // Return the maximum sequence number for any tx (or 0 if none) from a given
    // sender in the pending or recent tx sets.
    SequenceNumber getMaxSeqInPendingTxs(ref AccountID);

    void triggerNextLedger(uint ledgerSeqToTrigger);

    // lookup a nodeID in config and in SCP messages
    bool resolveNodeID(ref string s, ref PublicKey retKey);

    void dumpInfo(ref JSONValue ret, size_t limit);
    void dumpQuorumInfo(ref JSONValue ret, ref NodeID id, bool summary, uint64 index = 0);

    static size_t copyCPHistoryToStream(ref Database db, uint32 ledgerSeq,
            uint32 ledgerCount, ref XDROutputFileStream cpHistory);
    static void dropAll(ref Database db);
    static void deleteOldEntries(ref Database db, uint32 ledgerSeq);
}
