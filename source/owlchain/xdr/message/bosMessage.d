module owlchain.xdr.bosMessage;

import owlchain.xdr.type;
import owlchain.xdr.messageType;
import owlchain.xdr.error;
import owlchain.xdr.auth;
import owlchain.xdr.dontHave;
import owlchain.xdr.peerAddress;
import owlchain.xdr.transactionSet;
import owlchain.xdr.transactionEnvelope;
import owlchain.xdr.bcpQuorumSet;
import owlchain.xdr.bcpEnvelope;
import owlchain.xdr.hello;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

// === xdr source ============================================================

//  union BOSMessage switch (MessageType type)
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
//  // BCP
//  case GET_BCP_QUORUMSET:
//      uint256 qSetHash;
//  case BCP_QUORUMSET:
//      SCPQuorumSet qSet;
//  case BCP_MESSAGE:
//      SCPEnvelope envelope;
//  case GET_BCP_STATE:
//      uint32 getBCPLedgerSeq; // ledger seq requested ; if 0, requests the latest
//  };

//  ===========================================================================
struct BOSMessage
{
    MessageType type;
    owlchain.xdr.error.Error error;
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
    uint32 getBCPLedgerSeq;
    
    static void encode(XdrDataOutputStream stream, ref const BOSMessage encoded)
    {
        encodeMessageType(stream, encoded.type);
        switch (encoded.type)
        {
        case MessageType.ERROR_MSG:
            owlchain.xdr.error.Error.encode(stream, encoded.error);
            break;
        case MessageType.AUTH:
            Auth.encode(stream, encoded.auth);
            break;
        case MessageType.DONT_HAVE:
            DontHave.encode(stream, encoded.dontHave);
            break;
        case MessageType.GET_PEERS:
            break;
        case MessageType.PEERS:
            const int peerssize = cast(int)encoded.peers.length;
            stream.writeInt(peerssize);
            for (int i = 0; i < peerssize; i++) {
                PeerAddress.encode(stream, encoded.peers[i]);
            }
            break;
        case MessageType.GET_TX_SET:
            stream.writeUint256(encoded.txSetHash);
            break;
        case MessageType.TX_SET:
            TransactionSet.encode(stream, encoded.txSet);
            break;
        case MessageType.TRANSACTION:
            TransactionEnvelope.encode(stream, encoded.transaction);
            break;
        case MessageType.GET_BCP_QUORUMSET:
            stream.writeUint256(encoded.qSetHash);
            break;
        case MessageType.BCP_QUORUMSET:
            BCPQuorumSet.encode(stream, encoded.qSet);
            break;
        case MessageType.BCP_MESSAGE:
            BCPEnvelope.encode(stream, encoded.envelope);
            break;
        case MessageType.GET_BCP_STATE:
            stream.writeUint32(encoded.getBCPLedgerSeq);
            break;
        case MessageType.HELLO:
            Hello.encode(stream, encoded.hello);
            break;
        default:
            break;
        }
    }

    static BOSMessage decode(XdrDataInputStream stream)
    {
        BOSMessage decoded;

        decoded.type = decodeMessageType(stream);

        switch (decoded.type)
        {
        case MessageType.ERROR_MSG:
            decoded.error = owlchain.xdr.error.Error.decode(stream);
            break;
        case MessageType.AUTH:
            decoded.auth = Auth.decode(stream);
            break;
        case MessageType.DONT_HAVE:
            decoded.dontHave = DontHave.decode(stream);
            break;
        case MessageType.GET_PEERS:
            break;
        case MessageType.PEERS:
            const int peerssize = stream.readInt();
            for (int i = 0; i < peerssize; i++) {
                decoded.peers ~= PeerAddress.decode(stream);
            }
            break;
        case MessageType.GET_TX_SET:
            decoded.txSetHash = stream.readUint256();
            break;
        case MessageType.TX_SET:
            decoded.txSet = TransactionSet.decode(stream);
            break;
        case MessageType.TRANSACTION:
            decoded.transaction = TransactionEnvelope.decode(stream);
            break;
        case MessageType.GET_BCP_QUORUMSET:
            decoded.qSetHash = stream.readUint256();
            break;
        case MessageType.BCP_QUORUMSET:
            decoded.qSet = BCPQuorumSet.decode(stream);
            break;
        case MessageType.BCP_MESSAGE:
            decoded.envelope = BCPEnvelope.decode(stream);
            break;
        case MessageType.GET_BCP_STATE:
            decoded.getBCPLedgerSeq = stream.readUint32();
            break;
        case MessageType.HELLO:
            decoded.hello = Hello.decode(stream);
            break;
        default:
            break;
        }

        return decoded;
    }
}
