module owlchain.xdr.bosValue;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.upgradeType;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct BOSValue
{
    Hash txSetHash;
    uint64 closeTime;
    UpgradeType[] upgrades;
    int32 ext;

    ref BOSValue opAssign(BOSValue other)
    {
        txSetHash = other.txSetHash;
        closeTime = other.closeTime;
        upgrades.length = 0;
        for (int i = 0; i < other.upgrades.length; i++)
        {
            upgrades ~= other.upgrades[i];
        }
        ext = other.ext;
        return this;
    }

    static void encode(XdrDataOutputStream stream, ref const BOSValue encoded)
    {
        Hash.encode(stream, encoded.txSetHash);
        stream.writeUint64(encoded.closeTime);
        int upgradessize = cast(int) encoded.upgrades.length;
        stream.writeInt32(upgradessize);
        for (int i = 0; i < upgradessize; i++)
        {
            UpgradeType.encode(stream, encoded.upgrades[i]);
        }
        stream.writeInt32(encoded.ext);
    }

    static BOSValue decode(XdrDataInputStream stream)
    {
        BOSValue decoded;
        decoded.txSetHash = Hash.decode(stream);
        decoded.closeTime = stream.readUint64();
        const int upgradessize = stream.readInt32();
        for (int i = 0; i < upgradessize; i++)
        {
            decoded.upgrades ~= UpgradeType.decode(stream);
        }
        decoded.ext = stream.readInt32();
        return decoded;
    }
}
