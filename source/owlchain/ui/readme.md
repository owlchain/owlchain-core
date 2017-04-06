# Websocket Transaction for Web User Interface 
### - Event Data from Core to UI front

## Table of Contents

  - [User receiveTransaction](#user-receivetransaction)
    - [receiveBOS](#type---receivebos)
    - [receiveFreezingReward](#type---receivefreezingreward)
    - [receiveConfirmReward](#type---receiveconfirmreward)
    - [receiveProposal](#type---receiveproposal)
    - [receiveVote](#type---receivevote)
  - [Account Operations](#account-operations)
    - [recvAccountInformation](#recvaccountinformation)
 - [Block Operations](#block-operations)
    - [isBlockSync](#isblocksync)

## User receiveTransaction

- ### type - receiveBOS

>#### Receive parameter :
```
string type = "receiveBOS", 
string receiver account address, 
string sender account address, 
double amount
```

- ### type - receiveFreezingReward

>#### Receive parameter :
```
string type = "receiveFreezingReward", 
string receiver account address, 
string sender account address, 
double amount
```

- ### type - receiveConfirmReward

>#### Receive parameter :
```
string type = "receiveConfirmReward", 
string receiver account address, 
string sender account address, 
double amount
```

- ### type - receiveProposal

>#### Receive parameter :
```
string type = "receiveProposal",
string receiver account address, 
string account address, 
string contents
```

- ### type - receiveVote

>#### Receive parameter :
```
string type = "receiveVote", 
string receiver account address, 
string account address, 
string contents
```

## Account Operations

- ### recvAccountInformation

>#### Receive parameter :
```
int account address count,
AccountAddress acouuntAddresses

AccountAddress = [string account address, 
                  double account balance, 
                  bool freezing status]
```

## Block Operations

- ### int isBlockSync
```
BS_Ready = 0, (complete)
BS_Syncing = 1, (progressing)
BS_Offline = 2 (disconnection)
```

