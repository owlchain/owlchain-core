/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_auth_hmacsha256_H
*/

module deimos.sodium.crypto_auth_hmacsha256;

import deimos.sodium.crypto_hash_sha256 : crypto_hash_sha256_state;


extern(C) pure @nogc :


enum crypto_auth_hmacsha256_BYTES = 32U;

size_t crypto_auth_hmacsha256_bytes() @trusted;

enum crypto_auth_hmacsha256_KEYBYTES = 32U;

size_t crypto_auth_hmacsha256_keybytes() @trusted;

int crypto_auth_hmacsha256(ubyte* out_,
                           const(ubyte)* in_,
                           ulong inlen,
                           const(ubyte)* k) @system;

int crypto_auth_hmacsha256_verify(const(ubyte)* h,
                                  const(ubyte)* in_,
                                  ulong inlen,
                                  const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result));

/* ------------------------------------------------------------------------- */

struct crypto_auth_hmacsha256_state {
    crypto_hash_sha256_state ictx;
    crypto_hash_sha256_state octx;
}

size_t crypto_auth_hmacsha256_statebytes() @trusted;

int crypto_auth_hmacsha256_init(crypto_auth_hmacsha256_state* state,
                                const(ubyte)* key,
                                size_t keylen) @system;

int crypto_auth_hmacsha256_update(crypto_auth_hmacsha256_state* state,
                                  const(ubyte)* in_,
                                  ulong inlen) @system;

int crypto_auth_hmacsha256_final(crypto_auth_hmacsha256_state* state,
                                 ubyte* out_) @system;

void crypto_auth_hmacsha256_keygen(ref ubyte[crypto_auth_hmacsha256_KEYBYTES] k) nothrow @trusted;
