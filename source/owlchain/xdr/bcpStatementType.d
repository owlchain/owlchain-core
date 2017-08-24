module owlchain.xdr.bcpStatementType;

import owlchain.xdr.type;
import owlchain.xdr.xdrDataInputStream;
import owlchain.xdr.xdrDataOutputStream;

enum BCPStatementType
{
    CP_ST_PREPARE = 0,
    CP_ST_CONFIRM = 1,
    CP_ST_EXTERNALIZE = 2,
    CP_ST_NOMINATE = 3
}
