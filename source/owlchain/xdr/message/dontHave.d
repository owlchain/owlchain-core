module owlchain.xdr.dontHave;

import owlchain.xdr.type;
import owlchain.xdr.messageType;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct DontHave
{
    MessageType type;
    uint256 reqHash;

    static void encode(XdrDataOutputStream stream, ref const DontHave encoded)
    {
        encodeMessageType(stream, encoded.type);
        stream.writeUint256(encoded.reqHash);
    }

    static DontHave decode(XdrDataInputStream stream)
    {
        DontHave decoded;
        decoded.type = decodeMessageType(stream);
        decoded.reqHash = stream.readUint256();
        return decoded;
    }
}