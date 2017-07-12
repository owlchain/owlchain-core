module owlchain.xdr.nodeID;

import owlchain.xdr.publicKey;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct NodeID
{
    PublicKey publicKey;

    static NodeID opCall()
    {
        NodeID nodeID;
        return nodeID;
    }

    static NodeID opCall(PublicKey value)
    {
        NodeID nodeID;
        nodeID.publicKey = value;
        return nodeID;
    }

    static void encode(XdrDataOutputStream stream, ref const NodeID encodedNodeID)
    {
        PublicKey.encode(stream, encodedNodeID.publicKey);
    }

    static NodeID decode(XdrDataInputStream stream)
    {
        NodeID decodedNodeID;
        decodedNodeID.publicKey = PublicKey.decode(stream);
        return decodedNodeID;
    }
}