/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_aead_xchacha20poly1305_H
*/

module deimos.sodium.crypto_aead_xchacha20poly1305;

//#include <stddef.h>
//#include "export.h"
//

extern(C) pure @nogc :


enum crypto_aead_xchacha20poly1305_ietf_KEYBYTES = 32U;

size_t crypto_aead_xchacha20poly1305_ietf_keybytes() @trusted;

enum crypto_aead_xchacha20poly1305_ietf_NSECBYTES = 0U;

size_t crypto_aead_xchacha20poly1305_ietf_nsecbytes() @trusted;

enum crypto_aead_xchacha20poly1305_ietf_NPUBBYTES = 24U;

size_t crypto_aead_xchacha20poly1305_ietf_npubbytes() @trusted;

enum crypto_aead_xchacha20poly1305_ietf_ABYTES = 16U;

size_t crypto_aead_xchacha20poly1305_ietf_abytes() @trusted;


int crypto_aead_xchacha20poly1305_ietf_encrypt(ubyte* c,
                                               ulong* clen_p,
                                               const(ubyte)* m,
                                               ulong mlen,
                                               const(ubyte)* ad,
                                               ulong adlen,
                                               const(ubyte)* nsec,
                                               const(ubyte)* npub,
                                               const(ubyte)* k) @system;

int crypto_aead_xchacha20poly1305_ietf_decrypt(ubyte* m,
                                               ulong* mlen_p,
                                               ubyte* nsec,
                                               const(ubyte)* c,
                                               ulong clen,
                                               const(ubyte)* ad,
                                               ulong adlen,
                                               const(ubyte)* npub,
                                               const(ubyte)* k) nothrow @system; //  __attribute__ ((warn_unused_result)); //  __attribute__ ((warn_unused_result));

int crypto_aead_xchacha20poly1305_ietf_encrypt_detached(ubyte* c,
                                                        ubyte* mac,
                                                        ulong* maclen_p,
                                                        const(ubyte)* m,
                                                        ulong mlen,
                                                        const(ubyte)* ad,
                                                        ulong adlen,
                                                        const(ubyte)* nsec,
                                                        const(ubyte)* npub,
                                                        const(ubyte)* k) @system;

int crypto_aead_xchacha20poly1305_ietf_decrypt_detached(ubyte* m,
                                                        ubyte* nsec,
                                                        const(ubyte)* c,
                                                        ulong clen,
                                                        const(ubyte)* mac,
                                                        const(ubyte)* ad,
                                                        ulong adlen,
                                                        const(ubyte)* npub,
                                                        const(ubyte)* k) nothrow @system; //  __attribute__ ((warn_unused_result));

void crypto_aead_xchacha20poly1305_ietf_keygen(ref ubyte[crypto_aead_xchacha20poly1305_ietf_KEYBYTES] k) nothrow @system;

/* Aliases */

alias crypto_aead_xchacha20poly1305_IETF_KEYBYTES  = crypto_aead_xchacha20poly1305_ietf_KEYBYTES;
alias crypto_aead_xchacha20poly1305_IETF_NSECBYTES = crypto_aead_xchacha20poly1305_ietf_NSECBYTES;
alias crypto_aead_xchacha20poly1305_IETF_NPUBBYTES = crypto_aead_xchacha20poly1305_ietf_NPUBBYTES;
alias crypto_aead_xchacha20poly1305_IETF_ABYTES    = crypto_aead_xchacha20poly1305_ietf_ABYTES;
