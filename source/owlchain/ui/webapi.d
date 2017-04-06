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

// Trust Contract Operations


// User receiveTransaction
struct ReceiveBos
{
	string type;
	string receiverAccountAddress;
	string senderAccountAddress;
	double amount;
}
