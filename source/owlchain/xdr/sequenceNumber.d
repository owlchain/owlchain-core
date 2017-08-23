module owlchain.xdr.sequenceNumber;

import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct SequenceNumber
{
    uint64 number;

    static void encode(XdrDataOutputStream stream, ref const SequenceNumber encoded)
    {
        stream.writeUint64(encoded.number);
    }
    
    static SequenceNumber decode(XdrDataInputStream stream)
    {
        SequenceNumber decoded;
        decoded.number = stream.readUint64();
        return decoded;
    }

};