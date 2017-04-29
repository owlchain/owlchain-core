/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define randombytes_H
*/

module deimos.sodium.randombytes;


extern(C) :


struct randombytes_implementation {
  const(char)* function()                             implementation_name; /* required */
  uint         function()                             random;              /* required */
  void         function()                             stir;                /* optional */
  uint         function(const uint upper_bound)       uniform;             /* optional, a default implementation will be used if null */
  void         function(void* buf, const size_t size) buf;                 /* required */
  int          function()                             close;               /* optional */
}


nothrow @nogc :
/* my understanding of the pure attribute in D is, that the following functions are impure; all depend on hidden global mutable state */


enum ubyte randombytes_SEEDBYTES = 32U;

size_t randombytes_seedbytes() @trusted;

void randombytes_buf(void* buf, const size_t size) @system;

void randombytes_buf_deterministic(void* buf, const size_t size,
                                   ref const(ubyte)[randombytes_SEEDBYTES] seed) @system;

uint randombytes_random() @trusted;

uint randombytes_uniform(const uint upper_bound) @trusted;

void randombytes_stir() @trusted;

int randombytes_close() @trusted;

/** See comment of function randombytes_implementation_name() */
int randombytes_set_implementation(randombytes_implementation* impl) @system;

/**
 * With attribute pure, function randombytes_implementation_name() is allowed to be called only
 * after the last call to randombytes_set_implementation (and this only before sodium_init() is called),
 * otherwise this function is strongly impure because the return value might change !
 * In the wrapper interface, function randombytes_set_implementation() is not allowed to be called at all !
 */
const(char)* randombytes_implementation_name() pure @system;

/* -- NaCl compatibility interface -- */

void randombytes(ubyte* buf, const ulong buf_len) @system;
