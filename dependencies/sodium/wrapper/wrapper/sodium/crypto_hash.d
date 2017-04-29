// Written in the D programming language.

module wrapper.sodium.crypto_hash;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_hash : crypto_hash_BYTES,
                                    crypto_hash_bytes,
                                    crypto_hash_PRIMITIVE;
/*                                  crypto_hash_primitive,
                                    crypto_hash; */


string crypto_hash_primitive() pure nothrow @nogc @trusted
{
  import std.string : fromStringz;
  static import deimos.sodium.crypto_hash;
  const(char)[] c_arr;
  try
    c_arr = fromStringz(deimos.sodium.crypto_hash.crypto_hash_primitive()); // strips terminating \0
  catch (Throwable t) { /* known not to throw */ }
  return c_arr;
}


alias crypto_hash = deimos.sodium.crypto_hash.crypto_hash;

pragma(inline, true)
bool crypto_hash(out ubyte[crypto_hash_BYTES] out_, in ubyte[] in_) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash;
  return  deimos.sodium.crypto_hash.crypto_hash(out_.ptr, in_.ptr, in_.length) == 0;
}


@safe
unittest
{
  import std.stdio : writeln, writefln;
  import std.string : representation;
  debug writeln("unittest block 1 from sodium.crypto_hash.d");

  assert(crypto_hash_bytes()     == crypto_hash_BYTES);
  assert(crypto_hash_primitive() == crypto_hash_PRIMITIVE);

  auto message = representation("test");

  ubyte[crypto_hash_BYTES]  hash;
  assert(crypto_hash(hash, message));
//  writefln("0x%(%02X%)", hash);  // 0xEE26B0DD4AF7E749AA1A8EE3C10AE9923F618980772E473F8819A5D4940E0DB27AC185F8A0E1D5F84F88BC887FD67B143732C304CC5FA9AD8E6F57F50028A8FF
}
