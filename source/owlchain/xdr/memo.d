module owlchain.xdr.memo;

import owlchain.xdr.type;
import owlchain.xdr.memoType;
import owlchain.xdr.hash;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct Memo
{
    MemoType type;
    string text;
    uint64 id;
    Hash hash;
    Hash retHash;

    static void encode(XdrDataOutputStream stream, ref const Memo encodedValue)
    {
        encodeMemoType(stream, encodedValue.type);
        stream.writeString(encodedValue.text);
        stream.writeUint64(encodedValue.id);
        Hash.encode(stream, encodedValue.hash);
        Hash.encode(stream, encodedValue.retHash);
    }

    static Memo decode(XdrDataInputStream stream)
    {
        Memo decodedValue;

        decodedValue.type = decodeMemoType(stream);

        switch (decodedValue.type)
        {
        case MemoType.MEMO_NONE:
            break;
        case MemoType.MEMO_TEXT:
            decodedValue.text = stream.readString();
            break;
        case MemoType.MEMO_ID:
            decodedValue.id = stream.readUint64();
            break;
        case MemoType.MEMO_HASH:
            decodedValue.hash = Hash.decode(stream);
            break;
        case MemoType.MEMO_RETURN:
            decodedValue.retHash = Hash.decode(stream);
            break;
        default:
            break;
        }
        return decodedValue;
    }

}
