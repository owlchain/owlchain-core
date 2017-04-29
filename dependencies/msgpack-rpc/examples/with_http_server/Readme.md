this example shows how to use msgpack-rpc-d client and server within a vibe.d http server.

in your dub.sdl file use ``` subConfiguration "msgpack-rpc" "integrated"  ``` 
and ``` versions "VibeCustomMain" ```

after that start your rpc server within your main method.

to test the example, start it and use curl:
``` curl '0.0.0.0:9090/?enhanceme=D' ```

