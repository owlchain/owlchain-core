module owlchain.consensus.consensusProtocol;
import std.stdio;
import std.json;
import std.format;
import std.digest.sha;
import std.algorithm : canFind;
import std.outbuffer;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.envelope;
import owlchain.xdr.value;
import owlchain.xdr.quorumSet;
import owlchain.xdr.nodeID;
import owlchain.xdr.ballot;
import owlchain.xdr.statement;
import owlchain.xdr.statementType;

import owlchain.crypto.keyUtils;

import owlchain.consensus.localNode;
import owlchain.consensus.consensusProtocolDriver;
import owlchain.consensus.slot;

class ConsensusProtocol
{
private:
    private ConsensusProtocolDriver _driver;

protected:
    LocalNode _localNode;
    Slot [uint64] _knownSlots;

public:
    enum EnvelopeState
    {
        INVALID, // the envelope is considered invalid
        VALID    // the envelope is valid
    };

    enum TriBool
    {
        TB_TRUE,
        TB_FALSE,
        TB_MAYBE
    };

	this(ConsensusProtocolDriver driver, SecretKey secretKey, bool isValidator, ref QuorumSet qSetLocal)
	{
        _driver = driver;
        _localNode = new LocalNode(secretKey, isValidator, qSetLocal, this);
	}

    // ConsensusProtocolDriver getter
    @property ConsensusProtocolDriver driver()
    {
        return _driver;
    }

    // ConsensusProtocolDriver setter
    @property void driver(ConsensusProtocolDriver value)
    {
        _driver = value;
    }

    // Local node getter
    @property ref LocalNode localNode()
    {
        return _localNode;
    }

    // Local nodeID getter
    @property const NodeID localNodeID()
    {
        return _localNode.getNodeID();
    }

    // Local QuorumSet getter
    @property ref QuorumSet localQuorumSet()
    {
        return _localNode.getQuorumSet();
    }

    // Retrieves the local secret key as specified at construction
    @property ref SecretKey secretKey()
    {
        return _localNode.getSecretKey();
    }

    // Returns whether the local node is a validator.
    @property bool isValidator()
    {
        return _localNode.isValidator();
    }

    // Slot getter
    Slot getSlot(uint64 slotIndex, bool create)
    {
        Slot slot;

        if (_knownSlots.keys.canFind(slotIndex))
        {
            slot = _knownSlots[slotIndex];
        } else
        {
            if (create)
            {
                slot = new Slot(slotIndex, this);
                _knownSlots[slotIndex] = slot;
            }
            else
            {
                slot = null;
            }
        }
        return slot;
    }

    // this is the main entry point of the Consensus Protocol library
    // it processes the envelope, updates the internal state and
    // invokes the appropriate methods
    EnvelopeState receiveEnvelope(ref const Envelope envelope)
    {
        // If the envelope is not correctly signed, we ignore it.
        if (!_driver.verifyEnvelope(envelope))
        {
            writefln("[%s], %s", "DEBUG", "ConsensusProtocol", "ConsensusProtocol.receiveEnvelope invalid");
            return EnvelopeState.INVALID;
        }

        return getSlot(envelope.statement.slotIndex, true).processEnvelope(envelope, false);
    }

    // Submit a value to consider for slotIndex
    // previousValue is the value from slotIndex-1
    bool nominate(uint64 slotIndex, ref const Value value, ref const Value previousValue)
    {
        return getSlot(slotIndex, true).nominate(value, previousValue, false);
    }

    // stops nomination for a slot
    void stopNomination(uint64 slotIndex)
    {
        auto s = getSlot(slotIndex, false);
        if (s)
        {
            s.stopNomination();
        }
    }

    // Local QuorumSet interface (can be dynamically updated)
    void updateLocalQuorumSet(ref const QuorumSet qSet)
    {
        _localNode.updateQuorumSet(qSet);
    }

    void dumpInfo(ref JSONValue ret, size_t limit)
    {
        uint64 slotIndex;
        size_t i = _knownSlots.keys.length-1;
        while ((i >= 0) && (limit-- != 0))
        {
            slotIndex = _knownSlots.keys[i];
            _knownSlots[slotIndex].dumpInfo(ret);
        }
    }

    // summary: only return object counts
    // index = 0 for returning information for all slots
    void dumpQuorumInfo(ref JSONValue ret, ref NodeID id, bool summary, uint64 index = 0)
    {
        if (index == 0)
        {
            foreach (uint64 slotIndex, Slot slot; _knownSlots)
            {
                slot.dumpQuorumInfo(ret, id, summary);
            }
        }
        else
        {
            auto s = getSlot(index, false);
            if (s)
            {
                s.dumpQuorumInfo(ret, id, summary);
            }
        }

    }

    // Purges all data relative to all the slots whose slotIndex is smaller
    // than the specified `maxSlotIndex`.
    void purgeSlots(uint64 maxSlotIndex)
    {
        uint64 slotIndex;
        uint64 [] k = _knownSlots.keys;
        for (size_t i = 0; i < k.length; i++)
        {
            slotIndex = k[i];
            if (slotIndex < maxSlotIndex)
            {
                _knownSlots.remove(slotIndex);
            }
        }
    }

    // Helpers for monitoring and reporting the internal memory-usage of the 
    // protocol to system metric reporters.
    size_t getKnownSlotsCount()
    {
        return _knownSlots.length;
    }

    size_t getCumulativeStatemtCount()
    {
        size_t count = 0;

        foreach (uint64 slotIndex, Slot slot; _knownSlots)
        {
            count += slot.getStatementCount();
        }
        return count;
    }

    // returns the latest messages sent for the given slot
    Envelope[] getLatestMessagesSend(uint64 slotIndex)
    {
        auto slot = getSlot(slotIndex, false);
        if (slot)
        {
            return slot.getLatestMessagesSend();
        }
        else
        {
            Envelope[] res;
            return res;
        }
    }

    // forces the state to match the one in the envelope
    // this is used when rebuilding the state after a crash for example
    void setStateFromEnvelope(uint64 slotIndex, ref const Envelope e)
    {
        if (_driver.verifyEnvelope(e))
        {
            auto slot = getSlot(slotIndex, true);
            slot.setStateFromEnvelope(e);
        }
    }

    // returns all messages for the slot
    Envelope[] getCurrentState(uint64 slotIndex)
    {
        auto slot = getSlot(slotIndex, false);
        if (slot)
        {
            return slot.getCurrentState();
        }
        else
        {
            Envelope[] res;
            return res;
        }
    }

    // returns messages that contributed to externalizing the slot
    // (or empty if the slot didn't externalize)
    Envelope[] getExternalizingState(uint64 slotIndex)
    {
        auto slot = getSlot(slotIndex, false);
        if (slot)
        {
            return slot.getExternalizingState();
        }
        else
        {
            Envelope[] res;
            return res;
        }

    }

    // returns if a node is in the (transitive) quorum originating at
    // the local node, scanning the known slots.
    // TB_TRUE iff n is in the quorum
    // TB_FALSE iff n is not in the quorum
    // TB_MAYBE iff the quorum cannot be computed
    TriBool isNodeInQuorum(ref const NodeID node)
    {
        TriBool res = TriBool.TB_MAYBE;
        foreach (uint64 slotIndex, Slot slot; _knownSlots)
        {
            res = slot.isNodeInQuorum(node);
            if (res == TriBool.TB_TRUE || res == TriBool.TB_FALSE)
            {
                break;
            }
        }
        return res;
    }

    // ** helper methods to stringify ballot for logging
    string getValueString(ref const Value v)
    {
        return _driver.getValueString(v);
    }

    string ballotToStr(ref const Ballot ballot)
    {
        return format("(%d,%s)", ballot.counter, getValueString(ballot.value));
    }

    string ballotToStr(ref const Ballot * ballot)
    {
        string res;
        if (ballot) {
            res = ballotToStr(*ballot);
        }
        else
        {
            res = "(<null_ballot>)";
        }
        return res;
    }

    string envToStr(ref const Envelope envelope)
    {
        return envToStr(envelope.statement);
    }

    string envToStr(ref const Statement st)
    {
        OutBuffer oBuffer = new OutBuffer(); 
        Hash qSetHash = Slot.getCompanionQuorumSetHashFromStatement(st);

        oBuffer.writef("{ENV@%s | i: %d", driver.toShortString(st.nodeID.publicKey), st.slotIndex);

        switch (st.pledges.type.val)
        {
            case StatementType.CP_ST_PREPARE:
                {
                    oBuffer.writef(" | PREPARE"~
                                   " | D: %s"~
                                   " | b: %s"~
                                   " | p: %s"~
                                   " | p: %s"~
                                   " | c.n: %d"~
                                   " | h.n: %d ",
                                     toHexString(qSetHash.hash),
                                     ballotToStr(st.pledges.prepare.ballot),
                                     ballotToStr(st.pledges.prepare.prepared),
                                     ballotToStr(st.pledges.prepare.preparedPrime),
                                     st.pledges.prepare.nC,
                                     st.pledges.prepare.nH
                                     );
                }
                break;
            case StatementType.CP_ST_CONFIRM:
                {
                    oBuffer.writef(" | CONFIRM"~
                                   " | D: %s"~
                                   " | b: %s"~
                                   " | p.n: %d"~
                                   " | c.n: %d"~
                                   " | h.n: %d ",
                                     toHexString(qSetHash.hash),
                                     ballotToStr(st.pledges.confirm.ballot),
                                     st.pledges.confirm.nPrepared,
                                     st.pledges.confirm.nCommit,
                                     st.pledges.confirm.nH
                                     );
                }
                break;
            case StatementType.CP_ST_EXTERNALIZE:
                {
                    oBuffer.writef(" | EXTERNALIZE"~
                                   " | c: %s"~
                                   " | h.n: %d"~
                                   " | (lastD): %s ",
                                     ballotToStr(st.pledges.externalize.commit),
                                     st.pledges.externalize.nH,
                                     toHexString(qSetHash.hash)
                                     );
                }
                break;
            case StatementType.CP_ST_NOMINATE:
                {
                    oBuffer.writef(" | NOMINATE"~
                                   " | D: %s"~
                                   " | X: {", toHexString(qSetHash.hash));
                    bool first = true;

                    for (int i = 0; i < st.pledges.nominate.votes.length; i++)
                    {
                        if (!first)
                        {
                            oBuffer.write(" ,");
                        }
                        oBuffer.writef("'%s'", st.pledges.nominate.votes[i]);
                        first = false;
                    }
                    oBuffer.write("}");
                    oBuffer.write(" | Y: {");
                    
                    first = true;
                    for (int i = 0; i < st.pledges.nominate.accepted.length; i++)
                    {
                        if (!first)
                        {
                            oBuffer.write(" ,");
                        }
                        oBuffer.writef("'%s'", st.pledges.nominate.accepted[i]);
                        first = false;
                    }
                    oBuffer.write("}");
                }
                break;
            default:
        }

        oBuffer.writef(" }");
        
        return oBuffer.toString();
    }
} 