module owlchain.ui.webapi;

struct ErrorState
{
	string errCode;	
	string errMessage;
}

struct SendBos
{
	bool sendBos;
}

struct CreateAccount
{
	string accountAddress;
	bool freezingStatus = false;
	bool transaction = false;
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

struct GetAccountTransaction
{
	string type;
	double freezingReward;
	double confirmReward;
	uint timestamp;
	string accountAddress;
	double amount;
	double fee;
	string memo;
}

struct Transaction
{
	this(string _hash) { hash = _hash; }
	string hash;

	string type;
	string senderAccAddress;
	string receiverAccAddress;
	double amount;
	double fee;
	string contents;
	uint confirmCount;
	string memo;

	//// copy from NXT
	//private final short deadline;
 //   private volatile byte[] senderPublicKey;
 //   private final long recipientId;
 //   private final long amountNQT;
 //   private final long feeNQT;
 //   private final byte[] referencedTransactionFullHash;
 //   private final TransactionType type;
 //   private final int ecBlockHeight;
 //   private final long ecBlockId;
 //   private final byte version;
 //   private final int timestamp;
 //   private final byte[] signature;
 //   private final Attachment.AbstractAttachment attachment;
 //   private final Appendix.Message message;
 //   private final Appendix.EncryptedMessage encryptedMessage;
 //   private final Appendix.EncryptToSelfMessage encryptToSelfMessage;
 //   private final Appendix.PublicKeyAnnouncement publicKeyAnnouncement;
 //   private final Appendix.Phasing phasing;
 //   private final Appendix.PrunablePlainMessage prunablePlainMessage;
 //   private final Appendix.PrunableEncryptedMessage prunableEncryptedMessage;

 //   private final List<Appendix.AbstractAppendix> appendages;
 //   private final int appendagesSize;

 //   private volatile int height = Integer.MAX_VALUE;
 //   private volatile long blockId;
 //   private volatile BlockImpl block;
 //   private volatile int blockTimestamp = -1;
 //   private volatile short index = -1;
 //   private volatile long id;
 //   private volatile String stringId;
 //   private volatile long senderId;
 //   private volatile byte[] fullHash;
 //   private volatile DbKey dbKey;
 //   private volatile byte[] bytes = null;
}

struct Account
{
	string accountAddress;
	double accountBalance = 0;	
	double availableBalance = 0;
	double pendingBalance = 0;
	bool freezingStatus = false;
	double freezingAmount = 0;
	uint freezingStartTime = 0;
	double freezingInterests = 0;
	bool transaction = false;

	// copy from NXT
	//public static final class AccountAsset {
	//	private final long accountId;
 //   	private final long assetId;
 //   	private final DbKey dbKey;
 //   	private long quantityQNT;
 //   	private long unconfirmedQuantityQNT;
 //   }
 //   public static final class AccountCurrency {

 //       private final long accountId;
 //       private final long currencyId;
 //       private final DbKey dbKey;
 //       private long units;
 //       private long unconfirmedUnits;
 //   }
 //   public static final class AccountLease {

 //       private final long lessorId;
 //       private final DbKey dbKey;
 //       private long currentLesseeId;
 //       private int currentLeasingHeightFrom;
 //       private int currentLeasingHeightTo;
 //       private long nextLesseeId;
 //       private int nextLeasingHeightFrom;
 //       private int nextLeasingHeightTo;
 //   }
 //   public static final class AccountInfo {

 //       private final long accountId;
 //       private final DbKey dbKey;
 //       private String name;
 //       private String description;
 //   }
 //   public static final class AccountProperty {

 //       private final long id;
 //       private final DbKey dbKey;
 //       private final long recipientId;
 //       private final long setterId;
 //       private String property;
 //       private String value;
 //   }
 //   public static final class PublicKey {

 //       private final long accountId;
 //       private final DbKey dbKey;
 //       private byte[] publicKey;
 //       private int height;
 //   }
 //  	private final long id;
 //   private final DbKey dbKey;
 //   private PublicKey publicKey;
 //   private long balanceNQT;
 //   private long unconfirmedBalanceNQT;
 //   private long forgedBalanceNQT;
 //   private long activeLesseeId;
 //   private Set<ControlType> controls;




}

struct Block
{
	this(int _height) { height = _height; }
	int height;
	string timestamp;
	int capacity;
	int confirmReward;
	int totalIssueVol;
	//Transaction[] txs;

	//// copy from NXT
 //   private final int version;
 //   private final int timestamp;
 //   private final long previousBlockId;
 //   private volatile byte[] generatorPublicKey;
 //   private final byte[] previousBlockHash;
 //   private final long totalAmountNQT;
 //   private final long totalFeeNQT;
 //   private final int payloadLength;
 //   private final byte[] generationSignature;
 //   private final byte[] payloadHash;
 //   private volatile List<TransactionImpl> blockTransactions;

 //   private byte[] blockSignature;
 //   private BigInteger cumulativeDifficulty = BigInteger.ZERO;
 //   private long baseTarget = Constants.INITIAL_BASE_TARGET;
 //   private volatile long nextBlockId;
 //   private int height = -1;
 //   private volatile long id;
 //   private volatile String stringId = null;
 //   private volatile long generatorId;
 //   private volatile byte[] bytes = null;
}

struct Blockchain
{
	//// referenced by NXT
	//private final Block lastBlock;
	//private final int height;
	//private final int lastBlockTimestamp;
	//private final Block block;
	//private final Block[] allBlocks;
	//private final int blockCount;
	//private final Block[] blocks;
	//private final long[] blockIdsAfter;
	//private final Block[] blocksAfter;
	//private final Transaction[] transactions;
}