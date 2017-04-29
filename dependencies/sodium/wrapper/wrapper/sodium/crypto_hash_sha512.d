// Written in the D programming language.

module wrapper.sodium.crypto_hash_sha512;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_hash_sha512 : crypto_hash_sha512_state,
                                           crypto_hash_sha512_statebytes,
                                           crypto_hash_sha512_BYTES,
                                           crypto_hash_sha512_bytes;
/*                                         crypto_hash_sha512,
                                           crypto_hash_sha512_init,
                                           crypto_hash_sha512_update,
                                           crypto_hash_sha512_final; */

alias crypto_hash_sha512 = deimos.sodium.crypto_hash_sha512.crypto_hash_sha512;

pragma(inline, true)
bool crypto_hash_sha512(out ubyte[crypto_hash_sha512_BYTES] out_, in ubyte[] in_) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash_sha512;
  return  deimos.sodium.crypto_hash_sha512.crypto_hash_sha512(out_.ptr, in_.ptr, in_.length) == 0;
}


alias crypto_hash_sha512_init = deimos.sodium.crypto_hash_sha512.crypto_hash_sha512_init;

pragma(inline, true)
bool crypto_hash_sha512_init(out crypto_hash_sha512_state state) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash_sha512;
  return  deimos.sodium.crypto_hash_sha512.crypto_hash_sha512_init(&state) == 0;
}

alias crypto_hash_sha512_update = deimos.sodium.crypto_hash_sha512.crypto_hash_sha512_update;

pragma(inline, true)
bool crypto_hash_sha512_update(ref crypto_hash_sha512_state state, in ubyte[] in_) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash_sha512;
  return  deimos.sodium.crypto_hash_sha512.crypto_hash_sha512_update(&state, in_.ptr, in_.length) == 0;
}

alias crypto_hash_sha512_final = deimos.sodium.crypto_hash_sha512.crypto_hash_sha512_final;

pragma(inline, true)
bool crypto_hash_sha512_final(ref crypto_hash_sha512_state state, out ubyte[crypto_hash_sha512_BYTES] out_) pure @nogc @trusted
{
  static import deimos.sodium.crypto_hash_sha512;
  return  deimos.sodium.crypto_hash_sha512.crypto_hash_sha512_final(&state, out_.ptr) == 0;
}


@safe
unittest
{
  import std.stdio : writeln, writefln;
  import std.string : representation;
  debug writeln("unittest block 1 from sodium.crypto_hash_sha512.d");

  assert(crypto_hash_sha512_statebytes == crypto_hash_sha512_state.sizeof);
//  writeln(crypto_hash_sha512_statebytes()); // 208
//  writeln(crypto_hash_sha512_state.sizeof); // 208
  assert(crypto_hash_sha512_bytes() == crypto_hash_sha512_BYTES);

  auto message = representation("test some more text!");

  ubyte[crypto_hash_sha512_BYTES]  hash;
  ubyte[crypto_hash_sha512_BYTES]  hash_saved;
  assert(crypto_hash_sha512(hash, message));
  hash_saved = hash;
//  writefln("0x%(%02X%)", hash);  // 0x751D946284C252417D596C384A710A02D25788A109BBAC3DC83F98A4EF4F0D235DAC3691E57B0013ABC24F174E71671152BFA9C41033683737328D34F57B528D
  hash = hash.init;
  auto message1 = representation("test some");
  auto message2 = representation(" more text!");
  crypto_hash_sha512_state  state;

  assert(crypto_hash_sha512_init  (state));
  assert(crypto_hash_sha512_update(state, message1));
  assert(crypto_hash_sha512_update(state, message2));
  assert(crypto_hash_sha512_final (state, hash));
  assert(hash == hash_saved);
}
