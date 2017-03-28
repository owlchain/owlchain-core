module owlchain.transaction.blockchain;
import owlchain.api.api;

//version(DO_NOT_COMPILE):

enum BLOCK_VERSION = 1_0_0;
enum TRANSACTION_VERSION = 1_0_0;

class Transaction: ITransaction
{
override:
	string getHash()
	{
		return "";
	}

	int getVer()
	{
		return TRANSACTION_VERSION;
	}

	int getVinSize()
	{
		return 0;
	}

	int getvoutSize()
	{
		return 0;
	}

	string getLockTime()
	{
		return "";
	}

	int getSize()
	{
		return 0;
	}

	int getBlockHeight()
	{
		return 0;
	}

	int getTxIndex()
	{
		return 0;
	}
}

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
    	return "";
    }
    string getMrklRoot()
    {
    	return "";
    }
    string getTime()
    {
    	return "";
    }
    int getBits()
    {
    	return 0;
    }

    int getNTx()
    {
    	return 0;
    }

    int getSize()
    {
    	return 0;
    }

    int getBlockIndex()
    {
    	return 0;
    }

    bool getMainChain()
    {
    	return 0;
    }

    int getHeight()
    {
    	return 0;
    }

    string getReceivedTime()
    {
    	return "";
    }

    ITransaction[] getTransactions()
    {
    	return null;
    }
}

class Blockchain: IBlockchain 
{
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
		return null;
	}

	IBlock getBlock(int index)
	{
		return null;
	}

	IBlock getBlock(string hash)
	{
		return null;
	}
    bool isReady()
    {
        return true;
    }
    BlockchainState getState()
    {
        return BlockchainState.BS_Offline;
    }
    ITransaction[] getTransactions(IAddress address)
    {
        return null;
    }
    ITransaction[] getTransactions(IAccount acount)
    {
        return null;
    }
} 
