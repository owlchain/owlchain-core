module owlchain.meterics.expDecaySample;

import std.datetime;
import core.sync.mutex;
import std.math;
import std.algorithm.comparison;

import core.atomic;
import owlchain.meterics.snapshot;
import owlchain.meterics.sample;

class ExpDecaySample : Sample
{
public:
    static const Duration kRESCALE_THRESHOLD = dur!"hours"(1);

    this(uint reservoirSize, double alpha)
    {
        mImpl = new Impl(reservoirSize, alpha);
    }

    override void clear()
    {
        mImpl.clear();
    }

    override long size()
    {
        return mImpl.size();
    }

    override void update(long value) nothrow
    {
        mImpl.update(value);
    }

    void update(long value, SysTime timestamp) nothrow
    {
        mImpl.update(value, timestamp);
    }

    override Snapshot makeSnapshot() nothrow
    {
        return mImpl.makeSnapshot();
    }

private:
    class Impl
    {
    public:
        this(uint reservoirSize, double alpha)
        {
            mtx = new Mutex();

            mAlpha = alpha;
            mReservoirSize = reservoirSize;
        }

        void clear()
        {
            mtx.lock_nothrow();
            mValues.clear();
            mCount = 0;
            mStartTime = Clock.currTime();
            mNextScaleTime = mStartTime + kRESCALE_THRESHOLD;
            mtx.unlock_nothrow();
        }

        long size()
        {
            return min(mReservoirSize, atomicLoad(mCount));
        }

        void update(long value) nothrow
        {
            try
            {
                update(value, Clock.currTime());
            }
            catch (Exception)
            {
            }
        }

        void update(long value, SysTime timestamp) nothrow
        {
            import std.random;

            mtx.lock_nothrow();
            try
            {
                if (timestamp >= mNextScaleTime)
                {
                    rescale(timestamp);
                }
                auto dur = timestamp - mStartTime;

                Random gen;
                auto priority = exp(mAlpha * dur.total!"nsecs") / uniform(0.0L, 1.0L, gen);
                atomicOp!"+="(mCount, 1);
                auto count = mCount;

                if (mCount <= mReservoirSize)
                {
                    mValues[priority] = value;
                }
                else
                {
                    if (mValues.length > 0)
                    {
                        auto firstKey = mValues.keys[0];
                        if (firstKey < priority)
                        {
                            auto p = priority in mValues;
                            if (p is null)
                            {
                                mValues[priority] = value;
                                while (!mValues.remove(firstKey))
                                {
                                    firstKey = mValues.keys[0];
                                }
                            }
                            else
                            {
                                *p = value;
                            }
                        }
                    }
                    else
                    {
                        mValues[priority] = value;
                    }
                }
            }
            catch (Exception E)
            {
            }
            mtx.unlock_nothrow();
        }

        Snapshot makeSnapshot() nothrow
        {
            double[] vals;
            Snapshot snapshot;
            try
            {
                foreach (double k, long v; mValues)
                {
                    vals ~= v;
                }
                snapshot = new Snapshot(vals);
            }
            catch (Exception)
            {
            }
            return snapshot;
        }

    private:
        double mAlpha;
        uint mReservoirSize;
        SysTime mStartTime;
        SysTime mNextScaleTime;

        shared long mCount;
        long[double] mValues;
        Mutex mtx;
        void rescale(SysTime when) nothrow
        {
            mtx.lock_nothrow();
            try
            {
                mNextScaleTime = when + kRESCALE_THRESHOLD;
                const auto oldStartTime = mStartTime;
                mStartTime = when;
                const ulong size = mValues.length;
                double[] keys;
                long[] values;

                foreach (double k, long v; mValues)
                {
                    keys ~= k;
                    values ~= v;
                }
                mValues.clear;

                for (long i = 0; i < size; i++)
                {
                    Duration dur = (when - oldStartTime);
                    auto key = keys[i] * exp(-mAlpha * dur.total!"msecs");
                    mValues[key] = values[i];
                }
                mCount = mValues.length;

            }
            catch (Exception E)
            {
            }
            mtx.unlock_nothrow();
        }

    }

    Impl mImpl;
}
