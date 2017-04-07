module owlchain.wallet.wallet;

import owlchain.api.api;

class Wallet : IWallet
{
    IAccount getAccount()
    {
        return null;
    }
    
    string createSeed()
    {
        return null;
    }
    
    bool removeAccount(IAddress address)
    {
        return true;
    }
    
    bool removeAccount(IAccount account)
    {
        return true;
    }
}

class Account {
    IAddress getAddress()
    {
        return null;
    }
    
    string getAlias()
    {
        return null;
    }
    
    void setAlias(AccountAlias aliasName)
    {
        
    }
    
    ulong getBalance()
    {
        return 0;
    }
    
    bool send(ulong amount, IAccount receiver)
    {
        return true;
    }
    
    bool send(ulong amount, IAddress address)
    {
        return true;
    }
    
    bool setFreeze(ulong amount)
    {
        return true;
    }
}