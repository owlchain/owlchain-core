module owlchain.xdr.bosMessage;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

// === xdr source ============================================================

//  union StellarMessage switch (MessageType type)
//  {
//  case ERROR_MSG:
//      Error error;
//  case HELLO:
//      Hello hello;
//  case AUTH:
//      Auth auth;
//  case DONT_HAVE:
//      DontHave dontHave;
//  case GET_PEERS:
//      void;
//  case PEERS:
//      PeerAddress peers<>;
//  
//  case GET_TX_SET:
//      uint256 txSetHash;
//  case TX_SET:
//      TransactionSet txSet;
//  
//  case TRANSACTION:
//      TransactionEnvelope transaction;
//  
//  // SCP
//  case GET_SCP_QUORUMSET:
//      uint256 qSetHash;
//  case SCP_QUORUMSET:
//      SCPQuorumSet qSet;
//  case SCP_MESSAGE:
//      SCPEnvelope envelope;
//  case GET_SCP_STATE:
//      uint32 getSCPLedgerSeq; // ledger seq requested ; if 0, requests the latest
//  };

//  ===========================================================================
struct BOSMessage
{
    MessageType type;
    Error error;
    Hello hello;
    Auth auth;
    DontHave dontHave;
    PeerAddress[] peers;
    uint256 txSetHash;
    TransactionSet txSet;
    TransactionEnvelope transaction;
    uint256 qSetHash;
    BCPQuorumSet qSet;
    BCPEnvelope envelope;
    Uint32 getBCPLedgerSeq;
}
