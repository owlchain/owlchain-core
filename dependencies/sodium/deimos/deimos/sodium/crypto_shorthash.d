/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_shorthash_H
*/

module deimos.sodium.crypto_shorthash;

import deimos.sodium.crypto_shorthash_siphash24 : crypto_shorthash_siphash24_BYTES,
                                                  crypto_shorthash_siphash24_KEYBYTES;


extern(C) pure @nogc :


alias crypto_shorthash_BYTES = crypto_shorthash_siphash24_BYTES;

size_t  crypto_shorthash_bytes() @trusted;

alias crypto_shorthash_KEYBYTES = crypto_shorthash_siphash24_KEYBYTES;

size_t  crypto_shorthash_keybytes() @trusted;

enum crypto_shorthash_PRIMITIVE = "siphash24";

const(char)* crypto_shorthash_primitive() @system;

int crypto_shorthash(ubyte* out_, const(ubyte)* in_,
                     ulong inlen, const(ubyte)* k) @system;

void crypto_shorthash_keygen(ref ubyte[crypto_shorthash_KEYBYTES] k) nothrow @trusted;
