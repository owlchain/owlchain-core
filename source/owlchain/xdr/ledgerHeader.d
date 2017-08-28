module owlchain.xdr.ledgerHeader;

import owlchain.xdr.type;

import owlchain.xdr.hash;
import owlchain.xdr.bosValue;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct LedgerHeader
{
    // the protocol version of the ledger
    uint32 ledgerVersion;

    // hash of the previous ledger header
    Hash previousLedgerHash;

    // what consensus agreed to
    BOSValue bcpValue;

    // the TransactionResultSet that led to this ledger
    Hash txSetResultHash;

    // hash of the ledger state
    Hash bucketListHash;

    // sequence number of this ledger
    uint32 ledgerSeq;

    // total number of stroops in existence.
    // 10,000,000 stroops in 1 XLM
    int64 totalCoins;

    // fees burned since last inflation run
    int64 feePool;

    // inflation sequence number
    uint32 inflationSeq;

    // last used global ID, used for generating objects
    uint64 idPool;

    // base fee per operation in stroops
    uint32 baseFee;

    // account base reserve in stroops
    uint32 baseReserve;

    // maximum size a transaction set can be
    uint32 maxTxSetSize;
    
    // hashes of ledgers in the past. allows you to jump back
    // in time without walking the chain back ledger by ledger
    // each slot contains the oldest ledger that is mod of
    // either 50  5000  50000 or 500000 depending on index
    // skipList[0] mod(50), skipList[1] mod(5000), etc
    Hash[4] skipList;

    LedgerHeaderExt ext;

    static void encode(XdrDataOutputStream stream, ref const LedgerHeader encoded)
    {
        stream.writeUint32(encoded.ledgerVersion);
        Hash.encode(stream, encoded.previousLedgerHash);
        BOSValue.encode(stream, encoded.bcpValue);
        Hash.encode(stream, encoded.txSetResultHash);
        Hash.encode(stream, encoded.bucketListHash);
        stream.writeUint32(encoded.ledgerSeq);
        stream.writeInt64(encoded.totalCoins);
        stream.writeInt64(encoded.feePool);
        stream.writeUint32(encoded.inflationSeq);
        stream.writeUint64(encoded.idPool);
        stream.writeUint32(encoded.baseFee);
        stream.writeUint32(encoded.baseReserve);
        stream.writeUint32(encoded.maxTxSetSize);

        int length = cast(int)skipList.length;
        for (int i = 0; i < length; i++)
        {
            Hash.encode(stream, encoded.skipList[i]);
        }
        LedgerHeaderExt.encode(stream, encoded.ext);
    }

    static LedgerHeader decode(XdrDataInputStream stream)
    {
        LedgerHeader decoded;
        decoded.ledgerVersion = stream.readUint32();
        decoded.previousLedgerHash = Hash.decode(stream);
        decoded.bcpValue = BOSValue.decode(stream);
        decoded.txSetResultHash = Hash.decode(stream);
        decoded.bucketListHash = Hash.decode(stream);
        decoded.ledgerSeq = stream.readUint32();
        decoded.totalCoins = stream.readInt64();
        decoded.feePool = stream.readInt64();
        decoded.inflationSeq = stream.readUint32();
        decoded.idPool = stream.readUint64();
        decoded.baseFee = stream.readUint32();
        decoded.baseReserve = stream.readUint32();
        decoded.maxTxSetSize = stream.readUint32();
        int length = 4;
        for (int i = 0; i < length; i++)
        {
            decoded.skipList[i] = Hash.decode(stream);
        }
        decoded.ext = LedgerHeaderExt.decode(stream);
        return decoded;
    }
}

struct LedgerHeaderExt 
{
    int32 v;

    static void encode(XdrDataOutputStream stream, ref const LedgerHeaderExt encoded)
    {
        stream.writeInt32(encoded.v);
    }

    static LedgerHeaderExt decode(XdrDataInputStream stream)
    {
        LedgerHeaderExt decoded;
        decoded.v = stream.readInt32();
        return decoded;
    }

}