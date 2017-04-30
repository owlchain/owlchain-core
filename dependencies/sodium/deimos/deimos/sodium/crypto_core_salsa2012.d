/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_core_salsa2012_H
*/

module deimos.sodium.crypto_core_salsa2012;


extern(C) pure @nogc :


enum crypto_core_salsa2012_OUTPUTBYTES = 64U;

size_t crypto_core_salsa2012_outputbytes() @trusted;

enum crypto_core_salsa2012_INPUTBYTES = 16U;

size_t crypto_core_salsa2012_inputbytes() @trusted;

enum crypto_core_salsa2012_KEYBYTES = 32U;

size_t crypto_core_salsa2012_keybytes() @trusted;

enum crypto_core_salsa2012_CONSTBYTES = 16U;

size_t crypto_core_salsa2012_constbytes() @trusted;

int crypto_core_salsa2012(ubyte* out_, const(ubyte)* in_,
                          const(ubyte)* k, const(ubyte)* c) @system;
