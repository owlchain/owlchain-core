# RESTful API.

## Table of Contents

  - [User sendTransaction](#user-sendtransaction)
    - [sendBOS](#type---sendbos)
    - [sendProposal](#type---sendproposal)
    - [sendVote](#sendvote)
  - [Account Operations](#account-operations)
    - [createSeed](#createseed)
    - [confirmSeed](#confirmseed)
    - [getAccount](#getaccount)
    - [getBalance](#getbalance)
    - [getFreezingStatus](#getfreezingstatus)
    - [getAccountTransaction](#getaccounttransaction)
    - [delAccount](#delaccount)
  - [Account Control Operations](#account-control-operations)
    - [setAccountName](#setaccountname)
  - [Block Operations](#block-operations)
    - [getBlock](#getblock)
    - [getBlockInforamtion](#getblockinformation)    
  - [Freezing Operations](#freezing-operations)
    - [setFreezing](#setfreezing)
    - [unFreezing](#unfreezing)
  - [Networking Operations](#networking-operations)
    - [findQuorum](#findquorum)
    - [joinQuorum](#joinquorum)
    - [releaseQuorum](#releasequorum)       
  - [Proposal Operations](#proposal-operations)
  - [Trust Contract Operations](#trust-contract-operations)
  - [Voting Operations](#voting-operations)

## User sendTransaction

- ### type - sendBOS

 http://localhost:8080/blockchain/transactions/sendTransaction

>#### Request parameter :
```
 { “type" : "sendBOS",
   “sender accout address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   “receiver accout address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   “amount" : double,
   “fee" : double}
```
>#### Response parameter :
```
 { "sendBOS" : true }
```

- ### type - sendProposal

 http://localhost:8080/blockchain/transactions/sendTransaction

> #### Request parameter :
```
 { “type" : "sendProposal",
   “sender accout address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   “receiver accout address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   "contents" : "string",
   “fee" : double}
```
> #### Response parameter :
```
 { "sendProposal" : true }
```

- ### type - sendVote

 http://localhost:8080/blockchain/transactions/sendTransaction

> #### Request parameter :
```
 { “type" : "sendVote",
   “sender accout address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   “receiver accout address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   "contents" : "string",
   “fee" : double}
```
> #### Response parameter :
```
 { "sendVote" : true }
```

## Account Operations

- ### createSeed

 http://localhost:8080/blockchain/AccountOperations/creatSeed

> #### Request parameter :
```
 Nothing
```
> #### Response parameter :
```
 { "passphrase" : "12 words"}
```

- ### confirmSeed

 http://localhost:8080/blockchain/AccountOperations/confirmSeed

> #### Request parameter :
```
 { "passphrase" : "12 words"}
```
> #### Response parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   "account balance" : 0,
   "freezing status" : false}
```

- ### getAccount

 http://localhost:8080/blockchain/AccountOperations/getAccount

> #### Request parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX"}
```
> #### Response parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   "account balance" : udouble,
   "available balance" : udouble,
   "pending balance" : udouble, 
   "freezing status" : bool,
   "freezing amount" : udouble,
   "freezing start time" : uint,
   "freezing interests" : udouble}
```

- ### getBalance

 http://localhost:8080/blockchain/AccountOperations/getBalance

> #### Request parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX"}
```
> #### Response parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   "account balance" : udouble,
   "available balance" : udouble,
   "pending balance" : udouble}
```

- ### getFreezingStatus

 http://localhost:8080/blockchain/AccountOperations/getgetFreezingStatus

> #### Request parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX"}
```
> #### Response parameter :
```
 { "freezing status" : bool,
   "freezing amount" : udouble,
   "freezing start time" : uint,
   "freezing interests" : udouble}
```

- ### getAccountTransaction

 http://localhost:8080/blockchain/AccountOperations/getAccountTransaction

> #### Request parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX"}
```
> #### Response parameter :
```
 { “type" : "sendBOS/sendProposal/sendVote",
   “timestamp" : uint,
   “amount" : double,
   “fee or reward" : double,
   “accout address" : "BOS-XXXXX-XXXXX-XXXXXXX"}
```

- ### delAccount

 http://localhost:8080/blockchain/AccountOperations/delAccount

> #### Request parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX"}
```
> #### Response parameter :
```
 { “delAccount" : true}
```

## Account Control Operations

- ### setAccountName

 http://localhost:8080/blockchain/AccountControlOperations/setAccountName

> #### Request parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   "rename" : "string"}
```
> #### Response parameter :
```
 { "setName" : true}
```

## Block Operations

- ### getBlock

 http://localhost:8080/blockchain/BlockOperations/getBlock

> #### Request parameter :
```
 { "block height" : uint}
```
> #### Response parameter :
```
 { "block height" : uint,
   "previousBlockHash" : "string",
   "generator" : "account address",
   "nextBlock" : uint,
   "transactions" : [ 
     "string",
     "string",
     "string",
     "string",
     "string"
     ],
   "timestamp" : uint}
```

- ### getBlockInformation

 http://localhost:8080/blockchain/BlockOperations/getBlockInformation

> #### Request parameter :
```
 Nothing
```
> #### Response parameter :
```
 { "block height" : uint,
   "timestamp" : uint,
   "amount" : udouble,
   "fee" : udouble,
   "generator" : "account address"}
```

## Freezing Operations

- ### setFreezing

 http://localhost:8080/blockchain/FreezingOperations/setFreezing

> #### Request parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   "freezing status" : true,
   "freezing amount" : udouble}
```
> #### Response parameter :
```
 { "account address" : BOS-XXXXX-XXXXX-XXXXXXX",
   "setFreezing" : true, 
   "freezing amount" : udouble,
   "account balance" : udouble(total amount - freezing amount),
   "freezing interests" : udouble,
   "freezing start time" : uint } 
```
- ### unFreezing

 http://localhost:8080/blockchain/FreezingOperations/unFreezing

> #### Request parameter :
```
 { "account address" : "BOS-XXXXX-XXXXX-XXXXXXX",
   "freezing status" : false,
   "freezing amount" : udouble}
```
> #### Response parameter :
```
 { "account address" : BOS-XXXXX-XXXXX-XXXXXXX",
   "setFreezing" : false, 
   "unfreezing amount" : udouble,
   "total return amount" : udouble(unfreezing amount + interests),
   "freezing stop time" : uint } 
```

## Networking Operations

- ### findQuorum

 http://localhost:8080/blockchain/NetworkingOperations/findQuorum

> #### Request parameter :
```
 Nothing
```
> #### Response parameter :
```
 { "quorum list" : [ 
     "string",
     "string",
     "string",
     "string",
     "string"
     ]}
```

- ### joinQuorum

 http://localhost:8080/blockchain/NetworkingOperations/joinQuorum

> #### Request parameter :
```
 { "select quorom" : "string"}
```
> #### Response parameter :
```
 { "joinQuorom" : true}
```

- ### releaseQuorum

 http://localhost:8080/blockchain/NetworkingOperations/releaseQuorum

> #### Request parameter :
```
 { "release quorom" : "string"}
```
> #### Response parameter :
```
 { "releaseQuorum" : true}
```

## Proposal Operations

## Trust Contract Operations

## Voting Operations