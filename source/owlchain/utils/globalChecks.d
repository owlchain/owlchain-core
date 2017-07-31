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