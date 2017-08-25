module owlchain.meterics.util;

import std.datetime;
import core.time;

static const long NS_PER_US = 1000;
static const long NS_PER_MS = 1000 * NS_PER_US;
static const long NS_PER_SECOND = 1000 * NS_PER_MS;
static const long NS_PER_MIN = 60 * NS_PER_SECOND;
static const long NS_PER_HOUR = 60 * NS_PER_MIN;
static const long NS_PER_DAY = 24 * NS_PER_HOUR;

string FormatRateUnit(Duration rate_unit)
{
    auto nanosecs = rate_unit.total!"nsecs";

    if (nanosecs >= NS_PER_DAY)
    {
        return "d";
    }
    else if (nanosecs >= NS_PER_HOUR)
    {
        return "h";
    }
    else if (nanosecs >= NS_PER_MIN)
    {
        return "m";
    }
    else if (nanosecs >= NS_PER_SECOND)
    {
        return "s";
    }
    else if (nanosecs >= NS_PER_MS)
    {
        return "ms";
    }
    else if (nanosecs >= NS_PER_US)
    {
        return "us";
    }
    return "ns";
}
