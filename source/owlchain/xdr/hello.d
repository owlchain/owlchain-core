module owlchain.xdr.hello;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.nodeID;
import owlchain.xdr.authCert;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Hello
{
    uint32 ledgerVersion;
    uint32 overlayVersion;
    uint32 overlayMinVersion;
    Hash networkID;
    string versionStr;
    int32 listeningPort;
    NodeID peerID;
    AuthCert cert;
    uint256 nonce;
    
    static void encode(XdrDataOutputStream stream, ref const Hello encodedValue)
    {
        stream.writeUint32(encodedValue.ledgerVersion);
        stream.writeUint32(encodedValue.overlayVersion);
        stream.writeUint32(encodedValue.overlayMinVersion);
        Hash.encode(stream, encodedValue.networkID);
        stream.writeString(encodedValue.versionStr);
        stream.writeInt32(encodedValue.listeningPort);
        NodeID.encode(stream, encodedValue.peerID);
        AuthCert.encode(stream, encodedValue.cert);
        stream.writeUint256(encodedValue.nonce);
    }

    static Hello decode(XdrDataInputStream stream)
    {
        Hello decodedValue;

        decodedValue.ledgerVersion = stream.readUint32();
        decodedValue.overlayVersion = stream.readUint32();
        decodedValue.overlayMinVersion = stream.readUint32();
        decodedValue.networkID = Hash.decode(stream);
        decodedValue.versionStr = stream.readString();
        decodedValue.listeningPort = stream.readInt32();
        decodedValue.peerID = NodeID.decode(stream);
        decodedValue.cert = AuthCert.decode(stream);
        decodedValue.nonce = stream.readUint256();

        return decodedValue;
    }
}
