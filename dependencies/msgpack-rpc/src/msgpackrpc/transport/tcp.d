// Written in the D programming language.

/**
 * MessagePack RPC TCP transport layer
 */
module msgpackrpc.transport.tcp;

import msgpackrpc.common;
import msgpackrpc.server;

import msgpack;
import vibe.core.net;
import vibe.core.driver;

import std.conv;


abstract class BaseSocket
{
  private:
    TCPConnection _connection;
    StreamingUnpacker _unpacker;

  public:
    this(TCPConnection connection)
    {
        _connection = connection;
        _unpacker = StreamingUnpacker([], 2048);
    }

    void close()
    {
        _connection.close();
    }

    void sendResponse(Args...)(const Args args)
    {
        sendMessage(pack(MessageType.response, args));
    }

    void onRequest(size_t id, string method, Value[] params)
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
        InputStream input = _connection;

        do {
            static if (size_t.sizeof == 4)
                auto size = cast(uint)input.leastSize;
            else
                auto size = input.leastSize;
            if (size > 0) {
                ubyte[] data = new ubyte[](size);

                input.read(data);
                proccessRequest(data);
                //if (!_connection.waitForData(dur!"seconds"(10)))
                //    break;
            }
        } while (_connection.connected);
    }

  private:
    void sendMessage(ubyte[] message)
    {
        OutputStream output = _connection;
        output.write(message);
        output.flush();
    }

    void proccessRequest(const(ubyte)[] data)
    {
        _unpacker.feed(data);
        foreach (ref unpacked; _unpacker) {
            immutable msgSize = unpacked.length;
            if (msgSize != 4 && msgSize != 3)
                throw new Exception("Mismatched");

            immutable type = unpacked[0].as!uint;
            switch (type) {
            case MessageType.request:
                onRequest(unpacked[1].as!size_t, unpacked[2].as!string, unpacked[3].via.array);
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


class ClientSocket(Client) : BaseSocket
{
  private:
    Client _client;

  public:
    this(TCPConnection connection, Client client)
    {
        super(connection);
        _client = client;
    }

    override void onRead()
    {
        InputStream input = _connection;

        do {
            //if (!input.dataAvailableForRead)
            //    return;
            static if (size_t.sizeof == 4)
                ubyte[] data = new ubyte[](cast(uint)input.leastSize);
            else
                ubyte[] data = new ubyte[](input.leastSize);
            input.read(data);
            proccessRequest(data);
            break;
        } while (_connection.connected);
    }

    override void onResponse(size_t id, Value error, Value result)
    {
        _client.onResponse(id, error, result);
    }
}


final class ClientTransport(Client)
{
  private:
    Endpoint _endpoint;
    Client _client;
    ClientSocket!Client _socket;

  public:
    this(Client client, Endpoint endpoint)
    {
        _client = client;
        _endpoint = endpoint;
        _socket = new ClientSocket!Client(connectTCP(_endpoint.address, _endpoint.port), client);
    }

    void sendMessage(ubyte[] message, bool request = true)
    {
        _socket.sendMessage(message);
        if (request)
            _socket.onRead();
        else
            getEventDriver().processEvents();  // force notify event to send
    }

    void close()
    {
        _socket.close();
    }
}


class ServerSocket(Server) : BaseSocket
{
  private:
    Server _server;

  public:
    this(TCPConnection connection, Server server)
    {
        super(connection);
        _server = server;
    }

    override void onRequest(size_t id, string method, Value[] params)
    {
        _server.onRequest(this, id, method, params);
    }

    override void onNotify(string method, Value[] params)
    {
        _server.onNotify(method, params);
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
        auto callback = (TCPConnection conn) {
            auto socket = new ServerSocket!Server(conn, server);
            socket.onRead();
        };
        listenTCP(_endpoint.port, callback, _endpoint.address);
    }

    void close()
    {
    }
}
