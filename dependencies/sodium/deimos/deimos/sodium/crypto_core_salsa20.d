/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_core_salsa20_H
*/

module deimos.sodium.crypto_core_salsa20;


extern(C) pure @nogc :


enum crypto_core_salsa20_OUTPUTBYTES = 64U;

size_t crypto_core_salsa20_outputbytes() @trusted;

enum crypto_core_salsa20_INPUTBYTES = 16U;

size_t crypto_core_salsa20_inputbytes() @trusted;

enum crypto_core_salsa20_KEYBYTES = 32U;

size_t crypto_core_salsa20_keybytes() @trusted;

enum crypto_core_salsa20_CONSTBYTES = 16U;

size_t crypto_core_salsa20_constbytes() @trusted;

int crypto_core_salsa20(ubyte* out_, const(ubyte)* in_,
                        const(ubyte)* k, const(ubyte)* c) @system;
