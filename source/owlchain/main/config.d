module owlchain.main.config;

import owlchain.xdr;
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

    @property bool MANUAL_CLOSE()
    {
        return false;
    }

    string toShortString(ref PublicKey pk) 
    {
        return "";
    }

    string toStrKey(ref PublicKey pk) 
    {
        return "";
    }

    string toStrKey2(ref PublicKey pk, ref bool isAlias) 
    {
        return "";
    }

    bool resolveNodeID(ref string s, ref PublicKey retKey) const
    {
        return false;
    }
}
