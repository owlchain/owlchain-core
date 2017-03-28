module owlchain.wallet.wallet;

import owlchain.api.api;

class Wallet : IWallet {
    IAccount getAccount() {
        return null;
    }
    string createSeed() {
        return null;
    }
    bool removeAccount(IAddress address) {
        return true;
    }
    bool removeAccount(IAccount account) {
        return true;
    }
}
