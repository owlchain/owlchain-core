module owlchain.base.types;

import std.format : format, FormatSpec;
public import gfm.integers.wideint:
    int128,
    uint128,
    int256,
    uint256;

string toHexUpper(T)(T val)
{
    return format("%X", val);
}

string toHexLower(T)(T val)
{
    return format("%x", val);
}

alias toHex = toHexUpper;

@("int256")
@system
unittest {
    import std.stdio: writefln;
    auto y = int256.literal!"0xf1f2f3f4f5f6f7f8f9f0_f1f2f3f4f5f6f7f8f9f0_f1f2f3f4f5f6f7f8f9f0_f0f1"; // 256bit integer
    writefln( "y.toHex: " ~ y.toHex);
    assert( y.toHexLower == "f1f2f3f4f5f6f7f8f9f0f1f2f3f4f5f6f7f8f9f0f1f2f3f4f5f6f7f8f9f0f0f1"); 
    assert( y.toHexUpper == "F1F2F3F4F5F6F7F8F9F0F1F2F3F4F5F6F7F8F9F0F1F2F3F4F5F6F7F8F9F0F0F1"); 
    assert( y.toHex == "F1F2F3F4F5F6F7F8F9F0F1F2F3F4F5F6F7F8F9F0F1F2F3F4F5F6F7F8F9F0F0F1"); 

    int x = 0xf0f0f0f0;
    assert( x.toHex == "F0F0F0F0" );
}
