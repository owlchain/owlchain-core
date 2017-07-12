module owlchain.xdr.value;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Value
{
    ubyte[] value;

    static void encode(XdrDataOutputStream stream, ref const Value encodedValue)
    {
        stream.writeUint(cast(uint)(encodedValue.value.length));
        stream.write(encodedValue.value);
    }

    static Value decode(XdrDataInputStream stream)
    {
        Value decodedValue;

        uint size = stream.readUint();
        if (size > 0) 
        {
            decodedValue.value.length = size;
            stream.read(decodedValue.value);
        }
        return decodedValue;
    }
}
