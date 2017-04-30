/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_scalarmult_H
*/

module deimos.sodium.crypto_scalarmult;

import deimos.sodium.crypto_scalarmult_curve25519 : crypto_scalarmult_curve25519_BYTES,
                                                    crypto_scalarmult_curve25519_SCALARBYTES;


extern(C) pure @nogc :


alias crypto_scalarmult_BYTES = crypto_scalarmult_curve25519_BYTES;

size_t  crypto_scalarmult_bytes() @trusted;

alias crypto_scalarmult_SCALARBYTES = crypto_scalarmult_curve25519_SCALARBYTES;

size_t  crypto_scalarmult_scalarbytes() @trusted;

enum crypto_scalarmult_PRIMITIVE = "curve25519";

const(char)* crypto_scalarmult_primitive() @system;

int crypto_scalarmult_base(ubyte* q, const(ubyte)* n) @system;

int crypto_scalarmult(ubyte* q, const(ubyte)* n,
                      const(ubyte)* p) nothrow @system; // __attribute__ ((warn_unused_result));
