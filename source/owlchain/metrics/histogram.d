module owlchain.meterics.histogram;

import core.sync.mutex;
import core.atomic;
import std.typecons;

import owlchain.meterics.metricProcessor;
import owlchain.meterics.metricInterface;
import owlchain.meterics.samplingInterface;
import owlchain.meterics.summarizableInterface;
import owlchain.meterics.snapshot;
import owlchain.meterics.sample;
import owlchain.meterics.expDecaySample;
import owlchain.meterics.uniformSample;

class Histogram : MetricInterface, SamplingInterface, SummarizableInterface
{
public:

    static const double kDefaultAlpha = 0.015;

    this(SampleType type = SampleType.kUniform)
    {
        mImpl = new Impl(type);
    }

    ~this()
    {

    }

    Snapshot getSnapshot()
    {
        return mImpl.getSnapshot();
    }

    double sum()
    {
        return mImpl.sum();
    }

    double max()
    {
        return mImpl.max();
    }

    double min()
    {
        return mImpl.min();
    }

    double mean()
    {
        return mImpl.mean();
    }

    double std_dev()
    {
        return mImpl.std_dev();
    }

    void update(long value)
    {
        mImpl.update(value);
    }

    long count()
    {
        return mImpl.count();
    }

    double variance()
    {
        return mImpl.variance();
    }

    void clear()
    {
        mImpl.clear();
    }

    void Process(MetricProcessor processor)
    {
        processor.Process(this);
    }

private:
    class Impl
    {
    public:
        this(SampleType sample_type = SampleType.kUniform)
        {
            mtx = new Mutex();
            mType = sample_type;
            if (sample_type == SampleType.kUniform)
            {
                mSample = cast(Unique!Sample)(new UniformSample(kDefaultSampleSize));
            }
            else if (sample_type == SampleType.kBiased)
            {
                mSample = cast(Unique!Sample)(new ExpDecaySample(kDefaultSampleSize, kDefaultAlpha));
            }
            else
            {
                throw new Exception("invalid sample_type");
            }
        }

        ~this()
        {

        }

        Snapshot getSnapshot() nothrow
        {
            Snapshot s;
            mtx.lock_nothrow();
            s = mSample.makeSnapshot();
            mtx.unlock_nothrow();
            return s;
        }

        double sum() nothrow
        {
            double value;
            mtx.lock_nothrow();
            value = mSum;
            mtx.unlock_nothrow();
            return value;
        }

        double max() nothrow
        {
            double value;
            mtx.lock_nothrow();
            if (mCount > 0)
            {
                value = mMax;
            }
            else
            {
                value = 0.0;
            }
            mtx.unlock_nothrow();
            return value;
        }

        double min() nothrow
        {
            double value;
            mtx.lock_nothrow();
            if (mCount > 0)
            {
                value = mMin;
            }
            else
            {
                value = 0.0;
            }
            mtx.unlock_nothrow();
            return value;
        }

        double mean() nothrow
        {
            double value;
            mtx.lock_nothrow();
            if (mCount > 0)
            {
                value = mSum / mCount;
            }
            else
            {
                value = 0.0;
            }
            mtx.unlock_nothrow();
            return value;
        }

        double std_dev() nothrow
        {
            import std.math;

            double value;
            mtx.lock_nothrow();
            if (mCount > 0)
            {
                value = sqrt(variance());
            }
            else
            {
                value = 0.0;
            }
            mtx.unlock_nothrow();
            return value;
        }

        void update(long value) nothrow
        {
            mtx.lock_nothrow();
            mSample.update(value);
            if (mCount > 0)
            {
                if (mMax < value)
                    mMax = value;
                if (mMin > value)
                    mMin = value;
            }
            else
            {
                mMax = value;
                mMin = value;
            }
            atomicOp!"+="(mSum, value);
            atomicOp!"+="(mCount, 1);
            auto new_count = mCount;

            auto old_vm = mVarianceM;
            auto old_vs = mVarianceS;
            if (new_count > 1)
            {
                mVarianceM = old_vm + (value - old_vm) / new_count;
                mVarianceS = old_vs + (value - old_vm) * (value - mVarianceM);
            }
            else
            {
                mVarianceM = value;
            }
            mtx.unlock_nothrow();
        }

        long count() nothrow
        {
            long value;
            mtx.lock_nothrow();
            value = mCount;
            mtx.unlock_nothrow();
            return value;
        }

        double variance() nothrow
        {
            double value;
            mtx.lock_nothrow();
            auto c = mCount;
            if (c > 1)
            {
                value = mVarianceS / (c - 1.0);
            }
            else
            {
                value = 0.0;
            }
            mtx.unlock_nothrow();
            return value;
        }

        void clear()
        {
            mtx.lock_nothrow();
            mMin = 0;
            mMax = 0;
            mSum = 0;
            mCount = 0;
            mVarianceM = 0.0;
            mVarianceS = 0.0;
            mtx.unlock_nothrow();
            mSample.clear();
        }

    private:
        static const ulong kDefaultSampleSize = 1028;
        Unique!Sample mSample;
        shared long mMin;
        shared long mMax;
        shared long mSum;
        shared long mCount;
        shared double mVarianceM;
        shared double mVarianceS;

        Mutex mtx;
        SampleType mType;

    }

    Impl mImpl;
}
