**Build state**

[![Build Status](https://travis-ci.org/carblue/sodium.svg?branch=master)](https://travis-ci.org/carblue/sodium)
[![Coverage Status](https://coveralls.io/repos/github/carblue/sodium/badge.svg?branch=master)](https://coveralls.io/github/carblue/sodium?branch=master)

# sodium

Twofold binding to libsodium, current C-source version 1.0.12, released on Mar 12, 2017 [https://github.com/jedisct1/libsodium]

subPackage 'deimos':  Static binding, the "import-only" C header's declarations.<br>
subPackage 'wrapper': 'deimos' + some 'D-friendly' stuff, predominantly overloaded functions and unittests.

dub.json sets dependency sodium:deimos as default. For the 'wrapper' subPackage, explicitely choose dependency:  sodium:wrapper

Some restructuring (subPackages)/changing importPath and sourcePath was done for version 0.1.0 (different from previous 0.08) in order to have the 'wrapper' subPackage sit aside
subPackage 'deimos'.<br>
Thus code that already used versions<0.1.0 needs to replace 'import sodium...' by either 'import deimos.sodium...' or 'import wrapper.sodium...'.

Maybe, usage of 'wrapper' isn't possible, if function randombytes_set_implementation shall be used (or maybe (I did't test that) there is a way to use it before this runs: wrapper.sodium.core:shared static this(), which calls sodium_init()).
The unittests of subPackage 'wrapper' include a lot of function usage examples, the next is a simple application example based on sodium:deimos, using rdmd:<br>

	cd example/source  &&  chmod 775 app.d  &&  ./app.d

Expected output (byte values within brackets differing of course):

Unpredictable sequence of 8 bytes: [52, 225, 21, 245, 74, 66, 192, 247]<br>
crypto_aead_aes256gcm_is_available<br>
ciphertext: [76, 18, 112, 219, 144, 230, 206, 219, 40, 255, 78, 43, 172, 49, 129, 175, 4, 235, 81, 224]


**Heap allocations**:
Quoting the Sodium-manual: "Cryptographic operations in Sodium (C binary) never allocate memory on the heap (malloc, calloc, etc) with the obvious exceptions of crypto_pwhash and sodium_malloc."<br>
The same holds, if usage is restricted to sodium:deimos.<br>
The case is different, more complex with sodium:wrapper: It shall provide more D-convenience and @safe callables making it hard to use functions in a wrong way, but this may involve the heap allocation's cost.<br>
1. The unittests make permissive use of heap allocations by means of GC allocated memory, but don't handle real secrets and aren't meant for release builds, thus no security problem.<br>
2. Most new functions are "overloads" (just D friendly wrappers around the C function calls).<br>
  Some are as simple as taking a D slice and pass it's .ptr and .length to be safe or require a static array to ensure .length, thus don't themselves allocate heap memory and have attribute @nogc (and calling them doesn't postulate heap allocation either; the D slice parameter is welcoming arguments being static arrays as well as dyn. heap allocated arrays).<br>
  Many functions call enforce to ensure, that some requirement is fullfilled, thus may allocate only just before the program bails out.<br>
  The residual: They use heap allocation !
3. Other functions perform convenience procedures or part of procedures shown in the Sodium documentaion, like DH keyexchange and may make generous use of heap memory.

Windows:
While it get's built, I recommend to stay away from the -m32_mscoff (--arch=x86_mscoff) build currently:
1. DUB (1.2.1) doesn't handle that correctly.
2. unittest of wrapper.crypto_aead_aes256gcm.d fails for crypto_aead_aes256gcm_beforenm for some unknown reason (same compiler, code and .dll as for -m32, only import lib/format of .obj/linker differ)
