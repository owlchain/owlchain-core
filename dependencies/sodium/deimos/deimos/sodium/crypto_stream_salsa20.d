/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_stream_salsa20_H
*/

module deimos.sodium.crypto_stream_salsa20;

/*
 *  WARNING: This is just a stream cipher. It is NOT authenticated encryption.
 *  While it provides some protection against eavesdropping, it does NOT
 *  provide any security against active attacks.
 *  Unless you know what you're doing, what you are looking for is probably
 *  the crypto_box functions.
 */


extern(C) pure @nogc :


enum crypto_stream_salsa20_KEYBYTES = 32U;

size_t crypto_stream_salsa20_keybytes() @trusted;

enum crypto_stream_salsa20_NONCEBYTES = 8U;

size_t crypto_stream_salsa20_noncebytes() @trusted;

int crypto_stream_salsa20(ubyte* c, ulong clen,
                          const(ubyte)* n, const(ubyte)* k) @system;

int crypto_stream_salsa20_xor(ubyte* c, const(ubyte)* m,
                              ulong mlen, const(ubyte)* n,
                              const(ubyte)* k) @system;

int crypto_stream_salsa20_xor_ic(ubyte* c, const(ubyte)* m,
                                 ulong mlen,
                                 const(ubyte)* n, ulong ic,
                                 const(ubyte)* k) @system;

void crypto_stream_salsa20_keygen(ref ubyte[crypto_stream_salsa20_KEYBYTES] k) @system;
