/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_secretbox_H
*/

module deimos.sodium.crypto_secretbox;

import deimos.sodium.crypto_secretbox_xsalsa20poly1305 : crypto_secretbox_xsalsa20poly1305_KEYBYTES,
                                                         crypto_secretbox_xsalsa20poly1305_NONCEBYTES,
                                                         crypto_secretbox_xsalsa20poly1305_MACBYTES,
                                                         crypto_secretbox_xsalsa20poly1305_ZEROBYTES,
                                                         crypto_secretbox_xsalsa20poly1305_BOXZEROBYTES;


extern(C) pure @nogc :


alias crypto_secretbox_KEYBYTES = crypto_secretbox_xsalsa20poly1305_KEYBYTES;

size_t  crypto_secretbox_keybytes() @trusted;

alias crypto_secretbox_NONCEBYTES = crypto_secretbox_xsalsa20poly1305_NONCEBYTES;

size_t  crypto_secretbox_noncebytes() @trusted;

alias crypto_secretbox_MACBYTES = crypto_secretbox_xsalsa20poly1305_MACBYTES;

size_t  crypto_secretbox_macbytes() @trusted;

enum crypto_secretbox_PRIMITIVE = "xsalsa20poly1305";

const(char)* crypto_secretbox_primitive() @system;

int crypto_secretbox_easy(ubyte* c, const(ubyte)* m,
                          ulong mlen, const(ubyte)* n,
                          const(ubyte)* k) @system;

int crypto_secretbox_open_easy(ubyte* m, const(ubyte)* c,
                               ulong clen, const(ubyte)* n,
                               const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_secretbox_detached(ubyte* c, ubyte* mac,
                              const(ubyte)* m,
                              ulong mlen,
                              const(ubyte)* n,
                              const(ubyte)* k) @system;

int crypto_secretbox_open_detached(ubyte* m,
                                   const(ubyte)* c,
                                   const(ubyte)* mac,
                                   ulong clen,
                                   const(ubyte)* n,
                                   const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result));

void crypto_secretbox_keygen(ref ubyte[crypto_secretbox_KEYBYTES] k) nothrow @trusted;

/* -- NaCl compatibility interface ; Requires padding -- */

alias crypto_secretbox_ZEROBYTES = crypto_secretbox_xsalsa20poly1305_ZEROBYTES;

size_t  crypto_secretbox_zerobytes() @trusted;

alias crypto_secretbox_BOXZEROBYTES = crypto_secretbox_xsalsa20poly1305_BOXZEROBYTES;

size_t  crypto_secretbox_boxzerobytes() @trusted;

int crypto_secretbox(ubyte* c, const(ubyte)* m,
                     ulong mlen, const(ubyte)* n,
                     const(ubyte)* k) @system;

int crypto_secretbox_open(ubyte* m, const(ubyte)* c,
                          ulong clen, const(ubyte)* n,
                          const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result));
