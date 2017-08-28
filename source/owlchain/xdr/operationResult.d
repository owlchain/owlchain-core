module owlchain.xdr.operationResult;

import owlchain.xdr.type;

import owlchain.xdr.operationResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct OperationResult
{
    OperationResultCode code;

    static void encode(XdrDataOutputStream stream, ref const OperationResult encoded)
    {
        encodeOperationResultCode(stream, encoded.code);
    }

    static OperationResult decode(XdrDataInputStream stream)
    {
        OperationResult decoded;
        decoded.code = decodeOperationResultCode(stream);
        return decoded;
    }
}
