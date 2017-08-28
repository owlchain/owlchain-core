module owlchain.xdr.accountMergeResultCode;

enum AccountMergeResultCode
{
    ACCOUNT_MERGE_SUCCESS = 0,// codes considered as "success" for the operation
    // codes considered as "failure" for the operation
    ACCOUNT_MERGE_MALFORMED = -1,// can't merge onto itself
    ACCOUNT_MERGE_NO_ACCOUNT = -2,// destination does not exist
    ACCOUNT_MERGE_IMMUTABLE_SET = -3,// source account has AUTH_IMMUTABLE set
    ACCOUNT_MERGE_HAS_SUB_ENTRIES = -4// account has trust lines/offers
}
