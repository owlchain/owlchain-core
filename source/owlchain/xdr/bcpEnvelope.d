module owlchain.xdr.bcpEnvelope;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.bcpStatement;
import owlchain.xdr.signature;

struct BCPEnvelope
{
    BCPStatement statement;
    Signature signature;
    
    static void encode(XdrDataOutputStream stream, ref const BCPEnvelope encodedEnvelope)
    {
        BCPStatement.encode(stream, encodedEnvelope.statement);
        Signature.encode(stream, encodedEnvelope.signature);
    }

    static BCPEnvelope decode(XdrDataInputStream stream)
    {
        BCPEnvelope decodedEnvelope;
        decodedEnvelope.statement = BCPStatement.decode(stream);
        decodedEnvelope.signature = Signature.decode(stream);
        return decodedEnvelope;
    }
}
