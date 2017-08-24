module owlchain.xdr.nodeID;

import owlchain.xdr.publicKey;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import std.container.rbtree;

alias RedBlackTree !(NodeID, "a.ed25519 < b.ed25519") NodeIDSet;

alias NodeID = PublicKey;