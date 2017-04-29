// Written in the D programming language.

module wrapper.sodium.crypto_auth;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_auth : crypto_auth_BYTES,
                                    crypto_auth_bytes,
                                    crypto_auth_KEYBYTES,
                                    crypto_auth_keybytes,
                                    crypto_auth_PRIMITIVE,
/*                                  crypto_auth_primitive,
                                    crypto_auth,
                                    crypto_auth_verify; */
                                    crypto_auth_keygen;

/*
 deimos.sodium.crypto_auth.crypto_auth_primitive() gets trusted to return a valid (program lifetime) address, to be evaluated as a null-terminated C string
 added nothrow again for D, i.e. return value must be used
*/
string crypto_auth_primitive() pure nothrow @nogc @trusted
{
  import std.string : fromStringz; // @system
  static import deimos.sodium.crypto_auth;
  const(char)[] c_arr;
  try
    c_arr = fromStringz(deimos.sodium.crypto_auth.crypto_auth_primitive()); // strips terminating \0
  catch (Exception e) { /* known not to throw */ }
  return c_arr; // assumeUnique not strictly required, as compiler can infer uniqueness for a pure function // omit .idup for @nogc
}

// overloading some functions between module deimos.sodium.crypto_auth and this module

alias crypto_auth        = deimos.sodium.crypto_auth.crypto_auth;

/**
 */
pragma(inline, true)
bool crypto_auth(out ubyte[crypto_auth_BYTES] mac, in ubyte[] message, in ubyte[crypto_auth_KEYBYTES] skey) pure @nogc @trusted
{
  static import deimos.sodium.crypto_auth;
  return  deimos.sodium.crypto_auth.crypto_auth(mac.ptr, message.ptr, message.length, skey.ptr) == 0;
}

alias crypto_auth_verify = deimos.sodium.crypto_auth.crypto_auth_verify;

/**
 */
pragma(inline, true)
bool crypto_auth_verify(in ubyte[crypto_auth_BYTES] mac, in ubyte[] message, in ubyte[crypto_auth_KEYBYTES] skey) pure nothrow @nogc @trusted
{
  static import deimos.sodium.crypto_auth;
  return  deimos.sodium.crypto_auth.crypto_auth_verify(mac.ptr, message.ptr, message.length, skey.ptr) == 0;
}


@safe
unittest
{
  import std.string : representation;
  import std.stdio : writeln;
  import wrapper.sodium.randombytes : randombytes;

  debug writeln("unittest block 1 from sodium.crypto_auth.d");

  assert(crypto_auth_bytes()      == crypto_auth_BYTES);
  assert(crypto_auth_keybytes()   == crypto_auth_KEYBYTES);
  assert(crypto_auth_primitive()  == crypto_auth_PRIMITIVE);

  auto                        message = representation("test");
  ubyte[crypto_auth_KEYBYTES] skey;
  ubyte[crypto_auth_BYTES]    mac;

  randombytes(skey);
  assert(crypto_auth(mac, message, skey));

  assert(crypto_auth_verify(mac, message, skey));
//  if (!crypto_auth_verify(mac, message, skey))
//    writeln("*** ATTENTION : The message has been forged ! ***");
  ubyte[crypto_auth_KEYBYTES] k;
  crypto_auth_keygen(k);
}
