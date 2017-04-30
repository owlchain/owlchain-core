/* ====================================================================
 * Copyright (c) 2008 The OpenSSL Project. All rights reserved.
 *
 * Rights for redistribution and usage in source and binary
 * forms are granted according to the OpenSSL license.
 */
module deimos.openssl.modes;

import deimos.openssl._d_util;

import core.stdc.config;

alias ExternC!(void function(const(ubyte[16])* in_,
			ubyte[16]* out_,
			const(void)* key)) block128_f;

alias ExternC!(void function(const(ubyte)* in_, ubyte* out_,
			size_t blocks, const(void)* key,
			const(ubyte[16])* ivec)) ctr128_f;

alias ExternC!(void function(const(ubyte)* in_, ubyte* out_,
			size_t blocks, const(void)* key,
			const(ubyte[16])* ivec, ubyte[16]* cmac)) ccm128_f;

alias ExternC!(void function(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, int enc)) cbc128_f;

void CRYPTO_cbc128_encrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, block128_f block);
void CRYPTO_cbc128_decrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, block128_f block);

void CRYPTO_ctr128_encrypt_ctr32(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, ubyte[16]* ecount_buf,
			uint *num, ctr128_f ctr);

void CRYPTO_ctr128_encrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, ubyte[16]* ecount_buf,
			uint* num, block128_f block);

void CRYPTO_ofb128_encrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, int* num,
			block128_f block);

void CRYPTO_cfb128_encrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, int* num,
			int enc, block128_f block);
void CRYPTO_cfb128_8_encrypt(const(ubyte)* in_, ubyte* out_,
			size_t length, const(void)* key,
			ubyte[16]* ivec, int* num,
			int enc, block128_f block);
void CRYPTO_cfb128_1_encrypt(const(ubyte)* in_, ubyte* out_,
			size_t bits, const(void)* key,
			ubyte[16]* ivec, int* num,
			int enc, block128_f block);

size_t CRYPTO_cts128_encrypt_block(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, block128_f block);
size_t CRYPTO_cts128_encrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, cbc128_f cbc);
size_t CRYPTO_cts128_decrypt_block(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, block128_f block);
size_t CRYPTO_cts128_decrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const(void)* key,
			ubyte[16]* ivec, cbc128_f cbc);

size_t CRYPTO_nistcts128_encrypt_block(const(ubyte)* in_, ubyte* out_,
			size_t len, const void *key,
			ubyte[16]* ivec, block128_f block);
size_t CRYPTO_nistcts128_encrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const void *key,
			ubyte[16]* ivec, cbc128_f cbc);
size_t CRYPTO_nistcts128_decrypt_block(const(ubyte)* in_, ubyte* out_,
			size_t len, const void *key,
			ubyte[16]* ivec, block128_f block);
size_t CRYPTO_nistcts128_decrypt(const(ubyte)* in_, ubyte* out_,
			size_t len, const void *key,
			ubyte[16]* ivec, cbc128_f cbc);

struct gcm128_context;
alias gcm128_context GCM128_CONTEXT;

GCM128_CONTEXT *CRYPTO_gcm128_new(void *key, block128_f block);
void CRYPTO_gcm128_init(GCM128_CONTEXT *ctx,void *key,block128_f block);
void CRYPTO_gcm128_setiv(GCM128_CONTEXT *ctx, const(ubyte)* iv,
			size_t len);
int CRYPTO_gcm128_aad(GCM128_CONTEXT *ctx, const(ubyte)* aad,
			size_t len);
int CRYPTO_gcm128_encrypt(GCM128_CONTEXT *ctx,
			const(ubyte)* in_, ubyte* out_,
			size_t len);
int CRYPTO_gcm128_decrypt(GCM128_CONTEXT *ctx,
			const(ubyte)* in_, ubyte* out_,
			size_t len);
int CRYPTO_gcm128_encrypt_ctr32(GCM128_CONTEXT *ctx,
			const(ubyte)* in_, ubyte* out_,
			size_t len, ctr128_f stream);
int CRYPTO_gcm128_decrypt_ctr32(GCM128_CONTEXT *ctx,
			const(ubyte)* in_, ubyte* out_,
			size_t len, ctr128_f stream);
int CRYPTO_gcm128_finish(GCM128_CONTEXT *ctx,const(ubyte)* tag,
			size_t len);
void CRYPTO_gcm128_tag(GCM128_CONTEXT *ctx, ubyte* tag, size_t len);
void CRYPTO_gcm128_release(GCM128_CONTEXT *ctx);

struct ccm128_context;
alias ccm128_context CCM128_CONTEXT;

void CRYPTO_ccm128_init(CCM128_CONTEXT *ctx,
	uint M, uint L, void *key,block128_f block);
int CRYPTO_ccm128_setiv(CCM128_CONTEXT *ctx,
	const(ubyte)* nonce, size_t nlen, size_t mlen);
void CRYPTO_ccm128_aad(CCM128_CONTEXT *ctx,
	const(ubyte)* aad, size_t alen);
int CRYPTO_ccm128_encrypt(CCM128_CONTEXT *ctx,
	const(ubyte)* inp, ubyte* out_, size_t len);
int CRYPTO_ccm128_decrypt(CCM128_CONTEXT *ctx,
	const(ubyte)* inp, ubyte* out_, size_t len);
int CRYPTO_ccm128_encrypt_ccm64(CCM128_CONTEXT *ctx,
	const(ubyte)* inp, ubyte* out_, size_t len,
	ccm128_f stream);
int CRYPTO_ccm128_decrypt_ccm64(CCM128_CONTEXT *ctx,
	const(ubyte)* inp, ubyte* out_, size_t len,
	ccm128_f stream);
size_t CRYPTO_ccm128_tag(CCM128_CONTEXT* ctx, ubyte* tag, size_t len);

struct xts128_context;
alias xts128_context XTS128_CONTEXT;

int CRYPTO_xts128_encrypt(const(XTS128_CONTEXT)* ctx, const(ubyte[16])* iv,
	const(ubyte)* inp, ubyte* out_, size_t len, int enc);
