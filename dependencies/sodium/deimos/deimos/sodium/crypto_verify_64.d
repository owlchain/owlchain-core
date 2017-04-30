/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_verify_64_H
*/

module deimos.sodium.crypto_verify_64;


extern(C) pure @nogc:


enum crypto_verify_64_BYTES = 64U;

size_t crypto_verify_64_bytes() @trusted;

int crypto_verify_64(const(ubyte)* x, const(ubyte)* y) nothrow @system; // __attribute__ ((warn_unused_result))
