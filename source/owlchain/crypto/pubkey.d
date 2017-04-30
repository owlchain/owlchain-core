module owlchain.crypto.pubkey;

import std.digest.sha;
import std.digest.ripemd;

import deimos.sodium;

import owlchain.api.api: IAddress;

/++
// account address space & serialization

Bitcoin Address - https://en.bitcoin.it/wiki/Address
    base58 - https://en.bitcoin.it/wiki/Base58Check_encoding
        Pay-to-script-hash (p2sh): payload is: RIPEMD160(SHA256(redeemScript)) where redeemScript is a script the wallet knows how to spend; version 0x05 (these addresses begin with the digit '3')
        Pay-to-pubkey-hash (p2pkh): payload is RIPEMD160(SHA256(ECDSA_publicKey)) where ECDSA_publicKey is a public key the wallet knows the private key for; version 0x00 (these addresses begin with the digit '1')
        RIPEMD160 - https://en.bitcoin.it/wiki/RIPEMD-160

    Common P2PKH which begin with the number 1, eg: 1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2.
                                                    1234567890123456789012345678901234
    Newer P2SH type starting with the number 3, eg: 3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy.

crypto lib:
    - botan: https://github.com/etcimon/botan
    - libsodium https://code.dlang.org/packages/sodium
    - openssl https://github.com/s-ludwig/openssl
+/


class Address : IAddress {
    bool isValid()
    {
        return true;    
    }
}
@system
unittest {
    import core.stdc.stdlib : EXIT_SUCCESS, EXIT_FAILURE;
    import std.stdio : writefln, writeln;

	int demo()
	{

		writefln("DEIMOS ---------");


		// Manual sodium, chapter "Usage":
		//synchronized { // if sodium_init could be executed by multiple threads simultaneously; not necessary since version 1.0.11
		if (sodium_init == -1) {
			return EXIT_FAILURE;
		}
		//}
		//sodium_init; // An error, if warnings are enabled! The compiler (DMD since 2.066.0) warns about unused/discarded function return value and bails out

		// Manual sodium, chapter "Generating random data":
		ubyte[8] buf;
		if (buf.length <= 256) // limit, that linux guarantees by default, using getrandom(); figure can be higher with added True Random Number Generator
			randombytes_buf(buf.ptr, buf.length);
		writefln("Unpredictable sequence of %s bytes: %s", buf.length, buf);


		// Secret-key authentication example
		auto MESSAGE = cast(immutable(ubyte)[4]) "test";

		if (crypto_aead_aes256gcm_is_available) {
			writeln("crypto_aead_aes256gcm_is_available");
			auto ADDITIONAL_DATA = cast(immutable(ubyte)[6]) "123456";
			ubyte[crypto_aead_aes256gcm_NPUBBYTES] nonce;
			ubyte[crypto_aead_aes256gcm_KEYBYTES]  key;
			ubyte[MESSAGE.length + crypto_aead_aes256gcm_ABYTES] ciphertext;
			ulong ciphertext_len;

			randombytes_buf(key.ptr, key.length);
			randombytes_buf(nonce.ptr, nonce.length);

			crypto_aead_aes256gcm_encrypt(ciphertext.ptr, &ciphertext_len,
									MESSAGE.ptr, MESSAGE.length,
									ADDITIONAL_DATA.ptr, ADDITIONAL_DATA.length,
									null, nonce.ptr, key.ptr);

			writeln("ciphertext: ", ciphertext);
			ubyte[MESSAGE.length] decrypted;
			ulong decrypted_len;
			if (ciphertext_len < crypto_aead_aes256gcm_ABYTES ||
				crypto_aead_aes256gcm_decrypt(decrypted.ptr, &decrypted_len,
										null,
										ciphertext.ptr, ciphertext_len,
										ADDITIONAL_DATA.ptr,
										ADDITIONAL_DATA.length,
										nonce.ptr, key.ptr) != 0) {
				writeln("The message has been forged!");
			}
		}
		else {
			writeln("NOT crypto_aead_aes256gcm_is_available");
			ubyte[crypto_auth_KEYBYTES] key;
			ubyte[crypto_auth_BYTES]    mac;

			randombytes_buf(key.ptr, key.length);
			crypto_auth(mac.ptr, MESSAGE.ptr, MESSAGE.length, key.ptr);

			if (crypto_auth_verify(mac.ptr, MESSAGE.ptr, MESSAGE.length, key.ptr) != 0)
				writeln("The message has been forged!");
		}

		return EXIT_SUCCESS;
	}

    assert(demo() == EXIT_SUCCESS);

}
