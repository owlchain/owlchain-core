module owlchain.xdr.allowTrustResultCode;

enum AllowTrustResultCode
{
    ALLOW_TRUST_SUCCESS = 0,
    ALLOW_TRUST_MALFORMED = -1,
    ALLOW_TRUST_NO_TRUST_LINE = -2,
    ALLOW_TRUST_TRUST_NOT_REQUIRED = -3,
    ALLOW_TRUST_CANT_REVOKE = -4,
    ALLOW_TRUST_SELF_NOT_ALLOWED = -5,
}
