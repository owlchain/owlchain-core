module owlchain.api.api;

interface IOntology {

}

interface IReasoner {

}

interface IInterpreter {
		
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
    Transaction[] getTransactions();
}

interface IBlockchain {

}

interface IOperator {
    ITransaction execute(scope IOntology ontology, scope IBlockchain blockchain) pure;  
}

