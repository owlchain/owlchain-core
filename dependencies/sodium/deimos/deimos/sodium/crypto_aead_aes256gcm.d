/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_aead_aes256gcm_H
*/

module deimos.sodium.crypto_aead_aes256gcm;


extern(C) pure @nogc :


int crypto_aead_aes256gcm_is_available() @trusted;

enum crypto_aead_aes256gcm_KEYBYTES = 32U;

size_t crypto_aead_aes256gcm_keybytes() @trusted;

enum crypto_aead_aes256gcm_NSECBYTES = 0U;

size_t crypto_aead_aes256gcm_nsecbytes() @trusted;

enum crypto_aead_aes256gcm_NPUBBYTES = 12U;

size_t crypto_aead_aes256gcm_npubbytes() @trusted;

enum crypto_aead_aes256gcm_ABYTES   = 16U;

size_t crypto_aead_aes256gcm_abytes() @trusted;

// it's not absolutely clear, if in D the align attribute will be part of the alias (as in C)  or not
alias  crypto_aead_aes256gcm_state = align(16) ubyte[512]; // typedef CRYPTO_ALIGN(16) unsigned char crypto_aead_aes256gcm_state[512];

size_t crypto_aead_aes256gcm_statebytes() @trusted;

int crypto_aead_aes256gcm_encrypt(ubyte* c,
                                  ulong* clen_p,
                                  const(ubyte)* m,
                                  ulong mlen,
                                  const(ubyte)* ad,
                                  ulong adlen,
                                  const(ubyte)* nsec,
                                  const(ubyte)* npub,
                                  const(ubyte)* k) @system;

int crypto_aead_aes256gcm_decrypt(ubyte* m,
                                  ulong* mlen_p,
                                  ubyte* nsec,
                                  const(ubyte)* c,
                                  ulong clen,
                                  const(ubyte)* ad,
                                  ulong adlen,
                                  const(ubyte)* npub,
                                  const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result))

int crypto_aead_aes256gcm_encrypt_detached(ubyte* c,
                                           ubyte* mac,
                                           ulong* maclen_p,
                                           const(ubyte)* m,
                                           ulong mlen,
                                           const(ubyte)* ad,
                                           ulong adlen,
                                           const(ubyte)* nsec,
                                           const(ubyte)* npub,
                                           const(ubyte)* k) @system;

int crypto_aead_aes256gcm_decrypt_detached(ubyte *m,
                                           ubyte *nsec,
                                           const(ubyte)* c,
                                           ulong clen,
                                           const(ubyte)* mac,
                                           const(ubyte)* ad,
                                           ulong adlen,
                                           const(ubyte)* npub,
                                           const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result))

/* -- Precomputation interface -- */

int crypto_aead_aes256gcm_beforenm(crypto_aead_aes256gcm_state* ctx_,
                                   const(ubyte)* k) @system;

int crypto_aead_aes256gcm_encrypt_afternm(ubyte* c,
                                          ulong* clen_p,
                                          const(ubyte)* m,
                                          ulong mlen,
                                          const(ubyte)* ad,
                                          ulong adlen,
                                          const(ubyte)* nsec,
                                          const(ubyte)* npub,
                                          const(crypto_aead_aes256gcm_state)* ctx_) @system;

int crypto_aead_aes256gcm_decrypt_afternm(ubyte* m,
                                          ulong* mlen_p,
                                          ubyte* nsec,
                                          const(ubyte)* c,
                                          ulong clen,
                                          const(ubyte)* ad,
                                          ulong adlen,
                                          const(ubyte)* npub,
                                          const(crypto_aead_aes256gcm_state)* ctx_) nothrow @system; // __attribute__ ((warn_unused_result))

int crypto_aead_aes256gcm_encrypt_detached_afternm(ubyte* c,
                                                   ubyte* mac,
                                                   ulong* maclen_p,
                                                   const(ubyte)* m,
                                                   ulong mlen,
                                                   const(ubyte)* ad,
                                                   ulong adlen,
                                                   const(ubyte)* nsec,
                                                   const(ubyte)* npub,
                                                   const(crypto_aead_aes256gcm_state)* ctx_) @system;

int crypto_aead_aes256gcm_decrypt_detached_afternm(ubyte* m,
                                                   ubyte* nsec,
                                                   const(ubyte)* c,
                                                   ulong clen,
                                                   const(ubyte)* mac,
                                                   const(ubyte)* ad,
                                                   ulong adlen,
                                                   const(ubyte)* npub,
                                                   const(crypto_aead_aes256gcm_state)* ctx_) nothrow @system; // __attribute__ ((warn_unused_result))

void crypto_aead_aes256gcm_keygen(ref ubyte[crypto_aead_aes256gcm_KEYBYTES] k) nothrow @trusted;
