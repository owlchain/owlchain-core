/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define sodium_H
*/

module deimos.sodium;

public :

import deimos.sodium.version_;

import deimos.sodium.core;
import deimos.sodium.crypto_aead_aes256gcm;
import deimos.sodium.crypto_aead_chacha20poly1305;
import deimos.sodium.crypto_aead_xchacha20poly1305;
import deimos.sodium.crypto_auth;
import deimos.sodium.crypto_auth_hmacsha256;
import deimos.sodium.crypto_auth_hmacsha512;
import deimos.sodium.crypto_auth_hmacsha512256;
import deimos.sodium.crypto_box;
import deimos.sodium.crypto_box_curve25519xsalsa20poly1305;
import deimos.sodium.crypto_core_hsalsa20;
import deimos.sodium.crypto_core_hchacha20;
import deimos.sodium.crypto_core_salsa20;
import deimos.sodium.crypto_core_salsa2012;
import deimos.sodium.crypto_core_salsa208;
import deimos.sodium.crypto_generichash;
import deimos.sodium.crypto_generichash_blake2b;
import deimos.sodium.crypto_hash;
import deimos.sodium.crypto_hash_sha256;
import deimos.sodium.crypto_hash_sha512;
import deimos.sodium.crypto_kdf;
import deimos.sodium.crypto_kdf_blake2b;
import deimos.sodium.crypto_kx;
import deimos.sodium.crypto_onetimeauth;
import deimos.sodium.crypto_onetimeauth_poly1305;
import deimos.sodium.crypto_pwhash;
import deimos.sodium.crypto_pwhash_argon2i;
import deimos.sodium.crypto_pwhash_scryptsalsa208sha256;
import deimos.sodium.crypto_scalarmult;
import deimos.sodium.crypto_scalarmult_curve25519;
import deimos.sodium.crypto_secretbox;
import deimos.sodium.crypto_secretbox_xsalsa20poly1305;
import deimos.sodium.crypto_shorthash;
import deimos.sodium.crypto_shorthash_siphash24;
import deimos.sodium.crypto_sign;
import deimos.sodium.crypto_sign_ed25519;
import deimos.sodium.crypto_stream;
import deimos.sodium.crypto_stream_chacha20;
import deimos.sodium.crypto_stream_salsa20;
import deimos.sodium.crypto_stream_xsalsa20;
import deimos.sodium.crypto_verify_16;
import deimos.sodium.crypto_verify_32;
import deimos.sodium.crypto_verify_64;
import deimos.sodium.randombytes;
version (__native_client__)
	import deimos.sodium.randombytes_nativeclient;

import deimos.sodium.randombytes_salsa20_random;
import deimos.sodium.randombytes_sysrandom;
import deimos.sodium.runtime;
import deimos.sodium.utils;

version(SODIUM_LIBRARY_MINIMAL) {}
else {
	import deimos.sodium.crypto_box_curve25519xchacha20poly1305;
	import deimos.sodium.crypto_secretbox_xchacha20poly1305;
	import deimos.sodium.crypto_stream_aes128ctr;
	import deimos.sodium.crypto_stream_salsa2012;
	import deimos.sodium.crypto_stream_salsa208;
	import deimos.sodium.crypto_stream_xchacha20;
}
