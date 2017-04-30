// Written in the D programming language.

module wrapper.sodium.crypto_pwhash;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_pwhash : crypto_pwhash_ALG_ARGON2I13,
                                      crypto_pwhash_alg_argon2i13,
                                      crypto_pwhash_ALG_DEFAULT,
                                      crypto_pwhash_alg_default,
                                      crypto_pwhash_SALTBYTES,
                                      crypto_pwhash_saltbytes,
                                      crypto_pwhash_STRBYTES,
                                      crypto_pwhash_strbytes,
                                      crypto_pwhash_STRPREFIX,
//                                      crypto_pwhash_strprefix,
                                      crypto_pwhash_OPSLIMIT_INTERACTIVE,
                                      crypto_pwhash_opslimit_interactive,
                                      crypto_pwhash_MEMLIMIT_INTERACTIVE,
                                      crypto_pwhash_memlimit_interactive,
                                      crypto_pwhash_OPSLIMIT_MODERATE,
                                      crypto_pwhash_opslimit_moderate,
                                      crypto_pwhash_MEMLIMIT_MODERATE,
                                      crypto_pwhash_memlimit_moderate,
                                      crypto_pwhash_OPSLIMIT_SENSITIVE,
                                      crypto_pwhash_opslimit_sensitive,
                                      crypto_pwhash_MEMLIMIT_SENSITIVE,
                                      crypto_pwhash_memlimit_sensitive,
//                                      crypto_pwhash,
//                                      crypto_pwhash_str,
                                      crypto_pwhash_str_verify,
                                      crypto_pwhash_PRIMITIVE;
//                                      crypto_pwhash_primitive;

import std.exception : enforce, assertThrown;

string crypto_pwhash_strprefix() pure nothrow @nogc @trusted
{
  import std.string : fromStringz;
  static import deimos.sodium.crypto_pwhash;
  const(char)[] c_arr;
  try
    c_arr = fromStringz(deimos.sodium.crypto_pwhash.crypto_pwhash_strprefix()); // strips terminating \0
  catch (Exception e) { /* known not to throw */ }
  return c_arr;
}

string crypto_pwhash_primitive() pure nothrow @nogc @trusted
{
  import std.string : fromStringz;
  static import deimos.sodium.crypto_pwhash;
  const(char)[] c_arr;
  try
    c_arr = fromStringz(deimos.sodium.crypto_pwhash.crypto_pwhash_primitive()); // strips terminating \0
  catch (Exception e) { /* known not to throw */ }
  return c_arr;
}

// overload

alias crypto_pwhash = deimos.sodium.crypto_pwhash.crypto_pwhash;

/** Key derivation
 */
bool crypto_pwhash(scope ubyte[] out_,
                   in string passwd,
                   in ubyte[crypto_pwhash_SALTBYTES] salt,
                   ulong opslimit, size_t memlimit, int alg) pure @trusted
{
  enforce(out_.length >= 16);
  return  crypto_pwhash(out_.ptr, out_.length, passwd.ptr, passwd.length, salt.ptr, opslimit, memlimit, alg) == 0;
}

/** Password storage  hash generation (with same parameters as used for key derivation)
 */
alias crypto_pwhash_str = deimos.sodium.crypto_pwhash.crypto_pwhash_str;

pragma(inline, true)
bool crypto_pwhash_str(out char[crypto_pwhash_STRBYTES] out_,
                       in string passwd,
                       in ulong opslimit, in size_t memlimit) pure nothrow @nogc @trusted
{
  return  crypto_pwhash_str(out_, passwd.ptr, passwd.length, opslimit, memlimit) == 0;
}


/** Password storage  hash verification
 */
alias crypto_pwhash_str_verify = deimos.sodium.crypto_pwhash.crypto_pwhash_str_verify;

pragma(inline, true)
bool crypto_pwhash_str_verify(in char[crypto_pwhash_STRBYTES] str, in string passwd) pure nothrow @nogc @trusted
{
  return  crypto_pwhash_str_verify(str, passwd.ptr, passwd.length) == 0;
}


@safe
unittest {
  import wrapper.sodium.randombytes : randombytes;
  import wrapper.sodium.crypto_box  : crypto_box_SEEDBYTES;
  import std.string: toStringz;
  import std.stdio: writeln, writefln;
  debug writeln("unittest block 1 from sodium.crypto_pwhash.d");

  assert(crypto_pwhash_alg_argon2i13()        == crypto_pwhash_ALG_ARGON2I13);
  assert(crypto_pwhash_alg_default()          == crypto_pwhash_ALG_DEFAULT);
  assert(crypto_pwhash_saltbytes()            == crypto_pwhash_SALTBYTES);
  assert(crypto_pwhash_strbytes()             == crypto_pwhash_STRBYTES);
  assert(crypto_pwhash_strprefix()            == crypto_pwhash_STRPREFIX);
  assert(crypto_pwhash_opslimit_interactive() == crypto_pwhash_OPSLIMIT_INTERACTIVE);
  assert(crypto_pwhash_memlimit_interactive() == crypto_pwhash_MEMLIMIT_INTERACTIVE);
  assert(crypto_pwhash_opslimit_moderate()    == crypto_pwhash_OPSLIMIT_MODERATE);
  assert(crypto_pwhash_memlimit_moderate()    == crypto_pwhash_MEMLIMIT_MODERATE);
  assert(crypto_pwhash_opslimit_sensitive()   == crypto_pwhash_OPSLIMIT_SENSITIVE);
  assert(crypto_pwhash_memlimit_sensitive()   == crypto_pwhash_MEMLIMIT_SENSITIVE);
  assert(crypto_pwhash_primitive()            == crypto_pwhash_PRIMITIVE);

  enum password = "Correct Horse Battery Staple";
  ubyte[crypto_pwhash_SALTBYTES] salt = void; // 16
  randombytes(salt);
  ubyte[crypto_box_SEEDBYTES]     key = void; // 32

  assertThrown(crypto_pwhash(key[0..15], password, salt, crypto_pwhash_OPSLIMIT_INTERACTIVE, crypto_pwhash_MEMLIMIT_INTERACTIVE, crypto_pwhash_ALG_DEFAULT));
  assert(crypto_pwhash(key, password, salt, crypto_pwhash_OPSLIMIT_INTERACTIVE, crypto_pwhash_MEMLIMIT_INTERACTIVE, crypto_pwhash_ALG_DEFAULT));
//  writefln("crypto_pwhash key generated:    0x%(%02x%)", key);   // 0xddf58869c0523709d57f2b532f4b82105882093cd3eaf0ad1623740c44f34089
//  writefln("crypto_pwhash salt used:        0x%(%02x%)", salt);  // 0x7714bdc12f92efcadc9b8970394db0e5

  char[crypto_pwhash_STRBYTES] password_storage;
  assert(crypto_pwhash_str(password_storage, password, crypto_pwhash_OPSLIMIT_INTERACTIVE, crypto_pwhash_MEMLIMIT_INTERACTIVE));
//  writeln("crypto_pwhash password_storage: ", password_storage); // $argon2i$v=19$m=32768,t=4,p=1$tfIofMr8IvXqKOwQt9iqcg$QGqBmFMcxeGptuTbq698i7KOC6oO8jw7VuVaPUWXeMQ
  assert(crypto_pwhash_str_verify(password_storage, password));
}
