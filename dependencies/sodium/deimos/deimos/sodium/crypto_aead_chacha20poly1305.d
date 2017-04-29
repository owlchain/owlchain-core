/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_aead_chacha20poly1305_H
*/

module deimos.sodium.crypto_aead_chacha20poly1305;


extern(C) pure @nogc :


/* -- IETF ChaCha20-Poly1305 construction with a 96-bit nonce and a 32-bit internal counter -- */

enum crypto_aead_chacha20poly1305_ietf_KEYBYTES = 32U;

size_t crypto_aead_chacha20poly1305_ietf_keybytes() @trusted;

enum crypto_aead_chacha20poly1305_ietf_NSECBYTES = 0U;

size_t crypto_aead_chacha20poly1305_ietf_nsecbytes() @trusted;

enum crypto_aead_chacha20poly1305_ietf_NPUBBYTES = 12U;

size_t crypto_aead_chacha20poly1305_ietf_npubbytes() @trusted;

enum crypto_aead_chacha20poly1305_ietf_ABYTES = 16U;

size_t crypto_aead_chacha20poly1305_ietf_abytes() @trusted;

int crypto_aead_chacha20poly1305_ietf_encrypt(ubyte* c,
                                              ulong* clen_p,
                                              const(ubyte)* m,
                                              ulong mlen,
                                              const(ubyte)* ad,
                                              ulong adlen,
                                              const(ubyte)* nsec,
                                              const(ubyte)* npub,
                                              const(ubyte)* k) @system;

int crypto_aead_chacha20poly1305_ietf_decrypt(ubyte* m,
                                              ulong* mlen_p,
                                              ubyte* nsec,
                                              const(ubyte)* c,
                                              ulong clen,
                                              const(ubyte)* ad,
                                              ulong adlen,
                                              const(ubyte)* npub,
                                              const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result))

int crypto_aead_chacha20poly1305_ietf_encrypt_detached(ubyte* c,
                                                       ubyte* mac,
                                                       ulong* maclen_p,
                                                       const(ubyte)* m,
                                                       ulong mlen,
                                                       const(ubyte)* ad,
                                                       ulong adlen,
                                                       const(ubyte)* nsec,
                                                       const(ubyte)* npub,
                                                       const(ubyte)* k) @system;

int crypto_aead_chacha20poly1305_ietf_decrypt_detached(ubyte* m,
                                                       ubyte* nsec,
                                                       const(ubyte)* c,
                                                       ulong clen,
                                                       const(ubyte)* mac,
                                                       const(ubyte)* ad,
                                                       ulong adlen,
                                                       const(ubyte)* npub,
                                                       const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result))

void crypto_aead_chacha20poly1305_ietf_keygen(ref ubyte[crypto_aead_chacha20poly1305_ietf_KEYBYTES] k) nothrow @system;

/* -- Original ChaCha20-Poly1305 construction with a 64-bit nonce and a 64-bit internal counter -- */

enum crypto_aead_chacha20poly1305_KEYBYTES = 32U;

size_t crypto_aead_chacha20poly1305_keybytes() @trusted;

enum crypto_aead_chacha20poly1305_NSECBYTES = 0U;

size_t crypto_aead_chacha20poly1305_nsecbytes() @trusted;

enum crypto_aead_chacha20poly1305_NPUBBYTES = 8U;

size_t crypto_aead_chacha20poly1305_npubbytes() @trusted;

enum crypto_aead_chacha20poly1305_ABYTES = 16U;

size_t crypto_aead_chacha20poly1305_abytes() @trusted;

int crypto_aead_chacha20poly1305_encrypt(ubyte* c,
                                         ulong* clen_p,
                                         const(ubyte)* m,
                                         ulong mlen,
                                         const(ubyte)* ad,
                                         ulong adlen,
                                         const(ubyte)* nsec,
                                         const(ubyte)* npub,
                                         const(ubyte)* k) @system;

int crypto_aead_chacha20poly1305_decrypt(ubyte* m,
                                         ulong* mlen_p,
                                         ubyte* nsec,
                                         const(ubyte)* c,
                                         ulong clen,
                                         const(ubyte)* ad,
                                         ulong adlen,
                                         const(ubyte)* npub,
                                         const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result))

int crypto_aead_chacha20poly1305_encrypt_detached(ubyte* c,
                                                  ubyte* mac,
                                                  ulong* maclen_p,
                                                  const(ubyte)* m,
                                                  ulong mlen,
                                                  const(ubyte)* ad,
                                                  ulong adlen,
                                                  const(ubyte)* nsec,
                                                  const(ubyte)* npub,
                                                  const(ubyte)* k) @system;

int crypto_aead_chacha20poly1305_decrypt_detached(ubyte* m,
                                                  ubyte* nsec,
                                                  const(ubyte)* c,
                                                  ulong clen,
                                                  const(ubyte)* mac,
                                                  const(ubyte)* ad,
                                                  ulong adlen,
                                                  const(ubyte)* npub,
                                                  const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result))

void crypto_aead_chacha20poly1305_keygen(ref ubyte[crypto_aead_chacha20poly1305_KEYBYTES] k) nothrow @system;

/* Aliases */

alias crypto_aead_chacha20poly1305_IETF_KEYBYTES  = crypto_aead_chacha20poly1305_ietf_KEYBYTES;
alias crypto_aead_chacha20poly1305_IETF_NSECBYTES = crypto_aead_chacha20poly1305_ietf_NSECBYTES;
alias crypto_aead_chacha20poly1305_IETF_NPUBBYTES = crypto_aead_chacha20poly1305_ietf_NPUBBYTES;
alias crypto_aead_chacha20poly1305_IETF_ABYTES    = crypto_aead_chacha20poly1305_ietf_ABYTES;
