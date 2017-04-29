/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_pwhash_H
*/

module deimos.sodium.crypto_pwhash;

import deimos.sodium.crypto_pwhash_argon2i : crypto_pwhash_argon2i_ALG_ARGON2I13,
                                             crypto_pwhash_argon2i_BYTES_MIN,
                                             crypto_pwhash_argon2i_BYTES_MAX,
                                             crypto_pwhash_argon2i_PASSWD_MIN,
                                             crypto_pwhash_argon2i_PASSWD_MAX,
                                             crypto_pwhash_argon2i_SALTBYTES,
                                             crypto_pwhash_argon2i_STRBYTES,
                                             crypto_pwhash_argon2i_STRPREFIX,
                                             crypto_pwhash_argon2i_OPSLIMIT_MIN,
                                             crypto_pwhash_argon2i_OPSLIMIT_MAX,
                                             crypto_pwhash_argon2i_MEMLIMIT_MIN,
                                             crypto_pwhash_argon2i_MEMLIMIT_MAX,
                                             crypto_pwhash_argon2i_OPSLIMIT_INTERACTIVE,
                                             crypto_pwhash_argon2i_MEMLIMIT_INTERACTIVE,
                                             crypto_pwhash_argon2i_OPSLIMIT_MODERATE,
                                             crypto_pwhash_argon2i_MEMLIMIT_MODERATE,
                                             crypto_pwhash_argon2i_OPSLIMIT_SENSITIVE,
                                             crypto_pwhash_argon2i_MEMLIMIT_SENSITIVE;


extern(C) pure @nogc :

alias crypto_pwhash_ALG_ARGON2I13 = crypto_pwhash_argon2i_ALG_ARGON2I13;

int crypto_pwhash_alg_argon2i13() @trusted;

alias crypto_pwhash_ALG_DEFAULT = crypto_pwhash_ALG_ARGON2I13;

int crypto_pwhash_alg_default() @trusted;

alias crypto_pwhash_BYTES_MIN = crypto_pwhash_argon2i_BYTES_MIN;

size_t crypto_pwhash_bytes_min() @trusted;

alias crypto_pwhash_BYTES_MAX = crypto_pwhash_argon2i_BYTES_MAX;

size_t crypto_pwhash_bytes_max() @trusted;

alias crypto_pwhash_PASSWD_MIN = crypto_pwhash_argon2i_PASSWD_MIN;

size_t crypto_pwhash_passwd_min() @trusted;

alias crypto_pwhash_PASSWD_MAX = crypto_pwhash_argon2i_PASSWD_MAX;

size_t crypto_pwhash_passwd_max() @trusted;

alias crypto_pwhash_SALTBYTES = crypto_pwhash_argon2i_SALTBYTES;

size_t crypto_pwhash_saltbytes() @trusted;

alias crypto_pwhash_STRBYTES = crypto_pwhash_argon2i_STRBYTES;

size_t crypto_pwhash_strbytes() @trusted;

alias crypto_pwhash_STRPREFIX = crypto_pwhash_argon2i_STRPREFIX;

const(char)* crypto_pwhash_strprefix() @system;

alias crypto_pwhash_OPSLIMIT_MIN = crypto_pwhash_argon2i_OPSLIMIT_MIN;

size_t crypto_pwhash_opslimit_min() @system;

alias crypto_pwhash_OPSLIMIT_MAX = crypto_pwhash_argon2i_OPSLIMIT_MAX;

size_t crypto_pwhash_opslimit_max() @system;

alias crypto_pwhash_MEMLIMIT_MIN = crypto_pwhash_argon2i_MEMLIMIT_MIN;

size_t crypto_pwhash_memlimit_min() @system;

alias crypto_pwhash_MEMLIMIT_MAX = crypto_pwhash_argon2i_MEMLIMIT_MAX;

size_t crypto_pwhash_memlimit_max() @system;

alias crypto_pwhash_OPSLIMIT_INTERACTIVE = crypto_pwhash_argon2i_OPSLIMIT_INTERACTIVE;

size_t crypto_pwhash_opslimit_interactive() @trusted;

alias crypto_pwhash_MEMLIMIT_INTERACTIVE = crypto_pwhash_argon2i_MEMLIMIT_INTERACTIVE;

size_t crypto_pwhash_memlimit_interactive() @trusted;

alias crypto_pwhash_OPSLIMIT_MODERATE = crypto_pwhash_argon2i_OPSLIMIT_MODERATE;

size_t crypto_pwhash_opslimit_moderate() @trusted;

alias crypto_pwhash_MEMLIMIT_MODERATE = crypto_pwhash_argon2i_MEMLIMIT_MODERATE;

size_t crypto_pwhash_memlimit_moderate() @trusted;

alias crypto_pwhash_OPSLIMIT_SENSITIVE = crypto_pwhash_argon2i_OPSLIMIT_SENSITIVE;

size_t crypto_pwhash_opslimit_sensitive() @trusted;

alias crypto_pwhash_MEMLIMIT_SENSITIVE = crypto_pwhash_argon2i_MEMLIMIT_SENSITIVE;

size_t crypto_pwhash_memlimit_sensitive() @trusted;

int crypto_pwhash(ubyte* out_, ulong outlen,
                  const(char*) passwd, ulong passwdlen,
                  const(ubyte*) salt,
                  ulong opslimit, size_t memlimit, int alg) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_pwhash_str(ref char[crypto_pwhash_STRBYTES] out_,
                      const(char*) passwd, ulong passwdlen,
                      ulong opslimit, size_t memlimit) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_pwhash_str_verify(ref const(char[crypto_pwhash_STRBYTES]) str,
                             const(char*) passwd,
                             ulong passwdlen) nothrow @system; // __attribute__ ((warn_unused_result));

enum crypto_pwhash_PRIMITIVE = "argon2i";

const(char)* crypto_pwhash_primitive() nothrow @system; // __attribute__ ((warn_unused_result))
