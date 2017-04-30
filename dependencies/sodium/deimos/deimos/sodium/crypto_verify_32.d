/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_verify_32_H
*/

module deimos.sodium.crypto_verify_32;


extern(C) pure @nogc:


enum crypto_verify_32_BYTES = 32U;

size_t crypto_verify_32_bytes() @trusted;

int crypto_verify_32(const(ubyte)* x, const(ubyte)* y) nothrow @system; // __attribute__ ((warn_unused_result))
