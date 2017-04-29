/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_core_salsa208_H
*/

module deimos.sodium.crypto_core_salsa208;


extern(C) pure @nogc :


enum crypto_core_salsa208_OUTPUTBYTES = 64U;

size_t crypto_core_salsa208_outputbytes() @trusted;

enum crypto_core_salsa208_INPUTBYTES = 16U;

size_t crypto_core_salsa208_inputbytes() @trusted;

enum crypto_core_salsa208_KEYBYTES = 32U;

size_t crypto_core_salsa208_keybytes() @trusted;

enum crypto_core_salsa208_CONSTBYTES = 16U;

size_t crypto_core_salsa208_constbytes() @trusted;

int crypto_core_salsa208(ubyte* out_, const(ubyte)* in_,
                         const(ubyte)* k, const(ubyte)* c) @system;
