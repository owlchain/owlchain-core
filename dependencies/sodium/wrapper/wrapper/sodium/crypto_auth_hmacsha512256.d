// Written in the D programming language.

module wrapper.sodium.crypto_auth_hmacsha512256;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_auth_hmacsha512256;


// overloading some functions between module deimos.sodium.crypto_auth_hmacsha512256 and this module
pragma(inline, true)  pure @nogc @trusted
{
alias  crypto_auth_hmacsha512256        = deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256;

/**
 * The crypto_auth_hmacsha512256() function authenticates a message `message` using the secret	key skey,
 * and puts the	authenticator	into mac.
 * Returns 0? on success.
 */
bool crypto_auth_hmacsha512256(out ubyte[crypto_auth_hmacsha512256_BYTES] mac,
                               in ubyte[] message,
                               in ubyte[crypto_auth_hmacsha512256_KEYBYTES] skey)
{
  return  deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256(mac.ptr, message.ptr, message.length, skey.ptr) == 0;
}

alias  crypto_auth_hmacsha512256_verify = deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256_verify;

/**
 * The	 	crypto_auth_hmacsha512256_verify()	 	function	verifies	in	constant	time	that	 	h	 	is	a	correct
authenticator	for	the	message	 	in		whose	length	is	 	inlen	 	under	a	secret	key	 	k	.
It	returns	 	-1		if	the	verification	fails,	and	 	0		on	success.

 */
bool crypto_auth_hmacsha512256_verify(in ubyte[crypto_auth_hmacsha512256_BYTES] mac,
                                      in ubyte[] message,
                                      in ubyte[crypto_auth_hmacsha512256_KEYBYTES] skey) nothrow
{
  return  deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256_verify(mac.ptr, message.ptr, message.length, skey.ptr) == 0;
}

alias crypto_auth_hmacsha512256_init    = deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256_init;

/**
 * This	alternative	API	supports	a	key	of	arbitrary	length
 */
bool crypto_auth_hmacsha512256_init(out crypto_auth_hmacsha512256_state state,
                                    in ubyte[] skey)
{
  return  deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256_init(&state, skey.ptr, skey.length) == 0;
}

alias crypto_auth_hmacsha512256_update  = deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256_update;

bool crypto_auth_hmacsha512256_update(ref crypto_auth_hmacsha512256_state state,
                                      in ubyte[] in_)
{
  return  deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256_update(&state, in_.ptr, in_.length) == 0;
}

alias crypto_auth_hmacsha512256_final   = deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256_final;

bool crypto_auth_hmacsha512256_final(ref crypto_auth_hmacsha512256_state state,
                                     out ubyte[crypto_auth_hmacsha512256_BYTES] out_)
{
  return  deimos.sodium.crypto_auth_hmacsha512256.crypto_auth_hmacsha512256_final(&state, out_.ptr) == 0;
}
} //pragma(inline, true)  pure @nogc @trusted


@safe
unittest
{
  import std.stdio : writeln;
  import std.string : representation;
  import wrapper.sodium.randombytes : randombytes;

  debug writeln("unittest block 1 from sodium.crypto_auth_hmacsha512256.d");

  assert(crypto_auth_hmacsha512256_bytes()      == crypto_auth_hmacsha512256_BYTES);
  assert(crypto_auth_hmacsha512256_keybytes()   == crypto_auth_hmacsha512256_KEYBYTES);
  assert(crypto_auth_hmacsha512256_statebytes() == crypto_auth_hmacsha512256_state.sizeof);
//  writeln("crypto_auth_hmacsha512256_statebytes(): ", crypto_auth_hmacsha512256_statebytes()); // 416
//  writeln("crypto_auth_hmacsha512256_state.sizeof: ", crypto_auth_hmacsha512256_state.sizeof); // 416 = 2*crypto_hash_sha512256_state.sizeof

  auto                                      message  = representation("test some more text");
  auto                                      message2 = representation(" some more text");
  ubyte[crypto_auth_hmacsha512256_KEYBYTES] skey;
  ubyte[crypto_auth_hmacsha512256_BYTES]    mac;

  randombytes(skey);
  assert(crypto_auth_hmacsha512256(mac, message, skey));
  assert(crypto_auth_hmacsha512256_verify(mac, message, skey));
  ubyte[crypto_auth_hmacsha512256_BYTES]    mac_saved = mac;

  message  = representation("test");
  crypto_auth_hmacsha512256_state state;
  assert(crypto_auth_hmacsha512256_init  (state, skey));
  assert(crypto_auth_hmacsha512256_update(state, message));
  assert(crypto_auth_hmacsha512256_update(state, message2));
  assert(crypto_auth_hmacsha512256_final (state, mac));
  message  = representation("test some more text");
  assert(crypto_auth_hmacsha512256_verify(mac, message, skey));
  assert(mac == mac_saved);
  ubyte[crypto_auth_hmacsha512256_KEYBYTES] k;
  crypto_auth_hmacsha512256_keygen(k);
}
