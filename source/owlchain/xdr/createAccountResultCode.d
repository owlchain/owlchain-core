module owlchain.xdr.createAccountResultCode;

import std.conv;
import owlchain.xdr.type;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum CreateAccountResultCode
{
    // codes considered as "success" for the operation
    CREATE_ACCOUNT_SUCCESS = 0, // account was created

    // codes considered as "failure" for the operation
    CREATE_ACCOUNT_MALFORMED = -1,  // invalid destination
    CREATE_ACCOUNT_UNDERFUNDED = -2, // not enough funds in source account
    CREATE_ACCOUNT_LOW_RESERVE = -3, // would create an account below the min reserve
    CREATE_ACCOUNT_ALREADY_EXIST = -4, // account already exists
}

static void encodeCreateAccountResultCode(XdrDataOutputStream stream, ref const CreateAccountResultCode encodedType)
{
    int32 value = cast(int) encodedType;
    stream.writeInt32(value);
}

static CreateAccountResultCode decodeCreateAccountResultCode(XdrDataInputStream stream)
{
    CreateAccountResultCode decodedType;
    const int32 value = stream.readInt32();
    switch (value)
    {
        case 0:
            decodedType = CreateAccountResultCode.CREATE_ACCOUNT_SUCCESS;
            break;
        case -1:
            decodedType = CreateAccountResultCode.CREATE_ACCOUNT_MALFORMED;
            break;
        case -2:
            decodedType = CreateAccountResultCode.CREATE_ACCOUNT_UNDERFUNDED;
            break;
        case -3:
            decodedType = CreateAccountResultCode.CREATE_ACCOUNT_LOW_RESERVE;
            break;
        case -4:
            decodedType = CreateAccountResultCode.CREATE_ACCOUNT_ALREADY_EXIST;
            break;
        default:
            throw new Exception("Unknown enum value: " ~ to!string(value,10));
    }
    return decodedType;
}
