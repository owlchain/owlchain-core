module owlchain.ui.app;

import vibe.d;
import vibe.utils.array;

import owlchain.utils.config;

import std.conv: to;
import std.file;
import std.stdio;
import std.path;
import std.array;
import std.random;

import owlchain.api.api;
import owlchain.ui.webapi;
import owlchain.shell.shell;
import owlchain.wallet.wallet;

//@rootPathFromName
interface IBlockchainREST
{
	// Transactions
	@method(HTTPMethod.GET)
	@path("/blockchain/transactions/sendTransaction/:type/:senderAccountAddress/:receiverAccountAddress/:amount/:fee")
	Json sendBos(string _type, string _senderAccountAddress, string _receiverAccountAddress, double _amount, double _fee);

	// Account Operations
	@method(HTTPMethod.GET)
	@path("/blockchain/AccountOperations/getAccount/:accountAddress")
	Json getAccount(string _accountAddress);

	@method(HTTPMethod.GET)
	@path("/blockchain/AccountOperations/getAccountTransaction/:accountAddress")
	Json getAccountTransaction(string _accountAddress);	

	@method(HTTPMethod.GET)
	@path("/blockchain/AccountOperations/createSeed")
	Json createSeed();	

	@method(HTTPMethod.GET)
	@path("/blockchain/AccountOperations/confirmSeed/:passphrase")
	Json confirmSeed(string _passphrase);	

	@method(HTTPMethod.GET)
	@path("/blockchain/AccountOperations/getBlockInformation")
	Json getBlockInformation();	

	// Freezing Operations
	@method(HTTPMethod.GET)
	@path("/blockchain/FreezingOperations/setFreezing/:accountAddress/:freezingStatus/:freezingAmount")
	Json setFreezing(string _accountAddress, bool _freezingStatus, double _freezingAmount);	

	@method(HTTPMethod.GET)
 	@path("/blockchain/AccountOperations/createAccount")
 	Json createAccount();

	 // Trust Contract
	@method(HTTPMethod.GET)
 	@path("/blockchain/trustcontract/validateTrustContract/:accountAddress/:contents")
 	Json validateTrustContract(string _accountAddress, string _contents);

	@method(HTTPMethod.GET)
 	@path("/blockchain/trustcontract/confirmedTrustContract/:tempContractID")
 	Json confirmedTrustContract(string _tempContractID);

	@method(HTTPMethod.GET)
 	@path("/blockchain/trustcontract/runTrustContract/:contractAddress/:contents")
 	Json runTrustContract(string _contractAddress, string _contents);

	@method(HTTPMethod.GET)
 	@path("/blockchain/trustcontract/reqTrustContractList")
 	Json reqTrustContractList();
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

	private void printTxInfo(string type, string senderAccountAddress, string receiverAccountAddress, double amount, double fee)
	{
		logInfo("type:" ~ type);
		logInfo("senderAccountAddress:" ~ senderAccountAddress);
		logInfo("receiverAccountAddress:" ~ receiverAccountAddress);
		logInfo("amount:" ~ to!string(amount));
		logInfo("fee:" ~ to!string(fee));
	}
	
	private void generateAddress()
	{
		tmpTc.addrNum = uniform(10000000000000000, 99999999999999999);
		auto s = to!string(tmpTc.addrNum);
		tmpTc.address = "TRX-" ~ s[0..5] ~ "-" ~ s[5..10] ~ "-" ~ s[10..17];
		
		while(confirmAddress != -1)
		{
			tmpTc.addrNum = uniform(1000000000000000, 99999999999999999);
			s = to!string(tmpTc.addrNum);
			tmpTc.address = "TRX-" ~ s[0..5] ~ "-" ~ s[5..10] ~ "-" ~ s[10..17];
		}

		logInfo(tmpTc.address);
	}

	private ulong confirmAddress()
	{
		foreach(i, r; rs)
		{
			if (tmpTc.address == r.contractID)
			{
				return i;
			}
		}
		return -1;
	}


	override:
	Json sendBos(string _type, string _senderAccountAddress, string _receiverAccountAddress, double _amount, double _fee)
	{
		Json json;

		if (_type == "" || _senderAccountAddress == "" || _receiverAccountAddress == "" || _amount == 0 || _fee == 0)
		{
			auto e = ErrorState();
			
			e.errCode = "01";
			e.errMessage = "no value.";
			
			json = serializeToJson(e);
		}

		else if (_type == "sendBOS")
		{
			printTxInfo(_type, _senderAccountAddress, _receiverAccountAddress, _amount, _fee);

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
			gs[i].timestamp = i;
			gs[i].amount = i*10000;
			gs[i].feeOrReward = i*10;
			gs[i].accountAddress = _accountAddress;
		}

		auto json = serializeToJson(gs);

		return json;
	}

	Json createSeed()
	{
		auto c = CreateSeed();
		c.passphrase = "Animal Body Class Dragon Elephant Fool Growl Human Icon Jewlry King Loop";

		auto json = serializeToJson(c);

		return json;
	}
	
	Json confirmSeed(string _passphrase)
	{
		auto c = ConfirmSeed();
		c.accountAddress = "BOS-AAAAA-BBBBB-CCCCCCC";
		c.accountBlance = 0;
		c.freezingStatus = false;

		auto json = serializeToJson(c);

		return json;
	}

	Json getBlockInformation()
	{
		GetBlockInformation[10] gs;

		foreach(uint i, g; gs)
		{
			gs[i].blockHeight = i + 1;
			gs[i].timestamp = 10000 + i;
			gs[i].amount = (i + 1) * 10000;
			gs[i].fee = 100;
			gs[i].generator = "BOS-AAAAA-BBBBB-CCCCCCC";
		}

		auto json = serializeToJson(gs);

		return json;
	}

	Json setFreezing(string _accountAddress, bool _freezingStatus, double _freezingAmount)
	{
		Json json;

		if (_freezingStatus == true)
		{
			if (_freezingAmount < 100000)
			{
				auto s = SetFreezing();

				s.accountAddress = _accountAddress;
				s.setFreezing = true;
				s.freezingAmount = _freezingAmount;
				s.accountBalance = 100000 - _freezingAmount;
				s.freezingInterests = 20;
				s.freezingStartTime = 201704042028;

				json = serializeToJson(s);

			}
		}
		return json;
	}

	Json createAccount()
	{
		auto c = CreateAccount();
 		c.accountAddress = "BOS-AAAAA-BBBBB-CCCCCCC";
 		c.filePath = exportAccountFile(c.accountAddress);
 
 		auto json = serializeToJson(c);
		return json;
	}

	Json validateTrustContract(string _accountAddress, string _contents)
	{
		auto v = ValidateTrustContract();
		v.status = true;
		v.statusMsg = "Confirmed";
		generateAddress();
		v.tempContractID = tmpTc.address; 

 		auto json = serializeToJson(v);
		return json;
	}

	Json confirmedTrustContract(string _tempContractID)
	{
		rs.length++;
		rs[rs.length - 1].contractID = _tempContractID;
		rs[rs.length - 1].title = "BOScoin";
		rs[rs.length - 1].txCount = 0;
	
		auto c = ConfirmedTrustContract();
		c.status = true;
		c.contractAddress = _tempContractID;

 		auto json = serializeToJson(c);
		return json;
	}

	Json runTrustContract(string _contractAddress, string _contents)
	{
		auto r = RunTrustContract();

		r.status = true;
		r.transactionID = tmpTc.address;

		rs[confirmAddress()].txCount++;

		auto json = serializeToJson(r);
		return json;
	}

	Json reqTrustContractList()
	{
		auto json = serializeToJson(rs);
		return json;
	}
}

ReceiveBos receiveBos()
{
	auto r = ReceiveBos();
	r.type = "receiveBOS";
	r.receiverAccountAddress = "BOS-AAAAA-BBBBB-CCCCCCC";
	r.senderAccountAddress = "BOS-XXXXX-YYYYY-ZZZZZZZ";
	r.amount = 10000;

	return r;
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
	logInfo("routes[7] = " ~ routes[7].pattern);	
	logInfo("routes[8] = " ~ routes[8].pattern);	
	logInfo("routes[9] = " ~ routes[9].pattern);	
	logInfo("routes[10] = " ~ routes[10].pattern);	
	logInfo("routes[11] = " ~ routes[11].pattern);	

	/*
	routes[0] = /blockchain/transactions/sendTransaction/:type/:senderAccountAddress/:receiverAccountAddress/:amount/:fee
	routes[1] = /blockchain/AccountOperations/getAccount/:accountAddress
	routes[2] = /blockchain/AccountOperations/getAccountTransaction/:accountAddress
	routes[3] = /blockchain/AccountOperations/createSeed"
	routes[4] = /blockchain/AccountOperations/confirmSeed/:passphrase
	routes[5] = /blockchain/AccountOperations/getBlockInformation
	routes[6] = /blockchain/FreezingOperations/setFreezing/:accountAddress/:freezingStatus/:freezingAmount
	routes[7] = /blockchain/AccountOperations/createAccount
	routes[8] = /blockchain/trustcontract/validateTrustContract/:accountAddress/:contents
	routes[9] = /blockchain/trustcontract/confirmedTrustContract/:tempContractID
	routes[10] = /blockchain/trustcontract/runTrustContract/:contractAddress/:contents
	routes[11] = /blockchain/trustcontract/reqTrustContractList
	*/
	
	assert (routes[0].method == HTTPMethod.GET && routes[0].pattern == "/blockchain/transactions/sendTransaction/:type/:senderAccountAddress/:receiverAccountAddress/:amount/:fee");
	assert (routes[1].method == HTTPMethod.GET && routes[1].pattern == "/blockchain/AccountOperations/getAccount/:accountAddress");
	assert (routes[2].method == HTTPMethod.GET && routes[2].pattern == "/blockchain/AccountOperations/getAccountTransaction/:accountAddress");
	assert (routes[3].method == HTTPMethod.GET && routes[3].pattern == "/blockchain/AccountOperations/createSeed");
	assert (routes[4].method == HTTPMethod.GET && routes[4].pattern == "/blockchain/AccountOperations/confirmSeed/:passphrase");
	assert (routes[5].method == HTTPMethod.GET && routes[5].pattern == "/blockchain/AccountOperations/getBlockInformation");
	assert (routes[6].method == HTTPMethod.GET && routes[6].pattern == "/blockchain/FreezingOperations/setFreezing/:accountAddress/:freezingStatus/:freezingAmount");
	assert (routes[7].method == HTTPMethod.GET && routes[7].pattern == "/blockchain/AccountOperations/createAccount");
	assert (routes[8].method == HTTPMethod.GET && routes[8].pattern == "/blockchain/trustcontract/validateTrustContract/:accountAddress/:contents");
	assert (routes[9].method == HTTPMethod.GET && routes[9].pattern == "/blockchain/trustcontract/confirmedTrustContract/:tempContractID");
	assert (routes[10].method == HTTPMethod.GET && routes[10].pattern == "/blockchain/trustcontract/runTrustContract/:contractAddress/:contents");
	assert (routes[11].method == HTTPMethod.GET && routes[11].pattern == "/blockchain/trustcontract/reqTrustContractList");
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

    auto shell = new Shell;
    auto occpSettings = new OCCPSettings;
    listener = shell.listenOCCP(occpSettings, (IOCCPRequest req, IOCCPResponse res)
    {
        logInfo("Callback Event Call");
        foreach(socket; sockets)
        {
			auto r = receiveBos();
			auto json = serializeToJson(r);
            socket.send(json.toString().dup);
        }
    });
    logInfo("listenOCCP");
}

// only for Demoday
ReqTrustContractList[] rs;
TrustContract tmpTc;

private IOCCPListener listener;
private WebSocket[] sockets;

void handleWebSocketConnection(scope WebSocket socket)
{
	sockets ~= socket;
	socket.waitForData(1.seconds);
	string name = socket.receiveText;

	if(name !is null) 
	{
		logInfo("%s connected @ %s.", name, socket.request.peer);
        
        listener.getResTask().send(name, 201703290133UL);
//		sendTextToOtherClients(null, "System", name ~ " connected to the chat.");
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
        
//        listener.getResTask().send(text);
        
        // Relay text to everyone else
 //       sendTextToOtherClients(socket, name, text);
    }
 
    // Remove socket from sockets list and close socket
    socket.close;
    sockets.removeFromArray!WebSocket(socket);
    logInfo("%s disconnected.", name);
 
//    sendTextToOtherClients(null, "System", name ~ " disconnected to the chat.");
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
