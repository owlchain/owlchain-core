module owlchain.xdr.ledgerBCPMessages;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.bcpEnvelope;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct LedgerBCPMessages 
{
    uint32 ledgerSeq;
    BCPEnvelope[] messages;

    static void encode(XdrDataOutputStream stream, ref const LedgerBCPMessages encoded)
    {
        stream.writeUint32(encoded.ledgerSeq);
        int length = cast(int)(encoded.messages.length);
        stream.writeInt(length);
        for (int i = 0; i < length; i++)
        {
            BCPEnvelope.encode(stream, encoded.messages[i]);
        }
    }

    static LedgerBCPMessages decode(XdrDataInputStream stream)
    {
        LedgerBCPMessages decoded;
        decoded.ledgerSeq = stream.readUint32();
        int length = stream.readInt();
        decoded.messages.length = 0;
        for (int i = 0; i < length; i++)
        {
            decoded.messages ~= BCPEnvelope.decode(stream);
        }
        return decoded;
    }
}
