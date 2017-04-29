/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_hash_sha256_H
*/

module deimos.sodium.crypto_hash_sha256;

/*
 * WARNING: Unless you absolutely need to use SHA256 for interoperatibility,
 * purposes, you might want to consider crypto_generichash() instead.
 * Unlike SHA256, crypto_generichash() is not vulnerable to length
 * extension attacks.
 */


extern(C) pure @nogc :


struct crypto_hash_sha256_state {
    uint[8]   state;
    ulong[2]  count;
    ubyte[64] buf;
}

size_t crypto_hash_sha256_statebytes() @trusted;

enum crypto_hash_sha256_BYTES = 32U;

size_t crypto_hash_sha256_bytes() @trusted;

int crypto_hash_sha256(ubyte* out_, const(ubyte)* in_,
                       ulong inlen) @system;

int crypto_hash_sha256_init(crypto_hash_sha256_state* state) @system;

int crypto_hash_sha256_update(crypto_hash_sha256_state* state,
                              const(ubyte)* in_,
                              ulong inlen) @system;

int crypto_hash_sha256_final(crypto_hash_sha256_state* state,
                             ubyte* out_) @system;
