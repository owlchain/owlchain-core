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
import owlchain.xdr.statement;

import owlchain.crypto.keyUtils;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.consensus.consensusProtocol;
import owlchain.consensus.consensusProtocolDriver;


// This is one Node in the network
class LocalNode 
{
    protected:
        const NodeID    _nodeID;
        const bool      _isValidator;
        SecretKey       _secretKey;
        QuorumSet       _qSet;
        Hash            _qSetHash;

        // alternative qset used during externalize {{_nodeID}}
        Hash            _singleQSetHash;    // hash of the singleton qset
        QuorumSet       _singleQSet;        // {{_nodeID}}

        ConsensusProtocol _consensusProtocol;

    public :
        this(SecretKey secretKey, bool isValidator, ref const QuorumSet qSet, ConsensusProtocol cp)
        {
            _nodeID.publicKey = secretKey.getPublicKey();
            _secretKey = secretKey;
            _isValidator = isValidator;

            _qSet = cast(QuorumSet)qSet;
            XdrDataOutputStream stream1 = new XdrDataOutputStream();
            QuorumSet.encode(stream1, _qSet);

            _qSetHash.hash = sha256Of(stream1.toBytes());

            _consensusProtocol = cp;

            writefln("[INFO], SCP LocalNode.LocalNode @%s qSet: %s", toHexString(_nodeID.publicKey.ed25519), toHexString(_qSetHash.hash));

            _singleQSet = buildSingletonQSet(_nodeID);
            XdrDataOutputStream stream2 = new XdrDataOutputStream();
            QuorumSet.encode(stream2, _singleQSet);

            _singleQSetHash.hash = sha256Of(stream2.toBytes());
        }

        ref const(NodeID) getNodeID()
        {
            return _nodeID;
        }

        void updateQuorumSet(ref const QuorumSet qSet)
        {
            _qSet = cast(QuorumSet)qSet;
            XdrDataOutputStream stream = new XdrDataOutputStream();
            QuorumSet.encode(stream, _qSet);
            _qSetHash.hash = sha256Of(stream.data);
        }

        ref const(QuorumSet) getQuorumSet()
        {
            return _qSet;
        }

        ref const(Hash) getQuorumSetHash()
        {
            return _qSetHash;
        }

        ref const(SecretKey) getSecretKey()
        {
            return _secretKey;
        }

        bool isValidator()
        {
            return _isValidator;
        }

        ConsensusProtocol.TriBool 
            isNodeInQuorum(ref const NodeID node, const QuorumSetPtr delegate(ref const Statement) qfn, ref Statement*[][NodeID] map)
        {

            // perform a transitive search, starting with the local node
            // the order is not important, so we can use sets to keep track of the work
            NodeID[] backlog;
            NodeID[] visited;

            ConsensusProtocol.TriBool res = ConsensusProtocol.TriBool.TB_FALSE;

            backlog ~= _nodeID;

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
                    forAllNodes(qset, (ref const NodeID n) {
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
        static QuorumSetPtr getSingletonQSet(ref const NodeID nodeID) 
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= nodeID.publicKey;
            return refCounted(qSet);
        }

        // runs proc over all nodes contained in qset
        static void forAllNodes(ref const QuorumSet qset, void delegate (ref const NodeID) proc)
        {
            NodeIDSet done = new NodeIDSet;

            forAllNodesInternal(qset, (ref const NodeID n) {
                if (done.insert(n)) {
                    proc(n);
                }
            });
            done.clear();
            done = null;
        }

        // returns the weight of the node within the qset
        // normalized between 0-UINT64_MAX
        static uint64 getNodeWeight(ref const NodeID nodeID, ref const QuorumSet qset)
        {
            import core.stdc.stdint;
            import owlchain.util.types;

            uint64 n = qset.threshold;
            uint64 d = qset.innerSets.length + qset.validators.length;
            uint64 res = 0;

            //  validator
            foreach (int i, PublicKey pk; qset.validators)
            {
                if (pk == nodeID.publicKey)
                {
                    bigDivide(res, UINT64_MAX, n, d, Rounding.ROUND_DOWN);
                    return res;
                }
            }

            //  inner-set validator
            foreach (int i, const QuorumSet q; qset.innerSets)
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
        static bool isQuorumSlice(ref const QuorumSet qSet, ref const NodeID [] nodeSet)
        {
            writefln("[TRACE], ConsensusProtocol, LocalNode.isQuorumSlice nodeSet.size: %d", nodeSet.length);
            return isQuorumSliceInternal(qSet, nodeSet);
        }

        static bool isVBlocking(ref const QuorumSet qSet, ref const NodeID [] nodeSet)
        {
            writefln("[TRACE], ConsensusProtocol, LocalNode.isVBlocking nodeSet.size: %d", nodeSet.length);
            return isVBlockingInternal(qSet, nodeSet);
        }

        // Tests this node against a map of NodeID -> T for the specified qSetHash.

        // `isVBlocking` tests if the filtered nodes V are a v-blocking set for
        // this node.
        static bool isVBlocking(
                        ref const QuorumSet qSet,
                        ref const Envelope[NodeID] map,
                        bool delegate (ref const Statement) filter = null)
        {
            if (filter == null)
            {
                filter = (ref const Statement) { return true; };
            }

            NodeID [] nodes;
            foreach (NodeID n, const Envelope e; map)
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
            ref const QuorumSet qSet, 
            ref const Envelope[NodeID] map,
            QuorumSetPtr delegate (ref const Statement) qfun,
            bool delegate (ref const Statement) filter = null)
        {
            if (filter == null)
            {
                filter = (ref const Statement) { return true; };
            }

            NodeID[] pNodes;
            foreach (NodeID n, const Envelope e; map)
            {
                if (filter(e.statement))
                {
                    pNodes ~= n;
                }
            }

            size_t count = 0;
            do
            {
                count = pNodes.length;
                NodeID [] fNodes;
                bool delegate (ref const NodeID nodeID) quorumFilter = (ref const NodeID nodeID)
                {
                    if (map.keys.canFind(nodeID))
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

            return isQuorumSlice(qSet, pNodes);
        }

        static NodeID[] findClosestVBlocking(
                    ref const QuorumSet qset, 
                    ref const Envelope[NodeID] map,
                    bool delegate (ref const Statement) filter = null,
                    const NodeID * excluded = null)
        {
            if (filter == null)
            {
                filter = (ref const Statement) { return true; };
            }

            //RedBlackTree!NodeID pNodes2;
            NodeIDSet pNodes = new NodeIDSet;
            foreach (const NodeID n, const Envelope e; map)
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
                ref const QuorumSet qset, 
                ref const NodeIDSet nodes,
                const NodeID * excluded)
        {
            size_t leftTillBlock = ((1 + qset.validators.length + qset.innerSets.length) - qset.threshold);

            NodeID[] res;
            NodeID validator;
            // first, compute how many top level items need to be blocked
            foreach (int i, PublicKey pk; qset.validators)
            {
                validator.publicKey = pk;
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

            struct orderBySize
            {
                bool operator()(ref const NodeID[] v1, ref const NodeID v2)
                {
                    return v1.length < v2.length;
                }
            };

            //std::multiset<std::vector<NodeID>, orderBySize> resInternals;

            NodeID[][] resInternals;
            foreach (int i, const QuorumSet inner; qset.innerSets)
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

        void toJson(ref const QuorumSet qSet, ref JSONValue value)
        {
            value["t"] = qSet.threshold;
            auto entries = value["v"];

            foreach (int i, const PublicKey pk; qSet.validators)
            {
                entries ~= _consensusProtocol.getCPDriver().toShortString(pk);
            }

            foreach (int i, const QuorumSet s; qSet.innerSets)
            {
                JSONValue iV;
                toJson(s, iV);
                entries ~= iV;
            }
        }

        string to_string(ref const QuorumSet qSet) 
        {
            JSONValue v;
            toJson(qSet, v);
            return v.toPrettyString();
        }


    protected :
        static QuorumSet buildSingletonQSet(ref const NodeID nodeID)
        {
            QuorumSet qSet;
            qSet.threshold = 1;
            qSet.validators ~= nodeID.publicKey;
            return qSet;
        }

        // runs proc over all nodes contained in qset
        static void forAllNodesInternal(ref const QuorumSet qset, void delegate (ref const NodeID) proc)
        {
            NodeID nodeID;
            foreach (int i, const PublicKey pk; qset.validators)
            {
                nodeID.publicKey = pk;
                proc(nodeID);
            }
            foreach (int i, const QuorumSet q; qset.innerSets)
            {
                forAllNodesInternal(q, proc);
            }
        }

        static bool isQuorumSliceInternal(ref const QuorumSet qset, ref const NodeID[] nodeSet)
        {
            uint32 thresholdLeft = qset.threshold;

            foreach (int i, const PublicKey pk; qset.validators)
            {
                if (nodeSet.canFind(NodeID(pk)))
                {
                    thresholdLeft--;
                    if (thresholdLeft <= 0)
                    {
                        return true;
                    }
                }
            }

            foreach (int i, const QuorumSet q; qset.innerSets)
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
        static bool isVBlockingInternal(ref const QuorumSet qset, ref const NodeID [] nodeSet)
        {
            // There is no v-blocking set for {\empty}
            if (qset.threshold == 0)
            {
                return false;
            }

            int leftTillBlock = cast(int)((1 + qset.validators.length + qset.innerSets.length) - qset.threshold);

            foreach (int i, const PublicKey pk; qset.validators)
            {
                if (nodeSet.canFind(NodeID(pk)))
                {
                    leftTillBlock--;
                    if (leftTillBlock <= 0)
                    {
                        return true;
                    }
                }
            }

            foreach (int i, const QuorumSet q; qset.innerSets)
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
