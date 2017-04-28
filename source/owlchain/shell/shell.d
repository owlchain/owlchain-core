module owlchain.shell.shell;

import owlchain.api.api;
import owlchain.transaction.blockchain;
import owlchain.wallet.wallet;
import vibe.core.core;
import vibe.core.log;
import vibe.core.concurrency : receive;
import core.time;
import std.functional;

class OCPRequest : IOCPRequest {
    OCPMethod _method;

    OCPMethod getMethod() {
        return _method;
    }
    void setMethod(OCPMethod method) {
      _method = method;
    }
}

class OCPResponse : IOCPResponse {

}

class OCPListener : IOCPListener {
    Task _reqTask;
    Task _resTask;
    IOCPSettings _settings;
    
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
    IOCPSettings getSettings() {
        return _settings;
    }
    
    void setSettings(IOCPSettings settings) {
        _settings = settings;
    }
}

class OCPSettings : IOCPSettings {

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

    IOCPListener listenOCP(IOCPSettings settings, OCPRequestDeligate requestHandler) {
        auto req = new OCPRequest; 
        req.setMethod(OCPMethod.OM_ReceiveBos);

        auto res = new OCPResponse;
        
        auto reqTask = runTask({
            sleep(5.seconds);
            requestHandler(req,res);
            yield();
        });
        auto resTask = runTask({
            while(true){
                receive(
                    (string msg) {
                        logInfo("listenOCP resTask: %s", msg);
                    },
                    (string msg, ulong time) {
                        logInfo("listenOCP Time: %d msg: %s", time, msg);
                    }
                );
            }
        });

        auto listener = new OCPListener;
        listener.setSettings(settings);
        listener.setReqTask(reqTask);
        listener.setResTask(resTask);

        return listener;
    }
}
