/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_onetimeauth_poly1305_H
*/

module deimos.sodium.crypto_onetimeauth_poly1305;


extern(C) pure @nogc :


align(16) struct crypto_onetimeauth_poly1305_state {
    ubyte[256] opaque;
}

size_t crypto_onetimeauth_poly1305_statebytes() @trusted;

enum crypto_onetimeauth_poly1305_BYTES = 16U;

size_t crypto_onetimeauth_poly1305_bytes() @trusted;

enum crypto_onetimeauth_poly1305_KEYBYTES = 32U;

size_t crypto_onetimeauth_poly1305_keybytes() @trusted;

int crypto_onetimeauth_poly1305(ubyte* out_,
                                const(ubyte)* in_,
                                ulong inlen,
                                const(ubyte)* k) @system;

int crypto_onetimeauth_poly1305_verify(const(ubyte)* h,
                                       const(ubyte)* in_,
                                       ulong inlen,
                                       const(ubyte)* k) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_onetimeauth_poly1305_init(crypto_onetimeauth_poly1305_state* state,
                                     const(ubyte)* key) @system;

int crypto_onetimeauth_poly1305_update(crypto_onetimeauth_poly1305_state* state,
                                       const(ubyte)* in_,
                                       ulong inlen) @system;

int crypto_onetimeauth_poly1305_final(crypto_onetimeauth_poly1305_state* state,
                                      ubyte* out_) @system;

void crypto_onetimeauth_poly1305_keygen(ref ubyte[crypto_onetimeauth_poly1305_KEYBYTES] k) nothrow @system;
