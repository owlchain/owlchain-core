module owlchain.meterics.consoleReporter;

import std.outbuffer;
import std.datetime;
import core.time;

import owlchain.meterics.abstractPollingReporter;
import owlchain.meterics.metricProcessor;
import owlchain.meterics.metricName;
import owlchain.meterics.counter;
import owlchain.meterics.histogram;
import owlchain.meterics.meter;
import owlchain.meterics.timer;
import owlchain.meterics.metricInterface;
import owlchain.meterics.metricsRegistry;
import owlchain.meterics.util;

class ConsoleReporter : AbstractPollingReporter, MetricProcessor
{
public:
    this(MetricsRegistry registry, OutBuffer obuffer)
    {
        mImpl = new Impl(this, registry, obuffer);
        super();
    }

    ~this()
    {
    }

    void Run()
    {
        mImpl.Run();
    }

    void Process(Counter counter)
    {
        mImpl.Process(counter);
    }

    void Process(Histogram histogram)
    {
        mImpl.Process(histogram);
    }

    void Process(Meter meter)
    {
        mImpl.Process(meter);
    }

    void Process(Timer timer)
    {
        mImpl.Process(timer);
    }

    void Process(MetricInterface metric)
    {
    }

private:

    class Impl
    {
    public:
        this(ConsoleReporter self, MetricsRegistry registry, OutBuffer obuffer)
        {
            mSelf = self;
            mRegistry = registry;
            mOBuffer = obuffer;
        }

        ~this()
        {

        }

        void Run()
        {
            foreach (ref const(MetricName) name, ref MetricInterface value; mRegistry.GetAllMetrics())
            {
                mOBuffer.writefln("%s:", name.ToString());
                value.Process(mSelf);
            }
            mOBuffer.writefln("");
        }

        void Process(Counter counter)
        {
            mOBuffer.writefln("count = %d", counter.count());
        }

        void Process(Meter meter)
        {
            auto event_type = meter.event_type();
            auto unit = FormatRateUnit(meter.rate_unit());

            mOBuffer.writefln("           count = %d", meter.count());
            mOBuffer.writefln("       mean rate = %f %s/%s", meter.mean_rate(), event_type, unit);
            mOBuffer.writefln("   1-minute rate = %f %s/%s",
							  meter.one_minute_rate(), event_type, unit);
            mOBuffer.writefln("   5-minute rate = %f %s/%s",
							  meter.five_minute_rate(), event_type, unit);
            mOBuffer.writefln("  15-minute rate = %f %s/%s",
							  meter.fifteen_minute_rate(), event_type, unit);
        }

        void Process(Histogram histogram)
        {
            auto snapshot = histogram.getSnapshot();
            mOBuffer.writefln("             min = %f", histogram.min());
            mOBuffer.writefln("             max = %f", histogram.max());
            mOBuffer.writefln("            mean = %f", histogram.mean());
            mOBuffer.writefln("          stddev = %f", histogram.std_dev());
            mOBuffer.writefln("          median = %f", snapshot.getMedian());
            mOBuffer.writefln("             75% = %f", snapshot.get75thPercentile());
            mOBuffer.writefln("             95% = %f", snapshot.get95thPercentile());
            mOBuffer.writefln("             98% = %f", snapshot.get98thPercentile());
            mOBuffer.writefln("             99% = %f", snapshot.get99thPercentile());
            mOBuffer.writefln("           99.9% = %f", snapshot.get999thPercentile());
        }

        void Process(Timer timer)
        {
            auto snapshot = timer.getSnapshot();
            auto event_type = timer.event_type();
            auto unit = FormatRateUnit(timer.duration_unit());
            mOBuffer.writefln("           count = %d", timer.count());
            mOBuffer.writefln("       mean rate = %f %s/%s", timer.mean_rate(), event_type, unit);
            mOBuffer.writefln("   1-minute rate = %f %s/%s",
							  timer.one_minute_rate(), event_type, unit);
            mOBuffer.writefln("   5-minute rate = %f %s/%s",
							  timer.five_minute_rate(), event_type, unit);
            mOBuffer.writefln("  15-minute rate = %f %s/%s",
							  timer.fifteen_minute_rate(), event_type, unit);
            mOBuffer.writefln("             min = %f %s", timer.min(), unit);
            mOBuffer.writefln("             max = %f %s", timer.max(), unit);
            mOBuffer.writefln("            mean = %f %s", timer.mean(), unit);
            mOBuffer.writefln("          stddev = %f %s", timer.std_dev(), unit);
            mOBuffer.writefln("          median = %f %s", snapshot.getMedian(), unit);
            mOBuffer.writefln("             75% = %f %s", snapshot.get75thPercentile(), unit);
            mOBuffer.writefln("             95% = %f %s", snapshot.get95thPercentile(), unit);
            mOBuffer.writefln("             98% = %f %s", snapshot.get98thPercentile(), unit);
            mOBuffer.writefln("             99% = %f %s", snapshot.get99thPercentile(), unit);
            mOBuffer.writefln("           99.9% = %f %s", snapshot.get999thPercentile(), unit);
        }

    private:
        ConsoleReporter mSelf;
        MetricsRegistry mRegistry;
        OutBuffer mOBuffer;

        string FormatRateUnit(Duration rate_unit)
        {
            static auto one_day = dur!"hours"(24).total!"nsecs";
            static auto one_hour = dur!"hours"(1).total!"nsecs";
            static auto one_minute = dur!"minutes"(1).total!"nsecs";
            static auto one_seconds = dur!"seconds"(1).total!"nsecs";
            static auto one_millisecond = dur!"msecs"(1).total!"nsecs";
            static auto one_microsecond = dur!"usecs"(1).total!"nsecs";

            auto unit_count = rate_unit.total!"nsecs";

            if (unit_count >= one_day)
            {
                return "d";
            }
            else if (unit_count >= one_hour)
            {
                return "h";
            }
            else if (unit_count >= one_minute)
            {
                return "m";
            }
            else if (unit_count >= one_seconds)
            {
                return "s";
            }
            else if (unit_count >= one_millisecond)
            {
                return "ms";
            }
            else if (unit_count >= one_microsecond)
            {
                return "us";
            }
            return "ns";

        }
    }

    Impl mImpl;
}
