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
        AuthenticatedMessageV0.encode(encoded.v0);
    }

    static AuthenticatedMessage decode(XdrDataInputStream stream)
    {
        AuthenticatedMessage decoded;
        encoded.v = stream.readUint32();
        encoded.v0 = AuthenticatedMessageV0.decode(stream);
        return decoded;
    }
}

struct AuthenticatedMessageV0
{
    private Uint64 sequence;
    private BOSMessage message;
    private HmacSha256Mac mac;

    static void encode(XdrDataOutputStream stream, ref const AuthenticatedMessageV0 encoded)
    {
        stream.writeUint64(encoded.sequence);
        BOSMessage.encode(encoded.message);
        HmacSha256Mac.encode(encoded.mac);
    }

    static AuthenticatedMessageV0 decode(XdrDataInputStream stream)
    {
        AuthenticatedMessageV0 decoded;
        encoded.sequence = stream.readUint64();
        encoded.messagev0 = BOSMessage.decode(stream);
        encoded.mac = HmacSha256Mac.decode(stream);
        return decoded;
    }
}