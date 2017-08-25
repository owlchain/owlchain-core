module owlchain.xdr.peerAddress;

import std.conv;
import owlchain.xdr.type;
import owlchain.xdr.ipAddrType;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct PeerAddress
{
    PeerAddressIp ip;
    uint32 port;
    uint32 numFailures;

    static void encode(XdrDataOutputStream stream, ref const PeerAddress encodedValue)
    {
        PeerAddressIp.encode(stream, encodedValue.ip);
        stream.writeUint32(encodedValue.port);
        stream.writeUint32(encodedValue.numFailures);
    }

    static PeerAddress decode(XdrDataInputStream stream)
    {
        PeerAddress decodedValue;
        decodedValue.ip = PeerAddressIp.decode(stream);
        decodedValue.port = stream.readUint32();
        decodedValue.numFailures = stream.readUint32();
        return decodedValue;
    }
}

struct PeerAddressIp
{
    IPAddrType type;
    ubyte[4] ipv4;
    ubyte[16] ipv6;

    static void encode(XdrDataOutputStream stream, ref const PeerAddressIp encodedValue)
    {
        encodeIPAddrType(stream, encodedValue.type);
        switch(encodedValue.type)
        {
            case IPAddrType.IPv4:
                stream.write(encodedValue.ipv4);
                break;
            case IPAddrType.IPv6:
                stream.write(encodedValue.ipv6);
                break;
            default:
                break;
        }
    }

    static PeerAddressIp decode(XdrDataInputStream stream)
    {
        PeerAddressIp decodedValue;

        decodedValue.type = decodeIPAddrType(stream);

        switch(decodedValue.type)
        {
            case IPAddrType.IPv4:
                stream.read(decodedValue.ipv4);
                break;
            case IPAddrType.IPv6:
                stream.read(decodedValue.ipv6);
                break;
            default:
                break;
        }
        return decodedValue;
    }
}
