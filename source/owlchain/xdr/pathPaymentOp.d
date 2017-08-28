module owlchain.xdr.pathPaymentOp;

import owlchain.xdr.type;
import owlchain.xdr.asset;
import owlchain.xdr.accountID;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct PathPaymentOp
{
    // asset we pay with
    Asset sendAsset;

    // the maximum amount of sendAsset to
    // send (excluding fees).
    // The operation will fail if can't be met
    int64 sendMax;

    // recipient of the payment
    AccountID destination;

    // what they end up with
    Asset destAsset;

    // amount they end up with
    int64 destAmount;

    // additional hops it must go through to get there
    Asset[] path;

    ref PathPaymentOp opAssign(PathPaymentOp other)
    {
        sendAsset = other.sendAsset;
        sendMax = other.sendMax;
        destination = other.destination;
        destAsset = other.destAsset;
        destAmount = other.destAmount;

        path.length = 0;
        for (int i = 0; i < other.path.length; i++)
        {
            path ~= other.path[i];
        }
        return this;
    }
    static void encode(XdrDataOutputStream stream, ref const PathPaymentOp encodedValue)
    {
        Asset.encode(stream, encodedValue.sendAsset);
        stream.writeInt64(encodedValue.sendMax);
        AccountID.encode(stream, encodedValue.destination);
        Asset.encode(stream, encodedValue.destAsset);
        stream.writeInt64(encodedValue.destAmount);
        const int pathsize = cast(int) encodedValue.path.length;
        stream.writeInt32(pathsize);
        for (int i = 0; i < pathsize; i++)
        {
            Asset.encode(stream, encodedValue.path[i]);
        }
    }

    static PathPaymentOp decode(XdrDataInputStream stream)
    {
        PathPaymentOp decodedValue;
        decodedValue.sendAsset = Asset.decode(stream);
        decodedValue.sendMax = stream.readInt64();
        decodedValue.destination = AccountID.decode(stream);
        decodedValue.destAsset = Asset.decode(stream);
        decodedValue.destAmount = stream.readInt64();
        const int pathsize = stream.readInt32();
        decodedValue.path.length = 0;
        for (int i = 0; i < pathsize; i++)
        {
            decodedValue.path ~= Asset.decode(stream);
        }
        return decodedValue;
    }
}
