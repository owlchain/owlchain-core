// Written in the D programming language.

module wrapper.sodium.crypto_auth_hmacsha256;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_auth_hmacsha256;


// overloading some functions between module deimos.sodium.crypto_auth_hmacsha256 and this module
pragma(inline, true)  pure @nogc @trusted
{
alias  crypto_auth_hmacsha256        = deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256;

/**
 * The crypto_auth_hmacsha256() function authenticates a message `message` using the secret key `skey`,
 * and puts the authenticator into `mac`.
 * It returns true on success.
 */
bool crypto_auth_hmacsha256(out ubyte[crypto_auth_hmacsha256_BYTES] mac,
                           in ubyte[] message,
                           in ubyte[crypto_auth_hmacsha256_KEYBYTES] skey)
{
  return  deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256(mac.ptr, message.ptr, message.length, skey.ptr) == 0;
}

alias  crypto_auth_hmacsha256_verify = deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256_verify;

/**
 * The crypto_auth_hmacsha256_verify() function verifies in constant time that `mac` is a correct
 * authenticator for the message `message` under a secret key `skey`.
 * It returns true on success of verification.

 */
bool crypto_auth_hmacsha256_verify(in ubyte[crypto_auth_hmacsha256_BYTES] mac,
                                   in ubyte[] message,
                                   in ubyte[crypto_auth_hmacsha256_KEYBYTES] skey) nothrow
{
  return  deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256_verify(mac.ptr, message.ptr, message.length, skey.ptr) == 0;
}

alias crypto_auth_hmacsha256_init    = deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256_init;

/** This alternative API supports a key of arbitrary length */
bool crypto_auth_hmacsha256_init(out crypto_auth_hmacsha256_state state,
                                 in ubyte[] skey)
{
  return  deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256_init(&state, skey.ptr, skey.length) == 0;
}

alias crypto_auth_hmacsha256_update  = deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256_update;

bool crypto_auth_hmacsha256_update(ref crypto_auth_hmacsha256_state state,
                                   in ubyte[] in_)
{
  return  deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256_update(&state, in_.ptr, in_.length) == 0;
}

alias crypto_auth_hmacsha256_final   = deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256_final;

bool crypto_auth_hmacsha256_final(ref crypto_auth_hmacsha256_state state,
                                  out ubyte[crypto_auth_hmacsha256_BYTES] out_)
{
  return  deimos.sodium.crypto_auth_hmacsha256.crypto_auth_hmacsha256_final(&state, out_.ptr) == 0;
}
} //pragma(inline, true)  pure @nogc @trusted


@safe
unittest
{
  import std.stdio : writeln;
  import std.string : representation;
  import wrapper.sodium.randombytes : randombytes;

  debug writeln("unittest block 1 from sodium.crypto_auth_hmacsha256.d");

  assert(crypto_auth_hmacsha256_bytes()      == crypto_auth_hmacsha256_BYTES);
  assert(crypto_auth_hmacsha256_keybytes()   == crypto_auth_hmacsha256_KEYBYTES);
//  assert(crypto_auth_hmacsha256_statebytes() == crypto_auth_hmacsha256_state.sizeof);
//  writeln("crypto_auth_hmacsha256_statebytes(): ", crypto_auth_hmacsha256_statebytes());   // 208
//  writeln("crypto_auth_hmacsha256_state.sizeof: ", crypto_auth_hmacsha256_state.sizeof); // 224 = 2*crypto_hash_sha256_state.sizeof

  auto                                   message  = representation("test some more text");
  auto                                   message2 = representation(" some more text");
  ubyte[crypto_auth_hmacsha256_KEYBYTES] skey;
  ubyte[crypto_auth_hmacsha256_BYTES]    mac;

  randombytes(skey);
  assert(crypto_auth_hmacsha256(mac, message, skey));
  assert(crypto_auth_hmacsha256_verify(mac, message, skey));
  ubyte[crypto_auth_hmacsha256_BYTES]    mac_saved = mac;

  message  = representation("test");
  crypto_auth_hmacsha256_state state;
  assert(crypto_auth_hmacsha256_init  (state, skey));
  assert(crypto_auth_hmacsha256_update(state, message));
  assert(crypto_auth_hmacsha256_update(state, message2));
  assert(crypto_auth_hmacsha256_final (state, mac));
  message  = representation("test some more text");
  assert(crypto_auth_hmacsha256_verify(mac, message, skey));
  assert(mac == mac_saved);
  ubyte[crypto_auth_hmacsha256_KEYBYTES] k;
  crypto_auth_hmacsha256_keygen(k);
}
