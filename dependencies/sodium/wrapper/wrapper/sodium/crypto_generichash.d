// Written in the D programming language.

module wrapper.sodium.crypto_generichash;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_generichash : crypto_generichash_BYTES_MIN,
                                           crypto_generichash_bytes_min,
                                           crypto_generichash_BYTES_MAX,
                                           crypto_generichash_bytes_max,
                                           crypto_generichash_BYTES,
                                           crypto_generichash_bytes,
                                           crypto_generichash_KEYBYTES_MIN,
                                           crypto_generichash_keybytes_min,
                                           crypto_generichash_KEYBYTES_MAX,
                                           crypto_generichash_keybytes_max,
                                           crypto_generichash_KEYBYTES,
                                           crypto_generichash_keybytes,
                                           crypto_generichash_PRIMITIVE,
//                                           crypto_generichash_primitive,
                                           crypto_generichash_state,
                                           crypto_generichash_statebytes,
//                                           crypto_generichash,
//                                           crypto_generichash_init,
//                                           crypto_generichash_update,
//                                           crypto_generichash_final;
                                           crypto_generichash_keygen;


import std.exception : enforce;

string crypto_generichash_primitive() pure nothrow @nogc @trusted
{
  import std.string : fromStringz;
  static import deimos.sodium.crypto_generichash;
  const(char)[] c_arr;
  try
    c_arr = fromStringz(deimos.sodium.crypto_generichash.crypto_generichash_primitive()); // strips terminating \0
  catch (Exception e) { /* known not to throw */ }
  return c_arr;
}

void crypto_generichash_multi(scope ubyte[] out_, in ubyte[][] in_multi, in ubyte[] key = null) pure @trusted
{
  enforce(out_.length >= crypto_generichash_BYTES_MIN && out_.length <= crypto_generichash_BYTES_MAX, "wrong length allocated for hash");
  if (key.length)
    enforce(key.length >= crypto_generichash_KEYBYTES_MIN && key.length <= crypto_generichash_KEYBYTES_MAX, "wrong length of key: Must be either 0 or 16<=length<=64");
  crypto_generichash_state state;
  crypto_generichash_init(state, key, out_.length);
  foreach (arr; in_multi)
    crypto_generichash_update(state, arr);
  crypto_generichash_final(state, out_);
 }


/* overload */

alias crypto_generichash = deimos.sodium.crypto_generichash.crypto_generichash;

int crypto_generichash(scope ubyte[] out_, in ubyte[] in_, in ubyte[] key = null) pure @trusted
{
  static import deimos.sodium.crypto_generichash;
  enforce(out_.length >= crypto_generichash_BYTES_MIN && out_.length <= crypto_generichash_BYTES_MAX, "wrong length allocated for hash");
  if (key.length)
    enforce(key.length >= crypto_generichash_KEYBYTES_MIN && key.length <= crypto_generichash_KEYBYTES_MAX, "wrong length of key: Must be either 0 or 16<=length<=64");
  return deimos.sodium.crypto_generichash.crypto_generichash(out_.ptr, out_.length, in_.ptr, in_.length, key.ptr, key.length);
}

alias crypto_generichash_init = deimos.sodium.crypto_generichash.crypto_generichash_init;

bool crypto_generichash_init(out crypto_generichash_state state,
                             in ubyte[] key, in size_t outlen) pure @trusted
{
  static import deimos.sodium.crypto_generichash;
  enforce(outlen     >= crypto_generichash_BYTES_MIN    && outlen     <= crypto_generichash_BYTES_MAX, "wrong length allocated for hash");
  if (key.length)
    enforce(key.length >= crypto_generichash_KEYBYTES_MIN && key.length <= crypto_generichash_KEYBYTES_MAX, "wrong length allocated for key");
  return  deimos.sodium.crypto_generichash.crypto_generichash_init(&state, key.ptr, key.length, outlen) == 0;
}

alias crypto_generichash_update = deimos.sodium.crypto_generichash.crypto_generichash_update;

//pragma(inline, true)
bool crypto_generichash_update(ref crypto_generichash_state state,
                               in ubyte[] in_) pure @nogc @trusted
{
  static import deimos.sodium.crypto_generichash;
  return  deimos.sodium.crypto_generichash.crypto_generichash_update(&state, in_.ptr, in_.length) == 0;
}

alias crypto_generichash_final = deimos.sodium.crypto_generichash.crypto_generichash_final;

bool crypto_generichash_final(ref crypto_generichash_state state,
                              scope ubyte[] out_) pure @trusted
{
  static import deimos.sodium.crypto_generichash;
  enforce(out_.length >= crypto_generichash_BYTES_MIN && out_.length  <= crypto_generichash_BYTES_MAX, "wrong length allocated for hash");
  return  deimos.sodium.crypto_generichash.crypto_generichash_final(&state, out_.ptr, out_.length) == 0;
}

@system
unittest
{
  import std.stdio : writeln, writefln;
  import std.algorithm.comparison : equal;
  import std.string : fromStringz, representation;
  import wrapper.sodium.randombytes : randombytes;
  debug  writeln("unittest block 1 from sodium.crypto_generichash.d");
/+
  writeln("crypto_generichash_state.alignof: ", crypto_generichash_state.alignof); // 8, the default for this struct; but actually the alignment is 64 as declared
  writeln("crypto_generichash_statebytes():  ", crypto_generichash_statebytes());  // 384 = 64*6
  writeln("crypto_generichash_state.sizeof:  ", crypto_generichash_state.sizeof);  // 384
  writeln("crypto_generichash_state.last_node.offsetof: ", crypto_generichash_state.last_node.offsetof); // 360, thus I use 361 bytes and 384-361=23 are padding
+/
  assert(crypto_generichash_bytes_min()    == crypto_generichash_BYTES_MIN);
  assert(crypto_generichash_bytes_max()    == crypto_generichash_BYTES_MAX);
  assert(crypto_generichash_bytes()        == crypto_generichash_BYTES);
  assert(crypto_generichash_keybytes_min() == crypto_generichash_KEYBYTES_MIN);
  assert(crypto_generichash_keybytes_max() == crypto_generichash_KEYBYTES_MAX);
  assert(crypto_generichash_keybytes()     == crypto_generichash_KEYBYTES);
  assert(crypto_generichash_primitive()    == crypto_generichash_PRIMITIVE);

  assert(crypto_generichash_statebytes() == 64*6);
  assert(crypto_generichash_statebytes() == crypto_generichash_state.sizeof);
version(D_LP64)
{
//    alias ulong size_t;
  assert(crypto_generichash_state.last_node.offsetof == 360); // there is no padding between offset 0 and the last member: ubyte last_node
}
else
{
//    alias uint  size_t;
  assert(crypto_generichash_state.last_node.offsetof == 356);
}

//Single-part example without a key

//crypto_generichash
  auto MESSAGE = representation("Arbitrary data to hash");
  ubyte[crypto_generichash_BYTES] hash;
  {
    static import deimos.sodium.crypto_generichash;
    deimos.sodium.crypto_generichash.crypto_generichash(hash.ptr, hash.length, MESSAGE.ptr, MESSAGE.length, null, 0);
//  writefln("0x%(%02x%)", hash); // 0x3dc7925e13e4c5f0f8756af2cc71d5624b58833bb92fa989c3e87d734ee5a600
  }

//Multi-part example with a key

  auto MESSAGE_PART1 = representation("Arbitrary data to hash");
  auto MESSAGE_PART2 = representation("is longer than expected");

  hash = ubyte.init;
  ubyte[crypto_generichash_KEYBYTES] key;
  randombytes(key);
//  writefln("0x%(%02x%)", key); // 0x516efcdd0db3fa9ececd98400dbd70df50fbe1ec2cfaf6a9cde509c7b306fcab

  crypto_generichash_state state;
  crypto_generichash_init  (state, key, hash.length);
  crypto_generichash_update(state, MESSAGE_PART1);
  crypto_generichash_update(state, MESSAGE_PART2);
  crypto_generichash_final (state, hash);
//  writefln("0x%(%02x%)", hash); // 0xbd4ec735d9b885a60e0a2b1f8e61842795126a77db60e4fa962290f29e63fde7

}

@safe
unittest
{
  import std.stdio : writeln, writefln;
  import std.algorithm.comparison : equal;
  import std.string : representation; // @system fromStringz
  import wrapper.sodium.randombytes : randombytes;
  debug  writeln("unittest block 2 from sodium.crypto_generichash.d");

//Single-part example without a key

//crypto_generichash
  ubyte[crypto_generichash_BYTES] hash;
  auto MESSAGE = representation("Arbitrary data to hash");
  crypto_generichash(hash, MESSAGE);

  auto hash_output = representation(x"3dc7925e13e4c5f0f8756af2cc71d5624b58833bb92fa989c3e87d734ee5a600"); // the result from invoking the C version
  assert(equal(hash[], hash_output));

  ubyte[crypto_generichash_KEYBYTES] key32 = void;
  randombytes(key32);
  crypto_generichash(hash, MESSAGE, key32);

//Multi-part example with a key

//crypto_generichash_multi
  hash = ubyte.init;
  auto MESSAGE_multi = [
    representation("Arbitrary data to hash"),
    representation("is longer than expected")
  ];
  auto key = cast(immutable(ubyte)[]) x"516efcdd0db3fa9ececd98400dbd70df50fbe1ec2cfaf6a9cde509c7b306fcab"; // a key chosen in a run of block 1
  crypto_generichash_multi(hash, MESSAGE_multi, key);

  hash_output = cast(immutable(ubyte)[]) x"bd4ec735d9b885a60e0a2b1f8e61842795126a77db60e4fa962290f29e63fde7"; // a hash calculated in a run of block 1 for same key and input
  assert(equal(hash[], hash_output));

  ubyte[crypto_generichash_KEYBYTES] k;
  crypto_generichash_keygen(k);
}
