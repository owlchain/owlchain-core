module owlchain.consensus.bcp;
import std.stdio;
import std.json;
import std.format;
import std.digest.sha;
import std.algorithm : canFind;
import std.outbuffer;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.bcpEnvelope;
import owlchain.xdr.value;
import owlchain.xdr.bcpQuorumSet;
import owlchain.xdr.nodeID;
import owlchain.xdr.bcpBallot;
import owlchain.xdr.bcpStatement;
import owlchain.xdr.bcpStatementType;

import owlchain.crypto.keyUtils;

import owlchain.consensus.localNode;
import owlchain.consensus.bcpDriver;
import owlchain.consensus.slot;

import owlchain.utils.globalChecks;

class BCP
{
private:
    private BCPDriver mBCPDriver;

protected:
    LocalNode mLocalNode;
    Slot[uint64] mKnownSlots;

public:
    enum EnvelopeState
    {
        INVALID, // the envelope is considered invalid
        VALID // the envelope is valid
    };

    enum TriBool
    {
        TB_TRUE,
        TB_FALSE,
        TB_MAYBE
    };

    this(BCPDriver driver, SecretKey secretKey, bool isValidator,
            ref BCPQuorumSet qSetLocal)
    {
        mBCPDriver = driver;
        mLocalNode = new LocalNode(secretKey, isValidator, qSetLocal, this);
    }

    // BCPDriver getter
    ref BCPDriver getCPDriver()
    {
        return mBCPDriver;
    }

    // Local node getter
    ref LocalNode getLocalNode()
    {
        return mLocalNode;
    }

    // Local nodeID getter
    ref NodeID getLocalNodeID()
    {
        return mLocalNode.getNodeID();
    }

    // Local BCPQuorumSet getter
    ref BCPQuorumSet getLocalQuorumSet()
    {
        return mLocalNode.getQuorumSet();
    }

    // Retrieves the local secret key as specified at construction
    ref SecretKey getSecretKey()
    {
        return mLocalNode.getSecretKey();
    }

    // Returns whether the local node is a validator.
    @property bool isValidator()
    {
        return mLocalNode.isValidator();
    }

    // Slot getter
    Slot getSlot(uint64 slotIndex, bool create)
    {
        Slot slot;

        auto p = slotIndex in mKnownSlots;

        if (p !is null)
        {
            slot = mKnownSlots[slotIndex];
        }
        else
        {
            if (create)
            {
                slot = new Slot(slotIndex, this);
                mKnownSlots[slotIndex] = slot;
            }
            else
            {
                slot = null;
            }
        }
        return slot;
    }

    // this is the main entry point of the BCP library
    // it processes the envelope, updates the internal state and
    // invokes the appropriate methods
    EnvelopeState receiveEnvelope(ref BCPEnvelope envelope)
    {
        // If the envelope is not correctly signed, we ignore it.
        if (!mBCPDriver.verifyEnvelope(envelope))
        {
            writefln("[%s], %s", "DEBUG", "BCP",
                    "BCP.receiveEnvelope invalid");
            return EnvelopeState.INVALID;
        }

        return getSlot(envelope.statement.slotIndex, true).processEnvelope(envelope, false);
    }

    // Submit a value to consider for slotIndex
    // previousValue is the value from slotIndex-1
    bool nominate(uint64 slotIndex, ref Value value, ref Value previousValue)
    {
        dbgAssert(isValidator());
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

    // Local BCPQuorumSet interface (can be dynamically updated)
    void updateLocalQuorumSet(ref BCPQuorumSet qSet)
    {
        mLocalNode.updateQuorumSet(qSet);
    }

    void dumpInfo(ref JSONValue ret, size_t limit)
    {
        uint64 slotIndex;
        size_t i = mKnownSlots.keys.length - 1;
        while ((i >= 0) && (limit-- != 0))
        {
            slotIndex = mKnownSlots.keys[i];
            mKnownSlots[slotIndex].dumpInfo(ret);
        }
    }

    // summary: only return object counts
    // index = 0 for returning information for all slots
    void dumpQuorumInfo(ref JSONValue ret, ref NodeID id, bool summary, uint64 index = 0)
    {
        if (index == 0)
        {
            foreach (uint64 slotIndex, ref Slot slot; mKnownSlots)
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
        uint64[] k = mKnownSlots.keys;
        for (size_t i = 0; i < k.length; i++)
        {
            slotIndex = k[i];
            if (slotIndex < maxSlotIndex)
            {
                mKnownSlots.remove(slotIndex);
            }
        }
    }

    // Helpers for monitoring and reporting the internal memory-usage of the 
    // protocol to system metric reporters.
    size_t getKnownSlotsCount()
    {
        return mKnownSlots.length;
    }

    size_t getCumulativeStatemtCount()
    {
        size_t count = 0;

        foreach (uint64 slotIndex, ref Slot slot; mKnownSlots)
        {
            count += slot.getStatementCount();
        }
        return count;
    }

    // returns the latest messages sent for the given slot
    BCPEnvelope[] getLatestMessagesSend(uint64 slotIndex)
    {
        auto slot = getSlot(slotIndex, false);
        if (slot)
        {
            return slot.getLatestMessagesSend();
        }
        else
        {
            BCPEnvelope[] res;
            return res;
        }
    }

    // forces the state to match the one in the envelope
    // this is used when rebuilding the state after a crash for example
    void setStateFromEnvelope(uint64 slotIndex, ref BCPEnvelope e)
    {
        if (mBCPDriver.verifyEnvelope(e))
        {
            auto slot = getSlot(slotIndex, true);
            slot.setStateFromEnvelope(e);
        }
    }

    // returns all messages for the slot
    BCPEnvelope[] getCurrentState(uint64 slotIndex)
    {
        auto slot = getSlot(slotIndex, false);
        if (slot)
        {
            return slot.getCurrentState();
        }
        else
        {
            BCPEnvelope[] res;
            return res;
        }
    }

    // returns messages that contributed to externalizing the slot
    // (or empty if the slot didn't externalize)
    BCPEnvelope[] getExternalizingState(uint64 slotIndex)
    {
        auto slot = getSlot(slotIndex, false);
        if (slot)
        {
            return slot.getExternalizingState();
        }
        else
        {
            BCPEnvelope[] res;
            return res;
        }
    }

    // returns if a node is in the (transitive) quorum originating at
    // the local node, scanning the known slots.
    // TB_TRUE iff n is in the quorum
    // TB_FALSE iff n is not in the quorum
    // TB_MAYBE iff the quorum cannot be computed
    TriBool isNodeInQuorum(ref NodeID node)
    {
        TriBool res = TriBool.TB_MAYBE;
        foreach (uint64 slotIndex, ref Slot slot; mKnownSlots)
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
    string getValueString(ref Value v)
    {
        return mBCPDriver.getValueString(v);
    }

    string ballotToStr(ref BCPBallot ballot)
    {
        if (ballot.counter == 0)
        {
            return "( , )";
        }
        else
        {
            return format("(%d,%s)", ballot.counter, getValueString(ballot.value));
        }
    }

    string ballotToStr(ref BCPBallot* ballot)
    {
        string res;
        if (ballot)
        {
            res = ballotToStr(*ballot);
        }
        else
        {
            res = "(<null_ballot>)";
        }
        return res;
    }

    string envToStr(ref BCPEnvelope envelope)
    {
        return envToStr(envelope.statement);
    }

    string envToStr(ref BCPStatement st)
    {
        import std.range;

        OutBuffer oBuffer = new OutBuffer();
        Hash qSetHash = Slot.getCompanionQuorumSetHashFromStatement(st);

        oBuffer.writef("{ENV@%s | i: %d", getCPDriver()
                .toShortString(st.nodeID), st.slotIndex);

        switch (st.pledges.type)
        {
        case BCPStatementType.BCP_ST_PREPARE:
            {
                oBuffer.writef(
                        " | PREPARE" ~ " | D: %s" ~ " | b: %s" ~ " | p: %s" ~ " | p: %s" ~ " | c.n: %d" ~ " | h.n: %d ",
                        toHexString(qSetHash.hash)[0 .. 5], ballotToStr(st.pledges.prepare.ballot),
                        ballotToStr(st.pledges.prepare.prepared), ballotToStr(st.pledges.prepare.preparedPrime),
                        st.pledges.prepare.nC, st.pledges.prepare.nH);
            }
            break;

        case BCPStatementType.BCP_ST_CONFIRM:
            {
                oBuffer.writef(" | CONFIRM" ~ " | D: %s" ~ " | b: %s" ~ " | p.n: %d" ~ " | c.n: %d" ~ " | h.n: %d ",
                        toHexString(qSetHash.hash)[0 .. 5], ballotToStr(st.pledges.confirm.ballot),
                        st.pledges.confirm.nPrepared,
                        st.pledges.confirm.nCommit, st.pledges.confirm.nH);
            }
            break;

        case BCPStatementType.BCP_ST_EXTERNALIZE:
            {
                oBuffer.writef(" | EXTERNALIZE" ~ " | c: %s" ~ " | h.n: %d" ~ " | (lastD): %s ",
                        ballotToStr(st.pledges.externalize.commit),
                        st.pledges.externalize.nH, toHexString(qSetHash.hash)[0 .. 5]);
            }
            break;

        case BCPStatementType.BCP_ST_NOMINATE:
            {
                auto nom = &st.pledges.nominate;

                oBuffer.writef(" | NOMINATE" ~ " | D: %s" ~ " | VOTE: {",
                        toHexString(qSetHash.hash)[0 .. 5]);

                bool first = true;
                foreach (int i, ref Value v; nom.votes)
                {
                    if (!first)
                    {
                        oBuffer.write(" ,");
                    }
                    oBuffer.write(getValueString(v));
                    first = false;
                }
                oBuffer.write("}");
                oBuffer.write(" | ACCEPTED: {");

                first = true;
                foreach (int i, ref Value a; nom.accepted)
                {
                    if (!first)
                    {
                        oBuffer.write(" ,");
                    }
                    oBuffer.write(getValueString(a));
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
