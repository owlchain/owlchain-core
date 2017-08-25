module owlchain.xdr.createAccountOp;

import owlchain.xdr.type;
import owlchain.xdr.accountID;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct CreateAccountOp
{
    AccountID destination;
    int64 startingBalance;

    static void encode(XdrDataOutputStream stream, ref const CreateAccountOp encodedValue)
    {
        AccountID.encode(stream, encodedValue.destination);
        stream.writeInt64(encodedValue.startingBalance);
    }

    static CreateAccountOp decode(XdrDataInputStream stream)
    {
        CreateAccountOp decodedValue;

        decodedValue.destination = AccountID.decode(stream);
        decodedValue.startingBalance = stream.readInt64();

        return decodedValue;
    }
}