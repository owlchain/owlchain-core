module owlchain.ui.webapi;

struct Transaction {
	this(string _hash) { hash = _hash; }
	string hash;
}

struct Block {
	this(int _height) { height = _height; }
	int height;
	string timestamp;
	int capacity;
	int confirmReward;
	int totalIssueVol;

	//Transaction[] txs;
}