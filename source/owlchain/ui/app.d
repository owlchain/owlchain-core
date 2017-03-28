module owlchain.ui.app;

import vibe.d;
import vibe.utils.array;

import owlchain.utils.config;

import std.conv: to;
import std.file;
import std.stdio;
import std.path;
import std.array;

import owlchain.api.api;
import owlchain.ui.webapi;

//@rootPathFromName
interface IBlockchainREST
{
	@path("/blockchain/transaction/:idx")
	Transaction getTransaction(int _idx);

	@path("/blockchain/block/:height")
	Block getBlock(int _height);

	@path("/blockchain/blocks/:height/:length")
	Block[] getBlocks(int _height, int _length);

	@method(HTTPMethod.GET)
	@path("/blockchain/transactions/sendTransaction/:type/:sender/:receiver/:amount/:fee/:memo")
	Json sendBos(string _type, string _sender, string _receiver, double _amount, double _fee, string _memo);

	@method(HTTPMethod.GET)
	@path("/blockchain/transactions/receiveTransaction/receiveBOS/:acknowlege")
	Json receiveBos(bool _acknowlege);

	@method(HTTPMethod.GET)
	@path("/blockchain/AccountOperations/createAccount")
	Json createAccount();

	@method(HTTPMethod.GET)
	@path("/blockchain/AccountOperations/getAccount/:accountAddress")
	Json getAccount(string _accountAddress);

	@method(HTTPMethod.GET)
	@path("/blockchain/AccountOperations/getAccountTransaction/:accountAddress")
	Json getAccountTransaction(string _accountAddress);	
}

class BlockchainRESTImpl : IBlockchainREST
{
	private string exportAccountFile(string accountAddress)
	{
		char[] path = asAbsolutePath("BOScoin/account/").array.dup; 
		mkdirRecurse(path);

		File file = File(path ~ "account.bos", "w");
		file.writeln("Account address: ", accountAddress);
		file.close();
		logInfo("<exportAccountFile>");
		logInfo("path : " ~ path);
		logInfo("Account address: " ~ accountAddress);

		return path.idup ~ "account.bos";
	}

	private void printTxInfo(Transaction tx)
	{
		logInfo("type:" ~ tx.type);
		logInfo("senderAccAddress:" ~ tx.senderAccAddress);
		logInfo("receiverAccAddress:" ~ tx.receiverAccAddress);
		logInfo("amount:" ~ to!string(tx.amount));
		logInfo("fee:" ~ to!string(tx.fee));
		logInfo("memo:" ~ tx.memo);
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
	in
    {
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

	Json sendBos(string _type, string _sender, string _receiver, double _amount, double _fee, string _memo)
	{
		Json json;

		if (_type == "" || _sender == "" || _receiver == "" || _amount == 0 || _fee == 0)
		{
			auto e = ErrorState();
			
			e.errCode = "01";
			e.errMessage = "no value.";
			
			json = serializeToJson(e);
		}
		else if (_memo.length > 20)
		{
			auto e = ErrorState();
			
			e.errCode = "02";
			e.errMessage = "The length of the memo should not exceed 20 characters.";
			
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
			t.memo = _memo;
			
			printTxInfo(t);

			auto s = SendBos();
			s.sendBos = true;
			json = serializeToJson(s);
		}
		else
		{
			auto e = ErrorState();

			e.errCode = "00";
			e.errMessage = "type is not 'SendBOS'.";

			json = serializeToJson(e);
		}

		return json;
	}

	Json receiveBos(bool _acknowlege)
	{
		if (_acknowlege != true)
		{
			logInfo("ReceiveBOS: Acknowlege is not true.");
			
			Json json;
			
			return json;
		}
		else
		{
			auto r = ReceiveBos();
			r.receiveBos = true;
			r.receiverAccountAddress = "test_receiver";
			r.senderAccountAddress = "test_sender";
			r.amount = 10000;
			r.confirmCount = 10;

			auto json = serializeToJson(r);

			return json;
		}
	}

	Json createAccount()
	{
		auto c = CreateAccount();
		c.accountAddress = "accountAddress";
		c.filePath = exportAccountFile(c.accountAddress);

		auto json = serializeToJson(c);

		return json;
	}

	Json getAccount(string _accountAddress)
	{
		auto g = GetAccount();
		g.accountAddress = _accountAddress;
		g.accountBalance = 100000;	
		g.availableBalance = 100000;
		g.pendingBalance = 0;
		g.freezingStatus = false;
		g.freezingAmount = 0;
		g.freezingStartTime = 0;
		g.freezingInterests = 0;

		auto json = serializeToJson(g);

		return json;		
	}

	Json getAccountTransaction(string _accountAddress)
	{
		GetAccountTransaction[10] gs;

		foreach(uint i, g; gs)
		{
			gs[i].type = "SendBOS";
			gs[i].freezingReward = i*100;
			gs[i].confirmReward = i*100;
			gs[i].timestamp = i;
			gs[i].accountAddress = _accountAddress;
			gs[i].amount = i*10000;
			gs[i].fee = i*10;
			gs[i].memo = to!string(i)~"_memo";
		}

		auto json = serializeToJson(gs);

		return json;
	}
}

unittest
{
	auto router = new URLRouter;
	registerRestInterface(router, new BlockchainRESTImpl());
	auto routes = router.getAllRoutes();

	logInfo("routes[0] = " ~ routes[0].pattern);
	logInfo("routes[1] = " ~ routes[1].pattern);
	logInfo("routes[2] = " ~ routes[2].pattern);
	logInfo("routes[3] = " ~ routes[3].pattern);
	logInfo("routes[4] = " ~ routes[4].pattern);
	logInfo("routes[5] = " ~ routes[5].pattern);
	logInfo("routes[6] = " ~ routes[6].pattern);
	
	assert (routes[0].method == HTTPMethod.GET && routes[0].pattern == "/blockchain/transaction/:idx");
	assert (routes[1].method == HTTPMethod.GET && routes[1].pattern == "/blockchain/block/:height");
	assert (routes[2].method == HTTPMethod.GET && routes[2].pattern == "/blockchain/blocks/:height/:length");
	assert (routes[3].method == HTTPMethod.GET && routes[3].pattern == "/blockchain/transactions/sendTransaction/:type/:sender/:receiver/:amount/:fee/:memo");
	assert (routes[4].method == HTTPMethod.GET && routes[4].pattern == "/blockchain/AccountOperations/createAccount");
	assert (routes[5].method == HTTPMethod.GET && routes[5].pattern == "/blockchain/AccountOperations/getAccount/:accountAddress");
	assert (routes[6].method == HTTPMethod.GET && routes[6].pattern == "/blockchain/AccountOperations/getAccountTransaction/:accountAddress");
}

shared static this()
{
	auto router = new URLRouter;
	router.get("/", staticRedirect("index.html"));
	router.get("/ws", handleWebSockets(&handleWebSocketConnection));
	router.get("*", serveStaticFiles("public/"));
	registerRestInterface(router, new BlockchainRESTImpl());

	auto settings = new HTTPServerSettings;
	settings.port = config.port;
	//settings.bindAddresses = ["::1", "127.0.0.1"];

	settings.bindAddresses = [config.ipv6, config.ipv4];
	listenHTTP(settings, router);
	logInfo("Please open http://" ~ config.ipv4 ~ ":" ~ to!string(config.port) ~ "/ in your browser.");

    import owlchain.shell.shell;

    auto shell = new Shell;
    auto occpSettings = new OCCPSettings;
    auto listener = shell.listenOCCP(occpSettings, (IOCCPRequest req, IOCCPResponse res) {
        logInfo("Callback Event Call");        
    });
    logInfo("listenOCCP");
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
