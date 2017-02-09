module owlchain.store.blockchain;
import owlchain.api.api;

/**
class Transaction: ITransaction
{
override:
	string getHash()
	{

	}
	int getVer()
	{

	}
	int getVinSize()
	{

	}
	int getvoutSize()
	{

	}
	string getLockTime()
	{

	}
	int getSize()
	{

	}
	int getBlockHeight()
	{

	}
	int getTxIndex()
	{

	}
}

enum BLOCK_VERSION = 0.01;

class Block: IBlock
{
override:
    string getHash()
    {
    	return "hash";
    }
    int getVer()
    {
    	return BLOCK_VERSION;
    }
    string getPrevBlock()
    {
    	return 
    }
    string getMrklRoot()
    {

    }
    string getTime()
    {

    }
    int getBits()
    {

    }
    int getNTx()
    {

    }
    int getSize()
    {

    }
    int getBlockIndex()
    {

    }
    bool getMainChain()
    {

    }
    int getHeight()
    {

    }
    string getReceivedTime()
    {

    }
    ITransaction[] getTransactions()
    {

    }
}

class Blockchain: IBlockchain 
{
	this(string path="") 
	{
		//if(0 == path.length)
		//{
		//	config.dataPath
		//}
	}
override:
	int getLastBlockIndex() 
	{
		return 0;
	}
	int getLastBlockHeight()
	{
		return 0;
	}
	IBlock getLastBlock()
	{
		return new IBlock;
	}
	IBlock getBlock(int index)
	{
		return new IBlock;
	}
	IBlock getBlock(string hash)
	{
		return new IBlock;
	}
} */