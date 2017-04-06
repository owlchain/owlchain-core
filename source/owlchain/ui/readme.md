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
string receiveBOS, 
string receiver account address, 
string sender account address, 
double amount
```

- ### type - receiveFreezingReward

>#### Receive parameter :
```
string receiveFreezingReward, 
string receiver account address, 
string sender account address, 
double amount
```

- ### type - receiveConfirmReward

>#### Receive parameter :
```
string receiveConfirmReward, 
string receiver account address, 
string sender account address, 
double amount
```

- ### type - receiveProposal

>#### Receive parameter :
```
string receiveProposal,
string receiver account address, 
string account address, 
string contents
```

- ### type - receiveVote

>#### Receive parameter :
```
string receiveVote,
string receiver account address, 
string account address, 
string contents
```

## Account Operations

- ### recvAccountInformation

>#### Receive parameter :
```
int account address count,
[ string account address, 
  double account balance, 
  bool freezing status]
```

## Block Operations

- ### isBlockSync

>#### Receive parameter :
```
int BS_Ready, (complete)
int BS_Syncing, (progressing)
nit BS_Offline (disconnection)
```

