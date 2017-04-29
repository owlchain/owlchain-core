/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_secretbox_xchacha20poly1305_H
*/

module deimos.sodium.crypto_secretbox_xchacha20poly1305;


extern(C) pure @nogc :


enum crypto_secretbox_xchacha20poly1305_KEYBYTES = 32U;

size_t crypto_secretbox_xchacha20poly1305_keybytes() @trusted;

enum crypto_secretbox_xchacha20poly1305_NONCEBYTES = 24U;

size_t crypto_secretbox_xchacha20poly1305_noncebytes() @trusted;

enum crypto_secretbox_xchacha20poly1305_MACBYTES = 16U;

size_t crypto_secretbox_xchacha20poly1305_macbytes() @trusted;

int crypto_secretbox_xchacha20poly1305_easy(ubyte* c,
                                            const(ubyte)* m,
                                            ulong mlen,
                                            const(ubyte)* n,
                                            const(ubyte)* k) @system;

int crypto_secretbox_xchacha20poly1305_open_easy(ubyte* m,
                                                 const(ubyte)* c,
                                                 ulong clen,
                                                 const(ubyte)* n,
                                                 const(ubyte)* k) nothrow @system; //  __attribute__ ((warn_unused_result));

int crypto_secretbox_xchacha20poly1305_detached(ubyte* c,
                                                ubyte* mac,
                                                const(ubyte)* m,
                                                ulong mlen,
                                                const(ubyte)* n,
                                                const(ubyte)* k) @system;

int crypto_secretbox_xchacha20poly1305_open_detached(ubyte* m,
                                                     const(ubyte)* c,
                                                     const(ubyte)* mac,
                                                     ulong clen,
                                                     const(ubyte)* n,
                                                     const(ubyte)* k) nothrow @system; //  __attribute__ ((warn_unused_result));
