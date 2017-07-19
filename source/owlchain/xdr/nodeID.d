module owlchain.xdr.nodeID;

import owlchain.xdr.publicKey;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import std.container.rbtree;

alias RedBlackTree !(NodeID, "a.publicKey.ed25519 < b.publicKey.ed25519") NodeIDSet;

struct NodeID
{
    PublicKey publicKey;

    static NodeID opCall()
    {
        NodeID nodeID;
        return nodeID;
    }
    int opCmp(ref NodeID other)
    {
        if (publicKey.ed25519 < other.publicKey.ed25519)
        {
            return -1;
        }
        else if (publicKey.ed25519 > other.publicKey.ed25519)
        {
            return 1;
        }
        else
        {
            return 0;
        }
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