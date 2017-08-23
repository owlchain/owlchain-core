module owlchain.metrics.metricProcessor;

import owlchain.metrics.counter;

// TODO : Converting....
/*
import owlchain.metrics.Historgam;
import owlchain.metrics.Meter;
import owlchain.metrics.Timer;
import owlchain.metrics.MetricInterface;
*/

interface MetricProcessor
{
	void process(Counter counter);
	// TODO : Converting....
	/**
	void process(Historgam histogram);
	void process(Meter meter);
	void process(Timer timer);
	void process(MetricInterface metric);
	*/
}