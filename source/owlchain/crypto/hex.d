module owlchain.cryto.hex;

import std.exception:enforce;
import owlchain.utils.types:uint256,UINT256_BYTE_LENGTH;
import wrapper.sodium.utils:sodium_hex2bin,sodium_bin2hex;

string binToHex(scope ubyte[] bin)
{
    return sodium_bin2hex(bin);
}

string hexAbbrev(scope ubyte[] bin)
{
    size_t sz = bin.length;
    if (sz > 3)
    {
        sz = 3;
    }
    return binToHex(bin[0 .. sz]);
}

ubyte[] hexToBin(scope string hex,string ignore=null)
{
    ubyte[] bin = new ubyte[]((hex.length/2) + 1);
    size_t  bin_len;
    string  hex_end;

    enforce(sodium_hex2bin(bin, hex, ignore, bin_len, hex_end) == 0);

    return bin;
}

uint256 hexToBin256(scope string hex) 
in 
{
    enforce(hex.length/2 == UINT256_BYTE_LENGTH);
}
body
{
    uint256 result;
    result = hexToBin(hex);
    return result;
}

@system
unittest{
    import std.stdio:writefln;
    string[] hexData = [
        "1234567890",
        "1234567890abcdf",
        "1234567890ABCDF"
    ];
    foreach(string hex; hexData){
        auto bin = hexToBin( hex );
        auto hex2 = binToHex( bin );
        writefln("%s(len(%d)) == binToHex( %s(len(%d)) ))",hex2,hex2.length, bin, bin.length);        
        assert(hex == binToHex( bin ));
    }
    writefln("hexToBin(binToHex((bin)) is done");
}