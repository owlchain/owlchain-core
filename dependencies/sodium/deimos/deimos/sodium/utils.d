/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define sodium_utils_H
*/

module deimos.sodium.utils;


extern(C) /*nothrow*/ @nogc @system :


void sodium_memzero(void* pnt, const size_t len) pure nothrow;

/**
 * WARNING: sodium_memcmp() must be used to verify if two secret keys
 * are equal, in constant time.
 * It returns 0 if the keys are equal, and -1 if they differ.
 * This function is not designed for lexicographical comparisons.
 */
int sodium_memcmp(const(void*) b1_, const(void*) b2_, size_t len) pure nothrow; // __attribute__ ((warn_unused_result));

version(LittleEndian) {
  /*
   * sodium_compare() returns -1 if b1_ < b2_, 1 if b1_ > b2_ and 0 if b1_ == b2_
   * It is suitable for lexicographical comparisons, or to compare nonces
   * and counters stored in little-endian format.
   * However, it is slower than sodium_memcmp().
   */
  int sodium_compare(const(ubyte)* b1_, const(ubyte)* b2_,
                     size_t len) pure nothrow; // __attribute__ ((warn_unused_result));
}

/*
 * deviating from the C source, this received attributes equivalent to __attribute__ ((warn_unused_result))
 */
int sodium_is_zero(const(ubyte)* n, const size_t nlen) pure nothrow;

version(LittleEndian) {
  void sodium_increment(ubyte* n, const size_t nlen) pure nothrow;

  void sodium_add(ubyte* a, const(ubyte)* b, const size_t len) pure nothrow;
}

char* sodium_bin2hex(char* hex, const size_t hex_maxlen,
                     const(ubyte*) bin, const size_t bin_len) pure;

int sodium_hex2bin(ubyte* bin, const size_t bin_maxlen,
                   const(char*) hex, const size_t hex_len,
                   const(char*) ignore, size_t* bin_len,
                   const(char)** hex_end) pure;

int sodium_mlock(void* addr, const size_t len) nothrow;

int sodium_munlock(void* addr, const size_t len) nothrow;

/* WARNING: sodium_malloc() and sodium_allocarray() are not general-purpose
 * allocation functions.
 *
 * They return a pointer to a region filled with 0xd0 bytes, immediately
 * followed by a guard page.
 * As a result, accessing a single byte after the requested allocation size
 * will intentionally trigger a segmentation fault.
 *
 * A canary and an additional guard page placed before the beginning of the
 * region may also kill the process if a buffer underflow is detected.
 *
 * The memory layout is:
 * [unprotected region size (read only)][guard page (no access)][unprotected pages (read/write)][guard page (no access)]
 * With the layout of the unprotected pages being:
 * [optional padding][16-bytes canary][user region]
 *
 * However:
 * - These functions are significantly slower than standard functions
 * - Each allocation requires 3 or 4 additional pages
 * - The returned address will not be aligned if the allocation size is not
 *   a multiple of the required alignment. For this reason, these functions
 *   are designed to store data, such as secret keys and messages.
 *
 * sodium_malloc() can be used to allocate any libsodium data structure.
 *
 * The crypto_generichash_state structure is packed and its length is
 * either 357 or 361 bytes. For this reason, when using sodium_malloc() to
 * allocate a crypto_generichash_state structure, padding must be added in
 * order to ensure proper alignment. crypto_generichash_statebytes()
 * returns the rounded up structure size, and should be prefered to sizeof():
 * state = sodium_malloc(crypto_generichash_statebytes());
 */

void* sodium_malloc(const size_t size) nothrow; // __attribute__ ((malloc));

void* sodium_allocarray(size_t count, size_t size) nothrow; // __attribute__ ((malloc));

void sodium_free(void* ptr) nothrow;

int sodium_mprotect_noaccess(void* ptr) nothrow;

int sodium_mprotect_readonly(void* ptr) nothrow;

int sodium_mprotect_readwrite(void* ptr) nothrow;
