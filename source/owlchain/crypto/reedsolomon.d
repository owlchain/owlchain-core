module owlchain.crypto.reedsolomon;

import std.array : appender;
import std.exception : Exception, enforce;
import std.conv : to;
import std.algorithm : reverse;
import std.bigint : BigInt;
import std.string : indexOf;
import std.stdio : writefln;

/*
Reed Solomon Encoding and Decoding for owlchain
NXT Address - https://nxtwiki.org/wiki/RS_Address_Format
    1.Reed–Solomon error correction 
        - https://en.wikipedia.org/wiki/Reed%E2%80%93Solomon_error_correction
    NXT-3DH5-DSAE-4WQ7-3LPSE
    NXT-K4G2-FF32-WLL3-QBGEL

Owlchain address is a reedsolomon error correction code.
    [SYM]-K4G2-FF32-WLL3-QBGEL
    ex) BOS-K4G2-FF32-WLL3-QBGEL, TRX-K4G2-FF32-WLL3-QBGEL

History:
    1. Version: 1.0, license: Public Domain, coder: NxtChg (admin@nxtchg.com)
        Java Version: ChuckOne (ChuckOne@mail.de).
    2. conversion from java to D language Yezune (knolza2016@gmail.com) 
*/

private
{
    static immutable int[] _INITIAL_CODEWORD = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    static immutable int[] _GEXP = [1, 2, 4, 8, 16, 5, 10, 20, 13, 26, 17, 7,
        14, 28, 29, 31, 27, 19, 3, 6, 12, 24, 21, 15, 30, 25, 23, 11, 22, 9, 18, 1];
    static immutable int[] _GLOG = [0, 0, 1, 18, 2, 5, 19, 11, 3, 29, 6, 27,
        20, 8, 12, 23, 4, 10, 30, 17, 7, 22, 28, 26, 21, 25, 9, 16, 13, 14, 24, 15];
    static immutable int[] _CODEWORK_MAP = [3, 2, 1, 0, 7, 6, 5, 4, 13, 14, 15,
        16, 12, 8, 9, 10, 11];
    static enum _ALPAHBET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    static enum BASE32_LENGTH = 13;
    static enum BASE10_LENGTH = 20;
}

static string encode(long plain)
{

    string plain_string = to!string(plain);
    ulong length = plain_string.length;
    int[] plain_string_10 = new int[BASE10_LENGTH];
    for (int i = 0; i < length; i++)
    {
        plain_string_10[i] = cast(int) plain_string[i] - cast(int) '0';
    }

    int codeword_length = 0;
    int[] codeword = new int[_INITIAL_CODEWORD.length];

    do
    { // base 10 to base 32 conversion
        int new_length = 0;
        int digit_32 = 0;
        for (int i = 0; i < length; i++)
        {
            digit_32 = digit_32 * 10 + plain_string_10[i];
            if (digit_32 >= 32)
            {
                plain_string_10[new_length] = digit_32 >> 5;
                digit_32 &= 31;
                new_length += 1;
            }
            else if (new_length > 0)
            {
                plain_string_10[new_length] = 0;
                new_length += 1;
            }
        }
        length = new_length;
        codeword[codeword_length] = digit_32;
        codeword_length += 1;
    }
    while (length > 0);

    int[] p = [0, 0, 0, 0];
    for (int i = BASE32_LENGTH - 1; i >= 0; i--)
    {
        immutable int fb = codeword[i] ^ p[3];
        p[3] = p[2] ^ gmult(30, fb);
        p[2] = p[1] ^ gmult(6, fb);
        p[1] = p[0] ^ gmult(9, fb);
        p[0] = gmult(17, fb);
    }

    immutable int codeword_base32_end = _INITIAL_CODEWORD.length - BASE32_LENGTH;
    codeword[BASE32_LENGTH .. BASE32_LENGTH + codeword_base32_end] = p[0 .. codeword_base32_end];

    auto cypher_string_builder = appender!string();

    for (int i = 0; i < 17; i++)
    {
        immutable int codework_index = _CODEWORK_MAP[i];
        immutable int alphabet_index = codeword[codework_index];
        cypher_string_builder.put(_ALPAHBET[alphabet_index]);

        //if ((i & 3) == 3 && i < 13) {
        if (((i + 1) % 4) == 0 && i < 13)
        {
            cypher_string_builder.put('-');
        }
    }
    return cypher_string_builder.data;
}

static long decode(string cypher_string)
{

    int[] codeword = _INITIAL_CODEWORD.dup;

    int codeword_length = 0;
    for (int i = 0; i < cypher_string.length; i++)
    {
        immutable position_in_alphabet = _ALPAHBET.indexOf(cypher_string[i]);

        if (position_in_alphabet <= -1 || position_in_alphabet > _ALPAHBET.length)
        {
            continue;
        }

        enforce(codeword_length <= 16);

        int codework_index = _CODEWORK_MAP[codeword_length];
        codeword[codework_index] = cast(int) position_in_alphabet;
        codeword_length += 1;
    }

    enforce((codeword_length != 17 && is_codeword_valid(codeword)) || codeword_length == 17);

    int length = BASE32_LENGTH;
    int[] cypher_string_32 = new int[length];
    for (int i = 0; i < length; i++)
    {
        cypher_string_32[i] = codeword[length - i - 1];
    }

    auto plain_string_builder = appender!string();
    do
    { // base 32 to base 10 conversion
        int new_length = 0;
        int digit_10 = 0;

        for (int i = 0; i < length; i++)
        {
            digit_10 = digit_10 * 32 + cypher_string_32[i];

            if (digit_10 >= 10)
            {
                cypher_string_32[new_length] = digit_10 / 10;
                digit_10 %= 10;
                new_length += 1;
            }
            else if (new_length > 0)
            {
                cypher_string_32[new_length] = 0;
                new_length += 1;
            }
        }
        length = new_length;
        plain_string_builder.put(cast(char)(digit_10 + cast(int) '0'));
    }
    while (length > 0);

    BigInt bigInt = BigInt( plain_string_builder.data.dup.reverse );
    
    return bigInt.toLong();
}

private static int gmult(int a, int b)
{
    if (a == 0 || b == 0)
    {
        return 0;
    }

    immutable idx = (_GLOG[a] + _GLOG[b]) % 31;

    return _GEXP[idx];
}

private static bool is_codeword_valid(int[] codeword)
{
    int sum = 0;

    for (int i = 1; i < 5; i++)
    {
        int t = 0;

        for (int j = 0; j < 31; j++)
        {
            if (j > 12 && j < 27)
            {
                continue;
            }

            int pos = j;
            if (j > 26)
            {
                pos -= 14;
            }

            t ^= gmult(codeword[pos], _GEXP[(i * j) % 31]);
        }

        sum |= t;
    }
    return sum == 0;
}
@system
unittest
{
    struct TA
    {
        long v;
        string rs;
    }

    TA[] test_accounts = [
    {
        8_264_278_205_416_377_583L, "K59H-9RMF-64CY-9X6E7"
    }, 
    {
        8_301_188_658_053_077_183L, "4Q7Z-5BEE-F5JZ-9ZXE8"
    }, 
    {
        1_798_923_958_688_893_959L, "GM29-TWRT-M5CK-3HSXK"
    }, 
    {
        6_899_983_965_971_136_120L, "MHMS-VHZT-W5CY-7CFJZ"
    }, 
    {
        1_629_938_923_029_941_274L, "JM2U-U4AE-G7WF-3NP9F"
    }, 
    {
        6_474_206_656_034_063_375L, "4K2H-NVHQ-7WXY-72AQM"
    }, 
    {
        1_691_406_066_100_673_814L, "Y9AQ-VE8F-U9SY-3NAYG"
    }, 
    {
        2_992_669_254_877_342_352L, "6UNJ-UMFM-Z525-4S24M"
    }, 
    {
        43_918_951_749_449_909L, "XY7P-3R8Y-26FC-2A293"
    }, 
    {
        9_129_355_674_909_631_300L, "YSU6-MRRL-NSC4-9WHEX"
    }, 
    {
        0L, "2222-2222-2222-22222"
    }, 
    {
        1L, "2223-2222-KB8Y-22222"
    }, 
    {
        10L, "222C-2222-VJTL-22222"
    }, 
    {
        100L, "2256-2222-QFKF-22222"
    }, 
    {
        1000L, "22ZA-2222-ZK43-22222"
    }, 
    {
        10_000L, "2BSJ-2222-KC3Y-22222"
    }, 
    {
        100_000L, "53P2-2222-SQQW-22222"
    }, 
    {
        1_000_000L, "YJL2-2222-ZZPC-22222"
    }, 
    {
        10_000_000L, "K7N2-222B-FVFG-22222"
    }, 
    {
        100_000_000L, "DSA2-224Z-849U-22222"
    }, 
    {
        1_000_000_000L, "PLJ2-22XT-DVNG-22222"
    }, 
    {
        10_000_000_000L, "RT22-2BC2-SMPD-22222"
    }, 
    {
        100_000_000_000L, "FU22-4X69-74VX-22222"
    }, 
    {
        1_000_000_000_000L, "C622-X5CC-EMM8-22222"
    }, 
    {
        10_000_000_000_000L, "7A22-5399-RNFK-2B222"
    }, 
    {
        100_000_000_000_000L, "NJ22-YEA9-KWDV-2U422"
    }, 
    {
        1_000_000_000_000_000L, "F222-HULE-NWMS-2FW22"
    }, 
    {
        10_000_000_000_000_000L, "4222-YBRW-T4XW-28WA2"
    }, 
    {
        100_000_000_000_000_000L, "N222-H3GS-QPZD-27US4"
    }, 
    {
        1_000_000_000_000_000_000L, "A222-QGMQ-WDH2-2Q7SV"
    }
    ];

    foreach (TA test_account; test_accounts)
    {
        // writefln(encode(test_account.v));
        assert(encode(test_account.v) == test_account.rs);
        assert(decode(test_account.rs) == test_account.v);
        writefln("Success: " ~ to!string(test_account.v) ~ " == " ~ test_account.rs);
    }
}

long decodeWithPrefix(string prefix, string cypher_string)
{
    auto dash_pos = cypher_string.indexOf("-");
    enforce(prefix == cypher_string[0 .. dash_pos]);

    return decode(cypher_string[dash_pos + 1 .. $]);
}

string encodeWithPrefix(string prefix, long plain)
{
    return prefix ~ "-" ~ encode(plain);
}

@system
unittest
{
    assert(encodeWithPrefix("BOS", 1_000_000_000_000_000_000L) == "BOS-A222-QGMQ-WDH2-2Q7SV");
    assert(decodeWithPrefix("BOS", "BOS-A222-QGMQ-WDH2-2Q7SV") == 1_000_000_000_000_000_000L);
}
