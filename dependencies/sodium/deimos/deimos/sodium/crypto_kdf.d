/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_kdf_H
*/

module deimos.sodium.crypto_kdf;

import deimos.sodium.crypto_kdf_blake2b;


extern(C) pure @nogc :


alias crypto_kdf_BYTES_MIN = crypto_kdf_blake2b_BYTES_MIN;

size_t crypto_kdf_bytes_min() @trusted;

alias crypto_kdf_BYTES_MAX = crypto_kdf_blake2b_BYTES_MAX;

size_t crypto_kdf_bytes_max() @trusted;

alias crypto_kdf_CONTEXTBYTES = crypto_kdf_blake2b_CONTEXTBYTES;

size_t crypto_kdf_contextbytes() @trusted;

alias crypto_kdf_KEYBYTES = crypto_kdf_blake2b_KEYBYTES;

size_t crypto_kdf_keybytes() @trusted;

enum crypto_kdf_PRIMITIVE = "blake2b";

const(char)* crypto_kdf_primitive() nothrow @system; //  __attribute__ ((warn_unused_result));

int crypto_kdf_derive_from_key(ubyte* subkey, size_t subkey_len,
                               ulong subkey_id,
                               ref const(char)[crypto_kdf_CONTEXTBYTES] ctx,
                               ref const(ubyte)[crypto_kdf_KEYBYTES] key);

void crypto_kdf_keygen(ref ubyte[crypto_kdf_KEYBYTES] k) nothrow @system;
