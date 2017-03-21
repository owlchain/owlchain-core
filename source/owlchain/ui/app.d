module owlchain.ui.app;

import vibe.d;
import vibe.utils.array;

import owlchain.utils.config;

import std.conv: to;

import owlchain.api.api;
import owlchain.ui.webapi;

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

//@rootPathFromName
interface IBlockchainREST{
	@path("/blockchain/transaction/:idx")
	Transaction getTransaction(int _idx);

	@path("/blockchain/block/:height")
	Block getBlock(int _height);

	@path("/blockchain/blocks/:height/:length")
	Block[] getBlocks(int _height, int _length);

	//@path("/blockchain/sendbos2/:hash/:type/:sender/:fee/:receiver/:amount")
	@path("/blockchain/transactions/sendTransaction/:type/:sender/:receiver/:amount/:fee")
	@method(HTTPMethod.GET)
	Json sendBos(string _type, string _sender, string _receiver, double _amount, double _fee);
}

class BlockchainRESTImpl : IBlockchainREST {

	private void printTxInfo2(Transaction tx)
	{
		logInfo("type:" ~ tx.type);
		logInfo("senderAccAddress:" ~ tx.senderAccAddress);
		logInfo("receiverAccAddress:" ~ tx.receiverAccAddress);
		logInfo("amount:" ~ to!string(tx.amount));
		logInfo("fee:" ~ to!string(tx.fee));
	}

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
		//b.txs ~= Transaction("1"); 
		//b.txs ~= Transaction("2"); 
		//b.txs ~= Transaction("3"); 
		//b.txs ~= Transaction("4"); 
		if (_height == 1)
		{
			b.timestamp = "17:02:28";
			b.capacity = 1000;
			b.confirmReward = 100;
			b.totalIssueVol = 10000;
		}
		else if (_height == 2)
		{
			b.timestamp = "17:02:29";
			b.capacity = 2000;
			b.confirmReward = 200;
			b.totalIssueVol = 20000;	
		}
		return b;
	}
	Block[] getBlocks(int _lastHeight, int _length)
	in{
		assert(_lastHeight >= 0);
		assert(_length > 0);
	}
	body
	{
		Block[] bs;

		for(int i = 0; i < _length; i++)
		{
			auto b = getBlock(_lastHeight-i);
			if(b.timestamp != "")
			{
				bs ~= b;	
			}
		}
		return bs;
	}

	Json sendBos(string _type, string _sender, string _receiver, double _amount, double _fee)
	{
		Json json;

		if (_type == "" || _sender == "" || _receiver == "" || _amount == 0 || _fee == 0)
		{
			auto e = ErrorState();
			
			e.errCode = "01";
			e.errMessage = "no value.";
			
			json = serializeToJson(e);
		}		
		else if (_type == "sendBOS")
		{
			auto t = Transaction();			
			t.type = _type;
			t.senderAccAddress = _sender;
			t.receiverAccAddress = _receiver;
			t.amount = _amount;
			t.fee = _fee;
			
			printTxInfo2(t);

			auto s = SendBosInfo();
			s.sendBos = true;
			json = serializeToJson(s);
		}
		else
		{
			auto e = ErrorState();

			e.errCode = "00";
			e.errMessage = "Error";

			json = serializeToJson(e);
		}

		return json;
	}
}

final class WebInterface
{
	void postSendbos(string type, string sender, double fee, string receiver, double amount)
	{
		logInfo("SEND BOS");

		auto t = sendBOS(type, sender, receiver, amount, fee);
		printTxInfo(t);
		redirect("index.html");
	}

	private Transaction sendBOS(string type, string senderAccAddress, string receiverAccAddress, double amount, double fee)
	{
		auto t = Transaction();
		
		t.type = type;
		t.senderAccAddress = senderAccAddress;
		t.receiverAccAddress = receiverAccAddress;
		t.amount = amount;
		t.fee = fee;
		
		return t;
	}

	private void printTxInfo(Transaction tx)
	{
		logInfo("type:" ~ tx.type);
		logInfo("senderAccAddress:" ~ tx.senderAccAddress);
		logInfo("receiverAccAddress:" ~ tx.receiverAccAddress);
		logInfo("amount:" ~ to!string(tx.amount));
		logInfo("fee:" ~ to!string(tx.fee));
	}
}

unittest
{
	auto router = new URLRouter;
	registerRestInterface(router, new BlockchainRESTImpl());
	registerWebInterface(router, new WebInterface);
	auto routes = router.getAllRoutes();

	logInfo("routes[0] = " ~ routes[0].pattern);
	logInfo("routes[1] = " ~ routes[1].pattern);
	logInfo("routes[2] = " ~ routes[2].pattern);
	logInfo("routes[3] = " ~ routes[3].pattern);
	
	assert (routes[0].method == HTTPMethod.GET && routes[0].pattern == "/blockchain/transaction/:idx");
	assert (routes[1].method == HTTPMethod.GET && routes[1].pattern == "/blockchain/block/:height");
	assert (routes[2].method == HTTPMethod.GET && routes[2].pattern == "/blockchain/blocks/:height/:length");
	assert (routes[3].method == HTTPMethod.GET && routes[3].pattern == "/blockchain/transactions/sendTransaction/:type/:sender/:receiver/:amount/:fee");
}

shared static this()
{
	auto router = new URLRouter;
	router.get("/", staticRedirect("index.html"));
	router.get("/ws", handleWebSockets(&handleWebSocketConnection));
	router.get("*", serveStaticFiles("public/"));
	registerRestInterface(router, new BlockchainRESTImpl());
	registerWebInterface(router, new WebInterface);

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
