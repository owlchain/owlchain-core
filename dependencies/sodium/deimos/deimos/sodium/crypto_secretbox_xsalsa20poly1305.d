/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_secretbox_xsalsa20poly1305_H
*/

module deimos.sodium.crypto_secretbox_xsalsa20poly1305;


extern(C) pure @nogc :


enum crypto_secretbox_xsalsa20poly1305_KEYBYTES = 32U;

size_t crypto_secretbox_xsalsa20poly1305_keybytes() @trusted;

enum crypto_secretbox_xsalsa20poly1305_NONCEBYTES = 24U;

size_t crypto_secretbox_xsalsa20poly1305_noncebytes() @trusted;

enum crypto_secretbox_xsalsa20poly1305_MACBYTES = 16U;

size_t crypto_secretbox_xsalsa20poly1305_macbytes() @trusted;

enum crypto_secretbox_xsalsa20poly1305_BOXZEROBYTES = 16U;

size_t crypto_secretbox_xsalsa20poly1305_boxzerobytes() @trusted;

enum crypto_secretbox_xsalsa20poly1305_ZEROBYTES =
    (crypto_secretbox_xsalsa20poly1305_BOXZEROBYTES +
     crypto_secretbox_xsalsa20poly1305_MACBYTES);

size_t crypto_secretbox_xsalsa20poly1305_zerobytes() @trusted;

int crypto_secretbox_xsalsa20poly1305(ubyte* c,
                                      const(ubyte)* m,
                                      ulong mlen,
                                      const(ubyte)* n,
                                      const(ubyte)* k) @system;

int crypto_secretbox_xsalsa20poly1305_open(ubyte* m,
                                           const(ubyte)* c,
                                           ulong clen,
                                           const(ubyte)* n,
                                           const(ubyte)* k) nothrow @system; //  __attribute__ ((warn_unused_result));

void crypto_secretbox_xsalsa20poly1305_keygen(ref ubyte[crypto_secretbox_xsalsa20poly1305_KEYBYTES] k) nothrow @system;
