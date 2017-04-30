# MessagePack RPC for D

MessagePack RPC implementation based on [vibe.d](http://vibed.org)

# Example

## Client

```d
auto client = new TCPClient(Endpoint(18800, "127.0.0.1"));

// sync request
auto num = client.call!ulong("sum", 1, 2);

// async request: return a Future object
auto future = client.callAsync("sum", 1, 2);

// notify
client.notify("hello", "hoge");
```

## Server

### Object

```d
class FooServer
{
    ulong sum(ulong l, ulong r)
    {
        return l + r;
    }

    void hello(string msg)
    {   
        writeln(msg);
    }
}

// TCPServer or UDPServer
auto server = new TCPServer!(FooServer)(new FooServer);
server.listen(Endpoint(18800, "127.0.0.1"));
server.start();
```

### module

```d
module foo;

ulong sum(ulong l, ulong r)
{
    return l + r;
}

void hello(string msg)
{   
    writeln(msg);
}

auto server = new TCPServer!(foo)();
// same as Object
```

# Link

* [MessagePack](http://msgpack.org/)

  MessagePack official site

* [msgpack-rpc-d repository](https://github.com/msgpack/msgpack-rpc-d)

  Github repository


# Copyright

<table>
  <tr>
    <td>Author</td><td>Masahiro Nakagawa <repeatedly@gmail.com></td>
  </tr>
  <tr>
    <td>Copyright</td><td>Copyright (c) 2013- Masahiro Nakagawa</td>
  </tr>
  <tr>
    <td>License</td><td>MIT License</td>
  </tr>
</table>
