module owlchain.reasoner.ontology;

import owlchain.api.api;
import sdlang;

class Ontology: IOntology {
    bool loadData(ubyte[] owlData){
        return false;
    }

    bool loadFile(string owlPath){
        return false;
    }
    
    IOperator operator(){
        return null;
    }
}


unittest {
    auto onto = new Ontology;
    assert(onto.loadData((cast(ubyte[])"test data")) is false);
    assert(onto.loadFile("path/to/file") is false );
    assert(onto.operator() is null);
}