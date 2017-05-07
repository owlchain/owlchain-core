module owlchain.crypto.ecdh;

import owlchain.crypto.hash : HmacSha256Key, hkdfExtract;
import wrapper.sodium : randombytes, crypto_scalarmult_base, crypto_scalarmult,
    crypto_scalarmult_BYTES;
import std.exception : enforce;

alias Curve25519Secret = ubyte[32];
alias Curve25519Public = ubyte[32];

Curve25519Secret ecdhRandomSecret()
{
    Curve25519Secret sec;
    randombytes(sec);
    return sec;
}

Curve25519Public ecdhDerivePublic(Curve25519Secret sec)
{
    Curve25519Public pub;
    enforce(crypto_scalarmult_base(pub, sec));
    return pub;
}

HmacSha256Key ecdhDeriveSharedKey(Curve25519Secret localSecret,
        Curve25519Public localPublic, Curve25519Public remotePublic, bool localFirst)
{

    auto publicA = localFirst ? localPublic : remotePublic;
    auto publicB = localFirst ? remotePublic : localPublic;

    ubyte[crypto_scalarmult_BYTES] q;
    enforce(crypto_scalarmult(q, localSecret, remotePublic));
    ubyte[] buf;
    buf ~= q;
    buf ~= publicA;
    buf ~= publicB;

    return hkdfExtract(buf);
}

@("ECDH")
@system unittest
{
    import std.stdio : writefln, writef;

    foreach (int x; 0 .. 1000)
    {
        auto a = ecdhRandomSecret();
        auto b = ecdhRandomSecret();
        assert(a != b);
        if (x % 100 == 0)
            writef(".");
    }
    writefln("pass ecdh randomness");

    foreach (int x; 0 .. 1000)
    {
        auto sk1 = ecdhRandomSecret();
        auto pk1 = ecdhDerivePublic(sk1);
        auto pk2 = ecdhDerivePublic(sk1);

        assert(pk1 == pk2);
        if (x % 100 == 0)
            writef("+");
    }
    writefln("ecdh public test");

    // TODO : ecdhDeriveSharedKey test function...
}
