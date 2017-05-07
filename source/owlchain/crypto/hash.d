module owlchain.crypto.hash;

import std.exception:enforce;
import std.string : representation;
import std.digest.hmac: HMAC;
import std.digest.sha: SHA256, sha256Of;

import wrapper.sodium: crypto_hash_sha256_BYTES,
                        crypto_hash_sha256,
                        crypto_hash_sha256_state, 
                        crypto_hash_sha256_init,
                        crypto_hash_sha256_update,
                        crypto_hash_sha256_final,
                        crypto_auth_hmacsha256,
                        crypto_auth_hmacsha256_state,
                        crypto_auth_hmacsha256_init,
                        crypto_auth_hmacsha256_update,
                        crypto_auth_hmacsha256_final,
                        crypto_auth_hmacsha256_verify,
                        crypto_auth_hmacsha256_keygen;

alias Sha256Digest = ubyte[crypto_hash_sha256_BYTES];

Sha256Digest sha256_sodium(immutable(ubyte)[] bin) 
{
    Sha256Digest  hash;
    enforce ( crypto_hash_sha256(hash, bin) );
    return hash;    
}

Sha256Digest sha256_sodium(in string bin) 
{   
    return sha256_sodium(bin.representation);
}

Sha256Digest sha256_sodium(in ubyte[] bin) 
{   
    return sha256_sodium(cast(immutable(ubyte)[])bin);
}

class Sha256Sodium{
    crypto_hash_sha256_state _state;
    this() {
        init();
    }

    void init(){
        enforce( crypto_hash_sha256_init(_state));
    }

    bool update(in ubyte[] _input) {
        return  crypto_hash_sha256_update(_state, _input);
    }
    bool update(in string _input) {
        return  update(cast(ubyte[])_input);
    }
    Sha256Digest finish(){
        Sha256Digest digest;
        enforce( crypto_hash_sha256_final(_state, digest) );
        return digest;
    }
}

Sha256Digest sha256_phobos(in ubyte[] bin) {
    return sha256Of(bin);
}
Sha256Digest sha256_phobos(in string bin) {
    return sha256Of(bin.representation);
}

@("sha256")
@system 
unittest {
    enum data = "hello world";

    auto a256 = sha256_sodium(data);

    auto s256 = new Sha256Sodium;
    s256.update("hello ");
    s256.update("world");

    assert(a256 == s256.finish());

    assert(a256 == sha256_phobos(data));
    
}

alias HmacSha256Mac = Sha256Digest;
alias HmacSha256Key = Sha256Digest;

HmacSha256Mac hmacSha256_sodium(in HmacSha256Key hkey, in ubyte[] message) {
    HmacSha256Mac mac;
    enforce( crypto_auth_hmacsha256(mac, message, hkey) );
    return mac;
}

bool hmacsha256_verify(in HmacSha256Mac mac, in ubyte[] message, in HmacSha256Key skey){
    return crypto_auth_hmacsha256_verify( mac, message, skey);
}

HmacSha256Key hmacSha256Keygen(in string skey) {
    enforce(HmacSha256Key.sizeof >= skey.length);
    HmacSha256Key k;
    for(int i=0;i < skey.length; i++)
        k[i] = skey[i];
    return k;
}

HmacSha256Key hmacSha256Keygen() {
    HmacSha256Key k;
    crypto_auth_hmacsha256_keygen(k);
    return k;
}

class HMACSha256Sodium{
    private crypto_auth_hmacsha256_state _state;

    this() {}

    this(in ubyte[] skey) { init(skey); }
    
    void init(in ubyte[] skey) { 
        enforce( crypto_auth_hmacsha256_init( _state, skey ) );
     }
    
    void update(in ubyte[] data) {
        enforce( crypto_auth_hmacsha256_update( _state, data ) );
    }

    HmacSha256Mac finish() {
        HmacSha256Mac data;
        enforce( crypto_auth_hmacsha256_final( _state, data ) );
        return data;
    }
}

alias HMacSha256Phobos = HMAC!SHA256;

HmacSha256Mac hmacSha256_phobos(in ubyte[] skey, in ubyte[] message) {
    HmacSha256Mac digest = HMacSha256Phobos(skey)
                            .put(message)
                            .finish();
    return digest;
}

@("HMAC")
@system 
unittest {

    import std.stdio;
    import std.range: take;
    import std.stdio: writefln;
    import owlchain.crypto.hex: toHex;

    auto secret = "secret";
    
    auto hkey = hmacSha256Keygen(secret);

    auto input = "long message here.";

    auto mac1 = hmacSha256_sodium(hkey, input.representation);

    assert( hmacsha256_verify(mac1, input.representation, hkey) );

    auto macsha256 = new HMACSha256Sodium;
    macsha256.init(secret.representation);
    macsha256.update(input.representation);
    auto mac2 = macsha256.finish();

    writefln("mac1(%s)\nmac2(%s)", mac1,mac2);

    assert( hmacsha256_verify(mac2, input.representation, hkey) );

    assert(mac1 == mac2);

    auto mac3 = hmacSha256_phobos(secret.representation, input.representation);

    writefln("mac1(%s)\nmac2(%s)\nmac3(%s)", mac1.toHex,mac2.toHex,mac3.toHex);

    assert(mac2 == mac3);
}



HmacSha256Key hkdfExtract(in ubyte[] msg,in ubyte[] salt=null) {
    auto mac = hmacSha256_phobos(salt, msg);
    return cast(HmacSha256Key)mac;
}

HmacSha256Key hkdfExpand(HmacSha256Key key,in ubyte[] msg){
    auto buf = msg.dup;
    buf ~= cast(ubyte)1;
    auto mac = hmacSha256_phobos(key,buf);
    return cast(HmacSha256Key)mac;
}

/*
for detail HKDF unittest, refer to https://tools.ietf.org/html/rfc5869
*/
@("HKDF")
@system
unittest{
    // // Test Case 1
    import owlchain.crypto.hex: hexToBin, hexToBin256;
    {
        auto ikm = hexToBin("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b");
        HmacSha256Key prk = hexToBin256(cast(ubyte[64])"19ef24a32c717b167f33a91d6f648bdf96596776afdb6377ac434c1c293ccb04");
        assert(hkdfExtract(ikm) == prk);

        HmacSha256Key okm = hexToBin256(cast(ubyte[64])"8da4e775a563c18f715f802a063c5a31b8a11f5c5ee1879ec3454e5f3c738d2d");
        ubyte[] info = null;
        assert(hkdfExpand(prk, info) == okm);
    }

    // Test Case 2
    {

        auto ikm  = hexToBin("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f"); //(80 octets)
        auto salt = hexToBin("606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeaf"); // (80 octets)
        auto info = hexToBin("b0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"); // (80 octets)
        auto prk  = hexToBin256(cast(ubyte[64])"06a6b88c5853361a06104c9ceb35b45cef760014904671014a193f40c15fc244"); // (32 octets)
        auto okm  = hexToBin256(cast(ubyte[64])"b11e398dc80327a1c8e7f78c596a49344f012eda2d4efad8a050cc4c19afa97c"); //(32 octets)
        //auto okm  = hexToBin256(cast(ubyte[64])"b11e398dc80327a1c8e7f78c596a49344f012eda2d4efad8a050cc4c19afa97c59045a99cac7827271cb41c65e590e09da3275600c2f09b8367793a9aca3db71cc30c58179ec3e87c14c01d5c1f3434f1d87"); //(82 octets)
        assert(hkdfExtract(ikm,salt) == prk);
        assert(hkdfExpand(prk, info) == okm);    
    }

    // Test Case 3
    {
        auto ikm = hexToBin("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b");
        auto salt = hexToBin("000102030405060708090a0b0c");
        auto info = hexToBin("f0f1f2f3f4f5f6f7f8f9");

        HmacSha256Key prk = hexToBin256(cast(ubyte[64])"077709362c2e32df0ddc3f0dc47bba6390b6c73bb50f9c3122ec844ad7c2b3e5");
        HmacSha256Key okm = hexToBin256(cast(ubyte[64])"3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf");
        // HmacSha256Key okm = hexToBin256(cast(ubyte[64])"3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865");
        assert(hkdfExtract(ikm,salt) == prk);
        assert(hkdfExpand(prk, info) == okm);
    }

}

