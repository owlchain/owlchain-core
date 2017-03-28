module owlchain.shell.shell;

import owlchain.api.api;
import owlchain.transaction.blockchain;
import owlchain.wallet.wallet;
import vibe.core.core;
import core.time;
import std.functional;

class OCCPRequest : IOCCPRequest {

}

class OCCPResponse : IOCCPResponse {

}

class OCCPListener : IOCCPListener {
    Task _task;
    IOCCPSettings _settings;

    Task getTask() {
        return _task;
    }
    IOCCPSettings getSettings() {
        return _settings;
    }
    void setTask(Task task) {
        _task = task;
    }
    void setSettings(IOCCPSettings settings) {
        _settings = settings;
    }
}

class OCCPSettings : IOCCPSettings {

}

class Shell : IShell {
    Wallet _wallet;
    Blockchain _blockchain;

    this(){
        _wallet = new Wallet;
        _blockchain = new Blockchain;
    }
    
    IWallet getWallet() {
        return _wallet;
    }
    
    IBlockchain getBlockchain() {
        return _blockchain;
    }

    IOCCPListener listenOCCP(IOCCPSettings settings, OCCPRequestDeligate requestHandler) {
        auto req = new OCCPRequest; 
        auto res = new OCCPResponse;
        
        auto task = runTask({
            while(1){
                requestHandler(req,res);
                sleep(1.seconds);
                yield();
            }
        });

        auto listener = new OCCPListener;
        listener.setSettings(settings);
        listener.setTask(task);

        return listener;
    }
}
