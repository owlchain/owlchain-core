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


    
}