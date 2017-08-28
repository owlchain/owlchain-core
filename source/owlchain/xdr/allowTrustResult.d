module owlchain.xdr.allowTrustResult;

import owlchain.xdr.type;
import owlchain.xdr.allowTrustResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct AllowTrustResult
{
    AllowTrustResultCode code;

    static void encode(XdrDataOutputStream stream, ref const AllowTrustResult encoded)
    {
        encodeAllowTrustResultCode(stream, encoded.code);
    }

    static AllowTrustResult decode(XdrDataInputStream stream)
    {
        AllowTrustResult decoded;
        decoded.code = decodeAllowTrustResultCode(stream);
        return decoded;
    }

}
