module owlchain.api.api;

interface Ontology {

}

interface Reasoner {

}

interface Interpreter {
		
}

interface Transaction {

}

interface Block {

}

interface Blockchain {

}

interface Operator {
    Transaction execute(scope Ontology ontology, scope Blockchain blockchain) pure;  
}
