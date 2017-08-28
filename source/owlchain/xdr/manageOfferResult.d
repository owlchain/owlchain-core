module owlchain.xdr.manageOfferResult;

import owlchain.xdr.type;
import owlchain.xdr.manageOfferResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct ManageOfferResult
{
    ManageOfferResultCode code;

    static void encode(XdrDataOutputStream stream, ref const ManageOfferResult encoded)
    {
        encodeManageOfferResultCode(stream, encoded.code);
    }

    static ManageOfferResult decode(XdrDataInputStream stream)
    {
        ManageOfferResult decoded;
        decoded.code = decodeManageOfferResultCode(stream);
        return decoded;
    }
}
