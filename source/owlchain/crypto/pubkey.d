module owlchain.crypto.pubkey;

import std.digest.sha;
import std.digest.ripemd;
import owlchain.api.api : IAddress;

/++
// account address space & serialization

Bitcoin Address - https://en.bitcoin.it/wiki/Address
    base58 - https://en.bitcoin.it/wiki/Base58Check_encoding
        Pay-to-script-hash (p2sh): payload is: RIPEMD160(SHA256(redeemScript)) where redeemScript is a script the wallet knows how to spend; 
                                version 0x05 (these addresses begin with the digit '3')
        Pay-to-pubkey-hash (p2pkh): payload is RIPEMD160(SHA256(ECDSA_publicKey)) where ECDSA_publicKey is a public key the wallet knows the private key for;
                                 version 0x00 (these addresses begin with the digit '1')
        RIPEMD160 - https://en.bitcoin.it/wiki/RIPEMD-160

    Common P2PKH which begin with the number 1, eg: 1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2.
                                                    1234567890123456789012345678901234
    Newer P2SH type starting with the number 3, eg: 3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy.

crypto lib:
    - libsodium https://code.dlang.org/packages/sodium
+/

class Address : IAddress
{
    bool isValid()
    {
        return true;
    }
}

class PublicKey
{
    string getStrKey()
    {
        return "";
    }
}

class SecretKey
{
    this()
    {

    }

    PublicKey getPublicKey()
    {
        return new PublicKey;
    }

    bool isValid(PublicKey pk)
    {
        return true;
    }

    static SecretKey random()
    {
        return new SecretKey;
    }
}

@system unittest
{
    auto sk = SecretKey.random();
    auto pk = sk.getPublicKey();
    assert(true == sk.isValid(pk));
}
