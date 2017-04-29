// Written in the D programming language.

module wrapper.sodium.crypto_stream_xsalsa20;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_stream_xsalsa20;

pure @system
unittest
{
  import std.stdio : writeln;
//  import std.range : iota, array;
  debug  writeln("unittest block 1 from sodium.crypto_stream_xsalsa20.d");

//crypto_stream_xsalsa20_keybytes
  assert(crypto_stream_xsalsa20_keybytes()   == crypto_stream_xsalsa20_KEYBYTES);

//crypto_stream_xsalsa20_noncebytes
  assert(crypto_stream_xsalsa20_noncebytes() == crypto_stream_xsalsa20_NONCEBYTES);
}
