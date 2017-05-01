module owlchain.base.types;

import std.format : FormatSpec;
public import gfm.integers.wideint:
    int128,
    uint128,
    int256,
    uint256;

//enum UINT256_BYTE_LENGTH=int256.sizeof;

string toHex(T)(T val, DG sink)
    if(typeof(val.init) in [uint256, int256, int128])
{
    FormatSpec!char fspec;
    fspec.spec = 'x';
    val.toString(sink, fspec);
}

alias DG = void function(const char[] v);

// void toHex(int256 v, DG dg){
//     FormatSpec!char fspec;
//     fspec.spec = 'x';
    
//     v.toString(dg, fspec); 
// }

@system
unittest {
    auto x = int128.literal!"0x111";
    enum xd = "0x1123342223";
    auto y = int256.literal!xd;
    
    FormatSpec!char fspec;
    fspec.spec = 'x';
    y.toString((const char[] x){
        import std.stdio:writefln;
        writefln(x);
    },
    fspec);
}
