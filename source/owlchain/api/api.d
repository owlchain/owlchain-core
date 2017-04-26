module owlchain.api.api;

import vibe.core.core;

interface IOntology 
{
    bool loadData(ubyte[] owlData);
    bool loadFile(string owlPath);
    IOperator operator();
}
interface IOwlReasoner 
{
	void setOntology(IOntology owlData);
    bool run();
}

interface ITalInterpreter 
{
	bool execute(IOperator op);
}

interface ITransaction 
{
	string getHash();
	int getVer();
	int getVinSize();
	int getvoutSize();
	string getLockTime();
	int getSize();
	int getBlockHeight();
	int getTxIndex();
}

interface IBlock 
{
    string getHash();
    int getVer();
    string getPrevBlock();
    string getMrklRoot();
    string getTime();
    int getBits();
    int getNTx();
    int getSize();
    int getBlockIndex();
    bool getMainChain();
    int getHeight();
    string getReceivedTime();
    ITransaction[] getTransactions();
}

enum BlockchainState 
{
    BS_Ready = 0,
    BS_Syncing,
    BS_Offline
}

interface IBlockchain 
{
    int getLastBlockIndex();
	int getLastBlockHeight();
	IBlock getLastBlock();
	IBlock getBlock(int index);
	IBlock getBlock(string hash);
    bool isReady();
    BlockchainState getState();
    ITransaction[] getTransactions(IAddress address);
    ITransaction[] getTransactions(IAccount account);
}


interface IWallet 
{
    IAccount getAccount();
    string createSeed();
    bool removeAccount(IAddress address);
    bool removeAccount(IAccount account);
}

enum MaxAliasSize = 100;
alias ubyte[MaxAliasSize] AccountAlias;

interface IAccount 
{
    IAddress getAddress();
    string getAlias();
    void setAlias(AccountAlias aliasName);
    ulong getBalance();
    bool send(ulong amount, IAccount receiver);
    bool send(ulong amount, IAddress address);
    bool setFreeze(ulong amount);
}

interface IAddress 
{
    bool isValid();
}

enum OCPMethod 
{
    OM_ReceiveBos = 0,
    OM_ReceiveVote,
    OM_ReceiveProposal,
    OM_BlockchainReady,
    OM_BlockchainSync,
    OM_BlockchainOffline
}

//OCP: Owlchain Consensus Protocol

interface IOCPRequest 
{
    OCPMethod getMethod();
    void setMethod(OCPMethod method);
}

interface IOCPResponse 
{

}

interface IOCPListener 
{
    Task getReqTask();
    void setReqTask(Task task);
    Task getResTask();
    void setResTask(Task task);
    IOCPSettings getSettings();
    void setSettings(IOCPSettings settings);
}

interface IOCPSettings 
{

}

alias OCPRequestDeligate = void delegate(IOCPRequest req, IOCPResponse res);
alias OCPRequestFunction = void function(IOCPRequest req, IOCPResponse res);

interface IShell 
{
    IWallet getWallet();
    IBlockchain getBlockchain();
    IOCPListener listenOCP(IOCPSettings settings, OCPRequestDeligate requestHandler);
}

interface IOperator 
{
    ITransaction execute(scope IOntology ontology, scope IBlockchain blockchain) pure;  
}

