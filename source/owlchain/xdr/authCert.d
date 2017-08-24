module owlchain.xdr.authCert;

import owlchain.xdr.type;
import owlchain.xdr.curve25519Public;
import owlchain.xdr.signature;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct AuthCert
{
    Curve25519Public pubkey;
    uint64 expiration;
    Signature sig;

    static void encode(XdrDataOutputStream stream, ref const AuthCert encoded)
    {
        Curve25519Public.encode(encoded.pubkey);
        stream.writeUint64(encoded.expiration);
        Signature.encode(encoded.sig);
    }

    static AuthCert decode(XdrDataInputStream stream)
    {
        AuthCert decoded;
        encoded.pubkey = Curve25519Public.decode(stream);
        encoded.expiration = stream.readUint64();
        encoded.sig = Signature.decode(stream);
        return decoded;
    }

}
