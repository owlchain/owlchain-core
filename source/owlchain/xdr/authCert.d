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
        Curve25519Public.encode(stream, encoded.pubkey);
        stream.writeUint64(encoded.expiration);
        Signature.encode(stream, encoded.sig);
    }

    static AuthCert decode(XdrDataInputStream stream)
    {
        AuthCert decoded;
        decoded.pubkey = Curve25519Public.decode(stream);
        decoded.expiration = stream.readUint64();
        decoded.sig = Signature.decode(stream);
        return decoded;
    }

}
