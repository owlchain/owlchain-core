module owlchain.transaction.transaction;

import owlchain.reasoner.ontology;

interface Transaction {

}

interface Blockchain {

}

interface Operator {
    Transaction execute(scope Ontology ontology, scope Blockchain blockchain) pure;  
}
