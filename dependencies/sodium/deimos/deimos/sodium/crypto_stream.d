/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_stream_H
*/

module deimos.sodium.crypto_stream;

/*
 *  WARNING: This is just a stream cipher. It is NOT authenticated encryption.
 *  While it provides some protection against eavesdropping, it does NOT
 *  provide any security against active attacks.
 *  Unless you know what you're doing, what you are looking for is probably
 *  the crypto_box functions.
 */


import deimos.sodium.crypto_stream_xsalsa20 : crypto_stream_xsalsa20_KEYBYTES,
                                              crypto_stream_xsalsa20_NONCEBYTES;


extern(C) pure @nogc :


alias crypto_stream_KEYBYTES = crypto_stream_xsalsa20_KEYBYTES;

size_t  crypto_stream_keybytes() @trusted;

alias crypto_stream_NONCEBYTES = crypto_stream_xsalsa20_NONCEBYTES;

size_t  crypto_stream_noncebytes() @trusted;

enum crypto_stream_PRIMITIVE = "xsalsa20";

const(char)* crypto_stream_primitive() @system;

int crypto_stream(ubyte* c, ulong clen,
                  const(ubyte)* n, const(ubyte)* k) @system;

int crypto_stream_xor(ubyte* c, const(ubyte)* m,
                      ulong mlen, const(ubyte)* n,
                      const(ubyte)* k) @system;

void crypto_stream_keygen(ref ubyte[crypto_stream_KEYBYTES] k) nothrow @trusted;
