module owlchain.ui.app;

import vibe.d;
import vibe.utils.array;

import owlchain.utils.config;

import std.conv: to;

import owlchain.api.api;

class TransactionImpl : ITransaction {
	override:
		string getHash()
		{
			return "b6f6991d03df0e2e04dafffcd6bc418aac66049e2cd74b80f14ac86db1e3f0da";
		}
		int getVer()
		{
			return 1;
		}
		int getVinSize()
		{
			return 1;
		}
		int getvoutSize()
		{
			return 2;
		}
		string getLockTime()
		{
			return "Unavailable";
		}
		int getSize()
		{
			return 258;
		}
		int getBlockHeight()
		{
			return 12200;
		}
		int getTxIndex()
		{
			return 12563028;
		}
}

struct Transaction {
	this(string _hash) { hash = _hash; }
	string hash;
}

struct Block {
	this(int _height) { height = _height; }
	int height;
	string hash;
	Transaction[] txs;
}

//@rootPathFromName
interface IBlockchainREST{
	@path("/blockchain/transaction/:idx")
	Transaction getTransaction(int _idx);

	@path("/blockchain/block/:height")
	Block getBlock(int _height);
}

class BlockchainRESTImpl : IBlockchainREST {
	override:
		Transaction getTransaction(int _idx)
		{
			auto t = Transaction();
			t.hash = to!string(_idx);
			return t;
		}
		Block getBlock(int _height)
		{
			auto b = Block(_height);
			// b.hash = to!string(_height);
			b.txs ~= Transaction("1"); 
			b.txs ~= Transaction("2"); 
			b.txs ~= Transaction("3"); 
			b.txs ~= Transaction("4"); 
			return b;
		}
}

unittest
{
	auto router = new URLRouter;
	router.registerRestInterface(new BlockchainRESTImpl());
	auto routes = router.getAllRoutes();

	logInfo("routes[0] = " ~ routes[0].pattern);
	logInfo("routes[1] = " ~ routes[1].pattern);
	assert (routes[0].method == HTTPMethod.GET && routes[0].pattern == "/blockchain/transaction/:idx");
	assert (routes[1].method == HTTPMethod.GET && routes[1].pattern == "/blockchain/block/:height");
}

shared static this()
{
	auto router = new URLRouter;
	router.get("/", staticRedirect("index.html"));
	router.get("/ws", handleWebSockets(&handleWebSocketConnection));
	router.get("*", serveStaticFiles("public/"));
	router.registerRestInterface(new BlockchainRESTImpl);

	auto settings = new HTTPServerSettings;
	settings.port = config.port;
	//settings.bindAddresses = ["::1", "127.0.0.1"];

	settings.bindAddresses = [config.ipv6, config.ipv4];
	listenHTTP(settings, router);
	logInfo("Please open http://" ~ config.ipv4 ~ ":" ~ to!string(config.port) ~ "/ in your browser.");
}

private WebSocket[] sockets;

void handleWebSocketConnection(scope WebSocket socket)
{
	sockets ~= socket;
	socket.waitForData(1.seconds);
	string name = socket.receiveText;

	if(name !is null) 
	{
		logInfo("%s connected @ %s.", name, socket.request.peer);
		sendTextToOtherClients(null, "System", name ~ " connected to the chat.");
	}
	else
	{
		socket.send("{\"name\":\"System\", \"text\":\"Invalid name.\"}");
		socket.close;
		sockets.removeFromArray!WebSocket(socket);
		logInfo("%s disconnected.", name);
		return;
	}

	while (socket.waitForData)
	{   
		if (!socket.connected) break;
        // we got something
        auto text = socket.receiveText;
 
        // Close if recieve "/close"
        if (text == "/close") break;
 
        logInfo("Received: \"%s\" from %s.", text, name);
        // Relay text to everyone else
        sendTextToOtherClients(socket, name, text);
    }
 
    // Remove socket from sockets list and close socket
    socket.close;
    sockets.removeFromArray!WebSocket(socket);
    logInfo("%s disconnected.", name);
 
    sendTextToOtherClients(null, "System", name ~ " disconnected to the chat.");
}

void sendTextToOtherClients(scope WebSocket src_socket, string name, string text)
{
    foreach (socket; sockets)
    {
        // Don't send it to people who won't get it.
        if (!socket.connected) continue;
 
        logInfo("Sending: \"%s\" to %s.", text, socket.request.peer);
        // JSON encoding for simplicity
        socket.send("{\"name\":\"" ~ name ~ "\", \"text\":\"" ~ text ~ "\"}");
    }
}
