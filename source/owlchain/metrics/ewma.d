module owlchain.meterics.ewma;
import std.math;
import core.atomic;
import core.time;
import core.sync.mutex;
import owlchain.meterics.metricProcessor;
import owlchain.meterics.metricInterface;

class EWMA
{
public:
    this(double alpha, Duration interval)
    {
        mImpl = new Impl(alpha, interval);
    }

    this(ref EWMA other)
    {
        mImpl = new Impl(other.mImpl);
    }

    ~this()
    {

    }

    static EWMA oneMinuteEWMA()
    {
        const double alpha = 1 - exp(-5.0 / 60.0 / 1.0);
        return new EWMA(alpha, dur!"seconds"(5));
    }

    static EWMA fiveMinuteEWMA()
    {
        const double alpha = 1 - exp(-5.0 / 60.0 / 5.0);
        return new EWMA(alpha, dur!"seconds"(5));
    }

    static EWMA fifteenMinuteEWMA()
    {
        const double alpha = 1 - exp(-5.0 / 60.0 / 15.0);
        return new EWMA(alpha, dur!"seconds"(5));
    }

    void update(long n)
    {
        mImpl.update(n);
    }

    void tick()
    {
        mImpl.tick();
    }

    double getRate(Duration duration = dur!"seconds"(1))
    {
        return mImpl.getRate(duration);
    }

private:

    class Impl
    {
    public:

        this(double alpha, Duration interval)
        {
            mInitialized = false;
            mRate = 0.0;
            atomicStore(mUncounted, 0L);
            mAlpha = alpha;
            mIntervalNanos = interval.total!"nsecs";
        }

        this(ref Impl other)
        {
            mInitialized = other.mInitialized;
            mRate = other.mRate;
            atomicStore(mUncounted, atomicLoad(other.mUncounted));
            mAlpha = other.mAlpha;
            mIntervalNanos = other.mIntervalNanos;
        }

        ~this()
        {

        }

        void update(long n) @safe nothrow
        {
            atomicOp!"+="(mUncounted, n);
        }

        void tick() @safe nothrow
        {
            double count;

            count = atomicLoad(mUncounted);
            atomicStore(mUncounted, 0L);

            const auto instantRate = count / mIntervalNanos;
            if (mInitialized)
            {
                mRate += (mAlpha * (instantRate - mRate));
            }
            else
            {
                mRate = instantRate;
                mInitialized = true;
            }
        }

        double getRate(Duration duration = dur!"seconds"(1))
        {
            return mRate * duration.total!"nsecs";
        }

    private:
        Mutex mtx;
        bool mInitialized;
        double mRate;
        shared long mUncounted;
        double mAlpha;
        long mIntervalNanos;
    }

    Impl mImpl;
}
