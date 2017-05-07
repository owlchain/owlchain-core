module owlchain.crypto.ecdh;

import owlchain.crypto.hash: HmacSha256Key, hkdfExtract;
import wrapper.sodium:randombytes, 
                        crypto_scalarmult_base, 
                        crypto_scalarmult, 
                        crypto_scalarmult_BYTES;
import std.exception: enforce;


alias Curve25519Secret=ubyte[32];
alias Curve25519Public=ubyte[32];

Curve25519Secret ecdhRandomSecret() {
    Curve25519Secret sec;
    randombytes(sec);
    return sec;
}

Curve25519Public ecdhDerivePublic(Curve25519Secret sec){
    Curve25519Public pub;
    enforce( crypto_scalarmult_base(pub, sec) );
    return pub;
}

HmacSha256Key ecdhDeriveSharedKey(Curve25519Secret localSecret, Curve25519Public localPublic,
                                Curve25519Public remotePublic, bool localFirst) {

    auto publicA = localFirst ? localPublic : remotePublic;
    auto publicB = localFirst ? remotePublic : localPublic;

    ubyte[crypto_scalarmult_BYTES] q;
    enforce( crypto_scalarmult(q, localSecret, remotePublic) );
    ubyte[] buf;
    buf ~= q;
    buf ~= publicA;
    buf ~= publicB;
    
    return hkdfExtract(buf);
}

@("ECDH")
@system
unittest{

}