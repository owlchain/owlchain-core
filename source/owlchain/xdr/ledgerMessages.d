module owlchain.xdr.ledgerMessages;

import owlchain.xdr.type;
import owlchain.xdr.envelope;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct LedgerMessages
{
    uint32 ledgerSeq;
    Envelope[] messages;

    ref LedgerMessages opAssign(LedgerMessages s)
    {
        ledgerSeq = s.ledgerSeq;
        messages.length = 0;
        for (int i = 0; i < s.messages.length; i++)
        {
            messages ~= cast(Envelope)s.messages[i];
        }
        return this;
    }

    ref LedgerMessages opAssign(ref LedgerMessages s)
    {
        ledgerSeq = s.ledgerSeq;
        messages.length = 0;
        for (int i = 0; i < s.messages.length; i++)
        {
            messages ~= cast(Envelope)s.messages[i];
        }
        return this;
    }

    ref LedgerMessages opAssign(ref const(LedgerMessages) s)
    {
        ledgerSeq = s.ledgerSeq;
        messages.length = 0;
        for (int i = 0; i < s.messages.length; i++)
        {
            messages ~= cast(Envelope)s.messages[i];
        }
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const LedgerMessages encodedLedgerMessages)
    {
        stream.writeUint32(encodedLedgerMessages.ledgerSeq);
        int messagessize = cast(int)(encodedLedgerMessages.messages.length);
        stream.writeInt(messagessize);
        for (int i = 0; i < messagessize; i++)
        {
            Envelope.encode(stream, encodedLedgerMessages.messages[i]);
        }
    }

    static LedgerMessages decode(XdrDataInputStream stream)
    {
        LedgerMessages decodedLedgerMessages;
        decodedLedgerMessages.ledgerSeq = stream.readUint32();
        int messagessize = stream.readInt();
        decodedLedgerMessages.messages.length = messagessize;
        for (int i = 0; i < messagessize; i++)
        {
            decodedLedgerMessages.messages[i] = Envelope.decode(stream);
        }
        return decodedLedgerMessages;
    }
}