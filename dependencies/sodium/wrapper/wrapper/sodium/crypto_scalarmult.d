// Written in the D programming language.

module wrapper.sodium.crypto_scalarmult;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_scalarmult : crypto_scalarmult_BYTES,
                                          crypto_scalarmult_bytes,
                                          crypto_scalarmult_SCALARBYTES,
                                          crypto_scalarmult_scalarbytes,
                                          crypto_scalarmult_PRIMITIVE;
//                                          crypto_scalarmult_primitive,
//                                          crypto_scalarmult_base,
//                                          crypto_scalarmult;

import wrapper.sodium.crypto_generichash : crypto_generichash_state,
                                           crypto_generichash_BYTES,
                                           crypto_generichash_init,
                                           crypto_generichash_update,
                                           crypto_generichash_final,
                                           crypto_generichash_BYTES_MIN,
                                           crypto_generichash_BYTES_MAX,
                                           crypto_generichash_multi;

import std.exception : enforce;


string crypto_scalarmult_primitive() pure nothrow @nogc @trusted
{
  import std.string : fromStringz;
  static import deimos.sodium.crypto_scalarmult;
  const(char)[] c_arr;
  try
    c_arr = fromStringz(deimos.sodium.crypto_scalarmult.crypto_scalarmult_primitive()); // strips terminating \0
  catch (Throwable t) { /* known not to throw */ }
  return c_arr;
}

/**
 * This function may be part of the keyexchange procedure:
 * It takes over from the arguments given, invokes crypto_scalarmult und results in the hashed our_sharedkey as proposed in the documentaion.
 * There is no heap allocation for secrets, yet enforce may require heap memory, thus inhibiting the attribute @nogc.
 * It may throw in error conditions.
 */
void sharedkey_hashed(scope ubyte[] our_sharedkey, in ubyte[crypto_scalarmult_SCALARBYTES] my_secretkey, in ubyte[crypto_scalarmult_BYTES] my_publickey,
  in bool my_pubkey_hashed_first, in ubyte[crypto_scalarmult_BYTES] other_publickey) pure @trusted
{
  /* I derive a shared key from my secret key and the other's public key */
  /* shared key = hash(q || client_publickey || server_publickey) */
  ubyte[crypto_scalarmult_BYTES]  our_scalarmult_q; // = new ubyte[crypto_scalarmult_BYTES];
  enforce( crypto_scalarmult(our_scalarmult_q, my_secretkey, other_publickey), "sharedkey_hashed: Error result from calling crypto_scalarmult");
  /+ are there security concerns to pass our_scalarmult_q through RAM/cache ?
  import wrapper.sodium.utils : sodium_memzero;
  ubyte[][] MESSAGE_multi = [
    our_scalarmult_q,
    (my_pubkey_hashed_first? my_publickey.dup    : other_publickey.dup),
    (my_pubkey_hashed_first? other_publickey.dup : my_publickey.dup)
  ];
  scope(exit) sodium_memzero(MESSAGE_multi[0]);
  crypto_generichash_multi(our_sharedkey, MESSAGE_multi);
  +/
  enforce(our_sharedkey.length >= crypto_generichash_BYTES_MIN && our_sharedkey.length <= crypto_generichash_BYTES_MAX, "wrong length allocated for hash");
  crypto_generichash_state state;
  crypto_generichash_init  (&state, null, 0, our_sharedkey.length);
  crypto_generichash_update(&state, our_scalarmult_q.ptr, our_scalarmult_q.length);
  if (my_pubkey_hashed_first) {
    crypto_generichash_update(&state, my_publickey.ptr,    my_publickey.length);
    crypto_generichash_update(&state, other_publickey.ptr, other_publickey.length);
  }
  else {
    crypto_generichash_update(&state, other_publickey.ptr, other_publickey.length);
    crypto_generichash_update(&state, my_publickey.ptr,    my_publickey.length);
  }
  crypto_generichash_final (&state, our_sharedkey.ptr, our_sharedkey.length);
 }

alias crypto_scalarmult_base = deimos.sodium.crypto_scalarmult.crypto_scalarmult_base;

pragma(inline, true)
bool crypto_scalarmult_base(out ubyte[crypto_scalarmult_BYTES] q, in ubyte[crypto_scalarmult_SCALARBYTES] n) pure @nogc @trusted
{
  static import deimos.sodium.crypto_scalarmult;
  return  deimos.sodium.crypto_scalarmult.crypto_scalarmult_base(q.ptr, n.ptr) == 0;
}

alias crypto_scalarmult      = deimos.sodium.crypto_scalarmult.crypto_scalarmult;

pragma(inline, true)
bool crypto_scalarmult(out ubyte[crypto_scalarmult_BYTES] q, in ubyte[crypto_scalarmult_SCALARBYTES] n, in ubyte[crypto_scalarmult_BYTES] p) pure nothrow @nogc @trusted
{
  static import deimos.sodium.crypto_scalarmult;
  return  deimos.sodium.crypto_scalarmult.crypto_scalarmult(q.ptr, n.ptr, p.ptr) == 0;
}


@system
unittest
{
  import std.stdio : writeln;
  import wrapper.sodium.randombytes : randombytes;
  import std.algorithm.comparison : equal;
  import std.string : fromStringz; // @system

  debug  writeln("unittest block 1 from sodium.crypto_scalarmult.d");

  assert(crypto_scalarmult_bytes()       == crypto_scalarmult_BYTES);
  assert(crypto_scalarmult_scalarbytes() == crypto_scalarmult_SCALARBYTES);
  assert(crypto_scalarmult_primitive()   == crypto_scalarmult_PRIMITIVE);


  //test keyexchange procedure

  ubyte[crypto_scalarmult_SCALARBYTES]  client_secretkey, server_secretkey;
  ubyte[crypto_scalarmult_BYTES]        client_publickey, server_publickey;
/+ +/
  ubyte[crypto_scalarmult_BYTES]    scalarmult_q_by_client;
  ubyte[crypto_scalarmult_BYTES]    scalarmult_q_by_server;
  crypto_generichash_state h;
/+ +/
  ubyte[crypto_generichash_BYTES]   sharedkey_by_client, sharedkey_by_server;

  /* Create client's secret and public keys */
  randombytes(client_secretkey);
  {
    static import deimos.sodium.crypto_scalarmult;
    deimos.sodium.crypto_scalarmult.crypto_scalarmult_base(client_publickey.ptr, client_secretkey.ptr);
  }
  /* Create server's secret and public keys */
  randombytes(server_secretkey);
  crypto_scalarmult_base(server_publickey, server_secretkey);

  /* The client derives a shared key from its secret key and the server's public key */
  /* shared key = h(q || client_publickey || server_publickey) */
  assert(crypto_scalarmult(scalarmult_q_by_client, client_secretkey, server_publickey));
  crypto_generichash_init  (&h, null, 0U, /*crypto_generichash_BYTES*/ sharedkey_by_client.length);
  crypto_generichash_update(&h, scalarmult_q_by_client.ptr, scalarmult_q_by_client.length);
  crypto_generichash_update(&h, client_publickey.ptr,       client_publickey.length);
  crypto_generichash_update(&h, server_publickey.ptr,       server_publickey.length);
  crypto_generichash_final (&h, sharedkey_by_client.ptr,    sharedkey_by_client.length);

  /* The server derives a shared key from its secret key and the client's public key */
  /* shared key = h(q || client_publickey || server_publickey) */
  assert(crypto_scalarmult(scalarmult_q_by_server, server_secretkey, client_publickey));
  assert(scalarmult_q_by_client == scalarmult_q_by_server);
  crypto_generichash_init  (&h, null, 0U, /*crypto_generichash_BYTES*/ sharedkey_by_server.length);
  crypto_generichash_update(&h, scalarmult_q_by_server.ptr, scalarmult_q_by_server.length);
  crypto_generichash_update(&h, client_publickey.ptr,       client_publickey.length);
  crypto_generichash_update(&h, server_publickey.ptr,       server_publickey.length);
  crypto_generichash_final (&h, sharedkey_by_server.ptr,    sharedkey_by_server.length);

/* sharedkey_by_client and sharedkey_by_server are identical */
  assert(sharedkey_by_client == sharedkey_by_server);
  ubyte[crypto_generichash_BYTES] sharedkey_by_client_saved = sharedkey_by_client;

  sharedkey_by_client[] = ubyte.init;
  sharedkey_by_server[] = ubyte.init;
  // same as before with less user code
  sharedkey_hashed(sharedkey_by_client, client_secretkey, client_publickey, true,  server_publickey);
  sharedkey_hashed(sharedkey_by_server, server_secretkey, server_publickey, false, client_publickey);
  assert(sharedkey_by_client == sharedkey_by_server);
  assert(sharedkey_by_client == sharedkey_by_client_saved);
}
