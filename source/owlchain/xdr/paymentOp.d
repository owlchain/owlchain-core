module owlchain.xdr.paymentOp;

import owlchain.xdr.type;
import owlchain.xdr.asset;
import owlchain.xdr.accountID;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct PaymentOp
{
    AccountID destination;  // recipient of the payment
    Asset asset;            // what they end up with
    int64 amount;           // amount they end up with

    static void encode(XdrDataOutputStream stream, ref const PaymentOp encodedValue)
    {   
        AccountID.encode(stream, encodedValue.destination);
        Asset.encode(stream, encodedValue.asset);
        stream.writeInt64(encodedValue.amount);
    }

    static PaymentOp decode(XdrDataInputStream stream)
    {
        PaymentOp decodedValue;
        decodedValue.destination = AccountID.decode(stream);
        decodedValue.asset = Asset.decode(stream);
        decodedValue.amount = stream.readInt64();
        return decodedValue;
    }
}