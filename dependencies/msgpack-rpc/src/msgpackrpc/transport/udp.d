// Written in the D programming language.

/**
 * MessagePack RPC UDP transport layer
 */
module msgpackrpc.transport.udp;

import msgpackrpc.common;
import msgpackrpc.server;

import msgpack;
import vibe.core.net;

import std.conv;


abstract class BaseSocket
{
  private:
    UDPConnection _connection;
    StreamingUnpacker _unpacker;

  public:
    this(UDPConnection connection)
    {
        _connection = connection;
        _unpacker = StreamingUnpacker([], 2048);
    }

    void onRequest(size_t id, string method, Value[] params, ref NetworkAddress netAddr)
    {
        throw new Exception("Not implemented yet");
    }

    void onResponse(size_t id, Value error, Value result)
    {
        throw new Exception("Not implemented yet");
    }

    void onNotify(string method, Value[] params)
    {
        throw new Exception("Not implemented yet");
    }

    void onRead()
    {
        NetworkAddress netAddr;
        auto data = _connection.recv(null, &netAddr);
        proccessRequest(data, netAddr);
    }

  private:
    void sendMessage(ubyte[] message)
    {
        _connection.send(message);
    }

    // TODO: Merge TCP proccessRequest
    void proccessRequest(const(ubyte)[] data, ref NetworkAddress netAddr)
    {
        _unpacker.feed(data);
        foreach (ref unpacked; _unpacker) {
            immutable msgSize = unpacked.length;
            if (msgSize != 4 && msgSize != 3)
                throw new Exception("Mismatched");

            immutable type = unpacked[0].as!uint;
            switch (type) {
            case MessageType.request:
                onRequest(unpacked[1].as!size_t, unpacked[2].as!string, unpacked[3].via.array, netAddr);
                break;
            case MessageType.response:
                onResponse(unpacked[1].as!size_t, unpacked[2], unpacked[3]);
                break;
            case MessageType.notify:
                onNotify(unpacked[1].as!string, unpacked[2].via.array);
                break;
            default:
                throw new RPCException("Unknown message type: type = " ~ to!string(type));
            }
        }
    }
}


class ServerSocket(Server) : BaseSocket
{
  private:
    Server _server;

  public:
    this(UDPConnection connection, Server server)
    {
        super(connection);
        _server = server;
    }

    override void onRequest(size_t id, string method, Value[] params, ref NetworkAddress netAddr)
    {
        _server.onRequest(Sender(_connection, &netAddr), id, method, params);
    }

    override void onNotify(string method, Value[] params)
    {
        _server.onNotify(method, params);
    }

    // Wraps a client endpoint to send the response
    static struct Sender
    {
      private:
        NetworkAddress* _netAddr;
        UDPConnection _connection;

      public:
        this(UDPConnection connection, NetworkAddress* netAddr)
        {
            _connection = connection;
            _netAddr = netAddr;
        }

        void sendResponse(Args...)(const Args args)
        {
            _connection.send(pack(MessageType.response, args), _netAddr);
        }
    }
}


final class ServerTransport(Server)
{
  private:
    Endpoint _endpoint;

  public:
    this(Endpoint endpoint)
    {
        _endpoint = endpoint;
    }

    void listen(Server server)
    {
        runTask({
            auto socket = new ServerSocket!Server(listenUDP(_endpoint.port, _endpoint.address), server);
            while (true)
                socket.onRead();
        });
    }

    void close()
    {
    }
}
