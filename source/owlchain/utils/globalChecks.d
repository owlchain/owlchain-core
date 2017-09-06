module owlchain.utils.globalChecks;

import std.stdio;
import std.system;

void assertThreadIsMain()
{

}

void dbgAbort()
{
    static if ((os == OS.win32) || (os == OS.win64))
    {
        import core.sys.windows.winbase;
        DebugBreak();
    }
    else
    {
        import core.stdc.stdlib;
        abort();
    }
}

debug(1) 
{ 
    void dbgAssert(bool expression)
    {
        if (!(expression)) {
            dbgAbort();
        }
    }
}
else
{
    void dbgAssert(bool expression) { }
}

void REQUIRE(bool condition)
{
    if (!condition)
    {
        writefln("REQUIRE Does not match.");
    }

}

void SECTION(string title)
{
    writefln("SECTION : %s", title);
}

void TEST_CASE(string title, string subtitle)
{
    writefln("TEST_CASE : %s %s", title, subtitle);
}
enum LEVEL
{
    GLOBAL = 1,
    TRACE = 2,
    DEBUG = 4,
    FATAL = 8,
    ERROR = 16,
    WARNING = 32,
    VERBOSE = 64,
    INFO = 128,
    UNKNOWN = 1010
}

void CLOG(LEVEL level, string title, string message)
{
    string value;

    switch(level) {
        case LEVEL.GLOBAL : 
            value = "G";
            break;
        case LEVEL.TRACE : 
            value = "T";
            break;
        case LEVEL.DEBUG : 
            value = "D";
            break;
        case LEVEL.FATAL : 
            value = "F";
            break;
        case LEVEL.ERROR : 
            value = "E";
            break;
        case LEVEL.WARNING : 
            value = "W";
            break;
        case LEVEL.VERBOSE : 
            value = "V";
            break;
        case LEVEL.INFO : 
            value = "I";
            break;
        case LEVEL.UNKNOWN : 
            value = "U";
            break;
        default :
            value = " ";
    }
    writefln("[%s], %s %s", value, title, message);
}