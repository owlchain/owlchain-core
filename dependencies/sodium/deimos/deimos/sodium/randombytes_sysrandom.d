/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define randombytes_sysrandom_H
*/

module deimos.sodium.randombytes_sysrandom;

import deimos.sodium.randombytes : randombytes_implementation;


extern(C) extern __gshared randombytes_implementation randombytes_sysrandom_implementation;
