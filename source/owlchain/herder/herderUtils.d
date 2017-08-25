module owlchain.herder.herderUtils;

import owlchain.xdr.type;
import owlchain.xdr.bcpStatement;
import owlchain.xdr.bcpStatementType;
import owlchain.xdr.hash;
import owlchain.xdr.bcpEnvelope;
import owlchain.xdr.value;
import owlchain.xdr.bosValue;
import owlchain.consensus.slot;

import owlchain.xdr.xdrDataOutputStream;
import owlchain.xdr.xdrDataInputStream;

Hash[]  
getTxSetHashes(ref BCPEnvelope envelope)
{
    BOSValue[] values = getBOSValues(envelope.statement);
    Hash [] res;

    for (int idx = 0; idx < values.length; idx++)
    {
        res ~= values[idx].txSetHash;
    }
    return res;
}

BOSValue[]
getBOSValues(ref BCPStatement statement)
{
    Value[] values = Slot.getStatementValues(statement);
    BOSValue[] res;
    BOSValue wb;

    XdrDataInputStream stream = new XdrDataInputStream();
    for (int idx = 0; idx < values.length; idx++)
    {
        stream.assign(xdr!Value.serialize(values[idx]));
        wb = BOSValue.decode(stream);
        res ~= wb;
    }

    return res;
}