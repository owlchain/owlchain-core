module owlchain.crypto.pubkey;

import std.digest.sha;
import std.digest.ripemd;

/*
   code_string = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
   x = convert_bytes_to_big_integer(hash_result)
   
   output_string = ""
   
   while(x > 0) 
       {
           (x, remainder) = divide(x, 58)
           output_string.append(code_string[remainder])
       }
   
   repeat(number_of_leading_zero_bytes_in_hash)
       {
       output_string.append(code_string[0]);
       }
   
   output_string.reverse();
*/
/**
class Base58{

	static string EncodeMap = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";;

	static ubyte[] encode(scope ubyte[] data) pure {
		auto buf = data.dup;

		foreach(ch, idx; data){
			buf[idx] = EncodeMap[ch % EncodeMap.length];
		}

		return buf;
	}

	static ubyte[] decode(scope ubyte[] encoded) pure {
		auto buf = encoded.dup;

		foreach(ch, idx; encoded){
			buf[idx] = EncodeMap[ch % EncodeMap.length];
		}
		return buf;
	}
}


immutable BITCOIN_BASE58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
immutable RIPPLE_BASE58 = "rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz";
immutable FLICKR_BASE58 = "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
immutable OWL_BASE58 = BITCOIN_BASE58;

//alias Base58 = Base58Impl!(ubyte[]);

ubyte[] bitcoinAddress(scope ubyte[] ver, scope ubyte[] hash) {
    auto payload = ver ~ hash;
    auto checksum = sha2560f(sha256(payload));
    auto bytes = hash ~ checksum[0..4];
    return Base58.encode(bytes);
}

*/
