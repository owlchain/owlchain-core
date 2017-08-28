module owlchain.xdr.changeTrustOp;

import owlchain.xdr.type;
import owlchain.xdr.asset;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct ChangeTrustOp
{
    Asset line;
    int64 limit;

    static void encode(XdrDataOutputStream stream, ref const ChangeTrustOp encodedValue)
    {    
        Asset.encode(stream, encodedValue.line);
        stream.writeInt64(encodedValue.limit);
    }

    static ChangeTrustOp decode(XdrDataInputStream stream)
    {
        ChangeTrustOp decodedValue;
        
        decodedValue.line = Asset.decode(stream);
        decodedValue.limit = stream.readInt64();

        return decodedValue;
    }
}