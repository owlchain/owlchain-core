module owlchain.main.config;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.bcpQuorumSet;
import owlchain.crypto.keyUtils;

class Config
{
private:
    SecretKey mSecretKey;
    bool mIsValidator;
    BCPQuorumSet mBCPQuorumSet;

public:
    this()
    {

    }

    @property SecretKey NODE_SEED()
    {
        return mSecretKey;
    }

    @property bool NODE_IS_VALIDATOR()
    {
        return mIsValidator;
    }

    @property ref  BCPQuorumSet QUORUM_SET()
    {
        return mBCPQuorumSet;
    }
}
