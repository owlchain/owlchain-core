// Written in the D programming language.

module wrapper.sodium.crypto_aead_chacha20poly1305;

import wrapper.sodium.core; // assure sodium got initialized

public
import  deimos.sodium.crypto_aead_chacha20poly1305 : crypto_aead_chacha20poly1305_ietf_KEYBYTES,
                                                     crypto_aead_chacha20poly1305_ietf_keybytes,
                                                     crypto_aead_chacha20poly1305_ietf_NSECBYTES,
                                                     crypto_aead_chacha20poly1305_ietf_nsecbytes,
                                                     crypto_aead_chacha20poly1305_ietf_NPUBBYTES,
                                                     crypto_aead_chacha20poly1305_ietf_npubbytes,
                                                     crypto_aead_chacha20poly1305_ietf_ABYTES,
                                                     crypto_aead_chacha20poly1305_ietf_abytes,
/*                                                   crypto_aead_chacha20poly1305_ietf_encrypt,
                                                     crypto_aead_chacha20poly1305_ietf_decrypt,
                                                     crypto_aead_chacha20poly1305_ietf_encrypt_detached,
                                                     crypto_aead_chacha20poly1305_ietf_decrypt_detached, */
                                                     crypto_aead_chacha20poly1305_ietf_keygen,
                                                     crypto_aead_chacha20poly1305_KEYBYTES,
                                                     crypto_aead_chacha20poly1305_keybytes,
                                                     crypto_aead_chacha20poly1305_NSECBYTES,
                                                     crypto_aead_chacha20poly1305_nsecbytes,
                                                     crypto_aead_chacha20poly1305_NPUBBYTES,
                                                     crypto_aead_chacha20poly1305_npubbytes,
                                                     crypto_aead_chacha20poly1305_ABYTES,
                                                     crypto_aead_chacha20poly1305_abytes,
/*                                                   crypto_aead_chacha20poly1305_encrypt,
                                                     crypto_aead_chacha20poly1305_decrypt,
                                                     crypto_aead_chacha20poly1305_encrypt_detached,
                                                     crypto_aead_chacha20poly1305_decrypt_detached, */
                                                     crypto_aead_chacha20poly1305_keygen;
;


// Written in the D programming language.

/* Authenticated Encryption with Additional Data : AES256-GCM */

/+
public
import  deimos.sodium.crypto_aead_aes256gcm : crypto_aead_aes256gcm_ABYTES,
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
+/
import std.exception : enforce, assertThrown, assertNotThrown;

// overloading some functions between module deimos.sodium.crypto_aead_chacha20poly1305 and this module

alias crypto_aead_chacha20poly1305_ietf_encrypt = deimos.sodium.crypto_aead_chacha20poly1305.crypto_aead_chacha20poly1305_ietf_encrypt;

/**
 * The function crypto_aead_chacha20poly1305_ietf_encrypt()
 * encrypts a message `m` using a secret key `k` (crypto_aead_chacha20poly1305_ietf_KEYBYTES bytes)
 * and a public nonce `npub` (crypto_aead_chacha20poly1305_ietf_NPUBBYTES bytes).
 * The encrypted message, as well as a tag authenticating both the confidential message m and ad.length bytes of non-confidential data `ad`,
 * are put into `c`.
 * ad can also be an empty array if no additional data are required.
 * At most m.length + crypto_aead_chacha20poly1305_ietf_ABYTES bytes are put into `c`, and the actual number of bytes is stored into `clen_p`.
 * The function always returns true.
 * The public nonce npub should never ever be reused with the same key. The recommended way to generate it is to use
 * randombytes_buf() for the first message, and then to increment it for each subsequent message using the same key.

 The	 	crypto_aead_chacha20poly1305_ietf_encrypt()		function	encrypts	a	message	 	m		whose
length	is	 	mlen	 	bytes	using	a	secret	key	 	k	 	( 	crypto_aead_chacha20poly1305_IETF_KEYBYTES
bytes)	and	public	nonce	 	npub		( 	crypto_aead_chacha20poly1305_IETF_NPUBBYTES		bytes).
The	encrypted	message,	as	well	as	a	tag	authenticating	both	the	confidential	message	 	m
and	 	adlen		bytes	of	non-confidential	data	 	ad	 ,	are	put	into	 	c	 .
	ad		can	be	a	 	NULL		pointer	with	 	adlen		equal	to	 	0		if	no	additional	data	are	required.
At	most	 	mlen	+	crypto_aead_chacha20poly1305_IETF_ABYTES		bytes	are	put	into	 	c	 ,	and	the
actual	number	of	bytes	is	stored	into	 	clen		unless	 	clen		is	a	 	NULL		pointer.
	nsec	 	is	not	used	by	this	particular	construction	and	should	always	be	 	NULL	 .
The	public	nonce	 	npub		should	never	ever	be	reused	with	the	same	key.	The	recommended
way	to	generate	it	is	to	use	 	randombytes_buf()	 	for	the	first	message,	and	increment	it	for
each	subsequent	message	using	the	same	key.

 */
bool crypto_aead_chacha20poly1305_ietf_encrypt(ref ubyte[] c,
//                                               out ulong clen_p,
                                               in ubyte[] m,
                                               in ubyte[] ad,
                                               in ubyte[crypto_aead_chacha20poly1305_ietf_NPUBBYTES] npub,
                                               in ubyte[crypto_aead_chacha20poly1305_ietf_KEYBYTES] k) pure @trusted
{
  enforce(m.length, "Error invoking crypto_aead_chacha20poly1305_ietf_encrypt: m is null"); // TODO check if m.ptr==null would be okay
  if (c.length <      m.length + crypto_aead_chacha20poly1305_ietf_ABYTES)
    c.length =        m.length + crypto_aead_chacha20poly1305_ietf_ABYTES;
  enforce(c.length >= m.length + crypto_aead_chacha20poly1305_ietf_ABYTES, "Error invoking crypto_aead_chacha20poly1305_ietf_encrypt: out buffer too small");
  ulong clen_p;
  bool result = crypto_aead_chacha20poly1305_ietf_encrypt(c.ptr, &clen_p, m.ptr, m.length, ad.ptr, ad.length, null, npub.ptr, k.ptr) == 0;
  if (clen_p) {
    assert(clen_p ==  m.length + crypto_aead_chacha20poly1305_ietf_ABYTES);
    if (c.length>clen_p)
	    c.length = clen_p;
  }
  return  result;
}

alias crypto_aead_chacha20poly1305_ietf_decrypt = deimos.sodium.crypto_aead_chacha20poly1305.crypto_aead_chacha20poly1305_ietf_decrypt;

/**
 * The function crypto_aead_chacha20poly1305_ietf_decrypt()
  verifies that the ciphertext `c` (as produced by crypto_aead_chacha20poly1305_ietf_encrypt()),
 * includes a valid tag using a secret key `k`, a public nonce `npub`, and additional data `ad`. c.length is the ciphertext length
 * in bytes with the authenticator, so it has to be at least crypto_aead_chacha20poly1305_ietf_ABYTES.
 *
 * ad can be an empty array if no additional data are required.
 * The function returns false if the verification fails.
 * If the verification succeeds, the function returns true, puts the decrypted message into `m` and stores its actual number of bytes into `mlen_p`.
 * At most c.length - crypto_aead_chacha20poly1305_ietf_ABYTES bytes will be put into m.
 */
bool crypto_aead_chacha20poly1305_ietf_decrypt(ref ubyte[] m,
//                                               out ulong mlen_p,
                                               in ubyte[] c,
                                               in ubyte[] ad,
                                               in ubyte[crypto_aead_chacha20poly1305_ietf_NPUBBYTES] npub,
                                               in ubyte[crypto_aead_chacha20poly1305_ietf_KEYBYTES] k) pure @trusted
{
  enforce(c.length >= crypto_aead_chacha20poly1305_ietf_ABYTES, "Error invoking crypto_aead_chacha20poly1305_ietf_decrypt: in buffer ciphertext too small");
  if (m.length <      c.length - crypto_aead_chacha20poly1305_ietf_ABYTES)
    m.length =        c.length - crypto_aead_chacha20poly1305_ietf_ABYTES;
  enforce(m.length >= c.length - crypto_aead_chacha20poly1305_ietf_ABYTES, "Error invoking crypto_aead_chacha20poly1305_ietf_decrypt: out buffer too small");
  ulong mlen_p;
  bool result = crypto_aead_chacha20poly1305_ietf_decrypt(m.ptr, &mlen_p, null, c.ptr, c.length, ad.ptr, ad.length, npub.ptr, k.ptr) == 0;
  if (result && mlen_p) {
    assert(mlen_p ==  c.length - crypto_aead_chacha20poly1305_ietf_ABYTES);
    if (m.length>mlen_p)
      m.length = mlen_p;
  }
  return  result;
}

alias crypto_aead_chacha20poly1305_ietf_encrypt_detached = deimos.sodium.crypto_aead_chacha20poly1305.crypto_aead_chacha20poly1305_ietf_encrypt_detached;

bool  crypto_aead_chacha20poly1305_ietf_encrypt_detached(ref ubyte[] c,
                                                        out ubyte[crypto_aead_chacha20poly1305_ietf_ABYTES] mac,
//                                                        out ulong maclen_p,
                                                        in ubyte[] m,
                                                        in ubyte[] ad,
                                                        in ubyte[crypto_aead_chacha20poly1305_ietf_NPUBBYTES] npub,
                                                        in ubyte[crypto_aead_chacha20poly1305_ietf_KEYBYTES] k) pure @trusted
{
  enforce(m.length, "Error invoking crypto_aead_chacha20poly1305_ietf_encrypt_detached: m is null"); // TODO check if m.ptr==null would be okay
  if (c.length <      m.length)
    c.length =        m.length;
  enforce(c.length >= m.length, "Error invoking crypto_aead_chacha20poly1305_ietf_encrypt_detached: out buffer too small");
  ulong maclen_p;
  bool result = crypto_aead_chacha20poly1305_ietf_encrypt_detached(c.ptr, mac.ptr, &maclen_p, m.ptr, m.length, ad.ptr, ad.length, null, npub.ptr, k.ptr) == 0;
  if (maclen_p && result)
    assert(maclen_p == crypto_aead_chacha20poly1305_ietf_ABYTES);
  return  result;
}

alias crypto_aead_chacha20poly1305_ietf_decrypt_detached = deimos.sodium.crypto_aead_chacha20poly1305.crypto_aead_chacha20poly1305_ietf_decrypt_detached;

bool crypto_aead_chacha20poly1305_ietf_decrypt_detached(ref ubyte[] m,
                                                        in ubyte[] c,
                                                        in ubyte[crypto_aead_chacha20poly1305_ietf_ABYTES] mac,
                                                        in ubyte[] ad,
                                                        in ubyte[crypto_aead_chacha20poly1305_ietf_NPUBBYTES] npub,
                                                        in ubyte[crypto_aead_chacha20poly1305_ietf_KEYBYTES] k) pure @trusted
{
  enforce(c.length, "Error invoking crypto_aead_chacha20poly1305_ietf_decrypt_detached: c is null"); // TODO check if c.ptr==null would be okay
  if (m.length <      c.length)
    m.length =        c.length;
  enforce(m.length >= c.length, "Error invoking crypto_aead_chacha20poly1305_ietf_decrypt_detached: out buffer too small");
  return  crypto_aead_chacha20poly1305_ietf_decrypt_detached(m.ptr, null, c.ptr, c.length, mac.ptr, ad.ptr, ad.length, npub.ptr, k.ptr) == 0;
}

/* -- Original ChaCha20-Poly1305 construction with a 64-bit nonce and a 64-bit internal counter -- */

alias crypto_aead_chacha20poly1305_encrypt = deimos.sodium.crypto_aead_chacha20poly1305.crypto_aead_chacha20poly1305_encrypt;

bool  crypto_aead_chacha20poly1305_encrypt(ref ubyte[] c,
//                                               out ulong clen_p,
                                               in ubyte[] m,
                                               in ubyte[] ad,
                                               in ubyte[crypto_aead_chacha20poly1305_NPUBBYTES] npub,
                                               in ubyte[crypto_aead_chacha20poly1305_KEYBYTES] k) pure @trusted
{
  enforce(m.length, "Error invoking crypto_aead_chacha20poly1305_encrypt: m is null"); // TODO check if m.ptr==null would be okay
  if (c.length <      m.length + crypto_aead_chacha20poly1305_ABYTES)
    c.length =        m.length + crypto_aead_chacha20poly1305_ABYTES;
  enforce(c.length >= m.length + crypto_aead_chacha20poly1305_ABYTES, "Error invoking crypto_aead_chacha20poly1305_encrypt: out buffer too small");
  ulong clen_p;
  bool result = crypto_aead_chacha20poly1305_encrypt(c.ptr, &clen_p, m.ptr, m.length, ad.ptr, ad.length, null, npub.ptr, k.ptr) == 0;
  if (clen_p) {
    assert(clen_p ==  m.length + crypto_aead_chacha20poly1305_ABYTES);
    if (c.length>clen_p)
	    c.length = clen_p;
  }
  return  result;
}

alias crypto_aead_chacha20poly1305_decrypt = deimos.sodium.crypto_aead_chacha20poly1305.crypto_aead_chacha20poly1305_decrypt;

bool  crypto_aead_chacha20poly1305_decrypt(ref ubyte[] m,
//                                               out ulong mlen_p,
                                           in ubyte[] c,
                                           in ubyte[] ad,
                                           in ubyte[crypto_aead_chacha20poly1305_NPUBBYTES] npub,
                                           in ubyte[crypto_aead_chacha20poly1305_KEYBYTES] k) pure @trusted
{
  enforce(c.length >= crypto_aead_chacha20poly1305_ABYTES, "Error invoking crypto_aead_chacha20poly1305_decrypt: in buffer ciphertext too small");
  if (m.length <      c.length - crypto_aead_chacha20poly1305_ABYTES)
    m.length =        c.length - crypto_aead_chacha20poly1305_ABYTES;
  enforce(m.length >= c.length - crypto_aead_chacha20poly1305_ABYTES, "Error invoking crypto_aead_chacha20poly1305_decrypt: out buffer too small");
  ulong mlen_p;
  bool result = crypto_aead_chacha20poly1305_decrypt(m.ptr, &mlen_p, null, c.ptr, c.length, ad.ptr, ad.length, npub.ptr, k.ptr) == 0;
  if (result && mlen_p) {
    assert(mlen_p ==  c.length - crypto_aead_chacha20poly1305_ABYTES);
    if (m.length>mlen_p)
      m.length = mlen_p;
  }
  return  result;
}

alias crypto_aead_chacha20poly1305_encrypt_detached = deimos.sodium.crypto_aead_chacha20poly1305.crypto_aead_chacha20poly1305_encrypt_detached;

bool  crypto_aead_chacha20poly1305_encrypt_detached(ref ubyte[] c,
                                                    out ubyte[crypto_aead_chacha20poly1305_ABYTES] mac,
//                                                  out ulong maclen_p,
                                                    in ubyte[] m,
                                                    in ubyte[] ad,
                                                    in ubyte[crypto_aead_chacha20poly1305_NPUBBYTES] npub,
                                                    in ubyte[crypto_aead_chacha20poly1305_KEYBYTES] k) pure @trusted
{
  enforce(m.length, "Error invoking crypto_aead_chacha20poly1305_encrypt_detached: m is null"); // TODO check if m.ptr==null would be okay
  if (c.length <      m.length)
    c.length =        m.length;
  enforce(c.length >= m.length, "Error invoking crypto_aead_chacha20poly1305_encrypt_detached: out buffer too small");
  ulong maclen_p;
  bool result = crypto_aead_chacha20poly1305_encrypt_detached(c.ptr, mac.ptr, &maclen_p, m.ptr, m.length, ad.ptr, ad.length, null, npub.ptr, k.ptr) == 0;
  if (maclen_p && result)
    assert(maclen_p == crypto_aead_chacha20poly1305_ABYTES);
  return  result;
}

alias crypto_aead_chacha20poly1305_decrypt_detached = deimos.sodium.crypto_aead_chacha20poly1305.crypto_aead_chacha20poly1305_decrypt_detached;

bool crypto_aead_chacha20poly1305_decrypt_detached(ref ubyte[] m,
                                                   in ubyte[] c,
                                                   in ubyte[crypto_aead_chacha20poly1305_ABYTES] mac,
                                                   in ubyte[] ad,
                                                   in ubyte[crypto_aead_chacha20poly1305_NPUBBYTES] npub,
                                                   in ubyte[crypto_aead_chacha20poly1305_KEYBYTES] k) pure @trusted
{
  enforce(c.length, "Error invoking crypto_aead_chacha20poly1305_decrypt_detached: c is null"); // TODO check if c.ptr==null would be okay
  if (m.length <      c.length)
    m.length =        c.length;
  enforce(m.length >= c.length, "Error invoking crypto_aead_chacha20poly1305_decrypt_detached: out buffer too small");
  return  crypto_aead_chacha20poly1305_decrypt_detached(m.ptr, null, c.ptr, c.length, mac.ptr, ad.ptr, ad.length, npub.ptr, k.ptr) == 0;
}


version(unittest)
{
  import wrapper.sodium.randombytes : randombytes;
  // share a key and nonce in the following unittests
  ubyte[crypto_aead_chacha20poly1305_ietf_NPUBBYTES]  nonce = void;
  ubyte[crypto_aead_chacha20poly1305_ietf_KEYBYTES]   key   = void;

  ubyte[crypto_aead_chacha20poly1305_NPUBBYTES]  nonce2 = void;
  ubyte[crypto_aead_chacha20poly1305_KEYBYTES]   key2   = void;

  static this() {
    randombytes(nonce);
    randombytes(key);
    randombytes(nonce2);
    randombytes(key2);
  }
}


@system
unittest
{
  import std.string : representation;
  import std.stdio : writeln;
  debug writeln("unittest block 1 from sodium.crypto_aead_chacha20poly1305.d");

  auto message         = representation("test");
  auto additional_data = representation("A typical use case for additional data is to store protocol-specific metadata " ~
    "about the message, such as its length and encoding. (non-confidential, non-encrypted data");
  ubyte[] ciphertext = new ubyte[message.length + crypto_aead_chacha20poly1305_ietf_ABYTES];
  ulong   ciphertext_len;

  crypto_aead_chacha20poly1305_ietf_encrypt(ciphertext.ptr, &ciphertext_len, message.ptr, message.length,
    additional_data.ptr, additional_data.length, null, nonce.ptr, key.ptr);

  ubyte[] decrypted = new ubyte[message.length];
  ulong decrypted_len;
  if (ciphertext_len < crypto_aead_chacha20poly1305_ietf_ABYTES ||
    crypto_aead_chacha20poly1305_ietf_decrypt(decrypted.ptr, &decrypted_len, null, ciphertext.ptr, ciphertext_len,
      additional_data.ptr, additional_data.length, nonce.ptr, key.ptr) != 0) {
    writeln("*** ATTENTION : The message has been forged ! ***");
  }
  else { // successfull verification of mac
    assert(decrypted == message); //writeln("Decrypted message (aead_chacha20poly1305): ", cast(string)decrypted);
    assert(decrypted_len == decrypted.length);
  }
  // test null for &ciphertext_len / decrypted_len
  crypto_aead_chacha20poly1305_ietf_encrypt(ciphertext.ptr, null, message.ptr, message.length,
    additional_data.ptr, additional_data.length, null, nonce.ptr, key.ptr);
  crypto_aead_chacha20poly1305_ietf_decrypt(decrypted.ptr, null, null, ciphertext.ptr, ciphertext_len,
    additional_data.ptr, additional_data.length, nonce.ptr, key.ptr);

  ubyte[crypto_aead_chacha20poly1305_ietf_KEYBYTES] k;
  crypto_aead_chacha20poly1305_ietf_keygen(k);
  ubyte[crypto_aead_chacha20poly1305_KEYBYTES] k2;
  crypto_aead_chacha20poly1305_keygen(k2);

}

@safe
unittest
{
  import std.string : representation;
  import std.stdio : writeln, writefln;
  import wrapper.sodium.utils : sodium_increment;
  debug writeln("unittest block 2 from sodium.crypto_aead_chacha20poly1305.d");

  assert(crypto_aead_chacha20poly1305_ietf_keybytes()   == crypto_aead_chacha20poly1305_ietf_KEYBYTES);
  assert(crypto_aead_chacha20poly1305_ietf_nsecbytes()  == crypto_aead_chacha20poly1305_ietf_NSECBYTES);
  assert(crypto_aead_chacha20poly1305_ietf_npubbytes()  == crypto_aead_chacha20poly1305_ietf_NPUBBYTES);
  assert(crypto_aead_chacha20poly1305_ietf_abytes()     == crypto_aead_chacha20poly1305_ietf_ABYTES);


  auto message         = representation("test");
  auto additional_data = representation("A typical use case for additional data is to store protocol-specific metadata " ~
    "about the message, such as its length and encoding. (non-confidential, non-encrypted data");
  ubyte[] ciphertext       = new ubyte[message.length + crypto_aead_chacha20poly1305_ietf_ABYTES];
  ubyte[] ciphertext_short = new ubyte[message.length + crypto_aead_chacha20poly1305_ietf_ABYTES -1];
  sodium_increment(nonce);

  assertNotThrown(crypto_aead_chacha20poly1305_ietf_encrypt(ciphertext_short, message, additional_data, nonce, key));
  assertThrown   (crypto_aead_chacha20poly1305_ietf_encrypt(ciphertext      , null,    additional_data, nonce, key));
  assertNotThrown(crypto_aead_chacha20poly1305_ietf_encrypt(ciphertext      , message, null,            nonce, key));

  ciphertext.length = 0;
  assert(crypto_aead_chacha20poly1305_ietf_encrypt(ciphertext, message, additional_data, nonce, key));
  assert(ciphertext.length == message.length + crypto_aead_chacha20poly1305_ietf_ABYTES);

  ubyte[] decrypted       = new ubyte[message.length];
  ubyte[] decrypted_short = new ubyte[message.length -1];
  assertThrown   (crypto_aead_chacha20poly1305_ietf_decrypt(decrypted,       ciphertext[0..crypto_aead_chacha20poly1305_ietf_ABYTES-1], additional_data, nonce, key));
  assertNotThrown(crypto_aead_chacha20poly1305_ietf_decrypt(decrypted_short, ciphertext,                                                additional_data, nonce, key));
  assertNotThrown(crypto_aead_chacha20poly1305_ietf_decrypt(decrypted,       ciphertext,                                                null,            nonce, key));

  decrypted.length = 0;
  assert(crypto_aead_chacha20poly1305_ietf_decrypt(decrypted, ciphertext, additional_data, nonce, key));
  assert(decrypted == message);
  assert(decrypted.length == ciphertext.length - crypto_aead_chacha20poly1305_ietf_ABYTES);
//
  ciphertext.length = message.length;
  ubyte[crypto_aead_chacha20poly1305_ietf_ABYTES] mac;
//  ulong                               maclen_p;
  sodium_increment(nonce);
  ciphertext_short.length = message.length + crypto_aead_chacha20poly1305_ietf_ABYTES -1;

  assertNotThrown(crypto_aead_chacha20poly1305_ietf_encrypt_detached(ciphertext_short, mac, message, additional_data, nonce, key));
  assertThrown   (crypto_aead_chacha20poly1305_ietf_encrypt_detached(ciphertext      , mac, null,    additional_data, nonce, key));
  assertNotThrown(crypto_aead_chacha20poly1305_ietf_encrypt_detached(ciphertext      , mac, message, null,            nonce, key));

  ciphertext.length = 0;
  assert(crypto_aead_chacha20poly1305_ietf_encrypt_detached(ciphertext, mac, message, additional_data, nonce, key));
  assert(ciphertext.length == message.length);

  decrypted_short.length = message.length -1;
  assertNotThrown(crypto_aead_chacha20poly1305_ietf_decrypt_detached(decrypted_short, ciphertext, mac, additional_data, nonce, key));
  assertThrown   (crypto_aead_chacha20poly1305_ietf_decrypt_detached(decrypted,       null,       mac, additional_data, nonce, key));
  assertNotThrown(crypto_aead_chacha20poly1305_ietf_decrypt_detached(decrypted,       ciphertext, mac, null,            nonce, key));

  decrypted.length = 0;
  assert(crypto_aead_chacha20poly1305_ietf_decrypt_detached(decrypted, ciphertext, mac, additional_data, nonce, key));
  assert(decrypted == message);

}

@safe
unittest
{
  import std.string : representation;
  import std.stdio : writeln, writefln;
  import wrapper.sodium.utils : sodium_increment;
  debug writeln("unittest block 3 from sodium.crypto_aead_chacha20poly1305.d");

  assert(crypto_aead_chacha20poly1305_keybytes()   == crypto_aead_chacha20poly1305_KEYBYTES);
  assert(crypto_aead_chacha20poly1305_nsecbytes()  == crypto_aead_chacha20poly1305_NSECBYTES);
  assert(crypto_aead_chacha20poly1305_npubbytes()  == crypto_aead_chacha20poly1305_NPUBBYTES);
  assert(crypto_aead_chacha20poly1305_abytes()     == crypto_aead_chacha20poly1305_ABYTES);

  auto message         = representation("test");
  auto additional_data = representation("A typical use case for additional data is to store protocol-specific metadata " ~
    "about the message, such as its length and encoding. (non-confidential, non-encrypted data");
  ubyte[] ciphertext       = new ubyte[message.length + crypto_aead_chacha20poly1305_ABYTES];
  ubyte[] ciphertext_short = new ubyte[message.length + crypto_aead_chacha20poly1305_ABYTES -1];
  sodium_increment(nonce2);

  assertNotThrown(crypto_aead_chacha20poly1305_encrypt(ciphertext_short, message, additional_data, nonce2, key2));
  assertThrown   (crypto_aead_chacha20poly1305_encrypt(ciphertext      , null,    additional_data, nonce2, key2));
  assertNotThrown(crypto_aead_chacha20poly1305_encrypt(ciphertext      , message, null,            nonce2, key2));

  ciphertext.length = 0;
  assert(crypto_aead_chacha20poly1305_encrypt(ciphertext, message, additional_data, nonce2, key2));
  assert(ciphertext.length == message.length + crypto_aead_chacha20poly1305_ABYTES);

  ubyte[] decrypted       = new ubyte[message.length];
  ubyte[] decrypted_short = new ubyte[message.length -1];
  assertThrown   (crypto_aead_chacha20poly1305_decrypt(decrypted,       ciphertext[0..crypto_aead_chacha20poly1305_ABYTES-1], additional_data, nonce2, key2));
  assertNotThrown(crypto_aead_chacha20poly1305_decrypt(decrypted_short, ciphertext,                                           additional_data, nonce2, key2));
  assertNotThrown(crypto_aead_chacha20poly1305_decrypt(decrypted,       ciphertext,                                           null,            nonce2, key2));

  decrypted.length = 0;
  assert(crypto_aead_chacha20poly1305_decrypt(decrypted, ciphertext, additional_data, nonce2, key2));
  assert(decrypted == message);
  assert(decrypted.length == ciphertext.length - crypto_aead_chacha20poly1305_ABYTES);
//
  ciphertext.length = message.length;
  ubyte[crypto_aead_chacha20poly1305_ABYTES] mac;
//  ulong                               maclen_p;
  sodium_increment(nonce2);
  ciphertext_short.length = message.length + crypto_aead_chacha20poly1305_ABYTES -1;

  assertNotThrown(crypto_aead_chacha20poly1305_encrypt_detached(ciphertext_short, mac, message, additional_data, nonce2, key2));
  assertThrown   (crypto_aead_chacha20poly1305_encrypt_detached(ciphertext      , mac, null,    additional_data, nonce2, key2));
  assertNotThrown(crypto_aead_chacha20poly1305_encrypt_detached(ciphertext      , mac, message, null,            nonce2, key2));

  ciphertext.length = 0;
  assert(crypto_aead_chacha20poly1305_encrypt_detached(ciphertext, mac, message, additional_data, nonce2, key2));
  assert(ciphertext.length == message.length);

  decrypted_short.length = message.length -1;
  assertNotThrown(crypto_aead_chacha20poly1305_decrypt_detached(decrypted_short, ciphertext, mac, additional_data, nonce2, key2));
  assertThrown   (crypto_aead_chacha20poly1305_decrypt_detached(decrypted,       null,       mac, additional_data, nonce2, key2));
  assertNotThrown(crypto_aead_chacha20poly1305_decrypt_detached(decrypted,       ciphertext, mac, null,            nonce2, key2));

  decrypted.length = 0;
  assert(crypto_aead_chacha20poly1305_decrypt_detached(decrypted, ciphertext, mac, additional_data, nonce2, key2));
  assert(decrypted == message);

}
