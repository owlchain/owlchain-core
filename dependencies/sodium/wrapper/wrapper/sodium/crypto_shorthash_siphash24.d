// Written in the D programming language.

module wrapper.sodium.crypto_shorthash_siphash24;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_shorthash_siphash24;


/*pure*/ @system
unittest {
  import std.stdio : writeln, writefln;
  import std.string : representation;
  import wrapper.sodium.randombytes : randombytes;
  import deimos.sodium.version_ : sodium_library_minimal;

  debug writeln("unittest block 1 from sodium.crypto_shorthash_siphash24.d");
  assert(crypto_shorthash_siphash24_bytes()    == crypto_shorthash_siphash24_BYTES);    //  8U
  assert(crypto_shorthash_siphash24_keybytes() == crypto_shorthash_siphash24_KEYBYTES); // 16U

  auto short_data = representation("Sparkling water");

  ubyte[crypto_shorthash_siphash24_BYTES]    hash_sip24;
  ubyte[crypto_shorthash_siphash24_KEYBYTES] key;

  randombytes(key);
  crypto_shorthash_siphash24(hash_sip24.ptr, short_data.ptr, short_data.length, key.ptr);
//  writefln("shorthash: 0x%(%X%)", hash_sip24); // shorthash: 0xB4E48C88341DF46

  if (!sodium_library_minimal) {
    /* -- 128-bit output -- */
    assert(crypto_shorthash_siphashx24_bytes()    == crypto_shorthash_siphashx24_BYTES);
    assert(crypto_shorthash_siphashx24_keybytes() == crypto_shorthash_siphashx24_KEYBYTES);
    ubyte[crypto_shorthash_siphashx24_KEYBYTES] keyx24 = void;
	  randombytes(keyx24);
    ubyte[crypto_shorthash_siphashx24_BYTES] rcv_bub;
    auto msg = representation("so what");
    crypto_shorthash_siphashx24(rcv_bub.ptr, msg.ptr, msg.length, keyx24.ptr);
	}
}
