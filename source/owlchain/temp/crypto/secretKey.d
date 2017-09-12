module owlchain.crypto.secretKey;

import std.stdio;
import std.digest.sha;
import std.digest.ripemd;
import std.outbuffer;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.publicKey;
import owlchain.xdr.publicKeyType;
import owlchain.xdr.signature;
import deimos.sodium.crypto_sign;
import deimos.sodium.crypto_sign_ed25519;

class PubKeyUtils
{
public:
    static bool verifySig(ref PublicKey key, ref Signature signature, ref const ubyte [] bin)
    {

        return true;
    }

    static void clearVerifySigCache()
    {

    }

    static void flushVerifySigCacheCounts(ref uint64 hits, ref uint64 misses)
    {

    }


    static PublicKey random()
    {
        PublicKey res;
        return res;
    }
}

class StrKeyUtils
{
public:
    static void logKey(OutBuffer s, string key)
    {

    }
}

class HashUtils
{
public:
    static Hash random()
    {
        Hash res;
        return res;
    }
}