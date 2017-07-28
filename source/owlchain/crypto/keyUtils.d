module owlchain.crypto.keyUtils;

import std.stdio;
import std.digest.sha;
import std.digest.ripemd;

import owlchain.xdr.type;
import owlchain.xdr.publicKey;
import owlchain.xdr.publicKeyType;
import owlchain.xdr.signature;
import deimos.sodium.crypto_sign;
import deimos.sodium.crypto_sign_ed25519;

class SecretKey
{
    private 
    {
        PublicKeyType _keyType;
        uint512 _secretKey;
        uint256 _seed;
    }

    this()
    {
        _keyType.val = PublicKeyType.PUBLIC_KEY_TYPE_ED25519;
        assert(crypto_sign_PUBLICKEYBYTES == uint256.sizeof, "Unexpected public key length");
        assert(crypto_sign_SEEDBYTES == uint256.sizeof, "Unexpected seed length");
        assert(crypto_sign_SECRETKEYBYTES == uint512.sizeof, "Unexpected secret key length");
        assert(crypto_sign_BYTES == uint512.sizeof, "Unexpected signature length");
    }

    @property ref PublicKeyType keyType()
    {
        return _keyType;
    }

    @property ref uint512 secretKey()
    {
        return _secretKey;
    }

    @property ref uint256 seed()
    {
        return _seed;
    }

    @property void seed(uint256 value)
    {
        _seed = value;
    }

    const PublicKey getPublicKey()
    {
        PublicKey pk;

        assert(_keyType.val == PublicKeyType.PUBLIC_KEY_TYPE_ED25519);

        if (crypto_sign_ed25519_sk_to_pk(pk.ed25519.ptr, _secretKey.ptr) != 0)
        {
            writeln ("error extracting public key from secret key");
        }
        return pk;
    }

    bool isValid(PublicKey pk)
    {
        return true;
    }

    static SecretKey random()
    {
        return new SecretKey;
    }

    static SecretKey fromSeed(uint256 seed)
    {
        PublicKey pk;
        SecretKey sk = new SecretKey();
        assert(sk.keyType.val == PublicKeyType.PUBLIC_KEY_TYPE_ED25519);

        if (seed.length != crypto_sign_SEEDBYTES)
        {
            writeln("seed does not match byte size");
        }

        sk.seed = seed;

        if (crypto_sign_seed_keypair(pk.ed25519.ptr, sk.secretKey.ptr, sk.seed.ptr) != 0)
        {
            writeln("error generating secret key from seed");
        }
        return sk;
    }

    Signature sign(ref const ubyte [] bin) const
    {
        assert(_keyType.val == PublicKeyType.PUBLIC_KEY_TYPE_ED25519);

        Signature S;
        S.signature.length = crypto_sign_BYTES;
        if (crypto_sign_detached(S.signature.ptr, null, bin.ptr, bin.length, _secretKey.ptr) != 0)
        {
            throw new Exception("error while signing");
        }
        return S;
    }
}

@system unittest
{
    auto sk = SecretKey.random();
    auto pk = sk.getPublicKey();
    assert(true == sk.isValid(pk));
}