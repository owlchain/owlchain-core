// Written in the D programming language.

module wrapper.sodium.crypto_box;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_box : crypto_box_SEEDBYTES,
                                   crypto_box_seedbytes,
                                   crypto_box_PUBLICKEYBYTES,
                                   crypto_box_publickeybytes,
                                   crypto_box_SECRETKEYBYTES,
                                   crypto_box_secretkeybytes,
                                   crypto_box_NONCEBYTES,
                                   crypto_box_noncebytes,
                                   crypto_box_MACBYTES,
                                   crypto_box_macbytes,
                                   crypto_box_PRIMITIVE,
                                   crypto_box_BEFORENMBYTES,
                                   crypto_box_beforenmbytes,
                                   crypto_box_beforenm,
                                   crypto_box_easy_afternm,
                                   crypto_box_open_easy_afternm,
                                   crypto_box_detached_afternm,
                                   crypto_box_open_detached_afternm,
                                   crypto_box_SEALBYTES,
                                   crypto_box_sealbytes,
                                   crypto_box_ZEROBYTES,
                                   crypto_box_zerobytes,
                                   crypto_box_BOXZEROBYTES,
                                   crypto_box_boxzerobytes,
                                   crypto_box,
                                   crypto_box_open,
                                   crypto_box_afternm,
                                   crypto_box_open_afternm;

/*
//crypto_box_primitive(), crypto_box_seed_keypair, crypto_box_keypair, crypto_box_easy, crypto_box_open_easy, crypto_box_detached, crypto_box_open_detached,
//crypto_box_seal, crypto_box_seal_open
*/

import std.exception : enforce, assertThrown;



string crypto_box_primitive() pure nothrow @nogc @trusted
{
  import std.string : fromStringz;
  static import deimos.sodium.crypto_box;
  const(char)[] c_arr;
  try
    c_arr = fromStringz(deimos.sodium.crypto_box.crypto_box_primitive()); // strips terminating \0
  catch (Throwable t) { /* known not to throw */ }
  return c_arr;
}

// overloading some functions between module deimos.sodium.crypto_box and this module


alias crypto_box_seed_keypair   = deimos.sodium.crypto_box.crypto_box_seed_keypair;

/**
 * Using crypto_box_seed_keypair(), the key pair can be deterministically derived from a single key `seed`.
 */
pragma(inline, true)
bool crypto_box_seed_keypair(out ubyte[crypto_box_PUBLICKEYBYTES] pkey, out ubyte[crypto_box_SECRETKEYBYTES] skey,
                             in ubyte[crypto_box_SEEDBYTES] seed) pure @nogc @trusted
{
  static import deimos.sodium.crypto_box;
  return  deimos.sodium.crypto_box.crypto_box_seed_keypair(pkey.ptr, skey.ptr, seed.ptr) == 0;
}

alias crypto_box_keypair        = deimos.sodium.crypto_box.crypto_box_keypair;

/**
 * The crypto_box_keypair() function randomly generates a secret key and a corresponding public key.
 * The public key is put into `pkey` and the secret key into `skey`.
 */
pragma(inline, true)
bool crypto_box_keypair(out ubyte[crypto_box_PUBLICKEYBYTES] pkey, out ubyte[crypto_box_SECRETKEYBYTES] skey) @nogc @trusted
{
  static import deimos.sodium.crypto_box;
  return  deimos.sodium.crypto_box.crypto_box_keypair(pkey.ptr, skey.ptr) == 0;
}

alias crypto_box_easy           = deimos.sodium.crypto_box.crypto_box_easy;

/**
 */
bool crypto_box_easy(scope ubyte[] c, in ubyte[] m, in ubyte[crypto_box_NONCEBYTES] n,
                     in ubyte[crypto_box_PUBLICKEYBYTES] pkey, in ubyte[crypto_box_SECRETKEYBYTES] skey) pure @trusted
{
  enforce(c.length >= crypto_box_MACBYTES + m.length, "Error in crypto_box_easy: c.length < crypto_box_MACBYTES + m.length");
  static import deimos.sodium.crypto_box;
  return  deimos.sodium.crypto_box.crypto_box_easy(c.ptr, m.ptr, m.length, n.ptr, pkey.ptr, skey.ptr) == 0;
}

alias crypto_box_open_easy      = deimos.sodium.crypto_box.crypto_box_open_easy;

/**
 */
bool crypto_box_open_easy(scope ubyte[] m, in ubyte[] c, in ubyte[crypto_box_NONCEBYTES] n,
                          in ubyte[crypto_box_PUBLICKEYBYTES] pkey, in ubyte[crypto_box_SECRETKEYBYTES] skey) pure @trusted
{
  enforce(m.length >= c.length - crypto_box_MACBYTES, "Error in crypto_box_easy: m.length < c.length - crypto_box_MACBYTES");
  static import deimos.sodium.crypto_box;
  return  deimos.sodium.crypto_box.crypto_box_open_easy(m.ptr, c.ptr, c.length, n.ptr, pkey.ptr, skey.ptr) == 0;
}

alias crypto_box_detached       = deimos.sodium.crypto_box.crypto_box_detached;

/**
 */
bool crypto_box_detached(scope ubyte[] c, out ubyte[crypto_box_MACBYTES] mac, in ubyte[] m, in ubyte[crypto_box_NONCEBYTES] n,
                         in ubyte[crypto_box_PUBLICKEYBYTES] pkey, in ubyte[crypto_box_SECRETKEYBYTES] skey) pure @trusted
{
  enforce(c.length >= m.length, "Error in crypto_box_easy: c.length < m.length");
  static import deimos.sodium.crypto_box;
  return  deimos.sodium.crypto_box.crypto_box_detached(c.ptr, mac.ptr, m.ptr, m.length, n.ptr, pkey.ptr, skey.ptr) == 0;
}

alias crypto_box_open_detached  = deimos.sodium.crypto_box.crypto_box_open_detached;

/**
 */
bool crypto_box_open_detached(scope ubyte[] m, in ubyte[] c, in ubyte[crypto_box_MACBYTES] mac, in ubyte[crypto_box_NONCEBYTES] n,
                              in ubyte[crypto_box_PUBLICKEYBYTES] pkey, in ubyte[crypto_box_SECRETKEYBYTES] skey) pure @trusted
{
  enforce(m.length >= c.length, "Error in crypto_box_easy: m.length < c.length");
  static import deimos.sodium.crypto_box;
  return  deimos.sodium.crypto_box.crypto_box_open_detached(m.ptr, c.ptr, mac.ptr, c.length, n.ptr, pkey.ptr, skey.ptr) == 0;
}

/* No overloads for -- Precomputation interface -- */

/* -- Ephemeral SK interface -- */

alias crypto_box_seal           = deimos.sodium.crypto_box.crypto_box_seal;

/**
 * The crypto_box_seal() function encrypts a message `m` for a recipient whose public key is `pkey`.
 * It puts the ciphertext whose length is crypto_box_SEALBYTES + m.length into `c`.
 * The function creates a new key pair for each message, and attaches the public key to the ciphertext.
 * The secret key is overwritten and is not accessible after this function returns.
 */
bool crypto_box_seal(scope ubyte[] c, in ubyte[] m, in ubyte[crypto_box_PUBLICKEYBYTES] pkey) pure @trusted
{
  enforce(c.length >= crypto_box_SEALBYTES + m.length, "Error in crypto_box_seal: c.length >= crypto_box_SEALBYTES + m.length");
  static import deimos.sodium.crypto_box;
  return  deimos.sodium.crypto_box.crypto_box_seal(c.ptr, m.ptr, m.length, pkey.ptr) == 0;
}

alias crypto_box_seal_open      = deimos.sodium.crypto_box.crypto_box_seal_open;

/**
 */
bool crypto_box_seal_open(scope ubyte[] m, in ubyte[] c,
                          in ubyte[crypto_box_PUBLICKEYBYTES] pkey, in ubyte[crypto_box_SECRETKEYBYTES] skey) pure @trusted
{
  enforce(m.length >= c.length - crypto_box_SEALBYTES, "Error in crypto_box_seal_open: m.length < c.length - crypto_box_SEALBYTES");
  static import deimos.sodium.crypto_box;
  return  deimos.sodium.crypto_box.crypto_box_seal_open(m.ptr, c.ptr, c.length, pkey.ptr, skey.ptr) == 0;
}

/* No overloads for -- NaCl compatibility interface ; Requires padding -- */


@safe
unittest {
  import std.string : representation;
  import std.stdio : writeln;
  import wrapper.sodium.randombytes : randombytes;
  import wrapper.sodium.utils : sodium_increment;

  debug writeln("unittest block 1 from sodium.crypto_box.d");

  assert(crypto_box_seedbytes()      == crypto_box_SEEDBYTES);
  assert(crypto_box_publickeybytes() == crypto_box_PUBLICKEYBYTES);
  assert(crypto_box_secretkeybytes() == crypto_box_SECRETKEYBYTES);
  assert(crypto_box_noncebytes()     == crypto_box_NONCEBYTES);
  assert(crypto_box_macbytes()       == crypto_box_MACBYTES);
  assert(crypto_box_primitive()      == crypto_box_PRIMITIVE);



  auto message = representation("test");
  // avoid heap allocation, like in the example code
  enum MESSAGE_LEN = 4;
  enum CIPHERTEXT_LEN = (crypto_box_MACBYTES + MESSAGE_LEN);

  ubyte[crypto_box_PUBLICKEYBYTES]  alice_publickey = void;
  ubyte[crypto_box_SECRETKEYBYTES]  alice_secretkey = void;
  crypto_box_keypair(alice_publickey, alice_secretkey);
  // check crypto_scalarmult_base (compute alice_publickey from alice_secretkey)
  {
    import wrapper.sodium.crypto_scalarmult;
    assert(crypto_scalarmult_BYTES       == crypto_box_PUBLICKEYBYTES);
    assert(crypto_scalarmult_SCALARBYTES == crypto_box_SECRETKEYBYTES);
    ubyte[crypto_box_PUBLICKEYBYTES]  alice_publickey_computed;
    assert(crypto_scalarmult_base(alice_publickey_computed, alice_secretkey));
    assert(alice_publickey_computed == alice_publickey);
  }

  ubyte[crypto_box_PUBLICKEYBYTES]  bob_publickey = void;
  ubyte[crypto_box_SECRETKEYBYTES]  bob_secretkey = void;
  crypto_box_keypair(bob_publickey, bob_secretkey);

  ubyte[crypto_box_NONCEBYTES] nonce = void;
  ubyte[CIPHERTEXT_LEN] ciphertext   = void;
  randombytes(nonce);
  // Alice encrypts message for Bob
  assertThrown(crypto_box_easy(ciphertext[0..$-1], message, nonce, bob_publickey, alice_secretkey));
  assert(crypto_box_easy(ciphertext, message, nonce, bob_publickey, alice_secretkey));
//  { /* error */ }

  ubyte[MESSAGE_LEN] decrypted = void;
  // Bob decrypts ciphertext from Alice
  assertThrown(crypto_box_open_easy(decrypted[0..$-1], ciphertext, nonce, alice_publickey, bob_secretkey));
  assert(crypto_box_open_easy(decrypted, ciphertext, nonce, alice_publickey, bob_secretkey));
//  { /* message for Bob pretending to be from Alice has been forged! */ }
  assert(decrypted == message);
//
  ubyte[crypto_box_MACBYTES]  mac = void;
  ciphertext = ubyte.init;
  decrypted  = ubyte.init;
  sodium_increment(nonce);
  assertThrown(crypto_box_detached(ciphertext[0..$-1-crypto_box_MACBYTES], mac, message, nonce, bob_publickey, alice_secretkey));
  assert(crypto_box_detached(ciphertext, mac, message, nonce, bob_publickey, alice_secretkey));

  assertThrown(crypto_box_open_detached(decrypted[0..$-1], ciphertext[0..$-crypto_box_MACBYTES], mac, nonce, alice_publickey, bob_secretkey));
  assert(crypto_box_open_detached(decrypted, ciphertext[0..$-crypto_box_MACBYTES], mac, nonce, alice_publickey, bob_secretkey));
//  { /* message for Bob pretending to be from Alice has been forged! */ }
  assert(decrypted == message);

//
  assert(crypto_box_sealbytes()      == crypto_box_SEALBYTES);

  enum CIPHERTEXTSEALED_LEN = (crypto_box_SEALBYTES + MESSAGE_LEN);
  ubyte[CIPHERTEXTSEALED_LEN] ciphertext_sealed = void;
  decrypted  = ubyte.init;

  assertThrown(crypto_box_seal(ciphertext_sealed[0..$-1], message, bob_publickey));
  assert(crypto_box_seal(ciphertext_sealed, message, bob_publickey));

  assertThrown(crypto_box_seal_open(decrypted[0..$-1], ciphertext_sealed, bob_publickey, bob_secretkey));
  assert(crypto_box_seal_open(decrypted, ciphertext_sealed, bob_publickey, bob_secretkey));
  assert(decrypted == message);

  ubyte[crypto_box_PUBLICKEYBYTES] pkey = void;
  ubyte[crypto_box_SECRETKEYBYTES] skey = void;
  ubyte[crypto_box_SEEDBYTES]      seed = void;
  randombytes(seed);
  assert(crypto_box_seed_keypair(pkey, skey, seed));
}
