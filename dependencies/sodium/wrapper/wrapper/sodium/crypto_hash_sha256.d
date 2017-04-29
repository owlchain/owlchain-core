// Written in the D programming language.

module wrapper.sodium.crypto_hash_sha256;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_hash_sha256 : crypto_hash_sha256_state,
                                           crypto_hash_sha256_statebytes,
                                           crypto_hash_sha256_BYTES,
                                           crypto_hash_sha256_bytes;
/*                                         crypto_hash_sha256,
                                           crypto_hash_sha256_init,
                                           crypto_hash_sha256_update,
                                           crypto_hash_sha256_final; */

alias crypto_hash_sha256 = deimos.sodium.crypto_hash_sha256.crypto_hash_sha256;

pragma(inline, true)
bool crypto_hash_sha256(out ubyte[crypto_hash_sha256_BYTES] out_, in ubyte[] in_) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash_sha256;
  return  deimos.sodium.crypto_hash_sha256.crypto_hash_sha256(out_.ptr, in_.ptr, in_.length) == 0;
}


alias crypto_hash_sha256_init = deimos.sodium.crypto_hash_sha256.crypto_hash_sha256_init;

pragma(inline, true)
bool crypto_hash_sha256_init(out crypto_hash_sha256_state state) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash_sha256;
  return  deimos.sodium.crypto_hash_sha256.crypto_hash_sha256_init(&state) == 0;
}

alias crypto_hash_sha256_update = deimos.sodium.crypto_hash_sha256.crypto_hash_sha256_update;

pragma(inline, true)
bool crypto_hash_sha256_update(ref crypto_hash_sha256_state state, in ubyte[] in_) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash_sha256;
  return  deimos.sodium.crypto_hash_sha256.crypto_hash_sha256_update(&state, in_.ptr, in_.length) == 0;
}

alias crypto_hash_sha256_final = deimos.sodium.crypto_hash_sha256.crypto_hash_sha256_final;

pragma(inline, true)
bool crypto_hash_sha256_final(ref crypto_hash_sha256_state state, out ubyte[crypto_hash_sha256_BYTES] out_) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash_sha256;
  return  deimos.sodium.crypto_hash_sha256.crypto_hash_sha256_final(&state, out_.ptr) == 0;
}


@safe
unittest
{
  import std.stdio : writeln, writefln;
  import std.string : representation;
  debug writeln("unittest block 1 from sodium.crypto_hash_sha256.d");

//  assert(crypto_hash_sha256_statebytes == crypto_hash_sha256_state.sizeof);
//  writeln(crypto_hash_sha256_statebytes()); // 104
//  writeln(crypto_hash_sha256_state.sizeof); // 112
  assert(crypto_hash_sha256_bytes() == crypto_hash_sha256_BYTES);

  auto message = representation("test some more text!");

  ubyte[crypto_hash_sha256_BYTES]  hash;
  ubyte[crypto_hash_sha256_BYTES]  hash_saved;
  assert(crypto_hash_sha256(hash, message));
  hash_saved = hash;
//  writefln("0x%(%02X%)", hash);  // 0xC01F1C6165CB6E3E28690B05D7DDCF8FEF28E8719E2F719800681058C08C9970
  hash = hash.init;
  auto message1 = representation("test some");
  auto message2 = representation(" more text!");
  crypto_hash_sha256_state  state;

  assert(crypto_hash_sha256_init  (state));
  assert(crypto_hash_sha256_update(state, message1));
  assert(crypto_hash_sha256_update(state, message2));
  assert(crypto_hash_sha256_final (state, hash));
  assert(hash == hash_saved);
}
