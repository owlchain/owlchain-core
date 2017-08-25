module owlchain.meterics.timer;

import core.time;
import owlchain.meterics.metricInterface;
import owlchain.meterics.meteredInterface;
import owlchain.meterics.samplingInterface;
import owlchain.meterics.summarizableInterface;

import owlchain.meterics.metricProcessor;
import owlchain.meterics.histogram;
import owlchain.meterics.meter;
import owlchain.meterics.snapshot;

class Timer : MetricInterface, MeteredInterface, SamplingInterface, SummarizableInterface
{

public:
    this(Duration durationUnit = dur!"msecs"(1), Duration rateUnit = dur!"seconds"(1))
    {
        mImpl = new Impl(this, durationUnit, rateUnit);
    }

    ~this()
    {

    }

    void Process(MetricProcessor processor)
    {
        return mImpl.Process(processor);
    }

    Duration duration_unit()
    {
        return mImpl.duration_unit();
    }

    Duration rate_unit()
    {
        return mImpl.rate_unit();
    }

    string event_type()
    {
        return mImpl.event_type();
    }

    long count()
    {
        return mImpl.count();
    }

    double fifteen_minute_rate()
    {
        return mImpl.fifteen_minute_rate();
    }

    double five_minute_rate()
    {
        return mImpl.five_minute_rate();
    }

    double one_minute_rate()
    {
        return mImpl.one_minute_rate();
    }

    double mean_rate()
    {
        return mImpl.mean_rate();
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

    void update(Duration duration)
    {
        mImpl.update(duration);
    }

    void clear()
    {
        mImpl.clear();
    }

private:
    class Impl
    {
    public:
        this(Timer self, Duration durationUnit = dur!"msecs"(1),
			 Duration rateUnit = dur!"seconds"(1))
        {
            mSelf = self;
            mDurationUnit = durationUnit;
            mRateUnit = rateUnit;
            mDurationUnitNanos = mDurationUnit.total!"nsecs";

            mMeter = new Meter("calls", rateUnit);
            mHistogram = new Histogram(SampleType.kBiased);
        }

        ~this()
        {

        }

        void Process(MetricProcessor processor)
        {
            processor.Process(mSelf);
        }

        Duration duration_unit()
        {
            return mDurationUnit;
        }

        Duration rate_unit()
        {
            return mRateUnit;
        }

        string event_type()
        {
            return mMeter.event_type();
        }

        long count()
        {
            return mHistogram.count();
        }

        double fifteen_minute_rate()
        {
            return mMeter.fifteen_minute_rate();
        }

        double five_minute_rate()
        {
            return mMeter.five_minute_rate();
        }

        double one_minute_rate()
        {
            return mMeter.one_minute_rate();
        }

        double mean_rate()
        {
            return mMeter.mean_rate();
        }

        Snapshot getSnapshot()
        {
            return mHistogram.getSnapshot();
        }

        double sum()
        {
            return mHistogram.sum() / mDurationUnitNanos;
        }

        double max()
        {
            return mHistogram.max() / mDurationUnitNanos;
        }

        double min()
        {
            return mHistogram.min() / mDurationUnitNanos;
        }

        double mean()
        {
            return mHistogram.mean() / mDurationUnitNanos;
        }

        double std_dev()
        {
            return mHistogram.std_dev() / mDurationUnitNanos;

        }

        void update(Duration duration)
        {
            auto count = duration.total!"nsecs";
            if (count >= 0)
            {
                mHistogram.update(count);
                mMeter.mark();
            }
        }

        void clear()
        {
            mHistogram.clear();
        }

    private:
        Timer mSelf;
        Duration mDurationUnit;
        long mDurationUnitNanos;
        Duration mRateUnit;
        Meter mMeter;
        Histogram mHistogram;
    }

    Impl mImpl;
}
