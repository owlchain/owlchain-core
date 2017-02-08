module owlchain.api.api;

interface IOntology {

}

interface IReasoner {

}

interface IInterpreter {
		
}

interface ITransaction {

}

interface IBlock {

}

interface IBlockchain {

}

interface IOperator {
    ITransaction execute(scope IOntology ontology, scope IBlockchain blockchain) pure;  
}

