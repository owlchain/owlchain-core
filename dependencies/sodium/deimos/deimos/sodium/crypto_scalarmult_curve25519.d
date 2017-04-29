/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_scalarmult_curve25519_H
*/

module deimos.sodium.crypto_scalarmult_curve25519;


extern(C) pure @nogc :


enum crypto_scalarmult_curve25519_BYTES = 32U;

size_t crypto_scalarmult_curve25519_bytes() @trusted;

enum crypto_scalarmult_curve25519_SCALARBYTES = 32U;

size_t crypto_scalarmult_curve25519_scalarbytes() @trusted;

int crypto_scalarmult_curve25519(ubyte* q, const(ubyte)* n,
                                 const(ubyte)* p) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_scalarmult_curve25519_base(ubyte* q, const(ubyte)* n) @system;
