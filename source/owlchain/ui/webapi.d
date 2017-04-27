module owlchain.ui.webapi;

struct ErrorState
{
	string errCode;	
	string errMessage;
}

// User sendTransaction
struct SendBos
{
	bool sendBos;
}

struct SendProposal
{
	bool sendProposal;
}

struct SendVote
{
	bool sendVote;
}

// Account Operations
struct CreateSeed
{
	string passphrase;
}

struct ConfirmSeed
{
	string accountAddress;
	double accountBlance;
	bool freezingStatus;
}

struct GetAccount
{
	string accountAddress;
	double accountBalance;	
	double availableBalance;
	double pendingBalance;
	bool freezingStatus;
	double freezingAmount;
	uint freezingStartTime;
	double freezingInterests;
}

struct GetBalance
{
	string accountAddress;
	double accountBalance;
	double availableBalance;
	double pendingBalance;
}

struct GetFreezingStatus
{
	bool freezingStatus;
	double freezingAmount;
	uint freezingStartTime;
	double freezingInterests;
}

struct GetAccountTransaction
{
	string type;
	uint timestamp;
	double amount;
	double feeOrReward;
	string accountAddress;
}

struct DelAccount
{
	bool delAccount;
}

// Account Control Operations
struct SetAccountName
{
	bool setName;
}

// BLock Operations
struct GetBlock
{
	uint blockHeight;
	string previousBlockHash;
	string generator;
	uint nextBlock;
	string[] transactions;
	uint timestamp;
}

struct GetBlockInformation
{
	uint blockHeight;
	uint timestamp;
	double amount;
	double fee;
	string generator;
}

// Freezing Operations
struct SetFreezing
{
	string accountAddress;
	bool setFreezing;
	double freezingAmount;
	double accountBalance;
	double freezingInterests;
	ulong freezingStartTime;
}

struct UnFreezing
{
	string accountAddress;
	bool setFreezing;
	double unFreezingAmount;
	double totalReturnAmount;
	uint freezingStopTime;
}

// Networking Operations
struct FindQuorum
{
	string[] quorumList;
}

struct JoinQuorum
{
	bool joinQuorum;
}

struct ReleaseQuorum
{
	bool releaseQuorum;
}

// Proposal Operations

// TrustContract Operations
struct ValidateTrustContract
{
	bool status;
	string statusMsg;
	string contractAddress;
}

struct ConfirmedTrustContract
{
	bool status;
	string statusMsg;
	string contractAddress;
	string title;
}

struct RunTrustContract
{
	bool status;
	string statusMsg;
	string transactionID;
	int balance;
}

struct ReqTrustContractList
{
	ulong no;
	string title;
	string contractID;
	uint txCount;
}

struct TcWallet
{
	uint totalBalance = 100000;
}

// User receiveTransaction
struct ReceiveBos
{
	string type = "receiveBOS";
	string receiverAccountAddress;
	string senderAccountAddress;
	double amount;
}

struct ReceiveParameter
{
	string type = "receiveParameter";
	string receiverAccountAddress; 
	string senderAccountAddress; 
	double amount;
}

struct ReceiveConfirmReward
{
	string type = "receiveConfirmReward";
	string receiverAccountAddress; 
	string senderAccountAddress;
	double amount;
}

struct ReceiveProposal
{
	string type = "receiveProposal";
	string receiverAccountAddress; 
	string accountAddress;
	string contents;
}

struct ReceiveVote
{
	string type = "receiveVote";
	string receiverAccountAddress;
	string accountAddress;
	string contents;
}

// Account Operations

struct RecvAccountInformation
{
	int accountAddressCount;
	AccountAddress[] accountAddresses;
}

struct AccountAddress
{
	string accountAddress;
	double accountBalance;
	bool freezingStatus;
}

// Block Operations
enum
{
	BS_Ready = 0, 	// complete
	BS_Syncing, 	// progressing
	BS_Offline		// disconnection
}

int isBlockSync;


struct CreateAccount
{
 	string accountAddress;
 	bool freezingStatus = false;
 	bool transaction = false;
 	string filePath;	
}