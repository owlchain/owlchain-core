module owlchain.xdr.messageType;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum MessageType
{
    ERROR_MSG = 0,
    AUTH = 2,
    DONT_HAVE = 3,
    GET_PEERS = 4,
    PEERS = 5,
    GET_TX_SET = 6,
    TX_SET = 7,
    TRANSACTION = 8,
    GET_BCP_QUORUMSET = 9,
    BCP_QUORUMSET = 10,
    BCP_MESSAGE = 11,
    GET_BCP_STATE = 12,
    HELLO = 13
}

static void encodeMessageType(XdrDataOutputStream stream, ref const MessageType encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static MessageType decodeMessageType(XdrDataInputStream stream)
{
    const int32 value = stream.readInt32();
    switch (value)
    {
    case 0:
        return MessageType.ERROR_MSG;
    case 2:
        return MessageType.AUTH;
    case 3:
        return MessageType.DONT_HAVE;
    case 4:
        return MessageType.GET_PEERS;
    case 5:
        return MessageType.PEERS;
    case 6:
        return MessageType.GET_TX_SET;
    case 7:
        return MessageType.TX_SET;
    case 8:
        return MessageType.TRANSACTION;
    case 9:
        return MessageType.GET_BCP_QUORUMSET;
    case 10:
        return MessageType.BCP_QUORUMSET;
    case 11:
        return MessageType.BCP_MESSAGE;
    case 12:
        return MessageType.GET_BCP_STATE;
    case 13:
        return MessageType.HELLO;
    default:
        throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
}
