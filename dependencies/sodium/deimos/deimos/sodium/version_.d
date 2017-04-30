/*
Written in the D programming language.
For git maintenance (ensure at least one congruent line with originating C header):
#define sodium_version_H
*/

module deimos.sodium.version_;

enum SODIUM_VERSION_STRING = "1.0.12";

enum SODIUM_LIBRARY_VERSION_MAJOR = 9;
enum SODIUM_LIBRARY_VERSION_MINOR = 4;


/*
 * The only reason for commenting-out the FunctionAttribute nothrow is this conflict:
 * All following C functions don't return void and effectively are strongly pure nothrow AND DON'T declare  __attribute__ ((warn_unused_result)) ! But,
 * Since DMD 2.066.0, compiler switch -w warns about an unused return value of a strongly pure nothrow function call,
 * thus these C function signatures can't be translated exactly to D, if compiler switch -w is thrown (assumed to be the case, e.g. it's the default for dub).
 *
 * Preference is given then here and in other headers, to express pure and the lack of  __attribute__ ((warn_unused_result))
 *
 */
extern(C) pure /*nothrow*/ @nogc :


const(char)* sodium_version_string() @system;

int          sodium_library_version_major() @trusted;

int          sodium_library_version_minor() @trusted;

int          sodium_library_minimal() @trusted;
