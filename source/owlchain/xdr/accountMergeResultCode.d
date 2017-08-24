module owlchain.xdr.accountMergeResultCode;

enum AccountMergeResultCode
{
    ACCOUNT_MERGE_SUCCESS = 0,
    ACCOUNT_MERGE_MALFORMED = -1,
    ACCOUNT_MERGE_NO_ACCOUNT = -2,
    ACCOUNT_MERGE_IMMUTABLE_SET = -3,
    ACCOUNT_MERGE_HAS_SUB_ENTRIES = -4
}
