module owlchain.xdr.operation;

import owlchain.utils.uniqueStruct;

import owlchain.xdr.type;

import owlchain.xdr.accountID;
import owlchain.xdr.operationType;
import owlchain.xdr.createAccountOp;
import owlchain.xdr.paymentOp;
import owlchain.xdr.pathPaymentOp;
import owlchain.xdr.manageOfferOp;
import owlchain.xdr.createPassiveOfferOp;
import owlchain.xdr.setOptionsOp;
import owlchain.xdr.changeTrustOp;
import owlchain.xdr.allowTrustOp;
import owlchain.xdr.manageDataOp;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Operation
{
    // sourceAccount is the account used to run the operation
    // if not set, the runtime defaults to "sourceAccount" specified at
    // the transaction level
    UniqueStruct!AccountID sourceAccount;
    OperationBody opBody;


    ref Operation opAssign(Operation other)
    {
        if (other.sourceAccount != null) {
            sourceAccount = cast(UniqueStruct!AccountID)(new AccountID());
            cast(AccountID)(*sourceAccount) = *other.sourceAccount;
        }
        opBody = other.opBody;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const Operation encodedValue)
    {
        if (encodedValue.sourceAccount != null)
        {
            stream.writeInt(1);
            AccountID.encode(stream, *encodedValue.sourceAccount);
        } else {
            stream.writeInt(0);
        }
        OperationBody.encode(stream, encodedValue.opBody);
    }

    static Operation decode(XdrDataInputStream stream)
    {
        Operation decodedValue;

        int sourceAccountPresent = stream.readInt();
        if (sourceAccountPresent != 0) {
            decodedValue.sourceAccount = cast(UniqueStruct!AccountID)(new AccountID());
            *decodedValue.sourceAccount = AccountID.decode(stream);
        }

        decodedValue.opBody = OperationBody.decode(stream);
        return decodedValue;
    }
}

struct OperationBody
{
    OperationType type;

    union
    {
        CreateAccountOp createAccountOp;
        PaymentOp paymentOp;
        PathPaymentOp pathPaymentOp;
        ManageOfferOp manageOfferOp;
        CreatePassiveOfferOp createPassiveOfferOp;
        SetOptionsOp setOptionsOp;
        ChangeTrustOp changeTrustOp;
        AllowTrustOp allowTrustOp;
        AccountID destination;
        ManageDataOp manageDataOp;
    }

    static void encode(XdrDataOutputStream stream, ref const OperationBody encodedValue)
    {
        encodeOperationType(stream, encodedValue.type);

        switch (encodedValue.type)
        {
        case OperationType.CREATE_ACCOUNT:
            CreateAccountOp.encode(stream, encodedValue.createAccountOp);
            break;
        case OperationType.PAYMENT:
            PaymentOp.encode(stream, encodedValue.paymentOp);
            break;
        case OperationType.PATH_PAYMENT:
            PathPaymentOp.encode(stream, encodedValue.pathPaymentOp);
            break;
        case OperationType.MANAGE_OFFER:
            ManageOfferOp.encode(stream, encodedValue.manageOfferOp);
            break;
        case OperationType.CREATE_PASSIVE_OFFER:
            CreatePassiveOfferOp.encode(stream, encodedValue.createPassiveOfferOp);
            break;
        case OperationType.SET_OPTIONS:
            SetOptionsOp.encode(stream, encodedValue.setOptionsOp);
            break;
        case OperationType.CHANGE_TRUST:
            ChangeTrustOp.encode(stream, encodedValue.changeTrustOp);
            break;
        case OperationType.ALLOW_TRUST:
            AllowTrustOp.encode(stream, encodedValue.allowTrustOp);
            break;
        case OperationType.ACCOUNT_MERGE:
            AccountID.encode(stream, encodedValue.destination);
            break;
        case OperationType.INFLATION:
            break;
        case OperationType.MANAGE_DATA:
            ManageDataOp.encode(stream, encodedValue.manageDataOp);
            break;
        default:
            break;
        }
    }

    static OperationBody decode(XdrDataInputStream stream)
    {
        OperationBody decodedValue;

        decodedValue.type = decodeOperationType(stream);
        switch (decodedValue.type)
        {
        case OperationType.CREATE_ACCOUNT:
            decodedValue.createAccountOp = CreateAccountOp.decode(stream);
            break;
        case OperationType.PAYMENT:
            decodedValue.paymentOp = PaymentOp.decode(stream);
            break;
        case OperationType.PATH_PAYMENT:
            decodedValue.pathPaymentOp = PathPaymentOp.decode(stream);
            break;
        case OperationType.MANAGE_OFFER:
            decodedValue.manageOfferOp = ManageOfferOp.decode(stream);
            break;
        case OperationType.CREATE_PASSIVE_OFFER:
            decodedValue.createPassiveOfferOp = CreatePassiveOfferOp.decode(stream);
            break;
        case OperationType.SET_OPTIONS:
            decodedValue.setOptionsOp = SetOptionsOp.decode(stream);
            break;
        case OperationType.CHANGE_TRUST:
            decodedValue.changeTrustOp = ChangeTrustOp.decode(stream);
            break;
        case OperationType.ALLOW_TRUST:
            decodedValue.allowTrustOp = AllowTrustOp.decode(stream);
            break;
        case OperationType.ACCOUNT_MERGE:
            decodedValue.destination = AccountID.decode(stream);
            break;
        case OperationType.INFLATION:
            break;
        case OperationType.MANAGE_DATA:
            decodedValue.manageDataOp = ManageDataOp.decode(stream);
            break;
        default:
            break;
        }
        return decodedValue;
    }

}
