module owlchain.api.api;

interface IOntology {

}

interface IOwlReasoner {
	bool loadData(ubyte[] owlData);
	bool loadFile(string owlPath);
}

interface ITalInterpreter {
		
}

interface ITransaction {
	string getHash();
	int getVer();
	int getVinSize();
	int getvoutSize();
	string getLockTime();
	int getSize();
	int getBlockHeight();
	int getTxIndex();
}

interface IBlock {
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

interface IBlockchain {
	int getLastBlockIndex();
	int getLastBlockHeight();
	IBlock getLastBlock();
	IBlock getBlock(int index);
	IBlock getBlock(string hash);
}

interface IOperator {
    ITransaction execute(scope IOntology ontology, scope IBlockchain blockchain) pure;  
}

