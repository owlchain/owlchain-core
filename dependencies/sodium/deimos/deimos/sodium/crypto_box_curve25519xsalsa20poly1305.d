/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_box_curve25519xsalsa20poly1305_H
*/

module deimos.sodium.crypto_box_curve25519xsalsa20poly1305;


extern(C) pure @nogc :


enum crypto_box_curve25519xsalsa20poly1305_SEEDBYTES = 32U;

size_t crypto_box_curve25519xsalsa20poly1305_seedbytes() @trusted;

enum crypto_box_curve25519xsalsa20poly1305_PUBLICKEYBYTES = 32U;

size_t crypto_box_curve25519xsalsa20poly1305_publickeybytes() @trusted;

enum crypto_box_curve25519xsalsa20poly1305_SECRETKEYBYTES = 32U;

size_t crypto_box_curve25519xsalsa20poly1305_secretkeybytes() @trusted;

enum crypto_box_curve25519xsalsa20poly1305_BEFORENMBYTES = 32U;

size_t crypto_box_curve25519xsalsa20poly1305_beforenmbytes() @trusted;

enum crypto_box_curve25519xsalsa20poly1305_NONCEBYTES = 24U;

size_t crypto_box_curve25519xsalsa20poly1305_noncebytes() @trusted;

enum crypto_box_curve25519xsalsa20poly1305_MACBYTES = 16U;

size_t crypto_box_curve25519xsalsa20poly1305_macbytes() @trusted;

enum crypto_box_curve25519xsalsa20poly1305_BOXZEROBYTES = 16U;

size_t crypto_box_curve25519xsalsa20poly1305_boxzerobytes() @trusted;

enum crypto_box_curve25519xsalsa20poly1305_ZEROBYTES =
    (crypto_box_curve25519xsalsa20poly1305_BOXZEROBYTES +
     crypto_box_curve25519xsalsa20poly1305_MACBYTES);

size_t crypto_box_curve25519xsalsa20poly1305_zerobytes() @trusted;

int crypto_box_curve25519xsalsa20poly1305(ubyte* c,
                                          const(ubyte)* m,
                                          ulong mlen,
                                          const(ubyte)* n,
                                          const(ubyte)* pk,
                                          const(ubyte)* sk) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_box_curve25519xsalsa20poly1305_open(ubyte* m,
                                               const(ubyte)* c,
                                               ulong clen,
                                               const(ubyte)* n,
                                               const(ubyte)* pk,
                                               const(ubyte)* sk) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_box_curve25519xsalsa20poly1305_seed_keypair(ubyte* pk,
                                                       ubyte* sk,
                                                       const(ubyte)* seed) @system;

int crypto_box_curve25519xsalsa20poly1305_keypair(ubyte* pk,
                                                  ubyte* sk) @system;

int crypto_box_curve25519xsalsa20poly1305_beforenm(ubyte* k,
                                                   const(ubyte)* pk,
                                                   const(ubyte)* sk) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_box_curve25519xsalsa20poly1305_afternm(ubyte* c,
                                                  const(ubyte)* m,
                                                  ulong mlen,
                                                  const(ubyte)* n,
                                                  const(ubyte)* k) @system;

int crypto_box_curve25519xsalsa20poly1305_open_afternm(ubyte* m,
                                                       const(ubyte)* c,
                                                       ulong clen,
                                                       const(ubyte)* n,
                                                       const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result));
