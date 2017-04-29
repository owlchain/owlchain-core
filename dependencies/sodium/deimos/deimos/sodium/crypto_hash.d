/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_hash_H
*/

module deimos.sodium.crypto_hash;

/*
 * WARNING: Unless you absolutely need to use SHA512 for interoperatibility,
 * purposes, you might want to consider crypto_generichash() instead.
 * Unlike SHA512, crypto_generichash() is not vulnerable to length
 * extension attacks.
 */

import deimos.sodium.crypto_hash_sha512 : crypto_hash_sha512_BYTES;


extern(C) pure @nogc :


alias crypto_hash_BYTES = crypto_hash_sha512_BYTES;

size_t crypto_hash_bytes() @trusted;

int crypto_hash(ubyte* out_, const(ubyte)* in_,
                ulong inlen) @system;

enum crypto_hash_PRIMITIVE = "sha512";

const(char)* crypto_hash_primitive() nothrow @system; // __attribute__ ((warn_unused_result));
