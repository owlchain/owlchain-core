module owlchain.xdr.createAccountResult;

import owlchain.xdr.type;
import owlchain.xdr.createAccountResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct CreateAccountResult
{
    CreateAccountResultCode code;

    static void encode(XdrDataOutputStream stream, ref const CreateAccountResult encoded)
    {
        encodeCreateAccountResultCode(stream, encoded.code);
    }

    static CreateAccountResult decode(XdrDataInputStream stream)
    {
        CreateAccountResult decoded;
        decoded.code = decodeCreateAccountResultCode(stream);
        return decoded;
    }

}
