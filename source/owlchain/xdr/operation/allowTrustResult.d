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
        stream.writeInt32(encoded.code);
        switch (encoded.code)
        {
        case AllowTrustResultCode.ALLOW_TRUST_SUCCESS:
            break;
        default:
            break;
        }
    }

    static AllowTrustResult decode(XdrDataInputStream stream)
    {
        AllowTrustResult decoded;
        decoded.code = cast(AllowTrustResultCode) stream.readInt32();
        switch (decoded.code)
        {
        case AllowTrustResultCode.ALLOW_TRUST_SUCCESS:
            break;
        default:
        }
        return decoded;
    }

}
