module owlchain.xdr.authenticatedMessage;

import owlchain.xdr.type;
import owlchain.xdr.bosMessage;
import owlchain.xdr.hmacSha256Mac;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct AuthenticatedMessage
{
    uint32 v;
    AuthenticatedMessageV0 v0;

    static void encode(XdrDataOutputStream stream, ref const AuthenticatedMessage encoded)
    {
        stream.writeUint32(encoded.v);
        AuthenticatedMessageV0.encode(stream, encoded.v0);
    }

    static AuthenticatedMessage decode(XdrDataInputStream stream)
    {
        AuthenticatedMessage decoded;
        decoded.v = stream.readUint32();
        decoded.v0 = AuthenticatedMessageV0.decode(stream);
        return decoded;
    }
}

struct AuthenticatedMessageV0
{
    private uint64 sequence;
    private BOSMessage message;
    private HmacSha256Mac mac;

    static void encode(XdrDataOutputStream stream, ref const AuthenticatedMessageV0 encoded)
    {
        stream.writeUint64(encoded.sequence);
        BOSMessage.encode(stream, encoded.message);
        HmacSha256Mac.encode(stream, encoded.mac);
    }

    static AuthenticatedMessageV0 decode(XdrDataInputStream stream)
    {
        AuthenticatedMessageV0 decoded;
        decoded.sequence = stream.readUint64();
        decoded.message = BOSMessage.decode(stream);
        decoded.mac = HmacSha256Mac.decode(stream);
        return decoded;
    }
}