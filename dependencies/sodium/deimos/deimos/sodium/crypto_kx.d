/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_kx_H
*/

module deimos.sodium.crypto_kx;


extern(C) pure @nogc :


enum crypto_kx_PUBLICKEYBYTES = 32;

size_t crypto_kx_publickeybytes() @trusted;

enum crypto_kx_SECRETKEYBYTES = 32;

size_t crypto_kx_secretkeybytes() @trusted;

enum crypto_kx_SEEDBYTES = 32;

size_t crypto_kx_seedbytes() @trusted;

enum crypto_kx_SESSIONKEYBYTES = 32;

size_t crypto_kx_sessionkeybytes() @trusted;

enum crypto_kx_PRIMITIVE = "x25519blake2b";

const(char)* crypto_kx_primitive() @trusted;

int crypto_kx_seed_keypair(ref ubyte[crypto_kx_PUBLICKEYBYTES] pk,
                           ref ubyte[crypto_kx_SECRETKEYBYTES] sk,
                           ref const(ubyte)[crypto_kx_SEEDBYTES] seed) @system;

int crypto_kx_keypair(ref ubyte[crypto_kx_PUBLICKEYBYTES] pk,
                      ref ubyte[crypto_kx_SECRETKEYBYTES] sk) @system;

int crypto_kx_client_session_keys(ref ubyte[crypto_kx_SESSIONKEYBYTES] rx,
                                  ref ubyte[crypto_kx_SESSIONKEYBYTES] tx,
                                  ref const(ubyte)[crypto_kx_PUBLICKEYBYTES] client_pk,
                                  ref const(ubyte)[crypto_kx_SECRETKEYBYTES] client_sk,
                                  ref const(ubyte)[crypto_kx_PUBLICKEYBYTES] server_pk) nothrow @system; //  __attribute__ ((warn_unused_result));

int crypto_kx_server_session_keys(ref ubyte[crypto_kx_SESSIONKEYBYTES] rx,
                                  ref ubyte[crypto_kx_SESSIONKEYBYTES] tx,
                                  ref const(ubyte)[crypto_kx_PUBLICKEYBYTES] server_pk,
                                  ref const(ubyte)[crypto_kx_SECRETKEYBYTES] server_sk,
                                  ref const(ubyte)[crypto_kx_PUBLICKEYBYTES] client_pk) nothrow @system; //  __attribute__ ((warn_unused_result));
