// Written in the D programming language.

/**
 * MessagePack RPC common symbols
 */
module msgpackrpc.common;

import msgpack;


/**
 * See: http://wiki.msgpack.org/display/MSGPACK/RPC+specification#RPCspecification-MessagePackRPCProtocolspecification
 */
enum MessageType
{
    request = 0,
    response = 1,
    notify = 2
}

struct Endpoint
{
    ushort port;
    string address;
}

/**
 * Base exception for RPC error hierarchy
 */
class RPCException : Exception
{
    enum Code = ".RPCError";

    static void rethrow(ref Value error)
    {
        if (error.type == Value.type.array) {
            auto errCode = error.via.array[0].as!string;
            auto errMsg = error.via.array[1].as!string;

            switch (errCode) {
            case RPCException.Code:
                throw new RPCException(errMsg);
            case TimeoutException.Code:
                throw new TimeoutException(errMsg);
            case TransportException.Code:
                throw new TransportException(errMsg);
            case CallException.Code:
                throw new CallException(errMsg);
            case NoMethodException.Code:
                throw new NoMethodException(errMsg);
            case ArgumentException.Code:
                throw new ArgumentException(errMsg);
            default:
                throw new Exception("Unknown code: code = " ~ errCode);
            }
        } else {
            throw new RPCException(error.as!string);
        }
    }

    mixin ExceptionConstructor;
}

///
class TimeoutException : RPCException
{
    enum Code = ".TimeoutError";
    mixin ExceptionConstructor;
}

///
class TransportException : RPCException
{
    enum Code = ".TransportError";
    mixin ExceptionConstructor;
}

///
class CallException : RPCException
{
    enum Code = ".NoMethodError";
    mixin ExceptionConstructor;
}

///
class NoMethodException : CallException
{
    enum Code = ".CallError.NoMethodError";
    mixin ExceptionConstructor;
}

///
class ArgumentException : CallException
{
    enum Code = ".CallError.ArgumentError";
    mixin ExceptionConstructor;
}

private:

mixin template ExceptionConstructor()
{
    @safe pure nothrow this(string msg)
    {
        super(msg);
    }

    void toMsgpack(Packer)(ref Packer packer, bool withFieldName = false) const
    {
        packer.beginArray(2);
        packer.pack(Code);
        packer.pack(msg);
    }
}

unittest
{
    import std.typetuple;

    foreach (E; TypeTuple!(RPCException, TimeoutException, TransportException, CallException, NoMethodException, ArgumentException)) {
        auto e = new E("hoge");
        string[] codeAndMsg;
        unpack(pack(e), codeAndMsg);
        assert(codeAndMsg[0] == E.Code);
    }
}
