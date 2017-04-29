// Written in the D programming language.

module wrapper.sodium;

public :

import wrapper.sodium.version_; /* unittest + code */

//import wrapper.sodium.core;   /* unittest + code */ No public import any more: it get's imported privately in all other modules (except randombytes_*) to ensure running it's shared static this() first

import wrapper.sodium.crypto_aead_aes256gcm;         /* unittest + code  TODO update Precomputation interface, update doc. comments, check -m32_mscoff */
import wrapper.sodium.crypto_aead_chacha20poly1305;  /* unittest + code */
import wrapper.sodium.crypto_aead_xchacha20poly1305; /* currently mere redirection; TODO v1.0.12 */

import wrapper.sodium.crypto_auth;                   /* unittest + code  */
import wrapper.sodium.crypto_auth_hmacsha256;        /* unittest + code  */
import wrapper.sodium.crypto_auth_hmacsha512;        /* unittest + code  */
import wrapper.sodium.crypto_auth_hmacsha512256;     /* unittest + code  */

import wrapper.sodium.crypto_box;                    /* unittest + code  */
import wrapper.sodium.crypto_box_curve25519xsalsa20poly1305; /* currently mere redirection; TODO */

import wrapper.sodium.crypto_core_hsalsa20;          /* currently mere redirection; TODO */
import wrapper.sodium.crypto_core_hchacha20;         /* currently mere redirection; TODO */
import wrapper.sodium.crypto_core_salsa20;           /* currently mere redirection; TODO */
import wrapper.sodium.crypto_core_salsa2012;         /* currently mere redirection; TODO */
import wrapper.sodium.crypto_core_salsa208;          /* currently mere redirection; TODO */

import wrapper.sodium.crypto_generichash;            /* unittest + code  */
import wrapper.sodium.crypto_generichash_blake2b;    /* unittest not required; mere redirection */
import wrapper.sodium.crypto_hash;                   /* unittest + code  */
import wrapper.sodium.crypto_hash_sha256;            /* unittest + code  */
import wrapper.sodium.crypto_hash_sha512;            /* unittest + code  */

import wrapper.sodium.crypto_kdf;                    /* currently mere redirection; TODO */
import wrapper.sodium.crypto_kdf_blake2b;            /* currently mere redirection; TODO */
import wrapper.sodium.crypto_kx;                     /* currently mere redirection; TODO */

import wrapper.sodium.crypto_onetimeauth;            /* currently mere redirection; TODO */
import wrapper.sodium.crypto_onetimeauth_poly1305;   /* currently mere redirection; TODO */

import wrapper.sodium.crypto_pwhash;                       /* unittest + code; TODO v1.0.12 */
import wrapper.sodium.crypto_pwhash_argon2i;               /* currently mere redirection; TODO */
import wrapper.sodium.crypto_pwhash_scryptsalsa208sha256;  /* currently mere redirection; TODO */

import wrapper.sodium.crypto_scalarmult;             /* unittest + code  */
import wrapper.sodium.crypto_scalarmult_curve25519;  /* unittest not required; mere redirection */

import wrapper.sodium.crypto_secretbox;                   /* unittest + code  */
import wrapper.sodium.crypto_secretbox_xsalsa20poly1305;  /* currently mere redirection; TODO v1.0.12 */

import wrapper.sodium.crypto_shorthash;              /* unittest + code  */
import wrapper.sodium.crypto_shorthash_siphash24;    /* unittest */
import wrapper.sodium.crypto_sign;                   /* currently mere redirection; TODO */
import wrapper.sodium.crypto_sign_ed25519;           /* currently mere redirection; TODO */
//import wrapper.sodium.crypto_sign_edwards25519sha512batch; /* currently mere redirection; TODO */

import wrapper.sodium.crypto_stream;           /* unittest + code  */
import wrapper.sodium.crypto_stream_chacha20;  // no_compile
import wrapper.sodium.crypto_stream_salsa20;   // no_compile
import wrapper.sodium.crypto_stream_xsalsa20;  /* unittest */

import wrapper.sodium.crypto_verify_16;  /* unittest + code */
import wrapper.sodium.crypto_verify_32;  /* unittest + code */
import wrapper.sodium.crypto_verify_64;  /* unittest + code */

/* WARNING: randombytes_set_implementation is not available from 'wrapper' and shouldn't be used through 'deimos' either, except You know what You are doing */
import wrapper.sodium.randombytes;                 /* unittest + code */
version(__native_client__)
import wrapper.sodium.randombytes_nativeclient;    /* unittest not required; mere redirection */

import wrapper.sodium.randombytes_salsa20_random;  /* unittest not required; mere redirection */
import wrapper.sodium.randombytes_sysrandom;       /* unittest not required; mere redirection */
import wrapper.sodium.runtime;                     /* unittest */
import wrapper.sodium.utils;                       /* unittest + code */

version(SODIUM_LIBRARY_MINIMAL) {}
else {
	import wrapper.sodium.crypto_box_curve25519xchacha20poly1305;  /* currently mere redirection; TODO v1.0.12 */
	import wrapper.sodium.crypto_secretbox_xchacha20poly1305;      /* currently mere redirection; TODO v1.0.12 */

	import wrapper.sodium.crypto_stream_aes128ctr;  /* currently mere redirection; TODO v1.0.12 */
	import wrapper.sodium.crypto_stream_salsa2012;  /* currently mere redirection; TODO v1.0.12 */
	import wrapper.sodium.crypto_stream_salsa208;   /* currently mere redirection; TODO v1.0.12 */
	import wrapper.sodium.crypto_stream_xchacha20;
}
