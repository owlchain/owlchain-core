module owlchain.meterics.uniformSample;

import std.datetime;
import core.sync.mutex;
import std.math;
import std.algorithm.comparison;

import core.atomic;
import owlchain.meterics.snapshot;
import owlchain.meterics.sample;

class UniformSample : Sample
{
public:
    static const Duration kRESCALE_THRESHOLD = dur!"hours"(1);

    this(uint reservoirSize)
    {
        mImpl = new Impl(reservoirSize);
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

    override Snapshot makeSnapshot()
    {
        return mImpl.makeSnapshot();
    }

private:
    class Impl
    {
    public:
        this(uint reservoirSize)
        {
            mtx = new Mutex();
            mValues.length = reservoirSize;
            clear();
        }

        void clear()
        {
            mtx.lock_nothrow();

            for (int k; k < mValues.length; k++)
            {
                mValues[k] = 0;
            }
            mCount = 0;
            mtx.unlock_nothrow();
        }

        long size()
        {
            return min(mValues.length, atomicLoad(mCount));
        }

        void update(long value) nothrow
        {
            import std.random;

            mtx.lock_nothrow();
            try
            {
                atomicOp!"+="(mCount, 1);
                auto count = mCount;
                auto size = mValues.length;

                if (count < size)
                {
                    mValues[count - 1] = value;
                }
                else
                {
                    Random gen;
                    auto rand = uniform(0, count - 1, gen);
                    if (rand < size)
                    {
                        mValues[rand] = value;
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
            mtx.lock_nothrow();
            try
            {
                for (int k; k < min(mCount, mValues.length); k++)
                {
                    vals ~= mValues[k];
                }
                snapshot = new Snapshot(vals);
            }
            catch (Exception)
            {
            }
            mtx.unlock_nothrow();
            return snapshot;
        }

    private:
        shared long mCount;
        long[] mValues;
        Mutex mtx;

    }

    Impl mImpl;
}
