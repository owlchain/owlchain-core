module owlchain.reasoner.reasoner;

import owlchain.api.api;
import clips;

class Reasoner : IOwlReasoner {

    void *_theEnv;
    IOntology _ont;

    this(){
        _theEnv = CreateEnvironment();

    }
    ~this() {
        DeallocateEnvironmentData();
        DestroyEnvironment(_theEnv);
    }
    
    void setOntology(IOntology ont) {
        _ont = ont;
    }

    bool run() {
        // RerouteStdin(_theEnv, cast(int)argv.length, cast(char **)argv.ptr);
        // CommandLoop(theEnv);
        return false;
    }
}


unittest {
    auto reasoner = new Reasoner;

    assert(reasoner.run() is false);
    import std.stdio: writefln;

    writefln("reasoner test...");
}