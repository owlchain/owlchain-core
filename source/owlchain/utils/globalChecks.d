module owlchain.utils.globalChecks;

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
