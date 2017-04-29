/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_hash_sha512_H
*/

module deimos.sodium.crypto_hash_sha512;

/*
 * WARNING: Unless you absolutely need to use SHA512 for interoperatibility,
 * purposes, you might want to consider crypto_generichash() instead.
 * Unlike SHA512, crypto_generichash() is not vulnerable to length
 * extension attacks.
 */


extern(C) pure @nogc :


struct crypto_hash_sha512_state {
    ulong[8]   state;
    ulong[2]   count;
    ubyte[128] buf;
}


size_t crypto_hash_sha512_statebytes() @trusted;

enum crypto_hash_sha512_BYTES = 64U;

size_t crypto_hash_sha512_bytes() @trusted;

int crypto_hash_sha512(ubyte* out_, const(ubyte)* in_,
                       ulong inlen) @system;

int crypto_hash_sha512_init(crypto_hash_sha512_state* state) @system;

int crypto_hash_sha512_update(crypto_hash_sha512_state* state,
                              const(ubyte)* in_,
                              ulong inlen) @system;

int crypto_hash_sha512_final(crypto_hash_sha512_state* state,
                             ubyte* out_) @system;
