module wrapper.sodium.crypto_verify_64;

import wrapper.sodium.core; // assure sodium got initialized

public import  deimos.sodium.crypto_verify_64;

// overloading a functions between module deimos.sodium.crypto_verify_64 and this module

alias crypto_verify_64 = deimos.sodium.crypto_verify_64.crypto_verify_64;

/** Secrets are always compared in constant time using sodium_memcmp() or crypto_verify_(16|32|64)()
 * @returns 0 if the len bytes pointed to by x match the len bytes pointed to by y.
 * Otherwise, it returns -1.
 */
int crypto_verify_64(in ubyte[crypto_verify_64_BYTES] x, in ubyte[crypto_verify_64_BYTES] y) pure nothrow @nogc @trusted
{
  return deimos.sodium.crypto_verify_64.crypto_verify_64(x.ptr, y.ptr);
}


pure @system
unittest
{
  import std.stdio : writeln;
  import std.range : iota, array;
  debug  writeln("unittest block 1 from sodium.crypto_verify_64.d");

//crypto_verify_64
  ubyte[] buf1 = array(iota(ubyte(1), cast(ubyte)(1+crypto_verify_64_BYTES)));
  ubyte[] buf2 = buf1.dup;
  assert(crypto_verify_64(buf1.ptr, buf2.ptr) ==  0);
  buf2[$-1] = 65;
  assert(crypto_verify_64(buf1.ptr, buf2.ptr) == -1);
}

pure @safe
unittest
{
  import std.stdio : writeln;
  import std.range : iota, array;
  debug  writeln("unittest block 2 from sodium.crypto_verify_64.d");

//crypto_verify_64
  assert(crypto_verify_64_bytes() == crypto_verify_64_BYTES);

//crypto_verify_64 overload
  ubyte[64] buf1 = array(iota(ubyte(1), cast(ubyte)(1+crypto_verify_64_BYTES)))[];
  ubyte[64] buf2 = buf1;
  assert(crypto_verify_64(buf1, buf2) ==  0);
  buf2[$-1] = 65;
  assert(crypto_verify_64(buf1, buf2) == -1);
}

