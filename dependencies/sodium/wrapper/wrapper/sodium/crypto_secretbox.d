// Written in the D programming language.

module wrapper.sodium.crypto_secretbox;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_secretbox : crypto_secretbox_KEYBYTES,
                                         crypto_secretbox_keybytes,
                                         crypto_secretbox_NONCEBYTES,
                                         crypto_secretbox_noncebytes,
                                         crypto_secretbox_MACBYTES,
                                         crypto_secretbox_macbytes,
                                         crypto_secretbox_PRIMITIVE,
//                                         crypto_secretbox_primitive,
//                                         crypto_secretbox_easy,
//                                         crypto_secretbox_open_easy,
//                                         crypto_secretbox_detached,
//                                         crypto_secretbox_open_detached,
                                         crypto_secretbox_keygen,
                                         crypto_secretbox_ZEROBYTES,
                                         crypto_secretbox_zerobytes,
                                         crypto_secretbox_BOXZEROBYTES,
                                         crypto_secretbox_boxzerobytes,
                                         crypto_secretbox,
                                         crypto_secretbox_open;

import std.exception : enforce, assertThrown;



string crypto_secretbox_primitive() pure nothrow @nogc @trusted
{
  import std.string : fromStringz;
  static import deimos.sodium.crypto_secretbox;
  const(char)[] c_arr;
  try
    c_arr = fromStringz(deimos.sodium.crypto_secretbox.crypto_secretbox_primitive()); // strips terminating \0
  catch (Exception e) { /* known not to throw */ }
  return c_arr;
}

// overloading some functions between module deimos.sodium.crypto_secretbox and this module

alias crypto_secretbox_easy          = deimos.sodium.crypto_secretbox.crypto_secretbox_easy;

bool crypto_secretbox_easy(scope ubyte[] c, in ubyte[] m, in ubyte[crypto_secretbox_NONCEBYTES] nonce,
                           in ubyte[crypto_secretbox_KEYBYTES] key) pure @trusted
{
  enforce(c.length >= crypto_secretbox_MACBYTES + m.length, "Error in crypto_secretbox_easy: c.length < crypto_secretbox_MACBYTES + m.length");
  static import deimos.sodium.crypto_secretbox;
  return  deimos.sodium.crypto_secretbox.crypto_secretbox_easy(c.ptr, m.ptr, m.length, nonce.ptr, key.ptr) == 0;
}

alias crypto_secretbox_open_easy     = deimos.sodium.crypto_secretbox.crypto_secretbox_open_easy;

bool crypto_secretbox_open_easy(scope ubyte[] m, in ubyte[] c,
                                in ubyte[crypto_secretbox_NONCEBYTES] nonce,
                                in ubyte[crypto_secretbox_KEYBYTES] key) pure @trusted
{
  enforce(c.length >= crypto_secretbox_MACBYTES, "Error in crypto_secretbox_open_easy: c.length < crypto_secretbox_MACBYTES");
  enforce(m.length >= c.length - crypto_secretbox_MACBYTES, "Error in crypto_secretbox_open_easy: m.length < c.length - crypto_secretbox_MACBYTES");
  static import deimos.sodium.crypto_secretbox;
  return  deimos.sodium.crypto_secretbox.crypto_secretbox_open_easy(m.ptr, c.ptr, c.length, nonce.ptr, key.ptr) == 0;
}

alias crypto_secretbox_detached      = deimos.sodium.crypto_secretbox.crypto_secretbox_detached;

bool crypto_secretbox_detached(scope ubyte[] c, out ubyte[crypto_secretbox_MACBYTES] mac, in ubyte[] m,
                               in ubyte[crypto_secretbox_NONCEBYTES] nonce, in ubyte[crypto_secretbox_KEYBYTES] key) pure @trusted
{
  enforce(c.length >= m.length, "Error in crypto_secretbox_detached: c.length < m.length");
  static import deimos.sodium.crypto_secretbox;
  return  deimos.sodium.crypto_secretbox.crypto_secretbox_detached(c.ptr, mac.ptr, m.ptr, m.length, nonce.ptr, key.ptr) == 0;
}

alias crypto_secretbox_open_detached = deimos.sodium.crypto_secretbox.crypto_secretbox_open_detached;

bool crypto_secretbox_open_detached(scope ubyte[] m, in ubyte[] c, in ubyte[] mac,
                                    in ubyte[crypto_secretbox_NONCEBYTES] nonce,
                                    in ubyte[crypto_secretbox_KEYBYTES] key) pure @trusted
{
  enforce(m.length >= c.length, "Error in crypto_secretbox_open_detached: m.length < c.length");
  static import deimos.sodium.crypto_secretbox;
  return  deimos.sodium.crypto_secretbox.crypto_secretbox_open_detached(m.ptr, c.ptr, mac.ptr, c.length, nonce.ptr, key.ptr) == 0;
}
/*

int crypto_secretbox_open_detached(ubyte* m,
                                   const(ubyte)* c,
                                   const(ubyte)* mac,
                                   ulong clen,
                                   const(ubyte)* n,
                                   const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result));

/* No overloads for -- NaCl compatibility interface ; Requires padding -- */

@safe
unittest {
  import std.string : representation;
  import std.stdio : writeln;
  import wrapper.sodium.randombytes : randombytes;
  import wrapper.sodium.utils : sodium_increment;

  debug writeln("unittest block 1 from sodium.crypto_secretbox.d");

  assert(crypto_secretbox_keybytes()   == crypto_secretbox_KEYBYTES);
  assert(crypto_secretbox_noncebytes() == crypto_secretbox_NONCEBYTES);
  assert(crypto_secretbox_macbytes()   == crypto_secretbox_MACBYTES);
  assert(crypto_secretbox_primitive()  == crypto_secretbox_PRIMITIVE);

  auto message = representation("test");
  // avoid heap allocation, like in the example code
  enum MESSAGE_LEN = 4;
  enum CIPHERTEXT_LEN = (crypto_secretbox_MACBYTES + MESSAGE_LEN);

  ubyte[crypto_secretbox_NONCEBYTES]  nonce = void;
  ubyte[crypto_secretbox_KEYBYTES]    key   = void;
  ubyte[CIPHERTEXT_LEN]               ciphertext = void;

  randombytes(nonce);
  randombytes(key);
  assertThrown(crypto_secretbox_easy(ciphertext[0..$-1], message, nonce, key));
  assert(crypto_secretbox_easy(ciphertext, message, nonce, key));
  version(none) {
    import std.array : appender;
    import std.base64 : Base64;
    auto app = appender!string();
    app.put("Message (plaintext): test\n");
    app.put("Ciphertext (base64): ");
    const(char)[] encoded = Base64.encode(ciphertext);
    app.put(encoded~"\n");
    app.put("Nonce      (base64): ");
    encoded = Base64.encode(nonce);
    app.put(encoded~"\n");
    app.put("Key        (base64): ");
    encoded = Base64.encode(key);
    app.put(encoded~"\n");
    writeln(app.data);
/* taking this from a previous run:
Message (plaintext): test
Ciphertext (base64): tNV0M68PZea7+XKsfTeiJuOxVfU=
Nonce      (base64): 0gkPP63C0it0WeeO1LIQk4BDLpHFD58Z
Key        (base64): AtN67ZJklRbVVJ7R9QwVbKFpZivWXFHq9YlwVbM9n6s=
*/
//ubyte[] decoded = Base64.decode("FPucA9l+");
    ubyte[crypto_secretbox_KEYBYTES]    key_   = Base64.decode("AtN67ZJklRbVVJ7R9QwVbKFpZivWXFHq9YlwVbM9n6s=");
    ubyte[crypto_secretbox_NONCEBYTES]  nonce_ = Base64.decode("0gkPP63C0it0WeeO1LIQk4BDLpHFD58Z");
    ubyte[CIPHERTEXT_LEN]               ciphertext_ = Base64.decode("tNV0M68PZea7+XKsfTeiJuOxVfU=");
    ubyte[MESSAGE_LEN]                  decrypted_  = void;
    assert(crypto_secretbox_open_easy(decrypted_, ciphertext_, nonce_, key_), "message forged!");
    assert(decrypted_ == message);
  }
  ubyte[MESSAGE_LEN]  decrypted = void;
  assertThrown(crypto_secretbox_open_easy(decrypted, ciphertext[0..$-1-crypto_secretbox_MACBYTES], nonce, key));
  assertThrown(crypto_secretbox_open_easy(decrypted[0..$-1], ciphertext, nonce, key));
  assert(crypto_secretbox_open_easy(decrypted, ciphertext, nonce, key), "message forged!");
  assert(decrypted == message);

//
  ubyte[crypto_secretbox_MACBYTES]  mac = void;
  ciphertext = ubyte.init;
  decrypted  = ubyte.init;
  sodium_increment(nonce);
  assertThrown(crypto_secretbox_detached(ciphertext[0..$-1-crypto_secretbox_MACBYTES], mac, message, nonce, key));
  assert(crypto_secretbox_detached(ciphertext, mac, message, nonce, key));

  assertThrown(crypto_secretbox_open_detached(decrypted[0..$-1], ciphertext[0..$-crypto_secretbox_MACBYTES], mac, nonce, key));
  assert(crypto_secretbox_open_detached(decrypted, ciphertext[0..$-crypto_secretbox_MACBYTES], mac, nonce, key), "message forged!");
  assert(decrypted == message);

  ubyte[crypto_secretbox_KEYBYTES] k;
  crypto_secretbox_keygen(k);
}
