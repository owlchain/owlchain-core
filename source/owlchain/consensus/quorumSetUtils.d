module owlchain.consensus.quorumSetUtils;

import std.stdio;
import std.algorithm : canFind;

import owlchain.xdr.publicKey;
import owlchain.xdr.nodeID;
import owlchain.xdr.quorumSet;

class QuorumSetSanityChecker
{

private:

    bool mExtraChecks;
    int[PublicKey] mKnownNodes;
    bool mIsSane;
    int mCount;

    bool checkSanity(ref const QuorumSet qSet, int depth)
    {
        if (depth > 2)
            return false;

        if (qSet.threshold < 1)
            return false;

        auto v = qSet.validators;
        auto i = qSet.innerSets;

        size_t totEntries = v.length + i.length;
        size_t vBlockingSize = totEntries - qSet.threshold + 1;
        mCount += v.length;

        if (qSet.threshold > totEntries)
            return false;

        // threshold is within the proper range
        if (mExtraChecks && (qSet.threshold < vBlockingSize))
            return false;

        int idx;
        for (idx = 0; idx < v.length; idx++)
        {
            PublicKey n = v[idx];

            if (mKnownNodes.keys.canFind(n))
            {
                // n was already present
                return false;
            }
            else
            {
                mKnownNodes[n] = 1;
            }
        }

        for (idx = 0; idx < i.length; idx++)
        {
            if (!checkSanity(i[idx], depth + 1))
            {
                return false;
            }
        }

        return true;
    }

public:

    this(ref QuorumSet qSet, bool extraChecks)
    {
        mCount = 0;
        mExtraChecks = extraChecks;
        mIsSane = checkSanity(qSet, 0) && (mCount >= 1) && (mCount <= 1000);
    }

    bool isSane()
    {
        return mIsSane;
    }
}

bool isQuorumSetSane(ref QuorumSet qSet, bool extraChecks)
{
    QuorumSetSanityChecker checker = new QuorumSetSanityChecker(qSet, extraChecks);
    return checker.isSane();
}

// helper function that:
//  * simplifies singleton inner set into outerset
//      { t: n, v: { ... }, { t: 1, X }, ... }
//        into
//      { t: n, v: { ..., X }, .... }
//  * simplifies singleton innersets
//      { t: 1, { innerSet } } into innerSet

void normalizeQSet(ref QuorumSet qSet)
{
    auto v = &qSet.validators;
    auto i = &qSet.innerSets;

    int idx = 0;
    while (idx < (*i).length)
    {
        normalizeQSet((*i)[idx]);
        // merge singleton inner sets into validator list
        if (((*i)[idx].threshold == 1) && ((*i)[idx].validators.length == 1)
                && ((*i)[idx].innerSets.length == 0))
        {
            (*v) ~= (*i)[idx].validators[0];
            (*i) = (*i)[0 .. idx] ~ (*i)[idx + 1 .. $];
        }
        else
        {
            idx++;
        }
    }

    // simplify quorum set if needed
    if ((qSet.threshold == 1) && (qSet.validators.length == 0) && (qSet.innerSets.length == 1))
    {
        qSet = qSet.innerSets[0];
    }

}
