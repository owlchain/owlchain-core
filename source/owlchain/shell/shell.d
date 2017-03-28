module owlchain.shell.shell;

import owlchain.api.api;
import owlchain.transaction.blockchain;
import owlchain.wallet.wallet;
import vibe.core.core;
import vibe.core.log;
import vibe.core.concurrency : receive;
import core.time;
import std.functional;

class OCCPRequest : IOCCPRequest {
    OCCPMethod _method;

    OCCPMethod getMethod() {
        return _method;
    }
    void setMethod(OCCPMethod method) {
      _method = method;
    }
}

class OCCPResponse : IOCCPResponse {

}

class OCCPListener : IOCCPListener {
    Task _reqTask;
    Task _resTask;
    IOCCPSettings _settings;
    
    Task getReqTask() {
        return _reqTask;
    }
    void setReqTask(Task task) {
        _reqTask = task;
    }
    Task getResTask() {
        return _resTask;
    }
    void setResTask(Task task) {
        _resTask = task;
    } 
    IOCCPSettings getSettings() {
        return _settings;
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
        req.setMethod(OCCPMethod.OM_ReceiveBos);

        auto res = new OCCPResponse;
        
        auto reqTask = runTask({
            while(true){
                requestHandler(req,res);
                sleep(1.seconds);
                yield();
            }
        });
        auto resTask = runTask({
            while(true){
                receive(
                    (string msg) {
                        logInfo("listenOCCP resTask: %s", msg);
                    },
                    (string msg, ulong time) {
                        logInfo("listenOCCP Time: %d msg: %s", time, msg);
                    }
                );
            }
        });

        auto listener = new OCCPListener;
        listener.setSettings(settings);
        listener.setReqTask(reqTask);
        listener.setResTask(resTask);

        return listener;
    }
}
