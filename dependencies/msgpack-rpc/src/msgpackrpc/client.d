// Written in the D programming language.

/**
 * MessagePack RPC Client
 */
module msgpackrpc.client;

public import msgpackrpc.common;
import msgpackrpc.transport.tcp;

import msgpack;
import vibe.vibe;

import std.array;
import std.traits;


/**
 * MessagePack RPC Client
 */
class Client(alias Protocol)
{
  private:
    alias Protocol.ClientTransport!(typeof(this)) Transport;

    Transport _transport;
    IDGenerater _generator;
    Future[size_t] _table;

  public:
    this(Endpoint endpoint)
    {
        _transport = new Transport(this, endpoint);
    }

    void close()
    {
        _transport.close();
        _table.destroy();
    }

    T call(T, Args...)(string method, Args args)
    {
        return sendRequest(method, args).get!T;
    }

    Future callAsync(Args...)(string method, Args args)
    {
        return sendRequest(method, args);
    }

    void notify(Args...)(string method, Args args)
    {
        auto packer = packer(Appender!(ubyte[])());

        packer.beginArray(3).pack(MessageType.notify, method).packArray(args);
        _transport.sendMessage(packer.stream.data, false);
    }

    void onResponse(size_t id, ref Value error, ref Value result)
    {
        auto future = id in _table;
        if (future is null)
            return;

        if (error.type == Value.Type.nil) {
            future.result = result;
        } else {
            future.error = error;
        }
        version( noExitEventloop) {} else
        { getEventDriver().exitEventLoop(); }
    }

  private:
    Future sendRequest(Args...)(string method, Args args)
    {
        import std.array;

        auto id = ++_generator;
        auto future = new Future();
        auto packer = packer(Appender!(ubyte[])());

        _table[id] = future;
        packer.beginArray(4).pack(MessageType.request, id, method).packArray(args);
        _transport.sendMessage(packer.stream.data);

        return future;
    }
}

alias Client!(msgpackrpc.transport.tcp) TCPClient;

/**
 * Compose the future value
 */
class Future
{
    alias void delegate(Future) Callback;

  private:
    Value _value;
    Callback _callback;
    bool _err;
    bool _yet = true;

  public:
    void join()
    {
        while (_yet)
            getEventDriver().runEventLoopOnce();
    }

    @property
    T get(T = Value)()
    {
        join();

        if (_err) {
            RPCException.rethrow(_value);
            return T.init;
        }

        static if (is(T : Value))
        {
            return _value;
        }
        else
        {
            return _value.as!T;
        }
    }

    @property
    {
        ref Value result()
        {
            return _value;
        }

        void result(ref Value res)
        {
            _yet = false;
            _value = res;

            if (_callback !is null)
                _callback(this);
        }

        bool errorOccurred()
        {
            return _err;
        }

        ref Value error()
        {
            return _value;
        }

        void error(ref Value err)
        {
            _yet = false;
            _err = true;
            _value = err;

            if (_callback !is null)
                _callback(this);
        }

        void callback(Callback callback)
        {
            _callback = callback;
        }
    }
}

private:

// TODO: Make shared
struct IDGenerater
{
  private:
    size_t _id;

  public:
    size_t opUnary(string op)() if (op == "++" || op == "--")
    {
        static if (op == "++")
        {
            return ++_id;
        }
        else
        {
            return ++_id;
        }
    }
}
