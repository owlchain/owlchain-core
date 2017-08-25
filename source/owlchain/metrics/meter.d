module owlchain.metrics.meter;

import std.datetime;
import core.time;
import core.atomic;

import owlchain.meterics.metricInterface;
import owlchain.meterics.meteredInterface;

import owlchain.meterics.metricProcessor;
import owlchain.meterics.ewma;

class Meter : MetricInterface, MeteredInterface
{
public:
    this(string eventType, Duration rateUnit = dur!"seconds"(1))
    {
        mImpl = new Impl(eventType, rateUnit);
    }

    ~this()
    {

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

    void mark(long n = 1)
    {
        mImpl.mark(n);
    }

    void Process(MetricProcessor processor)
    {
        processor.Process(this);
    }

private:
    class Impl
    {
    public:
        this(string eventType, Duration rateUnit = dur!"seconds"(1))
        {
            mEventType = eventType;
            mRateUnit = rateUnit;

            atomicStore(mCount, 0L);

            mStartTime = Clock.currTime();
            atomicStore(mLastTick, 0L);

            mM1Rate = EWMA.oneMinuteEWMA();
            mM5Rate = EWMA.fiveMinuteEWMA();
            mM15Rate = EWMA.fifteenMinuteEWMA();
        }

        ~this()
        {

        }

        Duration rate_unit()
        {
            return mRateUnit;
        }

        string event_type()
        {
            return mEventType;
        }

        long count()
        {
            long value = atomicLoad(mCount);
            return value;
        }

        double fifteen_minute_rate()
        {
            TickIfNecessary();
            return mM15Rate.getRate();
        }

        double five_minute_rate()
        {
            TickIfNecessary();
            return mM5Rate.getRate();
        }

        double one_minute_rate()
        {
            TickIfNecessary();
            return mM1Rate.getRate();
        }

        double mean_rate()
        {
            double c = atomicLoad(mCount);
            if (c > 0)
            {
                Duration elapsed = Clock.currTime() - mStartTime;
                return c * mRateUnit.total!"nsecs" / elapsed.total!"nsecs";
            }
            return 0.0;
        }

        void mark(long n = 1)
        {
            TickIfNecessary();
            atomicOp!"+="(mCount, n);
            mM1Rate.update(n);
            mM5Rate.update(n);
            mM15Rate.update(n);
        }

    private:
        static const auto kTickInterval = dur!"seconds"(5).total!"nsecs";
        string mEventType;
        Duration mRateUnit;

        shared long mCount;
        SysTime mStartTime;
        shared long mLastTick;

        EWMA mM1Rate;
        EWMA mM5Rate;
        EWMA mM15Rate;

        void Tick()
        {
            mM1Rate.tick();
            mM5Rate.tick();
            mM15Rate.tick();
        }

        void TickIfNecessary()
        {
            auto old_tick = atomicLoad(mLastTick);
            auto elapsed = Clock.currTime() - mStartTime;
            auto new_tick = elapsed.total!"nsecs";

            long age = new_tick - old_tick;
            if (age > kTickInterval)
            {
                atomicStore(mLastTick, new_tick);
                auto required_ticks = age / kTickInterval;
                for (auto i = 0; i < required_ticks; i++)
                {
                    Tick();
                }
            }
        }

    };

    Impl mImpl;
}
