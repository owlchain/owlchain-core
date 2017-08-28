module owlchain.xdr.setOptionsResult;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.setOptionsResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct SetOptionsResult
{
    SetOptionsResultCode code;

    static void encode(XdrDataOutputStream stream, ref const SetOptionsResult encoded)
    {
        encodeSetOptionsResultCode(stream, encoded.code);
    }

    static SetOptionsResult decode(XdrDataInputStream stream)
    {
        SetOptionsResult decoded;
        decoded.code = decodeSetOptionsResultCode(stream);
        return decoded;
    }
}
