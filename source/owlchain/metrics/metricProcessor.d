module owlchain.metrics.metricProcessor;

import owlchain.metrics.counter;
import owlchain.metrics.Meter;
import owlchain.metrics.Timer;
/*
import owlchain.metrics.Historgam;
import owlchain.metrics.MetricInterface;
*/

interface MetricProcessor
{
	void process(Counter counter);
	void process(Meter meter);	
	void process(Timer timer);
// TODO : Converting....
/**
	void process(Historgam histogram);	
	void process(MetricInterface metric);
*/
}