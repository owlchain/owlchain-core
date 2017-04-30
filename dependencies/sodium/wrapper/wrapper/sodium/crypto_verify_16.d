module wrapper.sodium.crypto_verify_16;

import wrapper.sodium.core; // assure sodium got initialized

public import  deimos.sodium.crypto_verify_16;


/* overloaded functions */

alias crypto_verify_16 = deimos.sodium.crypto_verify_16.crypto_verify_16;

/** Secrets are always compared in constant time using sodium_memcmp() or crypto_verify_(16|32|64)()
 * @returns 0 if the len bytes pointed to by x match the len bytes pointed to by y.
 * Otherwise, it returns -1.
 */
int crypto_verify_16(in ubyte[crypto_verify_16_BYTES] x, in ubyte[crypto_verify_16_BYTES] y) pure nothrow @nogc @trusted
{
  return deimos.sodium.crypto_verify_16.crypto_verify_16(x.ptr, y.ptr);
}


pure @system
unittest
{
  import std.stdio : writeln;
  import std.range : iota, array;
  debug  writeln("unittest block 1 from sodium.crypto_verify_16.d");

//crypto_verify_16
  ubyte[] buf1 = array(iota(ubyte(1), cast(ubyte)(1+crypto_verify_16_BYTES))); // [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
  ubyte[] buf2 = buf1.dup;
  assert(crypto_verify_16(buf1.ptr, buf2.ptr) ==  0);
  buf2[$-1] = 17;
  assert(crypto_verify_16(buf1.ptr, buf2.ptr) == -1);
}

pure @safe
unittest
{
  import std.stdio : writeln;
  import std.range : iota, array;
  debug  writeln("unittest block 2 from sodium.crypto_verify_16.d");

//crypto_verify_16_bytes
  assert(crypto_verify_16_bytes() == crypto_verify_16_BYTES);

//crypto_verify_16 overload
  ubyte[crypto_verify_16_BYTES] buf1 = array(iota(ubyte(1), cast(ubyte)(1+crypto_verify_16_BYTES)))[];
  ubyte[crypto_verify_16_BYTES] buf2 = buf1;
  assert(crypto_verify_16(buf1, buf2) ==  0);
  buf2[$-1] = 17;
  assert(crypto_verify_16(buf1, buf2) == -1);
}
