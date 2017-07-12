module owlchain.xdr.statementType;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

struct StatementType
{
    enum
    {
        int32 CP_ST_PREPARE = 0,
        int32 CP_ST_CONFIRM = 1,
        int32 CP_ST_EXTERNALIZE = 2,
        int32 CP_ST_NOMINATE = 3
    }

    int32 val;

    this(int32 value)
    {
        val = value;
    }

    static void encode(XdrDataOutputStream stream, ref const StatementType value)
    {
        stream.writeInt32(value.val);
    }

    static StatementType decode(XdrDataInputStream stream)
    {
        int32 value = stream.readInt32();
        switch (value) {
            case 0: return StatementType(StatementType.CP_ST_PREPARE);
            case 1: return StatementType(StatementType.CP_ST_CONFIRM);
            case 2: return StatementType(StatementType.CP_ST_EXTERNALIZE);
            case 3: return StatementType(StatementType.CP_ST_NOMINATE);
            default:
                throw new Exception("Unknown enum value");
        }
    }
}
