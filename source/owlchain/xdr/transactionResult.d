module owlchain.xdr.transactionResult;

import owlchain.xdr.type;
import owlchain.xdr.transactionResultCode;
import owlchain.xdr.operationResult;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct TransactionResult
{
    int64 feeCharged;
    TransactionResultResult result;
    TransactionResultExt ext;

    static void encode(XdrDataOutputStream stream, ref const TransactionResult encoded)
    {
        stream.writeInt64(encoded.feeCharged);
        TransactionResultResult.encode(stream, encoded.result);
        TransactionResultExt.encode(stream, encoded.ext);
    }

    static TransactionResult decode(XdrDataInputStream stream)
    {
        TransactionResult decoded;
        decoded.feeCharged = stream.readInt64();
        decoded.result = TransactionResultResult.decode(stream);
        decoded.ext = TransactionResultExt.decode(stream);
        return decoded;
    }
}

struct TransactionResultResult
{
    TransactionResultCode code;
    OperationResult[] results;

    static void encode(XdrDataOutputStream stream, ref const TransactionResultResult encoded)
    {
        encodeTransactionResultCode(stream, encoded.code);
        switch (encoded.code) {
        case TransactionResultCode.txSUCCESS:
        case TransactionResultCode.txFAILED:
            int resultssize = cast(int)encoded.results.length;
            stream.writeInt(resultssize);
            for (int i = 0; i < resultssize; i++) {
                OperationResult.encode(stream, encoded.results[i]);
            }
            break;
        default:
            break;
      }
    }

    static TransactionResultResult decode(XdrDataInputStream stream)
    {
        TransactionResultResult decoded;
        decoded.code = decodeTransactionResultCode(stream);
        switch (decoded.code) {
        case TransactionResultCode.txSUCCESS:
        case TransactionResultCode.txFAILED:
            int resultssize = stream.readInt();
            decoded.results.length = resultssize;
            for (int i = 0; i < resultssize; i++) {
                decoded.results[i] = OperationResult.decode(stream);
            }
            break;
        default:
            break;
      }
        return decoded;
    }
}

struct TransactionResultExt 
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const TransactionResultExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static TransactionResultExt decode(XdrDataInputStream stream)
    {
        TransactionResultExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }
}