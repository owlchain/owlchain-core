/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define sodium_core_H
*/

module deimos.sodium.core;

//version(DigitalMars) { pragma(lib, "sodium"); } // In order to come into effect, DUB has to be invoked with option dub build --build-mode=allAtOnce  or e.g. DMD invoked omitting the -c switch


extern(C) int sodium_init() nothrow @nogc @trusted; // __attribute__ ((warn_unused_result))
