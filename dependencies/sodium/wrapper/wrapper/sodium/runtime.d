// Written in the D programming language.

module wrapper.sodium.runtime;

import wrapper.sodium.core; // assure sodium got initialized

public import  deimos.sodium.runtime;


@safe
unittest {
  import std.stdio : writeln, writefln;
  writeln ("unittest block 1 from sodium.runtime.d");
  writefln("sodium_runtime_has_neon:   %s",sodium_runtime_has_neon());
  writefln("sodium_runtime_has_sse2:   %s",sodium_runtime_has_sse2());
  writefln("sodium_runtime_has_sse3:   %s",sodium_runtime_has_sse3());
  writefln("sodium_runtime_has_ssse3:  %s",sodium_runtime_has_ssse3());
  writefln("sodium_runtime_has_sse41:  %s",sodium_runtime_has_sse41());
  writefln("sodium_runtime_has_avx:    %s",sodium_runtime_has_avx());
  writefln("sodium_runtime_has_avx2:   %s",sodium_runtime_has_avx2());  // not available in version 1.0.8
  writefln("sodium_runtime_has_pclmul: %s",sodium_runtime_has_pclmul());
  writefln("sodium_runtime_has_aesni:  %s",sodium_runtime_has_aesni());
}