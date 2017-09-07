module owlchain.overlay.peer;

import owlchain.xdr;

import owlchain.main.application;
import owlchain.database.database;

import owlchain.meterics;

import owlchain.util.timer;
import std.typecons;
alias RefCounted!(BCPQuorumSet, RefCountedAutoInitialize.no) BCPQuorumSetPtr;

class Peer
{
public:
    enum PeerState
    {
        CONNECTING = 0,
        CONNECTED = 1,
        GOT_HELLO = 2,
        GOT_AUTH = 3,
        CLOSING = 4
    };

    enum PeerRole
    {
        REMOTE_CALLED_US,
        WE_CALLED_REMOTE
    };


    static Meter getByteReadMeter(Application app)
    {
        return app.getMetrics().NewMeter(new MetricName("overlay", "byte", "read"), "byte");
    }

    static Meter getByteWriteMeter(Application app)
    {
        return app.getMetrics().NewMeter(new MetricName("overlay", "byte", "write"), "byte");
    }
protected:

    Application mApp;

    PeerRole mRole;
    PeerState mState;
    NodeID mPeerID;
    uint256 mSendNonce;
    uint256 mRecvNonce;

    HmacSha256Key mSendMacKey;
    HmacSha256Key mRecvMacKey;
    uint64 mSendMacSeq = 0;
    uint64 mRecvMacSeq = 0;

    string mRemoteVersion;
    uint32 mRemoteOverlayMinVersion;
    uint32 mRemoteOverlayVersion;
    ushort mRemoteListeningPort;

    VirtualTimer mIdleTimer;
    VirtualClock.time_point mLastRead;
    VirtualClock.time_point mLastWrite;

    Meter mMessageRead;
    Meter mMessageWrite;
    Meter mByteRead;
    Meter mByteWrite;
    Meter mErrorRead;
    Meter mErrorWrite;
    Meter mTimeoutIdle;

    Timer mRecvErrorTimer;
    Timer mRecvHelloTimer;
    Timer mRecvAuthTimer;
    Timer mRecvDontHaveTimer;
    Timer mRecvGetPeersTimer;
    Timer mRecvPeersTimer;
    Timer mRecvGetTxSetTimer;
    Timer mRecvTxSetTimer;
    Timer mRecvTransactionTimer;
    Timer mRecvGetBCPQuorumSetTimer;
    Timer mRecvBCPQuorumSetTimer;
    Timer mRecvBCPMessageTimer;
    Timer mRecvGetBCPStateTimer;

    Timer mRecvBCPPrepareTimer;
    Timer mRecvBCPConfirmTimer;
    Timer mRecvBCPNominateTimer;
    Timer mRecvBCPExternalizeTimer;

    Meter mSendErrorMeter;
    Meter mSendHelloMeter;
    Meter mSendAuthMeter;
    Meter mSendDontHaveMeter;
    Meter mSendGetPeersMeter;
    Meter mSendPeersMeter;
    Meter mSendGetTxSetMeter;
    Meter mSendTransactionMeter;
    Meter mSendTxSetMeter;
    Meter mSendGetBCPQuorumSetMeter;
    Meter mSendBCPQuorumSetMeter;
    Meter mSendBCPMessageSetMeter;
    Meter mSendGetBCPStateMeter;

    Meter mDropInConnectHandlerMeter;
    Meter mDropInRecvMessageDecodeMeter;
    Meter mDropInRecvMessageSeqMeter;
    Meter mDropInRecvMessageMacMeter;
    Meter mDropInRecvMessageUnauthMeter;
    Meter mDropInRecvHelloUnexpectedMeter;
    Meter mDropInRecvHelloVersionMeter;
    Meter mDropInRecvHelloSelfMeter;
    Meter mDropInRecvHelloPeerIDMeter;
    Meter mDropInRecvHelloCertMeter;
    Meter mDropInRecvHelloBanMeter;
    Meter mDropInRecvHelloNetMeter;
    Meter mDropInRecvHelloPortMeter;
    Meter mDropInRecvAuthUnexpectedMeter;
    Meter mDropInRecvAuthRejectMeter;
    Meter mDropInRecvAuthInvalidPeerMeter;
    Meter mDropInRecvErrorMeter;

    bool shouldAbort()
    {
        return false;
    }

    void recvMessage(ref BOSMessage msg)
    {

    }

    void recvMessage(ref AuthenticatedMessage msg)
    {

    }

    void recvMessage(byte[] xdrBytes)
    {

    }

    void recvError(ref BOSMessage msg)
    {

    }

    // returns false if we should drop this peer
    void noteHandshakeSuccessInPeerRecord()
    {

    }

    void recvAuth(ref BOSMessage msg)
    {

    }

    void recvDontHave(ref BOSMessage msg)
    {

    }

    void recvGetPeers(ref BOSMessage msg)
    {

    }

    void recvHello(ref Hello elo)
    {

    }

    void recvPeers(ref BOSMessage msg)
    {

    }

    void recvGetTxSet(ref BOSMessage msg)
    {

    }

    void recvTxSet(ref BOSMessage msg)
    {

    }

    void recvTransaction(ref BOSMessage msg)
    {

    }

    void recvGetBCPQuorumSet(ref BOSMessage msg)
    {

    }

    void recvBCPQuorumSet(ref BOSMessage msg)
    {

    }

    void recvBCPMessage(ref BOSMessage msg)
    {


    }

    void recvGetBCPState(ref BOSMessage msg)
    {

    }

    void sendHello()
    {

    }

    void sendAuth()
    {

    }

    void sendBCPQuorumSet(BCPQuorumSetPtr qSet)
    {

    }

    void sendDontHave(MessageType type, ref uint256 itemID)
    {

    }

    void sendPeers()
    {

    }

    // NB: This is a move-argument because the write-buffer has to travel
    // with the write-request through the async IO system, and we might have
    // several queued at once. We have carefully arranged this to not copy
    // data more than the once necessary into this buffer, but it can't be
    // put in a reused/non-owned buffer without having to buffer/queue
    // messages somewhere else. The async write request will point _into_
    // this owned buffer. This is really the best we can do.
    void sendMessage(byte[] xdrBytes)
    {

    }

    void connected()
    {

    }

    AuthCert getAuthCert()
    {
        AuthCert temp;

        return temp;
    }

    void startIdleTimer()
    {

    }

    void idleTimerExpired(string error)
    {

    }

    size_t getIOTimeoutSeconds()
    {
        return 0;
    }

    // helper method to acknownledge that some bytes were received
    void receivedBytes(size_t byteCount, bool gotFullMessage)
    {

    }

public:

    this(Application app)
    {

    }

    void sendGetTxSet(ref uint256 setID)
    {

    }

    void sendGetQuorumSet(ref uint256 setID)
    {

    }

    void sendGetPeers()
    {

    }

    void sendGetScpState(uint32 ledgerSeq)
    {

    }

    void sendMessage(ref BOSMessage msg)
    {

    }


}
