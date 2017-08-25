module owlchain.meterics.metricsRegistry;

import core.sync.mutex;
import std.typecons;
import core.time;
import owlchain.meterics.counter;
import owlchain.meterics.histogram;
import owlchain.meterics.meter;
import owlchain.meterics.timer;
import owlchain.meterics.metricInterface;
import owlchain.meterics.samplingInterface;
import owlchain.meterics.metricName;

class MetricsRegistry
{
public:
    this()
    {
        mImpl = new Impl();
    }

    ~this()
    {

    }

    Counter NewCounter(MetricName name, long init_value = 0)
    {
        return mImpl.NewCounter(name, init_value);
    }

    Histogram NewHistogram(MetricName name, SampleType sample_type = SampleType.kUniform)
    {
        return mImpl.NewHistogram(name, sample_type);
    }

    Meter NewMeter(MetricName name, string event_type, Duration rate_unit = dur!"seconds"(1))
    {
        return mImpl.NewMeter(name, event_type, rate_unit);
    }

    Timer NewTimer(MetricName name, Duration duration_unit = dur!"msecs"(1),
				   Duration rate_unit = dur!"seconds"(1))
    {
        return mImpl.NewTimer(name, duration_unit, rate_unit);
    }

    MetricInterface[MetricName] GetAllMetrics()
    {
        return mImpl.GetAllMetrics();
    }

private:
    class Impl
    {

    public:
        this()
        {
            mtx = new Mutex();
        }

        ~this()
        {

        }

        Counter NewCounter(MetricName name, long init_value = 0)
        {
            auto p = name in mMetrics;

            if (p is null)
            {
                mMetrics[name] = new Counter(init_value);
            }

            return cast(Counter) mMetrics[name];
        }

        Histogram NewHistogram(MetricName name, SampleType sample_type = SampleType.kUniform)
        {
            auto p = name in mMetrics;

            if (p is null)
            {
                mMetrics[name] = new Histogram(sample_type);
            }

            return cast(Histogram) mMetrics[name];
        }

        Meter NewMeter(MetricName name, string event_type, Duration rate_unit = dur!"seconds"(1))
        {
            auto p = name in mMetrics;

            if (p is null)
            {
                mMetrics[name] = new Meter(event_type, rate_unit);
            }

            return cast(Meter) mMetrics[name];
        }

        Timer NewTimer(MetricName name, Duration duration_unit = dur!"msecs"(1),
					   Duration rate_unit = dur!"seconds"(1))
        {
            auto p = name in mMetrics;

            if (p is null)
            {
                mMetrics[name] = new Timer(duration_unit, rate_unit);
            }

            return cast(Timer) mMetrics[name];
        }

        MetricInterface[MetricName] GetAllMetrics()
        {
            return mMetrics;
        }

    private:

        MetricInterface[MetricName] mMetrics;
        Mutex mtx;

    }

    Impl mImpl;
}
