module owlchain.utils.types;

import core.stdc.stdint;
import gfm.integers.wideint ;

enum Rounding
{
    ROUND_DOWN,
    ROUND_UP
};

bool bigDivide(ref ulong result, ulong A, ulong B, ulong C, Rounding rounding)
{
    // update when moving to (signed) int128
    uwideint!128 a = A;
    uwideint!128 b = B;
    uwideint!128 c = C;
    uwideint!128 x = (rounding == Rounding.ROUND_DOWN) ? (a * b) / c : (a * b + c - 1) / c;

    result = cast(ulong)x;

    return (x <= UINT64_MAX);
}