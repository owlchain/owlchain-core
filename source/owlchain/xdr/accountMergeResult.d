module owlchain.xdr.accountMergeResult;

import owlchain.xdr.type;
import owlchain.xdr.accountMergeResultCode;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct AccountMergeResult
{
    AccountMergeResultCode code;
    int64 sourceAccountBalance;

    static void encode(XdrDataOutputStream stream, ref const AccountMergeResult encoded)
    {
        stream.writeInt32(encoded.code);
        switch (encoded.code)
        {
        case AccountMergeResultCode.ACCOUNT_MERGE_SUCCESS:
            stream.writeInt64(encoded.sourceAccountBalance);
            break;
        default:
            break;
        }
    }

    static AccountMergeResult decode(XdrDataInputStream stream)
    {
        AccountMergeResult decoded;
        decoded.code = cast(AccountMergeResultCode) stream.readInt32();
        switch (decoded.code)
        {
        case AccountMergeResultCode.ACCOUNT_MERGE_SUCCESS:
            decoded.sourceAccountBalance = stream.readInt64();
            break;
        default:
        }
        return decoded;
    }

}
