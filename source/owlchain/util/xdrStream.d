module owlchain.util.xdrStream;

import owlchain.crypto.hex;
import owlchain.crypto.sha;

/**
 * Helper for loading a sequence of XDR objects from a file one at a time,
 * rather than all at once.
 */
class XDRInputFileStream
{



}


class XDROutputFileStream
{
public:

    template M(T)
    {
        bool writeOne(ref T t, SHA256 * hasher = null, size_t* bytesPut = null)
        {
            return true;
        }
    }
}