module owlchain.crypto.keypair;

import wrapper.sodium;
import std.exception : enforce;
import std.typecons : tuple, Tuple;

alias KeyPair = Tuple!(ubyte[crypto_box_PUBLICKEYBYTES], "publicKey",
        ubyte[crypto_box_SECRETKEYBYTES], "secretKey");

bool keypair(out KeyPair kp)
{
    return crypto_box_keypair(kp.publicKey, kp.secretKey);
}

alias SeedBytes = ubyte[crypto_box_SEEDBYTES];
bool keypairWithSeed(out KeyPair kp, scope SeedBytes seed)
{
    return crypto_box_seed_keypair(kp.publicKey, kp.secretKey, seed);
}

@system 
unittest
{
    import std.stdio:writefln;
    import std.conv:to;
 
    KeyPair kp;
    assert ( keypair(kp) == true );
    writefln("keypair(pk=%s, sk=%s", kp.publicKey, kp.secretKey);

    KeyPair kp2;
    SeedBytes seed = ubyte.init;
    assert ( keypairWithSeed(kp2, seed) == true);
    writefln("keypairWithSeed(pk=%s, sk=%s, seed=%s", kp.publicKey, kp.secretKey, seed);

    writefln("passs KeyPair Test");
}

/++
usage
import owlchain.crypto.keypair;

  auto kp = keypair();
  auto private = kp.privateKey();
  auto public = kp.publicKye();

  ...
+/
