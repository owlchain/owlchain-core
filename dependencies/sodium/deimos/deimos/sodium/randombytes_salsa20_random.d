/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define randombytes_salsa20_random_H
*/

module deimos.sodium.randombytes_salsa20_random;

import deimos.sodium.randombytes : randombytes_implementation;


extern(C) extern __gshared randombytes_implementation randombytes_salsa20_implementation;
