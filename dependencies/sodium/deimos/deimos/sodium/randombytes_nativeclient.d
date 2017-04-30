/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define randombytes_nativeclient_H
*/

module deimos.sodium.randombytes_nativeclient;

version (__native_client__) {
  import deimos.sodium.randombytes : randombytes_implementation;

  extern(C) extern __gshared randombytes_implementation randombytes_nativeclient_implementation;
}

/*
  My understanding is, that the binary gets compiled either with randombytes_sysrandom_implementation or randombytes_nativeclient_implementation
  as default depending on __native_client__ #defined or not
  and that it is not provided to switch between the default implementations during runtime (the other one is not existant in the binary ?).
  Thus randombytes_set_implementation(randombytes_implementation* impl) is provided to switch to randombytes_salsa20_implementation or
  some other, user-supplied implementation.
  The documented procedure for 'Compilation on Unix-like systems' resulted in a default being randombytes_sysrandom_implementation for me and no
  randombytes_nativeclient_implementation available in the binary.

  Either way, if Your binary's default implemetations is randombytes_nativeclient_implementation and You want to access
  the data struct randombytes_implementation randombytes_nativeclient_implementation,
  then define the dlang version identifier  __native_client__ for the D language build (in this package's dub.json) as well,
  otherwise don't do it. A match is required !
*/
