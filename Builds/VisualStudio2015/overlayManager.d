module owlchain.overlay.overlayManager;

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

import owlchain.overlay.peer;

class OverlayManager
{
public:
    this()
    {


    }
    
    void broadcastMessage(ref BOSMessage msg, bool force = false) 
    {
        
    }

    PeerSet getPeersKnows(ref Hash h)
    {
        PeerSet p = new PeerSet;

        return p;       
    }

    Peer[] getRandomPeers()
    {
        Peer [] p;

        return p;
    }

}