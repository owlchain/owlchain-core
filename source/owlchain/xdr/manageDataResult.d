module owlchain.xdr.manageDataResult;

import owlchain.xdr.type;
import owlchain.xdr.manageDataResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct ManageDataResult
{
    ManageDataResultCode code;

    static void encode(XdrDataOutputStream stream, ref const ManageDataResult encoded)
    {
        encodeManageDataResultCode(stream, encoded.code);
    }

    static ManageDataResult decode(XdrDataInputStream stream)
    {
        ManageDataResult decoded;
        decoded.code = decodeManageDataResultCode(stream);
        return decoded;
    }

}
