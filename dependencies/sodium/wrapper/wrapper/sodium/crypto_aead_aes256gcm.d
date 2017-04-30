// Written in the D programming language.

/* Authenticated Encryption with Additional Data : AES256-GCM */

module wrapper.sodium.crypto_aead_aes256gcm;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_aead_aes256gcm : crypto_aead_aes256gcm_is_available,
                                              crypto_aead_aes256gcm_KEYBYTES,
                                              crypto_aead_aes256gcm_keybytes,
                                              crypto_aead_aes256gcm_NSECBYTES,
                                              crypto_aead_aes256gcm_nsecbytes,
                                              crypto_aead_aes256gcm_NPUBBYTES,
                                              crypto_aead_aes256gcm_npubbytes,
                                              crypto_aead_aes256gcm_ABYTES,
                                              crypto_aead_aes256gcm_abytes,
                                              crypto_aead_aes256gcm_state,
                                              crypto_aead_aes256gcm_statebytes,
/*                                            crypto_aead_aes256gcm_encrypt,
                                              crypto_aead_aes256gcm_decrypt,
                                              crypto_aead_aes256gcm_encrypt_detached,
                                              crypto_aead_aes256gcm_decrypt_detached,
                                              crypto_aead_aes256gcm_beforenm,
                                              crypto_aead_aes256gcm_encrypt_afternm,
                                              crypto_aead_aes256gcm_decrypt_afternm,
                                              crypto_aead_aes256gcm_encrypt_detached_afternm,
                                              crypto_aead_aes256gcm_decrypt_detached_afternm; */
                                              crypto_aead_aes256gcm_keygen;

import std.exception : enforce, assertThrown, assertNotThrown;

// overloading some functions between module deimos.sodium.crypto_aead_aes256gcm and this module

alias crypto_aead_aes256gcm_encrypt = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_encrypt;

/**
 * The function crypto_aead_aes256gcm_encrypt() encrypts a message `m` using a secret key `k` (crypto_aead_aes256gcm_KEYBYTES bytes)
 * and a public nonce `npub` (crypto_aead_aes256gcm_NPUBBYTES bytes).
 * The encrypted message, as well as a tag authenticating both the confidential message m and ad.length bytes of non-confidential data `ad`,
 * are put into `c` (and `c`'s .length might shrink to the length actually required).
 * ad can also be an empty array if no additional data are required.
 * At most m.length + crypto_aead_aes256gcm_ABYTES bytes are put into c, reflected by the length of `c`.
 * ATTENTION: The function reallocates `c` on the heap, if `c`'s .length supplied was too small !
 * The function always returns true.
 * The public nonce npub should never ever be reused with the same key. The recommended way to generate it is to use
 * randombytes_buf() for the first message, and then to increment it for each subsequent message using the same key.
 */
bool crypto_aead_aes256gcm_encrypt(ref ubyte[] c,
//                                   out ulong clen_p,
                                   in ubyte[] m,
                                   in ubyte[] ad,
                                   in ubyte[crypto_aead_aes256gcm_NPUBBYTES] npub,
                                   in ubyte[crypto_aead_aes256gcm_KEYBYTES] k) pure @trusted
{
  enforce(m.length, "Error invoking crypto_aead_aes256gcm_encrypt: m is null"); // TODO check if m.ptr==null would be okay
  if (c.length <      m.length + crypto_aead_aes256gcm_ABYTES)
    c.length =        m.length + crypto_aead_aes256gcm_ABYTES;
  enforce(c.length >= m.length + crypto_aead_aes256gcm_ABYTES, "Error invoking crypto_aead_aes256gcm_encrypt: out buffer too small");
  ulong clen_p;
  bool result = crypto_aead_aes256gcm_encrypt(c.ptr, &clen_p, m.ptr, m.length, ad.ptr, ad.length, null, npub.ptr, k.ptr) == 0;
  if (clen_p) {
    assert(clen_p ==  m.length + crypto_aead_aes256gcm_ABYTES);
    if (c.length>clen_p)
	    c.length = clen_p;
  }
  return  result;
}

alias crypto_aead_aes256gcm_decrypt = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_decrypt;

/**
 * The function crypto_aead_aes256gcm_decrypt() verifies that the ciphertext `c` (as produced by crypto_aead_aes256gcm_encrypt()),
 * includes a valid tag using a secret key `k`, a public nonce `npub`, and additional data `ad`. c.length is the ciphertext length
 * in bytes with the authenticator, so it has to be at least aead_aes256gcm_ABYTES.
 *
 * ad can be an empty array if no additional data are required.
 * The function returns false if the verification fails.
 * If the verification succeeds, the function returns true, puts the decrypted message into `m` and stores its actual number of bytes into `mlen_p`.
 *  (and `c`'s .length might shrink to the length actually required).
 * At most c.length - crypto_aead_aes256gcm_ABYTES bytes will be put into m.
 */
bool crypto_aead_aes256gcm_decrypt(ref ubyte[] m,
//                                   out ulong mlen_p,
                                   in ubyte[] c,
                                   in ubyte[] ad,
                                   in ubyte[crypto_aead_aes256gcm_NPUBBYTES] npub,
                                   in ubyte[crypto_aead_aes256gcm_KEYBYTES] k) pure @trusted
{
  enforce(c.length >= crypto_aead_aes256gcm_ABYTES, "Error invoking crypto_aead_aes256gcm_decrypt: in buffer ciphertext too short");
  if (m.length <      c.length - crypto_aead_aes256gcm_ABYTES)
    m.length =        c.length - crypto_aead_aes256gcm_ABYTES;
  enforce(m.length >= c.length - crypto_aead_aes256gcm_ABYTES, "Error invoking crypto_aead_aes256gcm_decrypt: out buffer too small");
  ulong mlen_p;
  bool result = crypto_aead_aes256gcm_decrypt(m.ptr, &mlen_p, null, c.ptr, c.length, ad.ptr, ad.length, npub.ptr, k.ptr) == 0;
  if (result && mlen_p) {
    assert(mlen_p ==  c.length - crypto_aead_aes256gcm_ABYTES);
    if (m.length>mlen_p)
      m.length = mlen_p;
  }
  return  result;
}

alias crypto_aead_aes256gcm_encrypt_detached = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_encrypt_detached;

bool crypto_aead_aes256gcm_encrypt_detached(ref ubyte[] c,
                                            out ubyte[crypto_aead_aes256gcm_ABYTES] mac,
//                                            out ulong maclen_p,
                                            in ubyte[] m,
                                            in ubyte[] ad,
                                            in ubyte[crypto_aead_aes256gcm_NPUBBYTES] npub,
                                            in ubyte[crypto_aead_aes256gcm_KEYBYTES] k) pure @trusted
{
  enforce(m.length, "Error invoking crypto_aead_aes256gcm_encrypt_detached: m is null"); // TODO check if m.ptr==null would be okay
  if (c.length <      m.length)
    c.length =        m.length;
  enforce(c.length >= m.length, "Error invoking crypto_aead_aes256gcm_encrypt_detached: out buffer too small");
  ulong maclen_p;
  bool result =  crypto_aead_aes256gcm_encrypt_detached(c.ptr, mac.ptr, &maclen_p, m.ptr, m.length, ad.ptr, ad.length, null, npub.ptr, k.ptr) == 0;
  if (maclen_p && result)
    assert(maclen_p == crypto_aead_aes256gcm_ABYTES);
  return  result;
}

alias crypto_aead_aes256gcm_decrypt_detached = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_decrypt_detached;

bool crypto_aead_aes256gcm_decrypt_detached(ref ubyte[] m,
                                            in ubyte[] c,
                                            in ubyte[crypto_aead_aes256gcm_ABYTES] mac,
                                            in ubyte[] ad,
                                            in ubyte[crypto_aead_aes256gcm_NPUBBYTES] npub,
                                            in ubyte[crypto_aead_aes256gcm_KEYBYTES] k) pure @trusted
{
  enforce(c.length, "Error invoking crypto_aead_aes256gcm_decrypt_detached: c is null"); // TODO check if c.ptr==null would be okay
  if (m.length <      c.length)
    m.length =        c.length;
  enforce(m.length >= c.length, "Error invoking crypto_aead_aes256gcm_decrypt_detached: out buffer too small");
  return  crypto_aead_aes256gcm_decrypt_detached(m.ptr, null, c.ptr, c.length, mac.ptr, ad.ptr, ad.length, npub.ptr, k.ptr) == 0;
}

/* -- Precomputation interface -- */

alias crypto_aead_aes256gcm_beforenm = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_beforenm;

pragma(inline, true)
bool crypto_aead_aes256gcm_beforenm(ref crypto_aead_aes256gcm_state ctx_,
                                    in ubyte[crypto_aead_aes256gcm_KEYBYTES] k) pure @nogc @trusted
{
//  enforce(k.length == crypto_aead_aes256gcm_KEYBYTES, "Error invoking crypto_aead_aes256gcm_beforenm: k.length is wrong");
  return  crypto_aead_aes256gcm_beforenm(&ctx_, k.ptr) == 0;
}

alias crypto_aead_aes256gcm_encrypt_afternm = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_encrypt_afternm;

bool crypto_aead_aes256gcm_encrypt_afternm(scope ubyte[] c,
                                           out ulong clen_p,
                                           in ubyte[] m,
                                           in ubyte[] ad,
                                           in ubyte[crypto_aead_aes256gcm_NPUBBYTES] npub,
                                           ref const crypto_aead_aes256gcm_state ctx_) pure @trusted
{
  enforce(m.length, "Error invoking crypto_aead_aes256gcm_encrypt_afternm: m is null");
  enforce(c.length >= m.length + crypto_aead_aes256gcm_ABYTES, "Error invoking crypto_aead_aes256gcm_encrypt_afternm: out buffer too small");
  return  crypto_aead_aes256gcm_encrypt_afternm(c.ptr, &clen_p, m.ptr, m.length, ad.ptr, ad.length, null, npub.ptr, &ctx_) == 0;
}

alias crypto_aead_aes256gcm_decrypt_afternm = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_decrypt_afternm;

bool crypto_aead_aes256gcm_decrypt_afternm(scope ubyte[] m,
                                           out ulong mlen_p,
                                           in ubyte[] c,
                                           in ubyte[] ad,
                                           in ubyte[crypto_aead_aes256gcm_NPUBBYTES] npub,
                                           ref const crypto_aead_aes256gcm_state ctx_) pure @trusted
{
  enforce(c.length >= crypto_aead_aes256gcm_ABYTES, "Error invoking crypto_aead_aes256gcm_decrypt_afternm: in ciphertext too short");
  enforce(m.length >= c.length - crypto_aead_aes256gcm_ABYTES, "Error invoking crypto_aead_aes256gcm_decrypt_afternm: out buffer too small");
  return  crypto_aead_aes256gcm_decrypt_afternm(m.ptr, &mlen_p, null, c.ptr, c.length, ad.ptr, ad.length, npub.ptr, &ctx_) == 0;
}

alias crypto_aead_aes256gcm_encrypt_detached_afternm = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_encrypt_detached_afternm;

bool crypto_aead_aes256gcm_encrypt_detached_afternm(scope ubyte[] c,
                                                    out ubyte[crypto_aead_aes256gcm_ABYTES] mac,
                                                    out ulong maclen_p,
                                                    in ubyte[] m,
                                                    in ubyte[] ad,
                                                    in ubyte[crypto_aead_aes256gcm_NPUBBYTES] npub,
                                                    ref const crypto_aead_aes256gcm_state ctx_) pure @trusted
{
  enforce(c.length >= m.length, "Error invoking crypto_aead_aes256gcm_encrypt_detached_afternm: out buffer too small");
  return  crypto_aead_aes256gcm_encrypt_detached_afternm(c.ptr, mac.ptr, &maclen_p, m.ptr, m.length, ad.ptr, ad.length, null, npub.ptr, &ctx_) == 0;
}

alias crypto_aead_aes256gcm_decrypt_detached_afternm = deimos.sodium.crypto_aead_aes256gcm.crypto_aead_aes256gcm_decrypt_detached_afternm;

bool crypto_aead_aes256gcm_decrypt_detached_afternm(scope ubyte[] m,
                                                    in ubyte[] c,
                                                    in ubyte[crypto_aead_aes256gcm_ABYTES] mac,
                                                    in ubyte[] ad,
                                                    in ubyte[crypto_aead_aes256gcm_NPUBBYTES] npub,
                                                    ref const crypto_aead_aes256gcm_state ctx_) pure @trusted
{
  enforce(m.length >= c.length, "Error invoking crypto_aead_aes256gcm_decrypt_detached_afternm: out buffer too small");
  return  crypto_aead_aes256gcm_decrypt_detached_afternm(m.ptr, null, c.ptr, c.length, mac.ptr, ad.ptr, ad.length, npub.ptr, &ctx_) == 0;
}


version(unittest)
{
  import wrapper.sodium.randombytes : randombytes;
  // share a key and nonce in the following unittests
  ubyte[crypto_aead_aes256gcm_NPUBBYTES]  nonce = void;
  ubyte[crypto_aead_aes256gcm_KEYBYTES]   key   = void;

  static this() {
    randombytes(nonce);
    randombytes(key);
  }

/*
version(Windows)
version(X86)
  version = viWindowsX86;
*/
}


@system
unittest
{
  import std.string : representation;
  import std.stdio : writeln;
  debug writeln("unittest block 1 from sodium.crypto_aead_aes256gcm.d");

  if (crypto_aead_aes256gcm_is_available() == 0)
    writeln("*** ATTENTION : The current CPU dosn't support the AES256-GCM implementation ! ***");
  else {
    auto message         = representation("test");
    auto additional_data = representation("A typical use case for additional data is to store protocol-specific metadata " ~
      "about the message, such as its length and encoding. (non-confidential, non-encrypted data");
    ubyte[] ciphertext = new ubyte[message.length + crypto_aead_aes256gcm_ABYTES];
    ulong   ciphertext_len;

    crypto_aead_aes256gcm_encrypt(ciphertext.ptr, &ciphertext_len, message.ptr, message.length,
      additional_data.ptr, additional_data.length, null, nonce.ptr, key.ptr);

    ubyte[] decrypted = new ubyte[message.length];
    ulong decrypted_len;
    if (ciphertext_len < crypto_aead_aes256gcm_ABYTES ||
      crypto_aead_aes256gcm_decrypt(decrypted.ptr, &decrypted_len, null, ciphertext.ptr, ciphertext_len,
        additional_data.ptr, additional_data.length, nonce.ptr, key.ptr) != 0) {
      writeln("*** ATTENTION : The message has been forged ! ***");
    }
    else { // successfull verification of mac
      assert(decrypted == message); //writeln("Decrypted message (aead_aes256gcm): ", cast(string)decrypted);
      assert(decrypted_len == decrypted.length);
    }
    // test null for &ciphertext_len
    crypto_aead_aes256gcm_encrypt(ciphertext.ptr, null, message.ptr, message.length,
      additional_data.ptr, additional_data.length, null, nonce.ptr, key.ptr);
    crypto_aead_aes256gcm_decrypt(decrypted.ptr, null, null, ciphertext.ptr, ciphertext_len,
      additional_data.ptr, additional_data.length, nonce.ptr, key.ptr);
  }
}

@safe
unittest
{
  import std.string : representation;
  import std.stdio : writeln, writefln;
  import wrapper.sodium.utils : sodium_increment;

version(none/*viWindowsX86*/) {
  writeln("early return for Windows X86: unittest block 2 from sodium.crypto_aead_aes256gcm.d");
  writeln("There is some not yet checked issue with 'Access Violation' running -m32_mscoff (alignment?), yet -m32 is okay");
  return;
}
else {
  debug writeln("unittest block 2 from sodium.crypto_aead_aes256gcm.d");

  assert(crypto_aead_aes256gcm_keybytes()   == crypto_aead_aes256gcm_KEYBYTES);
  assert(crypto_aead_aes256gcm_nsecbytes()  == crypto_aead_aes256gcm_NSECBYTES);
  assert(crypto_aead_aes256gcm_npubbytes()  == crypto_aead_aes256gcm_NPUBBYTES);
  assert(crypto_aead_aes256gcm_abytes()     == crypto_aead_aes256gcm_ABYTES);
  assert(crypto_aead_aes256gcm_statebytes() == crypto_aead_aes256gcm_state.sizeof);


  if (crypto_aead_aes256gcm_is_available() == 0)
    writeln("*** ATTENTION : The current CPU dosn't support the AES256-GCM implementation ! ***");
  else {
    auto message         = representation("test");
    auto additional_data = representation("A typical use case for additional data is to store protocol-specific metadata " ~
      "about the message, such as its length and encoding. (non-confidential, non-encrypted data");
    ubyte[] ciphertext       = new ubyte[message.length + crypto_aead_aes256gcm_ABYTES];
    ubyte[] ciphertext_short = new ubyte[message.length + crypto_aead_aes256gcm_ABYTES -1];
    sodium_increment(nonce);

    assertNotThrown(crypto_aead_aes256gcm_encrypt(ciphertext_short, message, additional_data, nonce, key));
    assertThrown   (crypto_aead_aes256gcm_encrypt(ciphertext      , null,    additional_data, nonce, key));
    assertNotThrown(crypto_aead_aes256gcm_encrypt(ciphertext      , message, null,            nonce, key));

    ciphertext.length = 0;
    assert(crypto_aead_aes256gcm_encrypt(ciphertext, message, additional_data, nonce, key));
    assert(ciphertext.length == message.length + crypto_aead_aes256gcm_ABYTES);

    ubyte[] decrypted       = new ubyte[message.length];
    ubyte[] decrypted_short = new ubyte[message.length -1];
    assertThrown   (crypto_aead_aes256gcm_decrypt(decrypted,       ciphertext[0..crypto_aead_aes256gcm_ABYTES-1], additional_data, nonce, key));
    assertNotThrown(crypto_aead_aes256gcm_decrypt(decrypted_short, ciphertext,                                    additional_data, nonce, key));
    assertNotThrown(crypto_aead_aes256gcm_decrypt(decrypted,       ciphertext,                                    null,            nonce, key));

    decrypted.length = 0;
    assert(crypto_aead_aes256gcm_decrypt(decrypted, ciphertext, additional_data, nonce, key));
    assert(decrypted == message);
    assert(decrypted.length == ciphertext.length - crypto_aead_aes256gcm_ABYTES);

    ciphertext.length = message.length;
    ubyte[crypto_aead_aes256gcm_ABYTES] mac;
    ulong                               maclen_p;
    sodium_increment(nonce);
    ciphertext_short.length = message.length + crypto_aead_aes256gcm_ABYTES -1;

    assertNotThrown(crypto_aead_aes256gcm_encrypt_detached(ciphertext_short, mac, message, additional_data, nonce, key));
    assertThrown   (crypto_aead_aes256gcm_encrypt_detached(ciphertext      , mac, null,    additional_data, nonce, key));
    assertNotThrown(crypto_aead_aes256gcm_encrypt_detached(ciphertext      , mac, message, null,            nonce, key));

    assert(crypto_aead_aes256gcm_encrypt_detached(ciphertext, mac, message, additional_data, nonce, key));

    decrypted_short.length = message.length -1;
    assertNotThrown(crypto_aead_aes256gcm_decrypt_detached(decrypted_short, ciphertext, mac, additional_data, nonce, key));
    assertThrown   (crypto_aead_aes256gcm_decrypt_detached(decrypted,       null,       mac, additional_data, nonce, key));
    assertNotThrown(crypto_aead_aes256gcm_decrypt_detached(decrypted,       ciphertext, mac, null,            nonce, key));

    decrypted.length = 0;
    assert(crypto_aead_aes256gcm_decrypt_detached(decrypted, ciphertext, mac, additional_data, nonce, key));
    assert(decrypted == message);

    /* -- Precomputation interface -- */

    align(16) crypto_aead_aes256gcm_state  ctx_;
    crypto_aead_aes256gcm_beforenm(ctx_, key);

    ciphertext.length = message.length + crypto_aead_aes256gcm_ABYTES;
    sodium_increment(nonce);
    ulong   ciphertext_len;

    assertThrown   (crypto_aead_aes256gcm_encrypt_afternm(ciphertext[0..$-1], ciphertext_len, message, additional_data, nonce, ctx_));
    assertThrown   (crypto_aead_aes256gcm_encrypt_afternm(ciphertext        , ciphertext_len, null,    additional_data, nonce, ctx_));
    assertNotThrown(crypto_aead_aes256gcm_encrypt_afternm(ciphertext        , ciphertext_len, message, null,            nonce, ctx_));

    crypto_aead_aes256gcm_encrypt_afternm(ciphertext, ciphertext_len, message, additional_data, nonce, ctx_);
    assert(ciphertext_len == ciphertext.length);

    ulong   decrypted_len;
    assertThrown   (crypto_aead_aes256gcm_decrypt_afternm(decrypted,         decrypted_len, ciphertext[0..crypto_aead_aes256gcm_ABYTES-1], additional_data, nonce, ctx_));
    assertThrown   (crypto_aead_aes256gcm_decrypt_afternm(decrypted[0..$-1], decrypted_len, ciphertext,                                    additional_data, nonce, ctx_));
    assertNotThrown(crypto_aead_aes256gcm_decrypt_afternm(decrypted,         decrypted_len, ciphertext,                                    null,            nonce, ctx_));

    if (!crypto_aead_aes256gcm_decrypt_afternm(decrypted, decrypted_len, ciphertext, additional_data, nonce, ctx_))
      writeln("*** ATTENTION : The message has been forged ! ***");
    else {
      assert(decrypted == message);
      assert(decrypted_len == decrypted.length);
    }


    ciphertext.length = message.length;
    sodium_increment(nonce);

    assertThrown   (crypto_aead_aes256gcm_encrypt_detached_afternm(ciphertext[0..$-1], mac, maclen_p, message, additional_data, nonce, ctx_));
    assertNotThrown(crypto_aead_aes256gcm_encrypt_detached_afternm(ciphertext        , mac, maclen_p, null,    additional_data, nonce, ctx_));
    assertNotThrown(crypto_aead_aes256gcm_encrypt_detached_afternm(ciphertext        , mac, maclen_p, message, null,            nonce, ctx_));

    crypto_aead_aes256gcm_encrypt_detached_afternm(ciphertext, mac, maclen_p, message, additional_data, nonce, ctx_);
    assert(maclen_p == mac.length);

    assertThrown   (crypto_aead_aes256gcm_decrypt_detached_afternm(decrypted[0..$-1], ciphertext, mac, additional_data, nonce, ctx_));
    assertNotThrown(crypto_aead_aes256gcm_decrypt_detached_afternm(decrypted,         null,       mac, additional_data, nonce, ctx_));
    assertNotThrown(crypto_aead_aes256gcm_decrypt_detached_afternm(decrypted,         ciphertext, mac, null,            nonce, ctx_));

    if (!crypto_aead_aes256gcm_decrypt_detached_afternm(decrypted, ciphertext, mac, additional_data, nonce, ctx_))
      writeln("*** ATTENTION : The message has been forged ! ***");
    else {
      assert(decrypted == message);
//      writefln("MAC: 0x%(%02x%)", mac);
    }

    ubyte[crypto_aead_aes256gcm_KEYBYTES] k;
    crypto_aead_aes256gcm_keygen(k);
  } // if (crypto_aead_aes256gcm_is_available() != 0)
}
}
