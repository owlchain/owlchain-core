/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define sodium_runtime_H
*/

module deimos.sodium.runtime;


extern(C) pure /*nothrow*/ @nogc @trusted :


int sodium_runtime_has_neon();

int sodium_runtime_has_sse2();

int sodium_runtime_has_sse3();

int sodium_runtime_has_ssse3();

int sodium_runtime_has_sse41();

int sodium_runtime_has_avx();

int sodium_runtime_has_avx2();  // not available in version 1.0.8

int sodium_runtime_has_pclmul();

int sodium_runtime_has_aesni();
