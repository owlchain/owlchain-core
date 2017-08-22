module owlchain.xdr.owlValue;

import owlchain.xdr.type;
import owlchain.xdr.hash;
import owlchain.xdr.upgradeType;

import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct OwlValue
{
    Hash txSetHash;
    uint64 closeTime;
    UpgradeType[] upgrades;
    int32 ext;

    static void encode(XdrDataOutputStream stream, ref const OwlValue encodedOwlValue)
    {
        Hash.encode(stream, encodedOwlValue.txSetHash);
        stream.writeUint64(encodedOwlValue.closeTime);
        int upgradessize = cast(int)encodedOwlValue.upgrades.length;
        stream.writeInt32(upgradessize);
        for (int i = 0; i < upgradessize; i++) {
            UpgradeType.encode(stream, encodedOwlValue.upgrades[i]);
        }
        stream.writeInt32(encodedOwlValue.ext);
    }

    static OwlValue decode(XdrDataInputStream stream)
    {
        OwlValue decodedOwlValue;
        decodedOwlValue.txSetHash = Hash.decode(stream);
        decodedOwlValue.closeTime = stream.readUint64();
        int upgradessize = stream.readInt32();
        decodedOwlValue.upgrades.length = upgradessize;
        for (int i = 0; i < upgradessize; i++) {
            decodedOwlValue.upgrades[i] = UpgradeType.decode(stream);
        }
        decodedOwlValue.ext = stream.readInt32();
        return decodedOwlValue;
    }
}
