module owlchain.meterics.metricProcessor;

import owlchain.meterics.counter;
import owlchain.meterics.histogram;
import owlchain.meterics.meter;
import owlchain.meterics.timer;
import owlchain.meterics.metricInterface;

interface MetricProcessor
{
    void Process(Counter counter);
    void Process(Histogram histogram);
    void Process(Meter meter);
    void Process(Timer timer);
    void Process(MetricInterface metric);
}
