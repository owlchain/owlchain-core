module deimos.openssl.whrlpool;

import deimos.openssl._d_util;

public import deimos.openssl.e_os2;
import core.stdc.config;

extern (C):
nothrow:

enum WHIRLPOOL_DIGEST_LENGTH = (512/8);
enum WHIRLPOOL_BBLOCK = 512;
enum WHIRLPOOL_COUNTER = (256/8);

struct WHIRLPOOL_CTX {
	union H_ {
		ubyte[WHIRLPOOL_DIGEST_LENGTH]	c;
		/* double q is here to ensure 64-bit alignment */
		double[WHIRLPOOL_DIGEST_LENGTH/double.sizeof]		q;
		}
	H_ H;
	ubyte[WHIRLPOOL_BBLOCK/8]	data;
	uint	bitoff;
	size_t[WHIRLPOOL_COUNTER/size_t.sizeof]		bitlen;
	};

version(OPENSSL_NO_WHIRLPOOL) {} else {
version(OPENSSL_FIPS) {
    int private_WHIRLPOOL_Init(WHIRLPOOL_CTX* c);
}
int WHIRLPOOL_Init	(WHIRLPOOL_CTX* c);
int WHIRLPOOL_Update	(WHIRLPOOL_CTX* c,const(void)* inp,size_t bytes);
void WHIRLPOOL_BitUpdate(WHIRLPOOL_CTX* c,const(void)* inp,size_t bits);
int WHIRLPOOL_Final	(ubyte* md,WHIRLPOOL_CTX* c);
ubyte* WHIRLPOOL(const(void)* inp,size_t bytes,ubyte* md);
}
