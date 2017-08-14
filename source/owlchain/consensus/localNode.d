module owlchain.consensus.localNode;

import std.typecons;

import std.stdio;
import std.conv;
import std.json;
import std.format;
import std.digest.sha;
import std.algorithm : canFind;
import std.algorithm : sort;
import core.stdc.stdint;

import std.container ;
import std.algorithm.comparison : equal;

import owlchain.xdr.type;
import owlchain.xdr.publicKey;
import owlchain.xdr.nodeID;
import owlchain.xdr.quorumSet;
import owlchain.xdr.hash;
import owlchain.xdr.statement;
import owlchain.xdr.envelope;
import owlchain.xdr.statementType;

import owlchain.crypto.keyUtils;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.consensus.consensusProtocol;
import owlchain.consensus.consensusProtocolDriver;

// This is one Node in the network
class LocalNode 
{
    protected:
        NodeID    mNodeID;
        bool      mIsValidator;
        SecretKey mSecretKey;
        QuorumSet       mQSet;
        Hash            mQSetHash;

        // alternative qset used during externalize {{mNodeID}}
        Hash            mSingleQSetHash;    // hash of the singleton qset
        QuorumSet       mSingleQSet;        // {{mNodeID}}

        ConsensusProtocol mConsensusProtocol;

    public :
        this(ref SecretKey secretKey, bool isValidator, ref QuorumSet qSet, ConsensusProtocol cp)
        {
            mNodeID.publicKey = secretKey.getPublicKey();
            mSecretKey = secretKey;
            mIsValidator = isValidator;

            mQSet = qSet;
            mQSetHash = Hash(sha256Of(xdr!QuorumSet.serialize(mQSet)));
            //writefln("Local Node QuorumSetHash(LocalNode) : %s", toHexString(mQSetHash.hash));

            mConsensusProtocol = cp;

            //writefln("[INFO], ConsensusProtocol LocalNode.LocalNode @%s qSet: %s", toHexString(mNodeID.publicKey.ed25519), toHexString(mQSetHash.hash));

            mSingleQSet = buildSingletonQSet(mNodeID);
            mSingleQSetHash = Hash(sha256Of(xdr!QuorumSet.serialize(mSingleQSet)));
        }

        ref NodeID getNodeID()
        {
            return mNodeID;
        }

        void updateQuorumSet(ref QuorumSet qSet)
        {
            mQSet = qSet;
            mQSetHash = Hash(sha256Of(xdr!QuorumSet.serialize(mQSet)));
        }

        ref QuorumSet getQuorumSet()
        {
            return mQSet;
        }

        ref Hash getQuorumSetHash()
        {
            //mQSetHash = Hash(sha256Of(xdr!QuorumSet.serialize(mQSet)));
            //writefln("Local Node QuorumSetHash(getQuorumSetHash) : %s", toHexString(mQSetHash.hash));
            return mQSetHash;
        }

        ref SecretKey getSecretKey()
        {
            return mSecretKey;
        }

        bool isValidator()
        {
            return mIsValidator;
        }

        ConsensusProtocol.TriBool 
            isNodeInQuorum(ref NodeID node, QuorumSetPtr delegate(ref Statement) qfn, ref Statement*[][NodeID] map) 
        {

            // perform a transitive search, starting with the local node
            // the order is not important, so we can use sets to keep track of the work
            NodeID[] backlog;
            NodeID[] visited;

            ConsensusProtocol.TriBool res = ConsensusProtocol.TriBool.TB_FALSE;

            backlog ~= mNodeID;

            while (backlog.length != 0)
            {
                auto c = backlog[0];
                if (c == node)
                {
                    return ConsensusProtocol.TriBool.TB_TRUE;
                }
                backlog = backlog[1..$];
                if (!visited.canFind(c)) visited ~= c;

                if (!map.keys.canFind(c))
                {
                    // can't lookup information on this node
                    res = ConsensusProtocol.TriBool.TB_MAYBE;
                    continue;
                }

                Statement*[] st = map[c];
                for (int i = 0; i < st.length; i++)
                {
                    auto qset = qfn(*(st[i]));
                    if (!qset.refCountedStore.isInitialized)
                    {
                        // can't find the quorum set
                        res = ConsensusProtocol.TriBool.TB_MAYBE;
                        continue;
                    }
                    // see if we need to explore further
                    forAllNodes(qset, (ref NodeID n) {
                        if (!visited.canFind(n))
                        {
                            if (!backlog.canFind(n)) backlog ~= n;
                        }
                    });
                }
            }
            return res;
        }

        // returns the quorum set {{X}}
        static QuorumSetPtr getSingletonQSet(ref NodeID nodeID) 
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= nodeID.publicKey;
            return refCounted(qSet);
        }

        // runs proc over all nodes contained in qset
        static void forAllNodes(ref QuorumSet qset, void delegate (ref NodeID) proc)
        {
            NodeIDSet done = new NodeIDSet;

            forAllNodesInternal(qset, (ref NodeID n) {
                if (done.insert(n)) {
                    proc(n);
                }
            });
            done.clear();
            done = null;
        }

        // returns the weight of the node within the qset
        // normalized between 0-UINT64_MAX
        static uint64 getNodeWeight(ref NodeID nodeID, ref QuorumSet qset)
        {
            import core.stdc.stdint;
            import owlchain.utils.types;

            uint64 n = qset.threshold;
            uint64 d = qset.innerSets.length + qset.validators.length;
            uint64 res = 0;

            //  validator
            foreach (int i, ref PublicKey pk; qset.validators)
            {
                if (pk == nodeID.publicKey)
                {
                    bigDivide(res, UINT64_MAX, n, d, Rounding.ROUND_DOWN);
                    return res;
                }
            }

            //  inner-set validator
            foreach (int i, ref QuorumSet q; qset.innerSets)
            {
                // node weight of inner-set
                uint64 leafW = getNodeWeight(nodeID, q);
                if (leafW)
                {
                    bigDivide(res, leafW, n, d, Rounding.ROUND_DOWN);
                    return res;
                }
            }

            return 0;
        }

        // Tests this node against nodeSet for the specified qSethash.
        static bool isQuorumSlice(ref QuorumSet qSet, ref NodeID [] nodeSet)
        {
            //writefln("[TRACE], ConsensusProtocol, LocalNode.isQuorumSlice nodeSet.size: %d", nodeSet.length);
            return isQuorumSliceInternal(qSet, nodeSet);
        }

        static bool isVBlocking(ref QuorumSet qSet, ref NodeID [] nodeSet)
        {
            //writefln("[TRACE], ConsensusProtocol, LocalNode.isVBlocking nodeSet.size: %d", nodeSet.length);
            return isVBlockingInternal(qSet, nodeSet);
        }

        // Tests this node against a map of NodeID -> T for the specified qSetHash.

        // `isVBlocking` tests if the filtered nodes V are a v-blocking set for
        // this node.
        static bool isVBlocking(
                        ref QuorumSet qSet,
                        ref Envelope[NodeID] map,
                        bool delegate (ref Statement) filter = null)
        {
            if (filter == null)
            {
                filter = (ref Statement) { return true; };
            }

            NodeID [] nodes;
            foreach (ref const NodeID n, ref Envelope e; map)
            {
                if (filter(e.statement))
                {
                    nodes ~= n;
                }
            }
            return isVBlocking(qSet, nodes);
        }

        // isQuorum tests if the filtered nodes V form a quorum
        // (meaning for each v \in V there is q \in Q(v)
        // included in V and we have quorum on V for qSetHash). `qfun` extracts the
        // QuorumSetPtr from the Statement for its associated node in map
        // (required for transitivity)
        static bool isQuorum(
            ref QuorumSet qSet, 
            ref Envelope[NodeID] map,
            QuorumSetPtr delegate (ref Statement) qfun,
            bool delegate (ref Statement) filter = null)
        {
            if (filter == null)
            {
                filter = (ref Statement) { return true; };
            }

            NodeID[] pNodes;

            //  Only the NodeID of the statement matching the condition is selected.
            foreach (ref const NodeID n, ref Envelope e; map)
            {
                if (filter(e.statement))
                {
                    pNodes ~= n;
                }
            }

            //  Checks whether the statement for a particular node satisfies the quorum of all nodes.
            size_t count = 0;
            do
            {
                count = pNodes.length;
                NodeID [] fNodes;
                bool delegate (ref NodeID nodeID) quorumFilter = (ref NodeID nodeID)
                {
                    auto p = (nodeID in map);
                    if (p !is null)
                    {
                        QuorumSetPtr qSetPtr = qfun(map[nodeID].statement);
                        if (qSetPtr.refCountedStore.isInitialized)
                        {
                            return isQuorumSlice(qSetPtr, pNodes);
                        }
                        else
                        {
                            return false;
                        }
                    }
                    else
                    {
                        return false;
                    }
                };

                for (int i = 0; i < pNodes.length; i++)
                {
                    if (quorumFilter(pNodes[i]))
                    {
                        fNodes ~= pNodes[i];
                    }
                }
                pNodes = fNodes;
            } while (count != pNodes.length);

            //  Finally, it checks whether the quorum number of the local load is satisfied.
            return isQuorumSlice(qSet, pNodes);
        }

        static NodeID[] findClosestVBlocking(
                    ref QuorumSet qset, 
                    ref Envelope[NodeID] map,
                    bool delegate (ref Statement) filter = null,
                    NodeID * excluded = null)
        {
            if (filter == null)
            {
                filter = (ref Statement) { return true; };
            }

            NodeIDSet pNodes = new NodeIDSet;
            foreach (ref const NodeID n, ref Envelope e; map)
            {
                if (filter(e.statement))
                {
                    pNodes.insert(n);
                }
            }
            return findClosestVBlocking(qset, pNodes, excluded);
        }

        // computes the distance to the set of v-blocking sets given
        // a set of nodes that agree (but can fail)
        // excluded, if set will be skipped altogether
        static NodeID[] findClosestVBlocking(
                ref QuorumSet qset, 
                ref NodeIDSet nodes,
                NodeID * excluded)
        {
            size_t leftTillBlock = ((1 + qset.validators.length + qset.innerSets.length) - qset.threshold);

            NodeID[] res;
            NodeID validator;
            // first, compute how many top level items need to be blocked
            foreach (int i, ref PublicKey pk; qset.validators)
            {
                validator = NodeID(pk);
                if (!excluded || !(validator == *excluded))
                {
                    if (!(validator in nodes))
                    {
                        leftTillBlock--;
                        if (leftTillBlock == 0)
                        {
                            // already blocked
                            NodeID[] newNodeSet;
                            return newNodeSet;
                        }
                    }
                    else
                    {
                        // save this for later
                        res ~= validator;
                    }
                }
            }

            NodeID[][] resInternals;
            foreach (int i, ref QuorumSet inner; qset.innerSets)
            {
                auto v = findClosestVBlocking(inner, nodes, excluded);
                if (v.length == 0)
                {
                    leftTillBlock--;
                    if (leftTillBlock == 0)
                    {
                        // already blocked
                        NodeID[] newNodeSet;
                        return newNodeSet;
                    }
                }
                else
                {
                    resInternals ~= v;
                }
            }

            // use the top level validators to get closer
            if (res.length > leftTillBlock)
            {
                res.length = leftTillBlock;
            }
            leftTillBlock -= res.length;

            alias comp = (x, y) => x.length < y.length;
            resInternals.sort!(comp).release;

            for (int i = 0; (leftTillBlock != 0) && (i < resInternals.length); i++)
            {
                res ~= resInternals[i];
                leftTillBlock--;
            }
            return res;
        }

        void toJson(ref QuorumSet qSet, ref JSONValue value)
        {
            import std.utf;
            JSONValue[] entries;
            value.object["t"] = JSONValue(qSet.threshold);
            value.object["v"] = entries;

            foreach (int i, ref PublicKey pk; qSet.validators)
            {
                value["v"].array ~= JSONValue(toUTF8(mConsensusProtocol.getCPDriver().toShortString(pk)));
            }

            foreach (int i, ref QuorumSet s; qSet.innerSets)
            {
                JSONValue[string] jsonObject;
                JSONValue iV = jsonObject;
                toJson(s, iV);
                value["v"].array ~= iV;
            }
        }

        string to_string(ref QuorumSet qSet) 
        {
            JSONValue[string] jsonObject;
            JSONValue v = jsonObject;
            toJson(qSet, v);
            return v.toString();
        }


    protected :
        static QuorumSet buildSingletonQSet(ref NodeID nodeID)
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= nodeID.publicKey;
            return qSet;
        }

        // runs proc over all nodes contained in qset
        static void forAllNodesInternal(ref QuorumSet qset, void delegate (ref NodeID) proc)
        {
            NodeID validator;
            foreach (int i, ref PublicKey pk; qset.validators)
            {
                validator = NodeID(pk);
                proc(validator);
            }
            foreach (int i, ref QuorumSet q; qset.innerSets)
            {
                forAllNodesInternal(q, proc);
            }
        }

        static bool isQuorumSliceInternal(ref QuorumSet qset, ref NodeID[] nodeSet)
        {
            uint32 thresholdLeft = qset.threshold;
            NodeID nodeId;

            foreach (int i, ref PublicKey pk; qset.validators)
            {
                nodeId = NodeID(pk);
                if (nodeSet.canFind(nodeId))
                {
                    thresholdLeft--;
                    if (thresholdLeft <= 0)
                    {
                        return true;
                    }
                }
            }

            foreach (int i, ref QuorumSet q; qset.innerSets)
            {
                if (isQuorumSliceInternal(q, nodeSet))
                {
                    thresholdLeft--;
                    if (thresholdLeft <= 0)
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        // called recursively
        static bool isVBlockingInternal(ref QuorumSet qset, ref NodeID [] nodeSet)
        {
            // There is no v-blocking set for {\empty}
            if (qset.threshold == 0)
            {
                return false;
            }

            //  if v is 4 and inserSet is 0 and threshold is 3 then leftTillBlock is 2;
            //  V: 4 T:3 => 2
            //  V: 7 T:5 => 3
            //  V:10 T:7 => 4

            int leftTillBlock = cast(int)((1 + qset.validators.length + qset.innerSets.length) - qset.threshold);

            NodeID validator;
            foreach (int i, ref PublicKey pk; qset.validators)
            {
                validator = NodeID(pk);
                if (nodeSet.canFind(validator))
                {
                    leftTillBlock--;
                    if (leftTillBlock <= 0)
                    {
                        return true;
                    }
                }
            }

            foreach (int i, ref QuorumSet q; qset.innerSets)
            {
                if (isVBlockingInternal(q, nodeSet))
                {
                    leftTillBlock--;
                    if (leftTillBlock <= 0)
                    {
                        return true;
                    }
                }
            }
            return false;
        }
}
