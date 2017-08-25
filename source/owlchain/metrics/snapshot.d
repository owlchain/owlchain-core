module owlchain.meterics.snapshot;

class Snapshot
{
public:
    static const double kMEDIAN_Q = 0.5;
    static const double kP75_Q = 0.75;
    static const double kP95_Q = 0.95;
    static const double kP98_Q = 0.98;
    static const double kP99_Q = 0.99;
    static const double kP999_Q = 0.999;

    this(ref double[] values)
    {
        mImpl = new Impl(values);
    }

    this(ref Snapshot other)
    {
        mImpl = other.mImpl;
        other.mImpl = null;
    }

    ~this()
    {

    }

    void checkImpl()
    {
        if (!mImpl)
        {
            throw new Exception("Access to moved Snapshot::impl_");
        }
    }

    long size()
    {
        checkImpl();
        return mImpl.size();
    }

    double[] getValues()
    {
        checkImpl();
        return mImpl.getValues();
    }

    double getValue(double quantile)
    {
        checkImpl();
        return mImpl.getValue(quantile);
    }

    double getMedian()
    {
        checkImpl();
        return mImpl.getMedian();
    }

    double get75thPercentile()
    {
        checkImpl();
        return mImpl.get75thPercentile();
    }

    double get95thPercentile()
    {
        checkImpl();
        return mImpl.get95thPercentile();
    }

    double get98thPercentile()
    {
        checkImpl();
        return mImpl.get98thPercentile();
    }

    double get99thPercentile()
    {
        checkImpl();
        return mImpl.get99thPercentile();
    }

    double get999thPercentile()
    {
        checkImpl();
        return mImpl.get999thPercentile();
    }

private:
    class Impl
    {
    public:
        this(ref double[] values)
        {
            import std.algorithm : sort;

            mValues = values.dup;
            mValues.sort!("a < b").release;
        }

        ~this()
        {

        }

        long size()
        {
            return mValues.length;
        }

        double getValue(double quantile)
        {
            import std.math;

            if (quantile < 0.0 || quantile > 1.0)
            {
                throw new Exception("quantile is not in [0..1]");
            }

            if (mValues.length == 0)
            {
                return 0.0;
            }

            auto pos = quantile * (mValues.length + 1);

            if (pos < 1)
            {
                return mValues[0];
            }

            if (pos >= mValues.length)
            {
                return mValues[$ - 1];
            }

            double lower = mValues[cast(long) pos - 1];
            double upper = mValues[cast(long) pos];
            return lower + (pos - floor(pos)) * (upper - lower);
        }

        double getMedian()
        {
            return getValue(kMEDIAN_Q);
        }

        double get75thPercentile()
        {
            return getValue(kP75_Q);
        }

        double get95thPercentile()
        {
            return getValue(kP95_Q);
        }

        double get98thPercentile()
        {
            return getValue(kP98_Q);
        }

        double get99thPercentile()
        {
            return getValue(kP99_Q);
        }

        double get999thPercentile()
        {
            return getValue(kP999_Q);
        }

        double[] getValues()
        {
            return mValues;
        }

    private:
        double[] mValues;
    }

    Impl mImpl;
}
