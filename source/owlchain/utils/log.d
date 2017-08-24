module owlchain.utils.log;

import std.experimental.logger;
import owlchain.utils.config;

private static FileLogger _logger;

static FileLogger flog()
{
    if (_logger is null)
    {
        _logger = new FileLogger(config.logFile);
    }
    return _logger;
}

@("log")
@system unittest
{
    flog.log("test");
}

// alias log       = flogger.log;
// alias trace     = flogger.trace;
// alias info      = flogger.info;
// alias warning   = flogger.warning;
// alias critical  = flogger.critical;

// alias fatalf    = flogger.fatalf;
// alias logf      = flogger.logf;
// alias tracef    = flogger.tracef;
// alias infof     = flogger.infof;
// alias warningf  = flogger.warningf;
// alias criticalf = flogger.criticalf;
// alias fatalf    = flogger.fatalf;
