/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define crypto_pwhash_scryptsalsa208sha256_H
*/

module deimos.sodium.crypto_pwhash_scryptsalsa208sha256;


extern(C) pure @nogc :

enum crypto_pwhash_scryptsalsa208sha256_BYTES_MIN = 16U;

size_t crypto_pwhash_scryptsalsa208sha256_bytes_min() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_BYTES_MAX = size_t.max;

size_t crypto_pwhash_scryptsalsa208sha256_bytes_max() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_PASSWD_MIN = 0U;

size_t crypto_pwhash_scryptsalsa208sha256_passwd_min() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_PASSWD_MAX = size_t.max;

size_t crypto_pwhash_scryptsalsa208sha256_passwd_max() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_SALTBYTES = 32U;

size_t crypto_pwhash_scryptsalsa208sha256_saltbytes() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_STRBYTES = 102U;

size_t crypto_pwhash_scryptsalsa208sha256_strbytes() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_STRPREFIX = "$7$";

const(char)* crypto_pwhash_scryptsalsa208sha256_strprefix() @system;

enum crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_MIN = 32768U;

size_t crypto_pwhash_scryptsalsa208sha256_opslimit_min() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_MAX = 4294967295U;

size_t crypto_pwhash_scryptsalsa208sha256_opslimit_max() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_MIN = 16777216U;

size_t crypto_pwhash_scryptsalsa208sha256_memlimit_min() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_MAX = ((size_t.max >= 68719476736U) ? 68719476736U : size_t.max);

size_t crypto_pwhash_scryptsalsa208sha256_memlimit_max() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_INTERACTIVE = 524288U;

size_t crypto_pwhash_scryptsalsa208sha256_opslimit_interactive() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_INTERACTIVE = 16777216U;

size_t crypto_pwhash_scryptsalsa208sha256_memlimit_interactive() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_SENSITIVE = 33554432U;

size_t crypto_pwhash_scryptsalsa208sha256_opslimit_sensitive() @trusted;

enum crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_SENSITIVE = 1073741824U;

size_t crypto_pwhash_scryptsalsa208sha256_memlimit_sensitive() @trusted;

int crypto_pwhash_scryptsalsa208sha256(ubyte* out_,
                                       ulong outlen,
                                       const(char*) passwd,
                                       ulong passwdlen,
                                       const(ubyte*) salt,
                                       ulong opslimit,
                                       size_t memlimit) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_pwhash_scryptsalsa208sha256_str(ref char[crypto_pwhash_scryptsalsa208sha256_STRBYTES] out_,
                                           const(char*) passwd,
                                           ulong passwdlen,
                                           ulong opslimit,
                                           size_t memlimit) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_pwhash_scryptsalsa208sha256_str_verify(ref const(char[crypto_pwhash_scryptsalsa208sha256_STRBYTES]) str,
                                                  const(char*) passwd,
                                                  ulong passwdlen) nothrow @system; // __attribute__ ((warn_unused_result));

int crypto_pwhash_scryptsalsa208sha256_ll(const(ubyte)* passwd, size_t passwdlen,
                                          const(ubyte)* salt, size_t saltlen,
                                          ulong N, uint r, uint p,
                                          ubyte* buf, size_t buflen) nothrow @system; // __attribute__ ((warn_unused_result));
