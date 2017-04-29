/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_sign_H
*/

module deimos.sodium.crypto_sign;

/*
 * THREAD SAFETY: crypto_sign_keypair() is thread-safe,
 * provided that you called sodium_init() once before using any
 * other libsodium function.
 * Other functions, including crypto_sign_seed_keypair() are always thread-safe.
 */

import deimos.sodium.crypto_sign_ed25519 : crypto_sign_ed25519_BYTES,
                                           crypto_sign_ed25519_SEEDBYTES,
                                           crypto_sign_ed25519_PUBLICKEYBYTES,
                                           crypto_sign_ed25519_SECRETKEYBYTES,
                                           crypto_sign_ed25519ph_state;


extern(C) @nogc :

alias crypto_sign_state = crypto_sign_ed25519ph_state;

size_t  crypto_sign_statebytes() pure @trusted;

alias crypto_sign_BYTES = crypto_sign_ed25519_BYTES;

size_t  crypto_sign_bytes() pure @trusted;

alias crypto_sign_SEEDBYTES = crypto_sign_ed25519_SEEDBYTES;

size_t  crypto_sign_seedbytes() pure @trusted;

alias crypto_sign_PUBLICKEYBYTES = crypto_sign_ed25519_PUBLICKEYBYTES;

size_t  crypto_sign_publickeybytes() pure @trusted;

alias crypto_sign_SECRETKEYBYTES = crypto_sign_ed25519_SECRETKEYBYTES;

size_t  crypto_sign_secretkeybytes() pure @trusted;

enum crypto_sign_PRIMITIVE = "ed25519";

const(char)* crypto_sign_primitive() pure @system;

int crypto_sign_seed_keypair(ubyte* pk, ubyte* sk,
                             const(ubyte)* seed) pure @system;

int crypto_sign_keypair(ubyte* pk, ubyte* sk) @system;

int crypto_sign(ubyte* sm, ulong* smlen_p,
                const(ubyte)* m, ulong mlen,
                const(ubyte)* sk) pure @system;

int crypto_sign_open(ubyte* m, ulong* mlen_p,
                     const(ubyte)* sm, ulong smlen,
                     const(ubyte)* pk) pure nothrow @system; // __attribute__ ((warn_unused_result))

int crypto_sign_detached(ubyte* sig, ulong* siglen_p,
                         const(ubyte)* m, ulong mlen,
                         const(ubyte)* sk) pure @system;

int crypto_sign_verify_detached(const(ubyte)* sig,
                                const(ubyte)* m,
                                ulong mlen,
                                const(ubyte)* pk) pure nothrow @system; // __attribute__ ((warn_unused_result))

int crypto_sign_init(crypto_sign_state* state) pure @system;

int crypto_sign_update(crypto_sign_state* state,
                       const(ubyte)* m, ulong mlen) pure @system;

int crypto_sign_final_create(crypto_sign_state* state, ubyte* sig,
                             ulong* siglen_p,
                             const(ubyte)* sk) pure @system;

int crypto_sign_final_verify(crypto_sign_state* state, ubyte* sig,
                             const(ubyte)* pk) pure nothrow @system; // __attribute__ ((warn_unused_result))
