/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_shorthash_siphash24_H
*/

module deimos.sodium.crypto_shorthash_siphash24;


extern(C) pure @nogc :

/* -- 64-bit output -- */

enum crypto_shorthash_siphash24_BYTES = 8U;

size_t crypto_shorthash_siphash24_bytes() @trusted;

enum crypto_shorthash_siphash24_KEYBYTES = 16U;

size_t crypto_shorthash_siphash24_keybytes() @trusted;

int crypto_shorthash_siphash24(ubyte* out_, const(ubyte)* in_,
                               ulong inlen, const(ubyte)* k) @system;

version(SODIUM_LIBRARY_MINIMAL) {}
else {
/* -- 128-bit output -- */

enum crypto_shorthash_siphashx24_BYTES = 16U;

size_t crypto_shorthash_siphashx24_bytes() @trusted;

enum crypto_shorthash_siphashx24_KEYBYTES = 16U;

size_t crypto_shorthash_siphashx24_keybytes() @trusted;

int crypto_shorthash_siphashx24(ubyte* out_, const(ubyte)* in_,
                                ulong inlen, const(ubyte)* k) @system;
}
