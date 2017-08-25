module owlchain.meterics.meteredInterface;

import core.time;
import owlchain.meterics.metricProcessor;

interface MeteredInterface
{
    Duration rate_unit();
    string event_type();
    long count();
    double fifteen_minute_rate();
    double five_minute_rate();
    double one_minute_rate();
    double mean_rate();
}
