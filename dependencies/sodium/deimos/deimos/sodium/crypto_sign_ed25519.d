/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_sign_ed25519_H
*/

module deimos.sodium.crypto_sign_ed25519;

import deimos.sodium.crypto_hash_sha512;


extern(C) @nogc :


struct crypto_sign_ed25519ph_state {
    crypto_hash_sha512_state hs;
}

size_t crypto_sign_ed25519ph_statebytes() pure @trusted;

enum crypto_sign_ed25519_BYTES = 64U;

size_t crypto_sign_ed25519_bytes() pure @trusted;

enum crypto_sign_ed25519_SEEDBYTES = 32U;

size_t crypto_sign_ed25519_seedbytes() pure @trusted;

enum crypto_sign_ed25519_PUBLICKEYBYTES = 32U;

size_t crypto_sign_ed25519_publickeybytes() pure @trusted;

enum crypto_sign_ed25519_SECRETKEYBYTES = (32U + 32U);

size_t crypto_sign_ed25519_secretkeybytes() pure @trusted;

int crypto_sign_ed25519(ubyte* sm, ulong* smlen_p,
                        const(ubyte)* m, ulong mlen,
                        const(ubyte)* sk) pure @system;

int crypto_sign_ed25519_open(ubyte* m, ulong* mlen_p,
                             const(ubyte)* sm, ulong smlen,
                             const(ubyte)* pk) pure nothrow @system; //  __attribute__ ((warn_unused_result))

int crypto_sign_ed25519_detached(ubyte* sig,
                                 ulong* siglen_p,
                                 const(ubyte)* m,
                                 ulong mlen,
                                 const(ubyte)* sk) pure @system;

int crypto_sign_ed25519_verify_detached(const(ubyte)* sig,
                                        const(ubyte)* m,
                                        ulong mlen,
                                        const(ubyte)* pk) pure nothrow @system; //  __attribute__ ((warn_unused_result))

int crypto_sign_ed25519_keypair(ubyte* pk, ubyte* sk) @system;

int crypto_sign_ed25519_seed_keypair(ubyte* pk, ubyte* sk,
                                     const(ubyte)* seed) pure @system;

int crypto_sign_ed25519_pk_to_curve25519(ubyte* curve25519_pk,
                                         const(ubyte)* ed25519_pk) pure nothrow @system; //  __attribute__ ((warn_unused_result))

int crypto_sign_ed25519_sk_to_curve25519(ubyte* curve25519_sk,
                                         const(ubyte)* ed25519_sk) pure @system;

int crypto_sign_ed25519_sk_to_seed(ubyte* seed,
                                   const(ubyte)* sk) pure @system;

int crypto_sign_ed25519_sk_to_pk(ubyte* pk, const(ubyte)* sk) pure @system;

int crypto_sign_ed25519ph_init(crypto_sign_ed25519ph_state* state) pure @system;

int crypto_sign_ed25519ph_update(crypto_sign_ed25519ph_state* state,
                                 const(ubyte)* m,
                                 ulong mlen) pure @system;

int crypto_sign_ed25519ph_final_create(crypto_sign_ed25519ph_state* state,
                                       ubyte* sig,
                                       ulong* siglen_p,
                                       const(ubyte)* sk) pure @system;

int crypto_sign_ed25519ph_final_verify(crypto_sign_ed25519ph_state* state,
                                       ubyte* sig,
                                       const(ubyte)* pk) pure nothrow @system; //  __attribute__ ((warn_unused_result));
