module owlchain.xdr.envelope;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

import owlchain.xdr.statement;
import owlchain.xdr.signature;

struct Envelope
{
    Statement statement;
    Signature signature;
    
    static void encode(XdrDataOutputStream stream, ref const Envelope encodedEnvelope)
    {
        Statement.encode(stream, encodedEnvelope.statement);
        Signature.encode(stream, encodedEnvelope.signature);
    }

    static Envelope decode(XdrDataInputStream stream)
    {
        Envelope decodedEnvelope;
        decodedEnvelope.statement = Statement.decode(stream);
        decodedEnvelope.signature = Signature.decode(stream);
        return decodedEnvelope;
    }
}
