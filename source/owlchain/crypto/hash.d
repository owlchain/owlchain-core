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

HmacSha256Key hkdfExtract(in ubyte[] bin) {
    HmacSha256Key zerosalt;
    auto mac = hmacSha256_sodium(zerosalt, bin);
    return cast(HmacSha256Key)mac;
}

HmacSha256Key hkdfExpand(HmacSha256Key key,in ubyte[] bin){
    auto buf = bin.dup;
    buf ~= cast(ubyte)1;
    auto mac = hmacSha256_sodium(key,buf);
    return cast(HmacSha256Key)mac;
}

@("HKDF")
@system
unittest{
    import owlchain.crypto.hex: hexToBin, hexToBin256;
    auto ikm = hexToBin("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b");
    HmacSha256Key prk = hexToBin256(cast(ubyte[64])"19ef24a32c717b167f33a91d6f648bdf96596776afdb6377ac434c1c293ccb04");
    HmacSha256Key okm = hexToBin256(cast(ubyte[64])"8da4e775a563c18f715f802a063c5a31b8a11f5c5ee1879ec3454e5f3c738d2d");
    assert(hkdfExtract(ikm) == prk);
    ubyte[] empty;
    assert(hkdfExpand(prk, empty) == okm);
}