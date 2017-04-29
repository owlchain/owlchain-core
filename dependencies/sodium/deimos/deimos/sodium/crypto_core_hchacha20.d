/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_core_hchacha20_H
*/

module deimos.sodium.crypto_core_hchacha20;


extern(C) pure @nogc :


enum crypto_core_hchacha20_OUTPUTBYTES = 32U;

size_t crypto_core_hchacha20_outputbytes() @trusted;

enum crypto_core_hchacha20_INPUTBYTES = 16U;

size_t crypto_core_hchacha20_inputbytes() @trusted;

enum crypto_core_hchacha20_KEYBYTES = 32U;

size_t crypto_core_hchacha20_keybytes() @trusted;

enum crypto_core_hchacha20_CONSTBYTES = 16U;

size_t crypto_core_hchacha20_constbytes() @trusted;

int crypto_core_hchacha20(ubyte* out_, const(ubyte)* in_,
                          const(ubyte)* k, const(ubyte)* c) @system;
