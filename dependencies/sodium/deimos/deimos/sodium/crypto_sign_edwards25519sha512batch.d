/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_sign_edwards25519sha512batch_H
*/

module deimos.sodium.crypto_sign_edwards25519sha512batch;

/*
 * WARNING: This construction was a prototype, which should not be used
 * any more in new projects.
 *
 * crypto_sign_edwards25519sha512batch is provided for applications
 * initially built with NaCl, but as recommended by the author of this
 * construction, new applications should use ed25519 instead.
 *
 * In Sodium, you should use the high-level crypto_sign_*() functions instead.
 */


extern(C) pure @nogc :


enum crypto_sign_edwards25519sha512batch_BYTES = 64U;
enum crypto_sign_edwards25519sha512batch_PUBLICKEYBYTES = 32U;
enum crypto_sign_edwards25519sha512batch_SECRETKEYBYTES = (32U + 32U);


deprecated("Please use the high-level crypto_sign_*() functions instead in new projects.") :


int crypto_sign_edwards25519sha512batch(ubyte* sm,
                                        ulong* smlen_p,
                                        const(ubyte)* m,
                                        ulong mlen,
                                        const(ubyte)* sk) @system;

int crypto_sign_edwards25519sha512batch_open(ubyte* m,
                                             ulong* mlen_p,
                                             const(ubyte)* sm,
                                             ulong smlen,
                                             const(ubyte)* pk) @system;

int crypto_sign_edwards25519sha512batch_keypair(ubyte* pk,
                                                ubyte* sk) @system;
