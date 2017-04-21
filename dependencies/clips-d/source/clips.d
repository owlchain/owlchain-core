/* Converted to D from clips.h by htod */
module clips;
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                   API HEADER FILE                   */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added filertr.h and tmpltfun.h to include      */
/*            list.                                          */
/*                                                           */
/*      6.30: Added classpsr.h, iofun.h, and strngrtr.h to   */
/*            include list.                                  */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_API
//C     #define _H_API

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
import core.stdc.stdio;
//C     #endif

//C     #include "setup.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/05/15            */
   /*                                                     */
   /*                  SETUP HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: This file is the general header file included by */
/*   all of the .c source files. It contains global          */
/*   definitions and the compiler flags which must be edited */
/*   to create a version for a specific machine, operating   */
/*   system, or feature set.                                 */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Default locale modification.                   */
/*                                                           */
/*            Removed CONFLICT_RESOLUTION_STRATEGIES,        */
/*            DYNAMIC_SALIENCE, INCREMENTAL_RESET,           */
/*            LOGICAL_DEPENDENCIES, IMPERATIVE_METHODS,      */
/*            INSTANCE_PATTERN_MATCHING, and                 */
/*            IMPERATIVE_MESSAGE_HANDLERS, and               */
/*            AUXILIARY_MESSAGE_HANDLERS compilation flags.  */
/*                                                           */
/*            Removed the SHORT_LINK_NAMES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, IBM_ICB, IBM_TBC, IBM_ZTC, and        */
/*            IBM_SC).                                       */
/*                                                           */
/*            Renamed IBM_MSC and WIN_MVC compiler flags     */
/*            and IBM_GCC to WIN_GCC.                        */
/*                                                           */
/*            Added LINUX and DARWIN compiler flags.         */
/*                                                           */
/*            Removed HELP_FUNCTIONS compilation flag and    */
/*            associated functionality.                      */
/*                                                           */
/*            Removed EMACS_EDITOR compilation flag and      */
/*            associated functionality.                      */
/*                                                           */
/*            Combined BASIC_IO and EXT_IO compilation       */
/*            flags into the single IO_FUNCTIONS flag.       */
/*                                                           */
/*            Used #ifndef for preprocessor definitions so   */
/*            they can be set at the project or makefile     */
/*            level.                                         */
/*                                                           */
/*            Removed ENVIRONMENT_API_ONLY compilation flag. */
/*                                                           */
/*            Combined BASIC_IO and EXT_IO compilation       */
/*            flags into the IO_FUNCTIONS compilation flag.  */
/*                                                           */
    
/*            Changed the EX_MATH compilation flag to        */
/*            EXTENDED_MATH_FUNCTIONS.                       */
/*                                                           */
/*            Removed VOID definition because of conflict    */
/*            with Windows.h header file.                    */
/*                                                           */
    
/*            Removed deprecated definitions.                */
/*                                                           */
/*            The ALLOW_ENVIRONMENT_GLOBALS flag now         */
/*            defaults to 0. The use of functions enabled    */
/*            by this flag is deprecated.                    */
/*                                                           */
/*            Removed support for BLOCK_MEMORY.              */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_setup
//C     #define _H_setup

/****************************************************************/
/* -------------------- COMPILER FLAGS ------------------------ */
/****************************************************************/

/*********************************************************************/
/* Flag denoting the environment in which the executable is to run.  */
/* Only one of these flags should be turned on (set to 1) at a time. */
/*********************************************************************/

//C     #ifndef UNIX_V
//C     #define UNIX_V  0   /* UNIX System V, 4.2bsd, or HP Unix, presumably with gcc */
//C     #endif
const UNIX_V = 0;

//C     #ifndef UNIX_7
//C     #define UNIX_7  0   /* UNIX System III Version 7 or Sun Unix, presumably with gcc */
//C     #endif
const UNIX_7 = 0;

//C     #ifndef LINUX
//C     #define LINUX   0   /* Untested, presumably with gcc */
//C     #endif
const LINUX = 0;

//C     #ifndef DARWIN
//C     #define DARWIN  0   /* Darwin Mac OS 10.10.2, presumably with gcc or Xcode 6.2 with Console */
//C     #endif
const DARWIN = 0;

//C     #ifndef MAC_XCD
//C     #define MAC_XCD 0   /* MacOS 10.10.2, with Xcode 6.2 and Cocoa GUI */
//C     #endif
const MAC_XCD = 0;

//C     #ifndef WIN_MVC
//C     #define WIN_MVC 0   /* Windows 7, with Visual Studio 2013 */
//C     #endif
const WIN_MVC = 0;

/* The following are unsupported: */

//C     #ifndef WIN_GCC
//C     #define WIN_GCC 0   /* Windows XP, with DJGPP 3.21 */
//C     #endif
const WIN_GCC = 0;

//C     #ifndef VAX_VMS                    
//C     #define VAX_VMS 0   /* VAX VMS */
//C     #endif
const VAX_VMS = 0;

/* Use GENERIC if nothing else is used. */

//C     #ifndef GENERIC
//C     #if (! UNIX_V) && (! LINUX) && (! UNIX_7) &&     (! MAC_XCD) && (! DARWIN) &&     (! WIN_MVC) && (! WIN_GCC) &&     (! VAX_VMS)
//C     #define GENERIC 1   /* Generic (any machine)                   */
//C     #else
const GENERIC = 1;
//C     #define GENERIC 0   /* Generic (any machine)                   */
//C     #endif
//C     #endif

//C     #if WIN_MVC
//C     #define IBM 1
//C     #else
//C     #define IBM 0
//C     #endif
const IBM = 0;

/***********************************************/
/* Some definitions for use with declarations. */
/***********************************************/

//C     #define VOID_ARG void
//C     #define STD_SIZE size_t
alias void VOID_ARG;

alias size_t STD_SIZE;
//C     #define intBool int
//C     #define globle
alias int intBool;

/*******************************************/
/* RUN_TIME:  Specifies whether a run-time */
/*   module is being created.              */
/*******************************************/

//C     #ifndef RUN_TIME
//C     #define RUN_TIME 0
//C     #endif
const RUN_TIME = 0;

/*************************************************/
/* DEFRULE_CONSTRUCT: Determines whether defrule */
/*   construct is included.                      */
/*************************************************/

//C     #ifndef DEFRULE_CONSTRUCT
//C     #define DEFRULE_CONSTRUCT 1
//C     #endif
const DEFRULE_CONSTRUCT = 1;

/************************************************/
/* DEFMODULE_CONSTRUCT:  Determines whether the */
/*   defmodule construct is included.           */
/************************************************/

//C     #ifndef DEFMODULE_CONSTRUCT
//C     #define DEFMODULE_CONSTRUCT 1
//C     #endif
const DEFMODULE_CONSTRUCT = 1;

/****************************************************/
/* DEFTEMPLATE_CONSTRUCT:  Determines whether facts */
/*   and the deftemplate construct are included.    */
/****************************************************/

//C     #ifndef DEFTEMPLATE_CONSTRUCT
//C     #define DEFTEMPLATE_CONSTRUCT 1
//C     #endif
const DEFTEMPLATE_CONSTRUCT = 1;

//C     #if ! DEFRULE_CONSTRUCT
//C     #undef DEFTEMPLATE_CONSTRUCT
//C     #define DEFTEMPLATE_CONSTRUCT 0
//C     #endif

/************************************************************/
/* FACT_SET_QUERIES: Determines if fact-set query functions */
/*  such as any-factp and do-for-all-facts are included.    */
/************************************************************/

//C     #ifndef FACT_SET_QUERIES
//C     #define FACT_SET_QUERIES 1
//C     #endif
const FACT_SET_QUERIES = 1;

//C     #if ! DEFTEMPLATE_CONSTRUCT
//C     #undef FACT_SET_QUERIES
//C     #define FACT_SET_QUERIES        0
//C     #endif

/****************************************************/
/* DEFFACTS_CONSTRUCT:  Determines whether deffacts */
/*   construct is included.                         */
/****************************************************/

//C     #ifndef DEFFACTS_CONSTRUCT
//C     #define DEFFACTS_CONSTRUCT 1
//C     #endif
const DEFFACTS_CONSTRUCT = 1;

//C     #if ! DEFTEMPLATE_CONSTRUCT
//C     #undef DEFFACTS_CONSTRUCT
//C     #define DEFFACTS_CONSTRUCT 0
//C     #endif

/************************************************/
/* DEFGLOBAL_CONSTRUCT:  Determines whether the */
/*   defglobal construct is included.           */
/************************************************/

//C     #ifndef DEFGLOBAL_CONSTRUCT
//C     #define DEFGLOBAL_CONSTRUCT 1
//C     #endif
const DEFGLOBAL_CONSTRUCT = 1;

/**********************************************/
/* DEFFUNCTION_CONSTRUCT:  Determines whether */
/*   deffunction construct is included.       */
/**********************************************/

//C     #ifndef DEFFUNCTION_CONSTRUCT
//C     #define DEFFUNCTION_CONSTRUCT 1
//C     #endif
const DEFFUNCTION_CONSTRUCT = 1;

/*********************************************/
/* DEFGENERIC_CONSTRUCT:  Determines whether */
/*   generic functions  are included.        */
/*********************************************/

//C     #ifndef DEFGENERIC_CONSTRUCT
//C     #define DEFGENERIC_CONSTRUCT 1
//C     #endif
const DEFGENERIC_CONSTRUCT = 1;

/*****************************************************************/
/* OBJECT_SYSTEM:  Determines whether object system is included. */
/*   The MULTIFIELD_FUNCTIONS flag should also be on if you want */
/*   to be able to manipulate multi-field slots.                 */
/*****************************************************************/

//C     #ifndef OBJECT_SYSTEM
//C     #define OBJECT_SYSTEM 1
//C     #endif
const OBJECT_SYSTEM = 1;

/*****************************************************************/
/* DEFINSTANCES_CONSTRUCT: Determines whether the definstances   */
/*   construct is enabled.                                       */
/*****************************************************************/

//C     #ifndef DEFINSTANCES_CONSTRUCT
//C     #define DEFINSTANCES_CONSTRUCT      1
//C     #endif
const DEFINSTANCES_CONSTRUCT = 1;

//C     #if ! OBJECT_SYSTEM
//C     #undef DEFINSTANCES_CONSTRUCT
//C     #define DEFINSTANCES_CONSTRUCT      0
//C     #endif

/********************************************************************/
/* INSTANCE_SET_QUERIES: Determines if instance-set query functions */
/*  such as any-instancep and do-for-all-instances are included.    */
/********************************************************************/

//C     #ifndef INSTANCE_SET_QUERIES
//C     #define INSTANCE_SET_QUERIES 1
//C     #endif
const INSTANCE_SET_QUERIES = 1;

//C     #if ! OBJECT_SYSTEM
//C     #undef INSTANCE_SET_QUERIES
//C     #define INSTANCE_SET_QUERIES        0
//C     #endif

/******************************************************************/
/* Check for consistencies associated with the defrule construct. */
/******************************************************************/

//C     #if (! DEFTEMPLATE_CONSTRUCT) && (! OBJECT_SYSTEM)
//C     #undef DEFRULE_CONSTRUCT
//C     #define DEFRULE_CONSTRUCT 0
//C     #endif

/*******************************************************************/
/* BLOAD/BSAVE_INSTANCES: Determines if the save/restore-instances */
/*  functions can be enhanced to perform more quickly by using     */
/*  binary files                                                   */
/*******************************************************************/

//C     #ifndef BLOAD_INSTANCES
//C     #define BLOAD_INSTANCES 1
//C     #endif
const BLOAD_INSTANCES = 1;
//C     #ifndef BSAVE_INSTANCES
//C     #define BSAVE_INSTANCES 1
//C     #endif
const BSAVE_INSTANCES = 1;

//C     #if ! OBJECT_SYSTEM
//C     #undef BLOAD_INSTANCES
//C     #undef BSAVE_INSTANCES
//C     #define BLOAD_INSTANCES             0
//C     #define BSAVE_INSTANCES             0
//C     #endif

/****************************************************************/
/* EXTENDED MATH PACKAGE FLAG: If this is on, then the extended */
/* math package functions will be available for use, (normal    */
/* default). If this flag is off, then the extended math        */
/* functions will not be available, and the 30K or so of space  */
/* they require will be free. Usually a concern only on PC type */
/* machines.                                                    */
/****************************************************************/

//C     #ifndef EXTENDED_MATH_FUNCTIONS
//C     #define EXTENDED_MATH_FUNCTIONS 1
//C     #endif
const EXTENDED_MATH_FUNCTIONS = 1;

/****************************************************************/
/* TEXT PROCESSING : Turn on this flag for support of the       */
/* hierarchical lookup system.                                  */
/****************************************************************/

//C     #ifndef TEXTPRO_FUNCTIONS
//C     #define TEXTPRO_FUNCTIONS 1
//C     #endif
const TEXTPRO_FUNCTIONS = 1;

/*************************************************************************/
/* BLOAD_ONLY:      Enables bload command and disables the load command. */
/* BLOAD:           Enables bload command.                               */
/* BLOAD_AND_BSAVE: Enables bload, and bsave commands.                   */
/*************************************************************************/

//C     #ifndef BLOAD_ONLY
//C     #define BLOAD_ONLY 0
//C     #endif
const BLOAD_ONLY = 0;
//C     #ifndef BLOAD
//C     #define BLOAD 0
//C     #endif
const BLOAD = 0;
//C     #ifndef BLOAD_AND_BSAVE
//C     #define BLOAD_AND_BSAVE 1
//C     #endif
const BLOAD_AND_BSAVE = 1;

//C     #if RUN_TIME
//C     #undef BLOAD_ONLY
//C     #define BLOAD_ONLY      0
//C     #undef BLOAD
//C     #define BLOAD           0
//C     #undef BLOAD_AND_BSAVE
//C     #define BLOAD_AND_BSAVE 0
//C     #endif

/********************************************************************/
/* CONSTRUCT COMPILER: If this flag is turned on, you can generate  */
/*   C code representing the constructs in the current environment. */
/*   With the RUN_TIME flag set, this code can be compiled and      */
/*   linked to create a stand-alone run-time executable.            */
/********************************************************************/

//C     #ifndef CONSTRUCT_COMPILER
//C     #define  CONSTRUCT_COMPILER 1
//C     #endif
const CONSTRUCT_COMPILER = 1;

//C     #if CONSTRUCT_COMPILER
//C     #define API_HEADER "clips.h"
//C     #endif

/************************************************/
/* IO_FUNCTIONS: Includes printout, read, open, */
/*   close, format, and readline functions.     */
/************************************************/

//C     #ifndef IO_FUNCTIONS
//C     #define IO_FUNCTIONS 1
//C     #endif
const IO_FUNCTIONS = 1;

/************************************************/
/* STRING_FUNCTIONS: Includes string functions: */
/*   str-length, str-compare, upcase, lowcase,  */
/*   sub-string, str-index, and eval.           */
/************************************************/

//C     #ifndef STRING_FUNCTIONS
//C     #define STRING_FUNCTIONS 1
//C     #endif
const STRING_FUNCTIONS = 1;

/*********************************************/
/* MULTIFIELD_FUNCTIONS: Includes multifield */
/*   functions:  mv-subseq, mv-delete,       */
/*   mv-append, str-explode, str-implode.    */
/*********************************************/

//C     #ifndef MULTIFIELD_FUNCTIONS
//C     #define MULTIFIELD_FUNCTIONS 1
//C     #endif
const MULTIFIELD_FUNCTIONS = 1;

/****************************************************/
/* DEBUGGING_FUNCTIONS: Includes functions such as  */
/*   rules, facts, matches, ppdefrule, etc.         */
/****************************************************/

//C     #ifndef DEBUGGING_FUNCTIONS
//C     #define DEBUGGING_FUNCTIONS 1
//C     #endif
const DEBUGGING_FUNCTIONS = 1;

/***************************************************/
/* PROFILING_FUNCTIONS: Enables code for profiling */
/*   constructs and user functions.                */
/***************************************************/

//C     #ifndef PROFILING_FUNCTIONS
//C     #define PROFILING_FUNCTIONS 1
//C     #endif
const PROFILING_FUNCTIONS = 1;

/*******************************************************************/
/* WINDOW_INTERFACE : Set this flag if you are recompiling any of  */
/*   the machine specific GUI interfaces. Currently, when enabled, */
/*   this flag disables the more processing used by the help       */
/*   system. This flag also prevents any input or output being     */
/*   directly sent to stdin or stdout.                             */
/*******************************************************************/

//C     #ifndef WINDOW_INTERFACE
//C     #define WINDOW_INTERFACE 0
//C     #endif
const WINDOW_INTERFACE = 0;

/*************************************************************/
/* ALLOW_ENVIRONMENT_GLOBALS: If enabled, tracks the current */
/*   environment and allows environments to be referred to   */
/*   by index. If disabled, CLIPS makes no use of global     */
/*   variables.                                              */
/*************************************************************/

//C     #ifndef ALLOW_ENVIRONMENT_GLOBALS
//C     #define ALLOW_ENVIRONMENT_GLOBALS 0
//C     #endif
const ALLOW_ENVIRONMENT_GLOBALS = 0;

/********************************************/
/* DEVELOPER: Enables code for debugging a  */
/*   development version of the executable. */
/********************************************/

//C     #ifndef DEVELOPER
//C     #define DEVELOPER 0
//C     #endif
const DEVELOPER = 0;

//C     #if DEVELOPER
//C     #include <assert.h>
//C     #define Bogus(x) assert(! (x))
//C     #else
//C     #define Bogus(x)
//C     #endif

/***************************/
/* Environment Definitions */
/***************************/

//C     #include "envrnmnt.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                ENVRNMNT HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for supporting multiple environments.   */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added code to CreateEnvironment to free        */
/*            already allocated data if one of the malloc    */
/*            calls fail.                                    */
/*                                                           */
/*            Modified AllocateEnvironmentData to print a    */
/*            message if it was unable to allocate memory.   */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added CreateRuntimeEnvironment function.       */
/*                                                           */
/*            Added support for context information when an  */
/*            environment is created (i.e a pointer from the */
/*            CLIPS environment to its parent environment).  */
/*                                                           */
/*      6.30: Added support for passing context information  */
 
/*            to user defined functions and callback         */
/*            functions.                                     */
/*                                                           */
/*            Support for hashing EXTERNAL_ADDRESS data      */
/*            type.                                          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_envrnmnt
//C     #define _H_envrnmnt

//C     #ifndef _H_symbol
//C     #include "symbol.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/03/15            */
   /*                                                     */
   /*                 SYMBOL HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Manages the atomic data value hash tables for    */
/*   storing symbols, integers, floats, and bit maps.        */
/*   Contains routines for adding entries, examining the     */
/*   hash tables, and performing garbage collection to       */
/*   remove entries no longer in use.                        */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: CLIPS crashing on AMD64 processor in the       */
/*            function used to generate a hash value for     */
/*            integers. DR0871                               */
/*                                                           */
/*            Support for run-time programs directly passing */
/*            the hash tables for initialization.            */
/*                                                           */
/*            Corrected code generating compilation          */
/*            warnings.                                      */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Support for hashing EXTERNAL_ADDRESS data      */
/*            type.                                          */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Used genstrcpy instead of strcpy.              */
/*                                                           */
             
/*            Added support for external address hash table  */
/*            and subtyping.                                 */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added ValueToPointer and EnvValueToPointer     */
/*            macros.                                        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_symbol
//C     #define _H_symbol

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _SYMBOL_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #include <stdlib.h>
import core.stdc.stdlib;

//C     #ifndef _H_multifld
//C     #include "multifld.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/19/14            */
   /*                                                     */
   /*                MULTIFIELD HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for creating and manipulating           */
/*   multifield values.                                      */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove compiler warnings.    */
/*                                                           */
/*            Moved ImplodeMultifield from multifun.c.       */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Used DataObjectToString instead of             */
/*            ValueToString in implode$ to handle            */
/*            print representation of external addresses.    */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed issue with StoreInMultifield when        */
/*            asserting void values in implied deftemplate   */
/*            facts.                                         */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_multifld

//C     #define _H_multifld

//C     struct field;
//C     struct multifield;

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/04/15            */
   /*                                                     */
   /*               EVALUATION HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides routines for evaluating expressions.    */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added EvaluateAndStoreInDataObject function.   */
/*                                                           */
/*      6.30: Added support for passing context information  */
 
/*            to user defined functions.                     */
/*                                                           */
/*            Added support for external address hash table  */
/*            and subtyping.                                 */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Support for DATA_OBJECT_ARRAY primitive.       */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_evaluatn

//C     #define _H_evaluatn

//C     struct entityRecord;
//C     struct dataObject;

//C     #ifndef _H_constant
//C     #include "constant.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/05/15            */
   /*                                                     */
   /*                CONSTANTS HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Moved default type constants (NO_DEFAULT,      */
/*            STATIC_DEFAULT, and DYNAMIC_DEFAULT) to        */
/*            constant.h                                     */
/*                                                           */
/*            Added DATA_OBJECT_ARRAY primitive type.        */
/*                                                           */
/*            Added NESTED_RHS constant.                     */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_constant

//C     #define _H_constant

//C     #ifndef FALSE
//C     #define FALSE 0
//C     #endif
const FALSE = 0;
//C     #ifndef TRUE
//C     #define TRUE 1
//C     #endif
const TRUE = 1;

//C     #define EXACTLY       0
//C     #define AT_LEAST      1
const EXACTLY = 0;
//C     #define NO_MORE_THAN  2
const AT_LEAST = 1;
//C     #define RANGE         3
const NO_MORE_THAN = 2;

const RANGE = 3;
//C     #define OFF           0
//C     #define ON            1
const OFF = 0;
//C     #define LHS           0
const ON = 1;
//C     #define RHS           1
const LHS = 0;
//C     #define NESTED_RHS    2
const RHS = 1;
//C     #define NEGATIVE      0
const NESTED_RHS = 2;
//C     #define POSITIVE      1
const NEGATIVE = 0;
//C     #define EOS        '\0'
const POSITIVE = 1;

//C     #define INSIDE        0
//C     #define OUTSIDE       1
const INSIDE = 0;

const OUTSIDE = 1;
//C     #define LESS_THAN     0
//C     #define GREATER_THAN  1
const LESS_THAN = 0;
//C     #define EQUAL         2
const GREATER_THAN = 1;

const EQUAL = 2;
//C     #define GLOBAL_SAVE   0
//C     #define LOCAL_SAVE    1
const GLOBAL_SAVE = 0;
//C     #define VISIBLE_SAVE  2
const LOCAL_SAVE = 1;

const VISIBLE_SAVE = 2;
//C     #define NO_DEFAULT      0
//C     #define STATIC_DEFAULT  1
const NO_DEFAULT = 0;
//C     #define DYNAMIC_DEFAULT 2
const STATIC_DEFAULT = 1;

const DYNAMIC_DEFAULT = 2;
//C     #ifndef WPROMPT_STRING
//C     #define WPROMPT_STRING "wclips"
//C     #endif

//C     #ifndef APPLICATION_NAME
//C     #define APPLICATION_NAME "CLIPS"
//C     #endif

//C     #ifndef COMMAND_PROMPT
//C     #define COMMAND_PROMPT "CLIPS> "
//C     #endif

//C     #ifndef VERSION_STRING
//C     #define VERSION_STRING "6.30"
//C     #endif

//C     #ifndef CREATION_DATE_STRING
//C     #define CREATION_DATE_STRING "3/17/15"
//C     #endif

//C     #ifndef BANNER_STRING
//C     #define BANNER_STRING "         CLIPS (6.30 3/17/15)\n"
//C     #endif

/*************************/
/* TOKEN AND TYPE VALUES */
/*************************/

//C     #define OBJECT_TYPE_NAME               "OBJECT"
//C     #define USER_TYPE_NAME                 "USER"
//C     #define PRIMITIVE_TYPE_NAME            "PRIMITIVE"
//C     #define NUMBER_TYPE_NAME               "NUMBER"
//C     #define INTEGER_TYPE_NAME              "INTEGER"
//C     #define FLOAT_TYPE_NAME                "FLOAT"
//C     #define SYMBOL_TYPE_NAME               "SYMBOL"
//C     #define STRING_TYPE_NAME               "STRING"
//C     #define MULTIFIELD_TYPE_NAME           "MULTIFIELD"
//C     #define LEXEME_TYPE_NAME               "LEXEME"
//C     #define ADDRESS_TYPE_NAME              "ADDRESS"
//C     #define EXTERNAL_ADDRESS_TYPE_NAME     "EXTERNAL-ADDRESS"
//C     #define FACT_ADDRESS_TYPE_NAME         "FACT-ADDRESS"
//C     #define INSTANCE_TYPE_NAME             "INSTANCE"
//C     #define INSTANCE_NAME_TYPE_NAME        "INSTANCE-NAME"
//C     #define INSTANCE_ADDRESS_TYPE_NAME     "INSTANCE-ADDRESS"

/*************************************************************************/
/* The values of these constants should not be changed.  They are set to */
/* start after the primitive type codes in CONSTANT.H.  These codes are  */
/* used to let the generic function bsave image be used whether COOL is  */
/* present or not.                                                       */
/*************************************************************************/

//C     #define OBJECT_TYPE_CODE                9
//C     #define PRIMITIVE_TYPE_CODE            10
const OBJECT_TYPE_CODE = 9;
//C     #define NUMBER_TYPE_CODE               11
const PRIMITIVE_TYPE_CODE = 10;
//C     #define LEXEME_TYPE_CODE               12
const NUMBER_TYPE_CODE = 11;
//C     #define ADDRESS_TYPE_CODE              13
const LEXEME_TYPE_CODE = 12;
//C     #define INSTANCE_TYPE_CODE             14
const ADDRESS_TYPE_CODE = 13;

const INSTANCE_TYPE_CODE = 14;
/****************************************************/
/* The first 9 primitive types need to retain their */
/* values!! Sorted arrays depend on their values!!  */
/****************************************************/

//C     #define FLOAT                           0
//C     #define INTEGER                         1
const FLOAT = 0;
//C     #define SYMBOL                          2
const INTEGER = 1;
//C     #define STRING                          3
const SYMBOL = 2;
//C     #define MULTIFIELD                      4
const STRING = 3;
//C     #define EXTERNAL_ADDRESS                5
const MULTIFIELD = 4;
//C     #define FACT_ADDRESS                    6
const EXTERNAL_ADDRESS = 5;
//C     #define INSTANCE_ADDRESS                7
const FACT_ADDRESS = 6;
//C     #define INSTANCE_NAME                   8
const INSTANCE_ADDRESS = 7;

const INSTANCE_NAME = 8;
//C     #define FCALL                          30
//C     #define GCALL                          31
const FCALL = 30;
//C     #define PCALL                          32
const GCALL = 31;
//C     #define GBL_VARIABLE                   33
const PCALL = 32;
//C     #define MF_GBL_VARIABLE                34
const GBL_VARIABLE = 33;

const MF_GBL_VARIABLE = 34;
//C     #define SF_VARIABLE                    35
//C     #define MF_VARIABLE                    36
const SF_VARIABLE = 35;
//C     #define SF_WILDCARD                    37
const MF_VARIABLE = 36;
//C     #define MF_WILDCARD                    38
const SF_WILDCARD = 37;
//C     #define BITMAPARRAY                    39
const MF_WILDCARD = 38;
//C     #define DATA_OBJECT_ARRAY              40
const BITMAPARRAY = 39;

const DATA_OBJECT_ARRAY = 40;
//C     #define FACT_PN_CMP1                   50
//C     #define FACT_JN_CMP1                   51
const FACT_PN_CMP1 = 50;
//C     #define FACT_JN_CMP2                   52
const FACT_JN_CMP1 = 51;
//C     #define FACT_SLOT_LENGTH               53
const FACT_JN_CMP2 = 52;
//C     #define FACT_PN_VAR1                   54
const FACT_SLOT_LENGTH = 53;
//C     #define FACT_PN_VAR2                   55
const FACT_PN_VAR1 = 54;
//C     #define FACT_PN_VAR3                   56
const FACT_PN_VAR2 = 55;
//C     #define FACT_JN_VAR1                   57
const FACT_PN_VAR3 = 56;
//C     #define FACT_JN_VAR2                   58
const FACT_JN_VAR1 = 57;
//C     #define FACT_JN_VAR3                   59
const FACT_JN_VAR2 = 58;
//C     #define FACT_PN_CONSTANT1              60
const FACT_JN_VAR3 = 59;
//C     #define FACT_PN_CONSTANT2              61
const FACT_PN_CONSTANT1 = 60;
//C     #define FACT_STORE_MULTIFIELD          62
const FACT_PN_CONSTANT2 = 61;
//C     #define DEFTEMPLATE_PTR                63
const FACT_STORE_MULTIFIELD = 62;

const DEFTEMPLATE_PTR = 63;
//C     #define OBJ_GET_SLOT_PNVAR1            70
//C     #define OBJ_GET_SLOT_PNVAR2            71
const OBJ_GET_SLOT_PNVAR1 = 70;
//C     #define OBJ_GET_SLOT_JNVAR1            72
const OBJ_GET_SLOT_PNVAR2 = 71;
//C     #define OBJ_GET_SLOT_JNVAR2            73
const OBJ_GET_SLOT_JNVAR1 = 72;
//C     #define OBJ_SLOT_LENGTH                74
const OBJ_GET_SLOT_JNVAR2 = 73;
//C     #define OBJ_PN_CONSTANT                75
const OBJ_SLOT_LENGTH = 74;
//C     #define OBJ_PN_CMP1                    76
const OBJ_PN_CONSTANT = 75;
//C     #define OBJ_JN_CMP1                    77
const OBJ_PN_CMP1 = 76;
//C     #define OBJ_PN_CMP2                    78
const OBJ_JN_CMP1 = 77;
//C     #define OBJ_JN_CMP2                    79
const OBJ_PN_CMP2 = 78;
//C     #define OBJ_PN_CMP3                    80
const OBJ_JN_CMP2 = 79;
//C     #define OBJ_JN_CMP3                    81
const OBJ_PN_CMP3 = 80;
//C     #define DEFCLASS_PTR                   82
const OBJ_JN_CMP3 = 81;
//C     #define HANDLER_GET                    83
const DEFCLASS_PTR = 82;
//C     #define HANDLER_PUT                    84
const HANDLER_GET = 83;

const HANDLER_PUT = 84;
//C     #define DEFGLOBAL_PTR                  90

const DEFGLOBAL_PTR = 90;
//C     #define PROC_PARAM                     95
//C     #define PROC_WILD_PARAM                96
const PROC_PARAM = 95;
//C     #define PROC_GET_BIND                  97
const PROC_WILD_PARAM = 96;
//C     #define PROC_BIND                      98
const PROC_GET_BIND = 97;

const PROC_BIND = 98;
//C     #define PATTERN_CE                    150
//C     #define AND_CE                        151
const PATTERN_CE = 150;
//C     #define OR_CE                         152
const AND_CE = 151;
//C     #define NOT_CE                        153
const OR_CE = 152;
//C     #define TEST_CE                       154
const NOT_CE = 153;
//C     #define NAND_CE                       155
const TEST_CE = 154;
//C     #define EXISTS_CE                     156
const NAND_CE = 155;
//C     #define FORALL_CE                     157
const EXISTS_CE = 156;

const FORALL_CE = 157;
//C     #define NOT_CONSTRAINT                160
//C     #define AND_CONSTRAINT                161
const NOT_CONSTRAINT = 160;
//C     #define OR_CONSTRAINT                 162
const AND_CONSTRAINT = 161;
//C     #define PREDICATE_CONSTRAINT          163
const OR_CONSTRAINT = 162;
//C     #define RETURN_VALUE_CONSTRAINT       164
const PREDICATE_CONSTRAINT = 163;

const RETURN_VALUE_CONSTRAINT = 164;
//C     #define LPAREN                        170
//C     #define RPAREN                        171
const LPAREN = 170;
//C     #define STOP                          172
const RPAREN = 171;
//C     #define UNKNOWN_VALUE                 173
const STOP = 172;

const UNKNOWN_VALUE = 173;
//C     #define RVOID                         175

const RVOID = 175;
//C     #define INTEGER_OR_FLOAT              180
//C     #define SYMBOL_OR_STRING              181
const INTEGER_OR_FLOAT = 180;
//C     #define INSTANCE_OR_INSTANCE_NAME     182
const SYMBOL_OR_STRING = 181;

const INSTANCE_OR_INSTANCE_NAME = 182;
//C     typedef long int FACT_ID;
extern (C):
alias int FACT_ID;

/*************************/
/* Macintosh Definitions */
/*************************/

//C     #define CREATOR_STRING "CLIS"
//C     #define CREATOR_CODE   'CLIS'

//C     #endif






//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*               EXPRESSION HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose: Contains routines for creating, deleting,        */
/*   compacting, installing, and hashing expressions.        */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Changed expression hashing value.              */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_expressn

//C     #define _H_expressn

//C     struct expr;
//C     struct exprHashNode;

//C     #ifndef _H_exprnops
//C     #include "exprnops.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*          EXPRESSION OPERATIONS HEADER FILE          */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides utility routines for manipulating and   */
/*   examining expressions.                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Add NegateExpression function.                 */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_exprnops

//C     #define _H_exprnops

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _EXPRNOPS_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE intBool                        ConstantExpression(struct expr *);
int  ConstantExpression(expr *);
//C        LOCALE void                           PrintExpression(void *,const char *,struct expr *);
void  PrintExpression(void *, char *, expr *);
//C        LOCALE long                           ExpressionSize(struct expr *);
int  ExpressionSize(expr *);
//C        LOCALE int                            CountArguments(struct expr *);
int  CountArguments(expr *);
//C        LOCALE struct expr                   *CopyExpression(void *,struct expr *);
expr * CopyExpression(void *, expr *);
//C        LOCALE intBool                        ExpressionContainsVariables(struct expr *,int);
int  ExpressionContainsVariables(expr *, int );
//C        LOCALE intBool                        IdenticalExpression(struct expr *,struct expr *);
int  IdenticalExpression(expr *, expr *);
//C        LOCALE struct expr                   *GenConstant(void *,unsigned short,void *);
expr * GenConstant(void *, ushort , void *);
//C     #if ! RUN_TIME
//C        LOCALE int                            CheckArgumentAgainstRestriction(void *,struct expr *,int);
int  CheckArgumentAgainstRestriction(void *, expr *, int );
//C     #endif
//C        LOCALE intBool                        ConstantType(int);
int  ConstantType(int );
//C        LOCALE struct expr                   *CombineExpressions(void *,struct expr *,struct expr *);
expr * CombineExpressions(void *, expr *, expr *);
//C        LOCALE struct expr                   *AppendExpressions(struct expr *,struct expr *);
expr * AppendExpressions(expr *, expr *);
//C        LOCALE struct expr                   *NegateExpression(void *,struct expr *);
expr * NegateExpression(void *, expr *);

//C     #endif /* _H_exprnops */


//C     #endif

/******************************/
/* Expression Data Structures */
/******************************/

//C     struct expr
//C        {
//C         unsigned short type;
//C         void *value;
//C         struct expr *argList;
//C         struct expr *nextArg;
//C        };
struct expr
{
    ushort type;
    void *value;
    expr *argList;
    expr *nextArg;
}

//C     #define arg_list argList
//C     #define next_arg nextArg
//alias argList arg_list;

//alias nextArg next_arg;
//C     typedef struct expr EXPRESSION;
alias expr EXPRESSION;

//C     typedef struct exprHashNode
//C       {
//C        unsigned hashval;
//C        unsigned count;
//C        struct expr *exp;
//C        struct exprHashNode *next;
//C        long bsaveID;
//C       } EXPRESSION_HN;
struct exprHashNode
{
    uint hashval;
    uint count;
    expr *exp;
    exprHashNode *next;
    int bsaveID;
}
alias exprHashNode EXPRESSION_HN;

//C     #define EXPRESSION_HASH_SIZE 503

const EXPRESSION_HASH_SIZE = 503;
/*************************/
/* Type and Value Macros */
/*************************/

//C     #define GetType(target)         ((target).type)
//C     #define GetpType(target)        ((target)->type)
//C     #define SetType(target,val)     ((target).type = (unsigned short) (val))
//C     #define SetpType(target,val)    ((target)->type = (unsigned short) (val))
//C     #define GetValue(target)        ((target).value)
//C     #define GetpValue(target)       ((target)->value)
//C     #define SetValue(target,val)    ((target).value = (void *) (val))
//C     #define SetpValue(target,val)   ((target)->value = (void *) (val))

//C     #define EnvGetType(theEnv,target)         ((target).type)
//C     #define EnvGetpType(theEnv,target)        ((target)->type)
//C     #define EnvSetType(theEnv,target,val)     ((target).type = (unsigned short) (val))
//C     #define EnvSetpType(theEnv,target,val)    ((target)->type = (unsigned short) (val))
//C     #define EnvGetValue(theEnv,target)        ((target).value)
//C     #define EnvGetpValue(theEnv,target)       ((target)->value)
//C     #define EnvSetValue(theEnv,target,val)    ((target).value = (void *) (val))
//C     #define EnvSetpValue(theEnv,target,val)   ((target)->value = (void *) (val))

/********************/
/* ENVIRONMENT DATA */
/********************/

//C     #ifndef _H_exprnpsr
//C     #include "exprnpsr.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            EXPRESSION PARSER HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides routines for parsing expressions.       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Module specifier can be used within an         */
/*            expression to refer to a deffunction or        */
/*            defgeneric exported by the specified module,   */
/*            but not necessarily imported by the current    */
/*            module.                                        */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_exprnpsr

//C     #define _H_exprnpsr

//C     #if (! RUN_TIME)

//C     typedef struct saved_contexts
//C       {
//C        int rtn;
//C        int brk;
//C        struct saved_contexts *nxt;
//C       } SAVED_CONTEXTS;
struct saved_contexts
{
    int rtn;
    int brk;
    saved_contexts *nxt;
}
alias saved_contexts SAVED_CONTEXTS;

//C     #endif

//C     #ifndef _H_extnfunc
//C     #include "extnfunc.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            EXTERNAL FUNCTIONS HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for adding new user or system defined   */
/*   functions.                                              */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Added support for passing context information  */
 
/*            to user defined functions.                     */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Replaced ALLOW_ENVIRONMENT_GLOBALS macros      */
/*            with functions.                                */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_extnfunc

//C     #define _H_extnfunc

//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif

//C     #include "userdata.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                USER DATA HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for attaching user data to constructs,  */
/*   facts, instances, user functions, etc.                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_userdata
//C     #define _H_userdata

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _USERDATA_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     struct userData
//C       {
//C        unsigned char dataID;
//C        struct userData *next;
//C       };
struct userData
{
    ubyte dataID;
    userData *next;
}

//C     typedef struct userData USER_DATA;
alias userData USER_DATA;
//C     typedef struct userData * USER_DATA_PTR;
alias userData *USER_DATA_PTR;
  
//C     struct userDataRecord
//C       {
//C        unsigned char dataID;
//C        void *(*createUserData)(void *);
//C        void (*deleteUserData)(void *,void *);
//C       };
struct userDataRecord
{
    ubyte dataID;
    void * function(void *)createUserData;
    void  function(void *, void *)deleteUserData;
}
  
//C     typedef struct userDataRecord USER_DATA_RECORD;
alias userDataRecord USER_DATA_RECORD;
//C     typedef struct userDataRecord * USER_DATA_RECORD_PTR;
alias userDataRecord *USER_DATA_RECORD_PTR;

//C     #define MAXIMUM_USER_DATA_RECORDS 100

const MAXIMUM_USER_DATA_RECORDS = 100;
//C     #define USER_DATA_DATA 56

const USER_DATA_DATA = 56;
//C     struct userDataData
//C       { 
//C        struct userDataRecord *UserDataRecordArray[MAXIMUM_USER_DATA_RECORDS];
//C        unsigned char UserDataRecordCount;
//C       };
struct userDataData
{
    userDataRecord *[100]UserDataRecordArray;
    ubyte UserDataRecordCount;
}

//C     #define UserDataData(theEnv) ((struct userDataData *) GetEnvironmentData(theEnv,USER_DATA_DATA))

//C        LOCALE void                           InitializeUserDataData(void *);
void  InitializeUserDataData(void *);
//C        LOCALE unsigned char                  InstallUserDataRecord(void *,struct userDataRecord *);
ubyte  InstallUserDataRecord(void *, userDataRecord *);
//C        LOCALE struct userData               *FetchUserData(void *,unsigned char,struct userData **);
userData * FetchUserData(void *, ubyte , userData **);
//C        LOCALE struct userData               *TestUserData(unsigned char,struct userData *);
userData * TestUserData(ubyte , userData *);
//C        LOCALE void                           ClearUserDataList(void *,struct userData *);
void  ClearUserDataList(void *, userData *);
//C        LOCALE struct userData               *DeleteUserData(void *,unsigned char,struct userData *);
userData * DeleteUserData(void *, ubyte , userData *);

//C     #endif


//C     struct FunctionDefinition
//C       {
//C        struct symbolHashNode *callFunctionName;
//C        const char *actualFunctionName;
//C        char returnValueType;
//C        int (*functionPointer)(void);
//C        struct expr *(*parser)(void *,struct expr *,const char *);
//C        const char *restrictions;
//C        short int overloadable;
//C        short int sequenceuseok;
//C        short int environmentAware;
//C        short int bsaveIndex;
//C        struct FunctionDefinition *next;
//C        struct userData *usrData;
//C        void *context;
//C       };
struct FunctionDefinition
{
    symbolHashNode *callFunctionName;
    char *actualFunctionName;
    char returnValueType;
    int  function()functionPointer;
    expr * function(void *, expr *, char *)parser;
    char *restrictions;
    short overloadable;
    short sequenceuseok;
    short environmentAware;
    short bsaveIndex;
    FunctionDefinition *next;
    userData *usrData;
    void *context;
}

//C     #define ValueFunctionType(target) (((struct FunctionDefinition *) target)->returnValueType)
//C     #define ExpressionFunctionType(target) (((struct FunctionDefinition *) ((target)->value))->returnValueType)
//C     #define ExpressionFunctionPointer(target) (((struct FunctionDefinition *) ((target)->value))->functionPointer)
//C     #define ExpressionFunctionCallName(target) (((struct FunctionDefinition *) ((target)->value))->callFunctionName)
//C     #define ExpressionFunctionRealName(target) (((struct FunctionDefinition *) ((target)->value))->actualFunctionName)

//C     #define PTIF (int (*)(void))
//C     #define PTIEF (int (*)(void *))

/*==================*/
/* ENVIRONMENT DATA */
/*==================*/

//C     #define EXTERNAL_FUNCTION_DATA 50

const EXTERNAL_FUNCTION_DATA = 50;
//C     struct externalFunctionData
//C       { 
//C        struct FunctionDefinition *ListOfFunctions;
//C        struct FunctionHash **FunctionHashtable;
//C       };
struct externalFunctionData
{
    FunctionDefinition *ListOfFunctions;
    FunctionHash **FunctionHashtable;
}

//C     #define ExternalFunctionData(theEnv) ((struct externalFunctionData *) GetEnvironmentData(theEnv,EXTERNAL_FUNCTION_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _EXTNFUNC_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #ifdef LOCALE
//C     struct FunctionHash
//C       {
//C        struct FunctionDefinition *fdPtr;
//C        struct FunctionHash *next;
//C       };
struct FunctionHash
{
    FunctionDefinition *fdPtr;
    FunctionHash *next;
}

//C     #define SIZE_FUNCTION_HASH 517
//C     #endif
const SIZE_FUNCTION_HASH = 517;

//C        LOCALE void                           InitializeExternalFunctionData(void *);
void  InitializeExternalFunctionData(void *);
//C        LOCALE int                            EnvDefineFunction(void *,const char *,int,
//C                                                                int (*)(void *),const char *);
int  EnvDefineFunction(void *, char *, int , int  function(void *), char *);
//C        LOCALE int                            EnvDefineFunction2(void *,const char *,int,
//C                                                                 int (*)(void *),const char *,const char *);
int  EnvDefineFunction2(void *, char *, int , int  function(void *), char *, char *);
//C        LOCALE int                            EnvDefineFunctionWithContext(void *,const char *,int,
//C                                                                int (*)(void *),const char *,void *);
int  EnvDefineFunctionWithContext(void *, char *, int , int  function(void *), char *, void *);
//C        LOCALE int                            EnvDefineFunction2WithContext(void *,const char *,int,
//C                                                                 int (*)(void *),const char *,const char *,void *);
int  EnvDefineFunction2WithContext(void *, char *, int , int  function(void *), char *, char *, void *);
//C        LOCALE int                            DefineFunction3(void *,const char *,int,
//C                                                              int (*)(void *),const char *,const char *,intBool,void *);
int  DefineFunction3(void *, char *, int , int  function(void *), char *, char *, int , void *);
//C        LOCALE int                            AddFunctionParser(void *,const char *,
//C                                                                struct expr *(*)( void *,struct expr *,const char *));
int  AddFunctionParser(void *, char *, expr * function(void *, expr *, char *));
//C        LOCALE int                            RemoveFunctionParser(void *,const char *);
int  RemoveFunctionParser(void *, char *);
//C        LOCALE int                            FuncSeqOvlFlags(void *,const char *,int,int);
int  FuncSeqOvlFlags(void *, char *, int , int );
//C        LOCALE struct FunctionDefinition     *GetFunctionList(void *);
FunctionDefinition * GetFunctionList(void *);
//C        LOCALE void                           InstallFunctionList(void *,struct FunctionDefinition *);
void  InstallFunctionList(void *, FunctionDefinition *);
//C        LOCALE struct FunctionDefinition     *FindFunction(void *,const char *);
FunctionDefinition * FindFunction(void *, char *);
//C        LOCALE int                            GetNthRestriction(struct FunctionDefinition *,int);
int  GetNthRestriction(FunctionDefinition *, int );
//C        LOCALE const char                    *GetArgumentTypeName(int);
char * GetArgumentTypeName(int );
//C        LOCALE int                            UndefineFunction(void *,const char *);
int  UndefineFunction(void *, char *);
//C        LOCALE int                            GetMinimumArgs(struct FunctionDefinition *);
int  GetMinimumArgs(FunctionDefinition *);
//C        LOCALE int                            GetMaximumArgs(struct FunctionDefinition *);
int  GetMaximumArgs(FunctionDefinition *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C     #if (! RUN_TIME)
//C        LOCALE int                            DefineFunction(const char *,int,int (*)(void),const char *);
//C        LOCALE int                            DefineFunction2(const char *,int,int (*)(void),const char *,const char *);
//C     #endif /* (! RUN_TIME) */

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_extnfunc */



//C     #endif
//C     #ifndef _H_scanner
//C     #include "scanner.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                 SCANNER HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for scanning lexical tokens from an     */
/*   input source.                                           */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added SetLineCount function.                   */
/*                                                           */
/*            Added UTF-8 support.                           */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_scanner
//C     #define _H_scanner

//C     struct token;

//C     #ifndef _H_pprint
//C     #include "pprint.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*               PRETTY PRINT HEADER FILE              */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for processing the pretty print         */
/*   representation of constructs.                           */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Used genstrcpy instead of strcpy.              */
/*                                                           */
             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_pprint
//C     #define _H_pprint

//C     #define PRETTY_PRINT_DATA 52

const PRETTY_PRINT_DATA = 52;
//C     struct prettyPrintData
//C       { 
//C        int PPBufferStatus;
//C        int PPBufferEnabled;
//C        int IndentationDepth;
//C        size_t PPBufferPos;
//C        size_t PPBufferMax;
//C        size_t PPBackupOnce;
//C        size_t PPBackupTwice;
//C        char *PrettyPrintBuffer;
//C       };
struct prettyPrintData
{
    int PPBufferStatus;
    int PPBufferEnabled;
    int IndentationDepth;
    size_t PPBufferPos;
    size_t PPBufferMax;
    size_t PPBackupOnce;
    size_t PPBackupTwice;
    char *PrettyPrintBuffer;
}

//C     #define PrettyPrintData(theEnv) ((struct prettyPrintData *) GetEnvironmentData(theEnv,PRETTY_PRINT_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _PPRINT_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializePrettyPrintData(void *);
void  InitializePrettyPrintData(void *);
//C        LOCALE void                           FlushPPBuffer(void *);
void  FlushPPBuffer(void *);
//C        LOCALE void                           DestroyPPBuffer(void *);
void  DestroyPPBuffer(void *);
//C        LOCALE void                           SavePPBuffer(void *,const char *);
void  SavePPBuffer(void *, char *);
//C        LOCALE void                           PPBackup(void *);
void  PPBackup(void *);
//C        LOCALE char                          *CopyPPBuffer(void *);
char * CopyPPBuffer(void *);
//C        LOCALE char                          *GetPPBuffer(void *);
char * GetPPBuffer(void *);
//C        LOCALE void                           PPCRAndIndent(void *);
void  PPCRAndIndent(void *);
//C        LOCALE void                           IncrementIndentDepth(void *,int);
void  IncrementIndentDepth(void *, int );
//C        LOCALE void                           DecrementIndentDepth(void *,int);
void  DecrementIndentDepth(void *, int );
//C        LOCALE void                           SetIndentDepth(void *,int);
void  SetIndentDepth(void *, int );
//C        LOCALE void                           SetPPBufferStatus(void *,int);
void  SetPPBufferStatus(void *, int );
//C        LOCALE int                            GetPPBufferStatus(void *);
int  GetPPBufferStatus(void *);
//C        LOCALE int                            SetPPBufferEnabled(void *,int);
int  SetPPBufferEnabled(void *, int );
//C        LOCALE int                            GetPPBufferEnabled(void *);
int  GetPPBufferEnabled(void *);

//C     #endif



//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _SCANNER_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     struct token
//C       {
//C        unsigned short type;
//C        void *value;
//C        const char *printForm;
//C       };
struct token
{
    ushort type;
    void *value;
    char *printForm;
}

//C     #define SCANNER_DATA 57

const SCANNER_DATA = 57;
//C     struct scannerData
//C       { 
//C        char *GlobalString;
//C        size_t GlobalMax;
//C        size_t GlobalPos;
//C        long LineCount;
//C        int IgnoreCompletionErrors;
//C       };
struct scannerData
{
    char *GlobalString;
    size_t GlobalMax;
    size_t GlobalPos;
    int LineCount;
    int IgnoreCompletionErrors;
}

//C     #define ScannerData(theEnv) ((struct scannerData *) GetEnvironmentData(theEnv,SCANNER_DATA))

//C        LOCALE void                           InitializeScannerData(void *);
void  InitializeScannerData(void *);
//C        LOCALE void                           GetToken(void *,const char *,struct token *);
void  GetToken(void *, char *, token *);
//C        LOCALE void                           CopyToken(struct token *,struct token *);
void  CopyToken(token *, token *);
//C        LOCALE void                           ResetLineCount(void *);
void  ResetLineCount(void *);
//C        LOCALE long                           GetLineCount(void *);
int  GetLineCount(void *);
//C        LOCALE long                           SetLineCount(void *,long);
int  SetLineCount(void *, int );
//C        LOCALE void                           IncrementLineCount(void *);
void  IncrementLineCount(void *);
//C        LOCALE void                           DecrementLineCount(void *);
void  DecrementLineCount(void *);

//C     #endif /* _H_scanner */




//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _EXPRNPSR_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE struct expr                   *Function0Parse(void *,const char *);
expr * Function0Parse(void *, char *);
//C        LOCALE struct expr                   *Function1Parse(void *,const char *);
expr * Function1Parse(void *, char *);
//C        LOCALE struct expr                   *Function2Parse(void *,const char *,const char *);
expr * Function2Parse(void *, char *, char *);
//C        LOCALE void                           PushRtnBrkContexts(void *);
void  PushRtnBrkContexts(void *);
//C        LOCALE void                           PopRtnBrkContexts(void *);
void  PopRtnBrkContexts(void *);
//C        LOCALE intBool                        ReplaceSequenceExpansionOps(void *,struct expr *,struct expr *,
//C                                                                          void *,void *);
int  ReplaceSequenceExpansionOps(void *, expr *, expr *, void *, void *);
//C        LOCALE struct expr                   *CollectArguments(void *,struct expr *,const char *);
expr * CollectArguments(void *, expr *, char *);
//C        LOCALE struct expr                   *ArgumentParse(void *,const char *,int *);
expr * ArgumentParse(void *, char *, int *);
//C        LOCALE struct expr                   *ParseAtomOrExpression(void *,const char *,struct token *);
expr * ParseAtomOrExpression(void *, char *, token *);
//C        LOCALE EXPRESSION                    *ParseConstantArguments(void *,const char *,int *);
EXPRESSION * ParseConstantArguments(void *, char *, int *);
//C        LOCALE intBool                        EnvSetSequenceOperatorRecognition(void *,int);
int  EnvSetSequenceOperatorRecognition(void *, int );
//C        LOCALE intBool                        EnvGetSequenceOperatorRecognition(void *);
int  EnvGetSequenceOperatorRecognition(void *);
//C        LOCALE struct expr                   *GroupActions(void *,const char *,struct token *,
//C                                                           int,const char *,int);
expr * GroupActions(void *, char *, token *, int , char *, int );
//C        LOCALE struct expr                   *RemoveUnneededProgn(void *,struct expr *);
expr * RemoveUnneededProgn(void *, expr *);

//C     #if (! RUN_TIME)

//C        LOCALE int                            CheckExpressionAgainstRestrictions(void *,struct expr *,
//C                                                                                 const char *,const char *);
int  CheckExpressionAgainstRestrictions(void *, expr *, char *, char *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        SetSequenceOperatorRecognition(int);
//C        LOCALE intBool                        GetSequenceOperatorRecognition(void);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_exprnpsr */




//C     #endif

//C     #define EXPRESSION_DATA 45

const EXPRESSION_DATA = 45;
//C     struct expressionData
//C       { 
//C        void *PTR_AND;
//C        void *PTR_OR;
//C        void *PTR_EQ;
//C        void *PTR_NEQ;
//C        void *PTR_NOT;
//C        EXPRESSION_HN **ExpressionHashTable;
//C     #if (BLOAD || BLOAD_ONLY || BLOAD_AND_BSAVE)
//C        long NumberOfExpressions;
//C        struct expr *ExpressionArray;
//C        long int ExpressionCount;
//C     #endif
//C     #if (! RUN_TIME)
//C        SAVED_CONTEXTS *svContexts;
//C        int ReturnContext;
//C        int BreakContext;
//C     #endif
//C        intBool SequenceOpMode;
//C       };
struct expressionData
{
    void *PTR_AND;
    void *PTR_OR;
    void *PTR_EQ;
    void *PTR_NEQ;
    void *PTR_NOT;
    EXPRESSION_HN **ExpressionHashTable;
    int NumberOfExpressions;
    expr *ExpressionArray;
    int ExpressionCount;
    SAVED_CONTEXTS *svContexts;
    int ReturnContext;
    int BreakContext;
    int SequenceOpMode;
}

//C     #define ExpressionData(theEnv) ((struct expressionData *) GetEnvironmentData(theEnv,EXPRESSION_DATA))

/********************/
/* Global Functions */
/********************/

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _EXPRESSN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           ReturnExpression(void *,struct expr *);
void  ReturnExpression(void *, expr *);
//C        LOCALE void                           ExpressionInstall(void *,struct expr *);
void  ExpressionInstall(void *, expr *);
//C        LOCALE void                           ExpressionDeinstall(void *,struct expr *);
void  ExpressionDeinstall(void *, expr *);
//C        LOCALE struct expr                   *PackExpression(void *,struct expr *);
expr * PackExpression(void *, expr *);
//C        LOCALE void                           ReturnPackedExpression(void *,struct expr *);
void  ReturnPackedExpression(void *, expr *);
//C        LOCALE void                           InitExpressionData(void *);
void  InitExpressionData(void *);
//C        LOCALE void                           InitExpressionPointers(void *);
void  InitExpressionPointers(void *);
//C     #if (! BLOAD_ONLY) && (! RUN_TIME)
//C        LOCALE EXPRESSION                    *AddHashedExpression(void *,EXPRESSION *);
EXPRESSION * AddHashedExpression(void *, EXPRESSION *);
//C     #endif
//C     #if (! RUN_TIME)
//C        LOCALE void                           RemoveHashedExpression(void *,EXPRESSION *);
void  RemoveHashedExpression(void *, EXPRESSION *);
//C     #endif
//C     #if BLOAD_AND_BSAVE || BLOAD_ONLY || BLOAD || CONSTRUCT_COMPILER
//C        LOCALE long                           HashedExpressionIndex(void *,EXPRESSION *);
int  HashedExpressionIndex(void *, EXPRESSION *);
//C     #endif

//C     #endif




//C     #endif

//C     struct dataObject
//C       {
//C        void *supplementalInfo;
//C        unsigned short type;
//C        void *value;
//C        long begin;
//C        long end;
//C        struct dataObject *next;
//C       };
struct dataObject
{
    void *supplementalInfo;
    ushort type;
    void *value;
    int begin;
    int end;
    dataObject *next;
}

//C     typedef struct dataObject DATA_OBJECT;
alias dataObject DATA_OBJECT;
//C     typedef struct dataObject * DATA_OBJECT_PTR;
alias dataObject *DATA_OBJECT_PTR;

//C     typedef struct expr FUNCTION_REFERENCE;
alias expr FUNCTION_REFERENCE;

//C     #define DATA_OBJECT_PTR_ARG DATA_OBJECT_PTR

alias DATA_OBJECT_PTR DATA_OBJECT_PTR_ARG;
//C     #define C_POINTER_EXTERNAL_ADDRESS 0

const C_POINTER_EXTERNAL_ADDRESS = 0;
//C     #include "userdata.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                USER DATA HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for attaching user data to constructs,  */
/*   facts, instances, user functions, etc.                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_userdata
//C     #define _H_userdata

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _USERDATA_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C     struct userData
//C       {
//C        unsigned char dataID;
//C        struct userData *next;
//C       };

//C     typedef struct userData USER_DATA;
//C     typedef struct userData * USER_DATA_PTR;
  
//C     struct userDataRecord
//C       {
//C        unsigned char dataID;
//C        void *(*createUserData)(void *);
//C        void (*deleteUserData)(void *,void *);
//C       };
  
//C     typedef struct userDataRecord USER_DATA_RECORD;
//C     typedef struct userDataRecord * USER_DATA_RECORD_PTR;

//C     #define MAXIMUM_USER_DATA_RECORDS 100

//C     #define USER_DATA_DATA 56

//C     struct userDataData
//C       { 
//C        struct userDataRecord *UserDataRecordArray[MAXIMUM_USER_DATA_RECORDS];
//C        unsigned char UserDataRecordCount;
//C       };

//C     #define UserDataData(theEnv) ((struct userDataData *) GetEnvironmentData(theEnv,USER_DATA_DATA))

//C        LOCALE void                           InitializeUserDataData(void *);
//C        LOCALE unsigned char                  InstallUserDataRecord(void *,struct userDataRecord *);
//C        LOCALE struct userData               *FetchUserData(void *,unsigned char,struct userData **);
//C        LOCALE struct userData               *TestUserData(unsigned char,struct userData *);
//C        LOCALE void                           ClearUserDataList(void *,struct userData *);
//C        LOCALE struct userData               *DeleteUserData(void *,unsigned char,struct userData *);

//C     #endif


//C     struct entityRecord
//C       {
//C        const char *name;
//C        unsigned int type : 13;
//C        unsigned int copyToEvaluate : 1;
//C        unsigned int bitMap : 1;
//C        unsigned int addsToRuleComplexity : 1;
//C        void (*shortPrintFunction)(void *,const char *,void *);
//C        void (*longPrintFunction)(void *,const char *,void *);
//C        intBool (*deleteFunction)(void *,void *);
//C        intBool (*evaluateFunction)(void *,void *,DATA_OBJECT *);
//C        void *(*getNextFunction)(void *,void *);
//C        void (*decrementBusyCount)(void *,void *);
//C        void (*incrementBusyCount)(void *,void *);
//C        void (*propagateDepth)(void *,void *);
//C        void (*markNeeded)(void *,void *);
//C        void (*install)(void *,void *);
//C        void (*deinstall)(void *,void *);
//C        struct userData *usrData;
//C       };
struct entityRecord
{
    char *name;
    uint __bitfield1;
    uint type() { return (__bitfield1 >> 0) & 0x1fff; }
    uint type(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffe000) | (value << 0); return value; }
    uint copyToEvaluate() { return (__bitfield1 >> 13) & 0x1; }
    uint copyToEvaluate(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffdfff) | (value << 13); return value; }
    uint bitMap() { return (__bitfield1 >> 14) & 0x1; }
    uint bitMap(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffbfff) | (value << 14); return value; }
    uint addsToRuleComplexity() { return (__bitfield1 >> 15) & 0x1; }
    uint addsToRuleComplexity(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffff7fff) | (value << 15); return value; }
    void  function(void *, char *, void *)shortPrintFunction;
    void  function(void *, char *, void *)longPrintFunction;
    int  function(void *, void *)deleteFunction;
    int  function(void *, void *, DATA_OBJECT *)evaluateFunction;
    void * function(void *, void *)getNextFunction;
    void  function(void *, void *)decrementBusyCount;
    void  function(void *, void *)incrementBusyCount;
    void  function(void *, void *)propagateDepth;
    void  function(void *, void *)markNeeded;
    void  function(void *, void *)install;
    void  function(void *, void *)deinstall;
    userData *usrData;
}

//C     struct externalAddressType
//C       {
//C        const  char *name;
//C        void (*shortPrintFunction)(void *,const char *,void *);
//C        void (*longPrintFunction)(void *,const char *,void *);
//C        intBool (*discardFunction)(void *,void *);
//C        void (*newFunction)(void *,DATA_OBJECT *);
//C        intBool (*callFunction)(void *,DATA_OBJECT *,DATA_OBJECT *);
//C       };
struct externalAddressType
{
    char *name;
    void  function(void *, char *, void *)shortPrintFunction;
    void  function(void *, char *, void *)longPrintFunction;
    int  function(void *, void *)discardFunction;
    void  function(void *, DATA_OBJECT *)newFunction;
    int  function(void *, DATA_OBJECT *, DATA_OBJECT *)callFunction;
}

//C     typedef struct entityRecord ENTITY_RECORD;
alias entityRecord ENTITY_RECORD;
//C     typedef struct entityRecord * ENTITY_RECORD_PTR;
alias entityRecord *ENTITY_RECORD_PTR;

//C     #define GetDOLength(target)       (((target).end - (target).begin) + 1)
//C     #define GetpDOLength(target)      (((target)->end - (target)->begin) + 1)
//C     #define GetDOBegin(target)        ((target).begin + 1)
//C     #define GetDOEnd(target)          ((target).end + 1)
//C     #define GetpDOBegin(target)       ((target)->begin + 1)
//C     #define GetpDOEnd(target)         ((target)->end + 1)
//C     #define SetDOBegin(target,val)   ((target).begin = (long) ((val) - 1))
//C     #define SetDOEnd(target,val)     ((target).end = (long) ((val) - 1))
//C     #define SetpDOBegin(target,val)   ((target)->begin = (long) ((val) - 1))
//C     #define SetpDOEnd(target,val)     ((target)->end = (long) ((val) - 1))

//C     #define EnvGetDOLength(theEnv,target)       (((target).end - (target).begin) + 1)
//C     #define EnvGetpDOLength(theEnv,target)      (((target)->end - (target)->begin) + 1)
//C     #define EnvGetDOBegin(theEnv,target)        ((target).begin + 1)
//C     #define EnvGetDOEnd(theEnv,target)          ((target).end + 1)
//C     #define EnvGetpDOBegin(theEnv,target)       ((target)->begin + 1)
//C     #define EnvGetpDOEnd(theEnv,target)         ((target)->end + 1)
//C     #define EnvSetDOBegin(theEnv,target,val)   ((target).begin = (long) ((val) - 1))
//C     #define EnvSetDOEnd(theEnv,target,val)     ((target).end = (long) ((val) - 1))
//C     #define EnvSetpDOBegin(theEnv,target,val)   ((target)->begin = (long) ((val) - 1))
//C     #define EnvSetpDOEnd(theEnv,target,val)     ((target)->end = (long) ((val) - 1))

//C     #define DOPToString(target) (((struct symbolHashNode *) ((target)->value))->contents)
//C     #define DOPToDouble(target) (((struct floatHashNode *) ((target)->value))->contents)
//C     #define DOPToFloat(target) ((float) (((struct floatHashNode *) ((target)->value))->contents))
//C     #define DOPToLong(target) (((struct integerHashNode *) ((target)->value))->contents)
//C     #define DOPToInteger(target) ((int) (((struct integerHashNode *) ((target)->value))->contents))
//C     #define DOPToPointer(target)       ((target)->value)
//C     #define DOPToExternalAddress(target) (((struct externalAddressHashNode *) ((target)->value))->externalAddress)

//C     #define EnvDOPToString(theEnv,target) (((struct symbolHashNode *) ((target)->value))->contents)
//C     #define EnvDOPToDouble(theEnv,target) (((struct floatHashNode *) ((target)->value))->contents)
//C     #define EnvDOPToFloat(theEnv,target) ((float) (((struct floatHashNode *) ((target)->value))->contents))
//C     #define EnvDOPToLong(theEnv,target) (((struct integerHashNode *) ((target)->value))->contents)
//C     #define EnvDOPToInteger(theEnv,target) ((int) (((struct integerHashNode *) ((target)->value))->contents))
//C     #define EnvDOPToPointer(theEnv,target)       ((target)->value)
//C     #define EnvDOPToExternalAddress(target) (((struct externalAddressHashNode *) ((target)->value))->externalAddress)

//C     #define DOToString(target) (((struct symbolHashNode *) ((target).value))->contents)
//C     #define DOToDouble(target) (((struct floatHashNode *) ((target).value))->contents)
//C     #define DOToFloat(target) ((float) (((struct floatHashNode *) ((target).value))->contents))
//C     #define DOToLong(target) (((struct integerHashNode *) ((target).value))->contents)
//C     #define DOToInteger(target) ((int) (((struct integerHashNode *) ((target).value))->contents))
//C     #define DOToPointer(target)        ((target).value)
//C     #define DOToExternalAddress(target) (((struct externalAddressHashNode *) ((target).value))->externalAddress)

//C     #define EnvDOToString(theEnv,target) (((struct symbolHashNode *) ((target).value))->contents)
//C     #define EnvDOToDouble(theEnv,target) (((struct floatHashNode *) ((target).value))->contents)
//C     #define EnvDOToFloat(theEnv,target) ((float) (((struct floatHashNode *) ((target).value))->contents))
//C     #define EnvDOToLong(theEnv,target) (((struct integerHashNode *) ((target).value))->contents)
//C     #define EnvDOToInteger(theEnv,target) ((int) (((struct integerHashNode *) ((target).value))->contents))
//C     #define EnvDOToPointer(theEnv,target)        ((target).value)
//C     #define EnvDOToExternalAddress(target) (((struct externalAddressHashNode *) ((target).value))->externalAddress)

//C     #define CoerceToLongInteger(t,v) ((t == INTEGER) ? ValueToLong(v) : (long int) ValueToDouble(v))
//C     #define CoerceToInteger(t,v) ((t == INTEGER) ? (int) ValueToLong(v) : (int) ValueToDouble(v))
//C     #define CoerceToDouble(t,v) ((t == INTEGER) ? (double) ValueToLong(v) : ValueToDouble(v))

//C     #define GetFirstArgument()           (EvaluationData(theEnv)->CurrentExpression->argList)
//C     #define GetNextArgument(ep)          (ep->nextArg)

//C     #define MAXIMUM_PRIMITIVES 150
//C     #define MAXIMUM_EXTERNAL_ADDRESS_TYPES 10
const MAXIMUM_PRIMITIVES = 150;

const MAXIMUM_EXTERNAL_ADDRESS_TYPES = 10;
//C     #define BITS_PER_BYTE    8

const BITS_PER_BYTE = 8;
//C     #define BitwiseTest(n,b)   ((n) & (char) (1 << (b)))
//C     #define BitwiseSet(n,b)    (n |= (char) (1 << (b)))
//C     #define BitwiseClear(n,b)  (n &= (char) ~(1 << (b)))

//C     #define TestBitMap(map,id)  BitwiseTest(map[(id) / BITS_PER_BYTE],(id) % BITS_PER_BYTE)
//C     #define SetBitMap(map,id)   BitwiseSet(map[(id) / BITS_PER_BYTE],(id) % BITS_PER_BYTE)
//C     #define ClearBitMap(map,id) BitwiseClear(map[(id) / BITS_PER_BYTE],(id) % BITS_PER_BYTE)

//C     #define EVALUATION_DATA 44

const EVALUATION_DATA = 44;
//C     struct evaluationData
//C       { 
//C        struct expr *CurrentExpression;
//C        int EvaluationError;
//C        int HaltExecution;
//C        int CurrentEvaluationDepth;
//C        int numberOfAddressTypes;
//C        struct entityRecord *PrimitivesArray[MAXIMUM_PRIMITIVES];
//C        struct externalAddressType *ExternalAddressTypes[MAXIMUM_EXTERNAL_ADDRESS_TYPES];
//C       };
struct evaluationData
{
    expr *CurrentExpression;
    int EvaluationError;
    int HaltExecution;
    int CurrentEvaluationDepth;
    int numberOfAddressTypes;
    entityRecord *[150]PrimitivesArray;
    externalAddressType *[10]ExternalAddressTypes;
}

//C     #define EvaluationData(theEnv) ((struct evaluationData *) GetEnvironmentData(theEnv,EVALUATION_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _EVALUATN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeEvaluationData(void *);
void  InitializeEvaluationData(void *);
//C        LOCALE int                            EvaluateExpression(void *,struct expr *,struct dataObject *);
int  EvaluateExpression(void *, expr *, dataObject *);
//C        LOCALE void                           SetEvaluationError(void *,intBool);
void  SetEvaluationError(void *, int );
//C        LOCALE int                            GetEvaluationError(void *);
int  GetEvaluationError(void *);
//C        LOCALE void                           SetHaltExecution(void *,int);
void  SetHaltExecution(void *, int );
//C        LOCALE int                            GetHaltExecution(void *);
int  GetHaltExecution(void *);
//C        LOCALE void                           ReturnValues(void *,struct dataObject *,intBool);
void  ReturnValues(void *, dataObject *, int );
//C        LOCALE void                           PrintDataObject(void *,const char *,struct dataObject *);
void  PrintDataObject(void *, char *, dataObject *);
//C        LOCALE void                           EnvSetMultifieldErrorValue(void *,struct dataObject *);
void  EnvSetMultifieldErrorValue(void *, dataObject *);
//C        LOCALE void                           ValueInstall(void *,struct dataObject *);
void  ValueInstall(void *, dataObject *);
//C        LOCALE void                           ValueDeinstall(void *,struct dataObject *);
void  ValueDeinstall(void *, dataObject *);
//C     #if DEFFUNCTION_CONSTRUCT || DEFGENERIC_CONSTRUCT
//C        LOCALE int                            EnvFunctionCall(void *,const char *,const char *,DATA_OBJECT *);
int  EnvFunctionCall(void *, char *, char *, DATA_OBJECT *);
//C        LOCALE int                            FunctionCall2(void *,FUNCTION_REFERENCE *,const char *,DATA_OBJECT *);
int  FunctionCall2(void *, FUNCTION_REFERENCE *, char *, DATA_OBJECT *);
//C     #endif
//C        LOCALE void                           CopyDataObject(void *,DATA_OBJECT *,DATA_OBJECT *,int);
void  CopyDataObject(void *, DATA_OBJECT *, DATA_OBJECT *, int );
//C        LOCALE void                           AtomInstall(void *,int,void *);
void  AtomInstall(void *, int , void *);
//C        LOCALE void                           AtomDeinstall(void *,int,void *);
void  AtomDeinstall(void *, int , void *);
//C        LOCALE struct expr                   *ConvertValueToExpression(void *,DATA_OBJECT *);
expr * ConvertValueToExpression(void *, DATA_OBJECT *);
//C        LOCALE unsigned long                  GetAtomicHashValue(unsigned short,void *,int);
uint  GetAtomicHashValue(ushort , void *, int );
//C        LOCALE void                           InstallPrimitive(void *,struct entityRecord *,int);
void  InstallPrimitive(void *, entityRecord *, int );
//C        LOCALE int                            InstallExternalAddressType(void *,struct externalAddressType *);
int  InstallExternalAddressType(void *, externalAddressType *);
//C        LOCALE void                           TransferDataObjectValues(DATA_OBJECT *,DATA_OBJECT *);
void  TransferDataObjectValues(DATA_OBJECT *, DATA_OBJECT *);
//C        LOCALE struct expr                   *FunctionReferenceExpression(void *,const char *);
expr * FunctionReferenceExpression(void *, char *);
//C        LOCALE intBool                        GetFunctionReference(void *,const char *,FUNCTION_REFERENCE *);
int  GetFunctionReference(void *, char *, FUNCTION_REFERENCE *);
//C        LOCALE intBool                        DOsEqual(DATA_OBJECT_PTR,DATA_OBJECT_PTR);
int  DOsEqual(DATA_OBJECT_PTR , DATA_OBJECT_PTR );
//C        LOCALE int                            EvaluateAndStoreInDataObject(void *,int,EXPRESSION *,DATA_OBJECT *,int);
int  EvaluateAndStoreInDataObject(void *, int , EXPRESSION *, DATA_OBJECT *, int );

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           SetMultifieldErrorValue(DATA_OBJECT_PTR);
//C        LOCALE int                            FunctionCall(const char *,const char *,DATA_OBJECT *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_evaluatn */
//C     #endif

//C     struct field
//C       {
//C        unsigned short type;
//C        void *value;
//C       };
struct field
{
    ushort type;
    void *value;
}

//C     struct multifield
//C       {
//C        unsigned busyCount;
//C        long multifieldLength;
//C        struct multifield *next;
//C        struct field theFields[1];
//C       };
struct multifield
{
    uint busyCount;
    int multifieldLength;
    multifield *next;
    field [1]theFields;
}

//C     typedef struct multifield SEGMENT;
alias multifield SEGMENT;
//C     typedef struct multifield * SEGMENT_PTR;
alias multifield *SEGMENT_PTR;
//C     typedef struct multifield * MULTIFIELD_PTR;
alias multifield *MULTIFIELD_PTR;
//C     typedef struct field FIELD;
alias field FIELD;
//C     typedef struct field * FIELD_PTR;
alias field *FIELD_PTR;

//C     #define GetMFLength(target)     (((struct multifield *) (target))->multifieldLength)
//C     #define GetMFPtr(target,index)  (&(((struct field *) ((struct multifield *) (target))->theFields)[index-1]))
//C     #define SetMFType(target,index,value)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].type = (unsigned short) (value))
//C     #define SetMFValue(target,index,val)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].value = (void *) (val))
//C     #define GetMFType(target,index)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].type)
//C     #define GetMFValue(target,index)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].value)

//C     #define EnvGetMFLength(theEnv,target)     (((struct multifield *) (target))->multifieldLength)
//C     #define EnvGetMFPtr(theEnv,target,index)  (&(((struct field *) ((struct multifield *) (target))->theFields)[index-1]))
//C     #define EnvSetMFType(theEnv,target,index,value)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].type = (unsigned short) (value))
//C     #define EnvSetMFValue(theEnv,target,index,val)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].value = (void *) (val))
//C     #define EnvGetMFType(theEnv,target,index)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].type)
//C     #define EnvGetMFValue(theEnv,target,index)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].value)

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _MULTIFLD_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                          *CreateMultifield2(void *,long);
void * CreateMultifield2(void *, int );
//C        LOCALE void                           ReturnMultifield(void *,struct multifield *);
void  ReturnMultifield(void *, multifield *);
//C        LOCALE void                           MultifieldInstall(void *,struct multifield *);
void  MultifieldInstall(void *, multifield *);
//C        LOCALE void                           MultifieldDeinstall(void *,struct multifield *);
void  MultifieldDeinstall(void *, multifield *);
//C        LOCALE struct multifield             *StringToMultifield(void *,const char *);
multifield * StringToMultifield(void *, char *);
//C        LOCALE void                          *EnvCreateMultifield(void *,long);
void * EnvCreateMultifield(void *, int );
//C        LOCALE void                           AddToMultifieldList(void *,struct multifield *);
void  AddToMultifieldList(void *, multifield *);
//C        LOCALE void                           FlushMultifields(void *);
void  FlushMultifields(void *);
//C        LOCALE void                           DuplicateMultifield(void *,struct dataObject *,struct dataObject *);
void  DuplicateMultifield(void *, dataObject *, dataObject *);
//C        LOCALE void                           PrintMultifield(void *,const char *,SEGMENT_PTR,long,long,int);
void  PrintMultifield(void *, char *, SEGMENT_PTR , int , int , int );
//C        LOCALE intBool                        MultifieldDOsEqual(DATA_OBJECT_PTR,DATA_OBJECT_PTR);
int  MultifieldDOsEqual(DATA_OBJECT_PTR , DATA_OBJECT_PTR );
//C        LOCALE void                           StoreInMultifield(void *,DATA_OBJECT *,EXPRESSION *,int);
void  StoreInMultifield(void *, DATA_OBJECT *, EXPRESSION *, int );
//C        LOCALE void                          *CopyMultifield(void *,struct multifield *);
void * CopyMultifield(void *, multifield *);
//C        LOCALE intBool                        MultifieldsEqual(struct multifield *,struct multifield *);
int  MultifieldsEqual(multifield *, multifield *);
//C        LOCALE void                          *DOToMultifield(void *,DATA_OBJECT *);
void * DOToMultifield(void *, DATA_OBJECT *);
//C        LOCALE unsigned long                  HashMultifield(struct multifield *,unsigned long);
uint  HashMultifield(multifield *, uint );
//C        LOCALE struct multifield             *GetMultifieldList(void *);
multifield * GetMultifieldList(void *);
//C        LOCALE void                          *ImplodeMultifield(void *,DATA_OBJECT *);
void * ImplodeMultifield(void *, DATA_OBJECT *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                          *CreateMultifield(long);
   
//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_multifld */




//C     #endif

//C     #ifndef SYMBOL_HASH_SIZE
//C     #define SYMBOL_HASH_SIZE       63559L
//C     #endif
const SYMBOL_HASH_SIZE = 63559;

//C     #ifndef FLOAT_HASH_SIZE
//C     #define FLOAT_HASH_SIZE         8191
//C     #endif
const FLOAT_HASH_SIZE = 8191;

//C     #ifndef INTEGER_HASH_SIZE
//C     #define INTEGER_HASH_SIZE       8191
//C     #endif
const INTEGER_HASH_SIZE = 8191;

//C     #ifndef BITMAP_HASH_SIZE
//C     #define BITMAP_HASH_SIZE        8191
//C     #endif
const BITMAP_HASH_SIZE = 8191;

//C     #ifndef EXTERNAL_ADDRESS_HASH_SIZE
//C     #define EXTERNAL_ADDRESS_HASH_SIZE        8191
//C     #endif
const EXTERNAL_ADDRESS_HASH_SIZE = 8191;

/************************************************************/
/* symbolHashNode STRUCTURE:                                */
/************************************************************/
//C     struct symbolHashNode
//C       {
//C        struct symbolHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededSymbol : 1;
//C        unsigned int bucket : 29;
//C        const char *contents;
//C       };
struct symbolHashNode
{
    symbolHashNode *next;
    int count;
    uint __bitfield1;
    uint permanent() { return (__bitfield1 >> 0) & 0x1; }
    uint permanent(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint markedEphemeral() { return (__bitfield1 >> 1) & 0x1; }
    uint markedEphemeral(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint neededSymbol() { return (__bitfield1 >> 2) & 0x1; }
    uint neededSymbol(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint bucket() { return (__bitfield1 >> 3) & 0x1fffffff; }
    uint bucket(uint value) { __bitfield1 = (__bitfield1 & 0xffffffff00000007) | (value << 3); return value; }
    char *contents;
}

/************************************************************/
/* floatHashNode STRUCTURE:                                  */
/************************************************************/
//C     struct floatHashNode
//C       {
//C        struct floatHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededFloat : 1;
//C        unsigned int bucket : 29;
//C        double contents;
//C       };
struct floatHashNode
{
    floatHashNode *next;
    int count;
    uint __bitfield1;
    uint permanent() { return (__bitfield1 >> 0) & 0x1; }
    uint permanent(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint markedEphemeral() { return (__bitfield1 >> 1) & 0x1; }
    uint markedEphemeral(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint neededFloat() { return (__bitfield1 >> 2) & 0x1; }
    uint neededFloat(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint bucket() { return (__bitfield1 >> 3) & 0x1fffffff; }
    uint bucket(uint value) { __bitfield1 = (__bitfield1 & 0xffffffff00000007) | (value << 3); return value; }
    double contents;
}

/************************************************************/
/* integerHashNode STRUCTURE:                               */
/************************************************************/
//C     struct integerHashNode
//C       {
//C        struct integerHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededInteger : 1;
//C        unsigned int bucket : 29;
//C        long long contents;
//C       };
struct integerHashNode
{
    integerHashNode *next;
    int count;
    uint __bitfield1;
    uint permanent() { return (__bitfield1 >> 0) & 0x1; }
    uint permanent(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint markedEphemeral() { return (__bitfield1 >> 1) & 0x1; }
    uint markedEphemeral(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint neededInteger() { return (__bitfield1 >> 2) & 0x1; }
    uint neededInteger(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint bucket() { return (__bitfield1 >> 3) & 0x1fffffff; }
    uint bucket(uint value) { __bitfield1 = (__bitfield1 & 0xffffffff00000007) | (value << 3); return value; }
    long contents;
}

/************************************************************/
/* bitMapHashNode STRUCTURE:                                */
/************************************************************/
//C     struct bitMapHashNode
//C       {
//C        struct bitMapHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededBitMap : 1;
//C        unsigned int bucket : 29;
//C        const char *contents;
//C        unsigned short size;
//C       };
struct bitMapHashNode
{
    bitMapHashNode *next;
    int count;
    uint __bitfield1;
    uint permanent() { return (__bitfield1 >> 0) & 0x1; }
    uint permanent(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint markedEphemeral() { return (__bitfield1 >> 1) & 0x1; }
    uint markedEphemeral(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint neededBitMap() { return (__bitfield1 >> 2) & 0x1; }
    uint neededBitMap(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint bucket() { return (__bitfield1 >> 3) & 0x1fffffff; }
    uint bucket(uint value) { __bitfield1 = (__bitfield1 & 0xffffffff00000007) | (value << 3); return value; }
    char *contents;
    ushort size;
}

/************************************************************/
/* externalAddressHashNode STRUCTURE:                       */
/************************************************************/
//C     struct externalAddressHashNode
//C       {
//C        struct externalAddressHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededPointer : 1;
//C        unsigned int bucket : 29;
//C        void *externalAddress;
//C        unsigned short type;
//C       };
struct externalAddressHashNode
{
    externalAddressHashNode *next;
    int count;
    uint __bitfield1;
    uint permanent() { return (__bitfield1 >> 0) & 0x1; }
    uint permanent(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint markedEphemeral() { return (__bitfield1 >> 1) & 0x1; }
    uint markedEphemeral(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint neededPointer() { return (__bitfield1 >> 2) & 0x1; }
    uint neededPointer(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint bucket() { return (__bitfield1 >> 3) & 0x1fffffff; }
    uint bucket(uint value) { __bitfield1 = (__bitfield1 & 0xffffffff00000007) | (value << 3); return value; }
    void *externalAddress;
    ushort type;
}

/************************************************************/
/* genericHashNode STRUCTURE:                               */
/************************************************************/
//C     struct genericHashNode
//C       {
//C        struct genericHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int needed : 1;
//C        unsigned int bucket : 29;
//C       };
struct genericHashNode
{
    genericHashNode *next;
    int count;
    uint __bitfield1;
    uint permanent() { return (__bitfield1 >> 0) & 0x1; }
    uint permanent(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint markedEphemeral() { return (__bitfield1 >> 1) & 0x1; }
    uint markedEphemeral(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint needed() { return (__bitfield1 >> 2) & 0x1; }
    uint needed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint bucket() { return (__bitfield1 >> 3) & 0x1fffffff; }
    uint bucket(uint value) { __bitfield1 = (__bitfield1 & 0xffffffff00000007) | (value << 3); return value; }
}

//C     typedef struct symbolHashNode SYMBOL_HN;
alias symbolHashNode SYMBOL_HN;
//C     typedef struct floatHashNode FLOAT_HN;
alias floatHashNode FLOAT_HN;
//C     typedef struct integerHashNode INTEGER_HN;
alias integerHashNode INTEGER_HN;
//C     typedef struct bitMapHashNode BITMAP_HN;
alias bitMapHashNode BITMAP_HN;
//C     typedef struct externalAddressHashNode EXTERNAL_ADDRESS_HN;
alias externalAddressHashNode EXTERNAL_ADDRESS_HN;
//C     typedef struct genericHashNode GENERIC_HN;
alias genericHashNode GENERIC_HN;

/**********************************************************/
/* EPHEMERON STRUCTURE: Data structure used to keep track */
/*   of ephemeral symbols, floats, and integers.          */
/*                                                        */
/*   associatedValue: Contains a pointer to the storage   */
/*   structure for the symbol, float, or integer which is */
/*   ephemeral.                                           */
/*                                                        */
/*   next: Contains a pointer to the next ephemeral item  */
/*   in a list of ephemeral items.                        */
/**********************************************************/
//C     struct ephemeron
//C       {
//C        GENERIC_HN *associatedValue;
//C        struct ephemeron *next;
//C       };
struct ephemeron
{
    GENERIC_HN *associatedValue;
    ephemeron *next;
}

/************************************************************/
/* symbolMatch STRUCTURE:                               */
/************************************************************/
//C     struct symbolMatch
//C       {
//C        struct symbolHashNode *match;
//C        struct symbolMatch *next;
//C       };
struct symbolMatch
{
    symbolHashNode *match;
    symbolMatch *next;
}

//C     #define ValueToString(target) (((struct symbolHashNode *) (target))->contents)
//C     #define ValueToDouble(target) (((struct floatHashNode *) (target))->contents)
//C     #define ValueToLong(target) (((struct integerHashNode *) (target))->contents)
//C     #define ValueToInteger(target) ((int) (((struct integerHashNode *) (target))->contents))
//C     #define ValueToBitMap(target) ((void *) ((struct bitMapHashNode *) (target))->contents)
//C     #define ValueToPointer(target) ((void *) target)
//C     #define ValueToExternalAddress(target) ((void *) ((struct externalAddressHashNode *) (target))->externalAddress)

//C     #define EnvValueToString(theEnv,target) (((struct symbolHashNode *) (target))->contents)
//C     #define EnvValueToDouble(theEnv,target) (((struct floatHashNode *) (target))->contents)
//C     #define EnvValueToLong(theEnv,target) (((struct integerHashNode *) (target))->contents)
//C     #define EnvValueToInteger(theEnv,target) ((int) (((struct integerHashNode *) (target))->contents))
//C     #define EnvValueToBitMap(theEnv,target) ((void *) ((struct bitMapHashNode *) (target))->contents)
//C     #define EnvValueToPointer(theEnv,target) ((void *) target)
//C     #define EnvValueToExternalAddress(theEnv,target) ((void *) ((struct externalAddressHashNode *) (target))->externalAddress)

//C     #define IncrementSymbolCount(theValue) (((SYMBOL_HN *) theValue)->count++)
//C     #define IncrementFloatCount(theValue) (((FLOAT_HN *) theValue)->count++)
//C     #define IncrementIntegerCount(theValue) (((INTEGER_HN *) theValue)->count++)
//C     #define IncrementBitMapCount(theValue) (((BITMAP_HN *) theValue)->count++)
//C     #define IncrementExternalAddressCount(theValue) (((EXTERNAL_ADDRESS_HN *) theValue)->count++)

/*==================*/
/* ENVIRONMENT DATA */
/*==================*/

//C     #define SYMBOL_DATA 49

const SYMBOL_DATA = 49;
//C     struct symbolData
//C       { 
//C        void *TrueSymbolHN;
//C        void *FalseSymbolHN;
//C        void *PositiveInfinity;
//C        void *NegativeInfinity;
//C        void *Zero;
//C        SYMBOL_HN **SymbolTable;
//C        FLOAT_HN **FloatTable;
//C        INTEGER_HN **IntegerTable;
//C        BITMAP_HN **BitMapTable;
//C        EXTERNAL_ADDRESS_HN **ExternalAddressTable;
//C     #if BLOAD || BLOAD_ONLY || BLOAD_AND_BSAVE || BLOAD_INSTANCES || BSAVE_INSTANCES
//C        long NumberOfSymbols;
//C        long NumberOfFloats;
//C        long NumberOfIntegers;
//C        long NumberOfBitMaps;
//C        long NumberOfExternalAddresses;
//C        SYMBOL_HN **SymbolArray;
//C        struct floatHashNode **FloatArray;
//C        INTEGER_HN **IntegerArray;
//C        BITMAP_HN **BitMapArray;
//C        EXTERNAL_ADDRESS_HN **ExternalAddressArray;
//C     #endif
//C       };
struct symbolData
{
    void *TrueSymbolHN;
    void *FalseSymbolHN;
    void *PositiveInfinity;
    void *NegativeInfinity;
    void *Zero;
    SYMBOL_HN **SymbolTable;
    FLOAT_HN **FloatTable;
    INTEGER_HN **IntegerTable;
    BITMAP_HN **BitMapTable;
    EXTERNAL_ADDRESS_HN **ExternalAddressTable;
    int NumberOfSymbols;
    int NumberOfFloats;
    int NumberOfIntegers;
    int NumberOfBitMaps;
    int NumberOfExternalAddresses;
    SYMBOL_HN **SymbolArray;
    floatHashNode **FloatArray;
    INTEGER_HN **IntegerArray;
    BITMAP_HN **BitMapArray;
    EXTERNAL_ADDRESS_HN **ExternalAddressArray;
}

//C     #define SymbolData(theEnv) ((struct symbolData *) GetEnvironmentData(theEnv,SYMBOL_DATA))

//C        LOCALE void                           InitializeAtomTables(void *,struct symbolHashNode **,struct floatHashNode **,
//C                                                                   struct integerHashNode **,struct bitMapHashNode **,
//C                                                                   struct externalAddressHashNode **);
void  InitializeAtomTables(void *, symbolHashNode **, floatHashNode **, integerHashNode **, bitMapHashNode **, externalAddressHashNode **);
//C        LOCALE void                          *EnvAddSymbol(void *,const char *);
void * EnvAddSymbol(void *, char *);
//C        LOCALE SYMBOL_HN                     *FindSymbolHN(void *,const char *);
SYMBOL_HN * FindSymbolHN(void *, char *);
//C        LOCALE void                          *EnvAddDouble(void *,double);
void * EnvAddDouble(void *, double );
//C        LOCALE void                          *EnvAddLong(void *,long long);
void * EnvAddLong(void *, long );
//C        LOCALE void                          *EnvAddBitMap(void *,void *,unsigned);
void * EnvAddBitMap(void *, void *, uint );
//C        LOCALE void                          *EnvAddExternalAddress(void *,void *,unsigned);
void * EnvAddExternalAddress(void *, void *, uint );
//C        LOCALE INTEGER_HN                    *FindLongHN(void *,long long);
INTEGER_HN * FindLongHN(void *, long );
//C        LOCALE unsigned long                  HashSymbol(const char *,unsigned long);
uint  HashSymbol(char *, uint );
//C        LOCALE unsigned long                  HashFloat(double,unsigned long);
uint  HashFloat(double , uint );
//C        LOCALE unsigned long                  HashInteger(long long,unsigned long);
uint  HashInteger(long , uint );
//C        LOCALE unsigned long                  HashBitMap(const char *,unsigned long,unsigned);
uint  HashBitMap(char *, uint , uint );
//C        LOCALE unsigned long                  HashExternalAddress(void *,unsigned long);
uint  HashExternalAddress(void *, uint );
//C        LOCALE void                           DecrementSymbolCount(void *,struct symbolHashNode *);
void  DecrementSymbolCount(void *, symbolHashNode *);
//C        LOCALE void                           DecrementFloatCount(void *,struct floatHashNode *);
void  DecrementFloatCount(void *, floatHashNode *);
//C        LOCALE void                           DecrementIntegerCount(void *,struct integerHashNode *);
void  DecrementIntegerCount(void *, integerHashNode *);
//C        LOCALE void                           DecrementBitMapCount(void *,struct bitMapHashNode *);
void  DecrementBitMapCount(void *, bitMapHashNode *);
//C        LOCALE void                           DecrementExternalAddressCount(void *,struct externalAddressHashNode *);
void  DecrementExternalAddressCount(void *, externalAddressHashNode *);
//C        LOCALE void                           RemoveEphemeralAtoms(void *);
void  RemoveEphemeralAtoms(void *);
//C        LOCALE struct symbolHashNode        **GetSymbolTable(void *);
symbolHashNode ** GetSymbolTable(void *);
//C        LOCALE void                           SetSymbolTable(void *,struct symbolHashNode **);
void  SetSymbolTable(void *, symbolHashNode **);
//C        LOCALE struct floatHashNode          **GetFloatTable(void *);
floatHashNode ** GetFloatTable(void *);
//C        LOCALE void                           SetFloatTable(void *,struct floatHashNode **);
void  SetFloatTable(void *, floatHashNode **);
//C        LOCALE struct integerHashNode       **GetIntegerTable(void *);
integerHashNode ** GetIntegerTable(void *);
//C        LOCALE void                           SetIntegerTable(void *,struct integerHashNode **);
void  SetIntegerTable(void *, integerHashNode **);
//C        LOCALE struct bitMapHashNode        **GetBitMapTable(void *);
bitMapHashNode ** GetBitMapTable(void *);
//C        LOCALE void                           SetBitMapTable(void *,struct bitMapHashNode **);
void  SetBitMapTable(void *, bitMapHashNode **);
//C        LOCALE struct externalAddressHashNode        
//C                                            **GetExternalAddressTable(void *);
externalAddressHashNode ** GetExternalAddressTable(void *);
//C        LOCALE void                           SetExternalAddressTable(void *,struct externalAddressHashNode **);
void  SetExternalAddressTable(void *, externalAddressHashNode **);
//C        LOCALE void                           RefreshSpecialSymbols(void *);
void  RefreshSpecialSymbols(void *);
//C        LOCALE struct symbolMatch            *FindSymbolMatches(void *,const char *,unsigned *,size_t *);
symbolMatch * FindSymbolMatches(void *, char *, uint *, size_t *);
//C        LOCALE void                           ReturnSymbolMatches(void *,struct symbolMatch *);
void  ReturnSymbolMatches(void *, symbolMatch *);
//C        LOCALE SYMBOL_HN                     *GetNextSymbolMatch(void *,const char *,size_t,SYMBOL_HN *,int,size_t *);
SYMBOL_HN * GetNextSymbolMatch(void *, char *, size_t , SYMBOL_HN *, int , size_t *);
//C        LOCALE void                           ClearBitString(void *,unsigned);
void  ClearBitString(void *, uint );
//C        LOCALE void                           SetAtomicValueIndices(void *,int);
void  SetAtomicValueIndices(void *, int );
//C        LOCALE void                           RestoreAtomicValueBuckets(void *);
void  RestoreAtomicValueBuckets(void *);
//C        LOCALE void                          *EnvFalseSymbol(void *);
void * EnvFalseSymbol(void *);
//C        LOCALE void                          *EnvTrueSymbol(void *);
void * EnvTrueSymbol(void *);
//C        LOCALE void                           EphemerateValue(void *,int,void *);
void  EphemerateValue(void *, int , void *);
//C        LOCALE void                           EphemerateMultifield(void *,struct multifield *);
void  EphemerateMultifield(void *, multifield *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                          *AddDouble(double);
//C        LOCALE void                          *AddLong(long long);
//C        LOCALE void                          *AddSymbol(const char *);
//C        LOCALE void                          *FalseSymbol(void);
//C        LOCALE void                          *TrueSymbol(void);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_symbol */



//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _ENVRNMNT_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #define USER_ENVIRONMENT_DATA 70
//C     #define MAXIMUM_ENVIRONMENT_POSITIONS 100
const USER_ENVIRONMENT_DATA = 70;

const MAXIMUM_ENVIRONMENT_POSITIONS = 100;
//C     struct environmentCleanupFunction
//C       {
//C        const char *name;
//C        void (*func)(void *);
//C        int priority;
//C        struct environmentCleanupFunction *next;
//C       };
struct environmentCleanupFunction
{
    char *name;
    void  function(void *)func;
    int priority;
    environmentCleanupFunction *next;
}

//C     struct environmentData
//C       {   
//C        unsigned int initialized : 1;
//C        unsigned long environmentIndex;
//C        void *context;
//C        void *routerContext;
//C        void *functionContext;
//C        void *callbackContext;
//C        void **theData;
//C        void (**cleanupFunctions)(void *);
//C        struct environmentCleanupFunction *listOfCleanupEnvironmentFunctions;
//C        struct environmentData *next;
//C       };
struct environmentData
{
    uint __bitfield1;
    uint initialized() { return (__bitfield1 >> 0) & 0x1; }
    uint initialized(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint environmentIndex;
    void *context;
    void *routerContext;
    void *functionContext;
    void *callbackContext;
    void **theData;
    void  function(void *)*cleanupFunctions;
    environmentCleanupFunction *listOfCleanupEnvironmentFunctions;
    environmentData *next;
}

//C     typedef struct environmentData ENVIRONMENT_DATA;
alias environmentData ENVIRONMENT_DATA;
//C     typedef struct environmentData * ENVIRONMENT_DATA_PTR;
alias environmentData *ENVIRONMENT_DATA_PTR;

//C     #define GetEnvironmentData(theEnv,position) (((struct environmentData *) theEnv)->theData[position])
//C     #define SetEnvironmentData(theEnv,position,value) (((struct environmentData *) theEnv)->theData[position] = value)

//C        LOCALE intBool                        AllocateEnvironmentData(void *,unsigned int,unsigned long,void (*)(void *));
int  AllocateEnvironmentData(void *, uint , uint , void  function(void *));
//C        LOCALE intBool                        DeallocateEnvironmentData(void);
int  DeallocateEnvironmentData();
//C     #if ALLOW_ENVIRONMENT_GLOBALS
//C        LOCALE void                           SetCurrentEnvironment(void *);
//C        LOCALE intBool                        SetCurrentEnvironmentByIndex(unsigned long);
//C        LOCALE void                          *GetEnvironmentByIndex(unsigned long);
//C        LOCALE void                          *GetCurrentEnvironment(void);
//C        LOCALE unsigned long                  GetEnvironmentIndex(void *);
//C     #endif
//C        LOCALE void                          *CreateEnvironment(void);
void * CreateEnvironment();
//C        LOCALE void                          *CreateRuntimeEnvironment(struct symbolHashNode **,struct floatHashNode **,
//C                                                                       struct integerHashNode **,struct bitMapHashNode **);
void * CreateRuntimeEnvironment(symbolHashNode **, floatHashNode **, integerHashNode **, bitMapHashNode **);
//C        LOCALE intBool                        DestroyEnvironment(void *);
int  DestroyEnvironment(void *);
//C        LOCALE intBool                        AddEnvironmentCleanupFunction(void *,const char *,void (*)(void *),int);
int  AddEnvironmentCleanupFunction(void *, char *, void  function(void *), int );
//C        LOCALE void                          *GetEnvironmentContext(void *);
void * GetEnvironmentContext(void *);
//C        LOCALE void                          *SetEnvironmentContext(void *,void *);
void * SetEnvironmentContext(void *, void *);
//C        LOCALE void                          *GetEnvironmentRouterContext(void *);
void * GetEnvironmentRouterContext(void *);
//C        LOCALE void                          *SetEnvironmentRouterContext(void *,void *);
void * SetEnvironmentRouterContext(void *, void *);
//C        LOCALE void                          *GetEnvironmentFunctionContext(void *);
void * GetEnvironmentFunctionContext(void *);
//C        LOCALE void                          *SetEnvironmentFunctionContext(void *,void *);
void * SetEnvironmentFunctionContext(void *, void *);
//C        LOCALE void                          *GetEnvironmentCallbackContext(void *);
void * GetEnvironmentCallbackContext(void *);
//C        LOCALE void                          *SetEnvironmentCallbackContext(void *,void *);
void * SetEnvironmentCallbackContext(void *, void *);

//C     #endif /* _H_envrnmnt */


/*************************************************/
/* Any user defined global setup information can */
/* be included in the file usrsetup.h which is   */
/* an empty file in the baseline version.        */
/*************************************************/

//C     #include "usrsetup.h"


//C     #endif	/* _H_setup */










//C     #ifndef _H_argacces
//C     #include "argacces.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*             ARGUMENT ACCESS HEADER FILE             */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides access routines for accessing arguments */
/*   passed to user or system functions defined using the    */
/*   DefineFunction protocol.                                */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added IllegalLogicalNameMessage function.      */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_argacces

//C     #define _H_argacces

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*                DEFMODULE HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose: Defines basic defmodule primitive functions such */
/*   as allocating and deallocating, traversing, and finding */
/*   defmodule data structures.                              */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_moduldef
//C     #define _H_moduldef

//C     struct defmodule;
//C     struct portItem;
//C     struct defmoduleItemHeader;
//C     struct moduleItem;

//C     #ifndef _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #define _STDIO_INCLUDED_
//C     #endif

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*           CONSTRUCT COMPILER HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Modifications to use the system constant       */
/*            FILENAME_MAX to check file name lengths.       */
/*            DR0856                                         */
/*                                                           */
/*            Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Used EnvClear rather than Clear in             */
/*            InitCImage initialization code.                */
/*                                                           */
/*            Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Removed SHORT_LINK_NAMES code as this option   */
/*            is no longer supported.                        */
/*                                                           */
/*            Support for run-time programs directly passing */
/*            the hash tables for initialization.            */
/*                                                           */
/*      6.30: Added path name argument to constructs-to-c.   */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW, MAC_MCW, */
/*            IBM_TBC, IBM_MSC, IBM_ICB, IBM_ZTC, and        */
/*            IBM_SC).                                       */
/*                                                           */
/*            Use genstrcpy instead of strcpy.               */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_conscomp
//C     #define _H_conscomp

//C     #define ArbitraryPrefix(codeItem,i)    (codeItem)->arrayNames[(i)]

//C     #define ModulePrefix(codeItem)         (codeItem)->arrayNames[0]
//C     #define ConstructPrefix(codeItem)      (codeItem)->arrayNames[1]

//C     #ifndef _H_constrct
//C     #include "constrct.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*                  CONSTRUCT MODULE                   */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Changed garbage collection algorithm.          */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added code for capturing errors/warnings       */
/*            (EnvSetParserErrorCallback).                   */
/*                                                           */
/*            Fixed issue with save function when multiple   */
/*            defmodules exist.                              */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*            Added code to prevent a clear command from     */
/*            being executed during fact assertions via      */
/*            Increment/DecrementClearReadyLocks API.        */
/*                                                           */
/*            Added code to keep track of pointers to        */
/*            constructs that are contained externally to    */
/*            to constructs, DanglingConstructs.             */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_constrct

//C     #define _H_constrct

//C     struct constructHeader;
//C     struct construct;

//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #include "userdata.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                USER DATA HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for attaching user data to constructs,  */
/*   facts, instances, user functions, etc.                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_userdata
//C     #define _H_userdata

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _USERDATA_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C     struct userData
//C       {
//C        unsigned char dataID;
//C        struct userData *next;
//C       };

//C     typedef struct userData USER_DATA;
//C     typedef struct userData * USER_DATA_PTR;
  
//C     struct userDataRecord
//C       {
//C        unsigned char dataID;
//C        void *(*createUserData)(void *);
//C        void (*deleteUserData)(void *,void *);
//C       };
  
//C     typedef struct userDataRecord USER_DATA_RECORD;
//C     typedef struct userDataRecord * USER_DATA_RECORD_PTR;

//C     #define MAXIMUM_USER_DATA_RECORDS 100

//C     #define USER_DATA_DATA 56

//C     struct userDataData
//C       { 
//C        struct userDataRecord *UserDataRecordArray[MAXIMUM_USER_DATA_RECORDS];
//C        unsigned char UserDataRecordCount;
//C       };

//C     #define UserDataData(theEnv) ((struct userDataData *) GetEnvironmentData(theEnv,USER_DATA_DATA))

//C        LOCALE void                           InitializeUserDataData(void *);
//C        LOCALE unsigned char                  InstallUserDataRecord(void *,struct userDataRecord *);
//C        LOCALE struct userData               *FetchUserData(void *,unsigned char,struct userData **);
//C        LOCALE struct userData               *TestUserData(unsigned char,struct userData *);
//C        LOCALE void                           ClearUserDataList(void *,struct userData *);
//C        LOCALE struct userData               *DeleteUserData(void *,unsigned char,struct userData *);

//C     #endif


//C     struct constructHeader
//C       {
//C        struct symbolHashNode *name;
//C        const char *ppForm;
//C        struct defmoduleItemHeader *whichModule;
//C        long bsaveID;
//C        struct constructHeader *next;
//C        struct userData *usrData;
//C       };
struct constructHeader
{
    symbolHashNode *name;
    char *ppForm;
    defmoduleItemHeader *whichModule;
    int bsaveID;
    constructHeader *next;
    userData *usrData;
}

//C     #define CHS (struct constructHeader *)

//C     struct construct
//C       {
//C        const char *constructName;
//C        const char *pluralName;
//C        int (*parseFunction)(void *,const char *);
//C        void *(*findFunction)(void *,const char *);
//C        struct symbolHashNode *(*getConstructNameFunction)(struct constructHeader *);
//C        const char *(*getPPFormFunction)(void *,struct constructHeader *);
//C        struct defmoduleItemHeader *(*getModuleItemFunction)(struct constructHeader *);
//C        void *(*getNextItemFunction)(void *,void *);
//C        void (*setNextItemFunction)(struct constructHeader *,struct constructHeader *);
//C        intBool (*isConstructDeletableFunction)(void *,void *);
//C        int (*deleteFunction)(void *,void *);
//C        void (*freeFunction)(void *,void *);
//C        struct construct *next;
//C       };
struct construct
{
    char *constructName;
    char *pluralName;
    int  function(void *, char *)parseFunction;
    void * function(void *, char *)findFunction;
    symbolHashNode * function(constructHeader *)getConstructNameFunction;
    char * function(void *, constructHeader *)getPPFormFunction;
    defmoduleItemHeader * function(constructHeader *)getModuleItemFunction;
    void * function(void *, void *)getNextItemFunction;
    void  function(constructHeader *, constructHeader *)setNextItemFunction;
    int  function(void *, void *)isConstructDeletableFunction;
    int  function(void *, void *)deleteFunction;
    void  function(void *, void *)freeFunction;
    construct *next;
}

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_scanner
//C     #include "scanner.h"
//C     #endif

//C     #define CONSTRUCT_DATA 42

const CONSTRUCT_DATA = 42;
//C     struct constructData
//C       { 
//C        int ClearReadyInProgress;
//C        int ClearInProgress;
//C        int ResetReadyInProgress;
//C        int ResetInProgress;
//C        short ClearReadyLocks;
//C        int DanglingConstructs;
//C     #if (! RUN_TIME) && (! BLOAD_ONLY)
//C        struct callFunctionItem *ListOfSaveFunctions;
//C        intBool PrintWhileLoading;
//C        unsigned WatchCompilations;
//C        int CheckSyntaxMode;
//C        int ParsingConstruct;
//C        char *ErrorString;
//C        char *WarningString;
//C        char *ParsingFileName;
//C        char *ErrorFileName;
//C        char *WarningFileName;
//C        long ErrLineNumber;
//C        long WrnLineNumber;
//C        int errorCaptureRouterCount;
//C        size_t MaxErrChars;
//C        size_t CurErrPos;
//C        size_t MaxWrnChars;
//C        size_t CurWrnPos;
//C        void (*ParserErrorCallback)(void *,const char *,const char *,const char *,long);
//C     #endif
//C        struct construct *ListOfConstructs;
//C        struct callFunctionItem *ListOfResetFunctions;
//C        struct callFunctionItem *ListOfClearFunctions;
//C        struct callFunctionItem *ListOfClearReadyFunctions;
//C        int Executing;
//C        int (*BeforeResetFunction)(void *);
//C       };
struct constructData
{
    int ClearReadyInProgress;
    int ClearInProgress;
    int ResetReadyInProgress;
    int ResetInProgress;
    short ClearReadyLocks;
    int DanglingConstructs;
    callFunctionItem *ListOfSaveFunctions;
    int PrintWhileLoading;
    uint WatchCompilations;
    int CheckSyntaxMode;
    int ParsingConstruct;
    char *ErrorString;
    char *WarningString;
    char *ParsingFileName;
    char *ErrorFileName;
    char *WarningFileName;
    int ErrLineNumber;
    int WrnLineNumber;
    int errorCaptureRouterCount;
    size_t MaxErrChars;
    size_t CurErrPos;
    size_t MaxWrnChars;
    size_t CurWrnPos;
    void  function(void *, char *, char *, char *, int )ParserErrorCallback;
    construct *ListOfConstructs;
    callFunctionItem *ListOfResetFunctions;
    callFunctionItem *ListOfClearFunctions;
    callFunctionItem *ListOfClearReadyFunctions;
    int Executing;
    int  function(void *)BeforeResetFunction;
}

//C     #define ConstructData(theEnv) ((struct constructData *) GetEnvironmentData(theEnv,CONSTRUCT_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CONSTRCT_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           EnvClear(void *);
void  EnvClear(void *);
//C        LOCALE void                           EnvReset(void *);
void  EnvReset(void *);
//C        LOCALE int                            EnvSave(void *,const char *);
int  EnvSave(void *, char *);

//C        LOCALE void                           InitializeConstructData(void *);
void  InitializeConstructData(void *);
//C        LOCALE intBool                        AddSaveFunction(void *,const char *,void (*)(void *,void *,const char *),int);
int  AddSaveFunction(void *, char *, void  function(void *, void *, char *), int );
//C        LOCALE intBool                        RemoveSaveFunction(void *,const char *);
int  RemoveSaveFunction(void *, char *);
//C        LOCALE intBool                        EnvAddResetFunction(void *,const char *,void (*)(void *),int);
int  EnvAddResetFunction(void *, char *, void  function(void *), int );
//C        LOCALE intBool                        EnvRemoveResetFunction(void *,const char *);
int  EnvRemoveResetFunction(void *, char *);
//C        LOCALE intBool                        AddClearReadyFunction(void *,const char *,int (*)(void *),int);
int  AddClearReadyFunction(void *, char *, int  function(void *), int );
//C        LOCALE intBool                        RemoveClearReadyFunction(void *,const char *);
int  RemoveClearReadyFunction(void *, char *);
//C        LOCALE intBool                        EnvAddClearFunction(void *,const char *,void (*)(void *),int);
int  EnvAddClearFunction(void *, char *, void  function(void *), int );
//C        LOCALE intBool                        EnvRemoveClearFunction(void *,const char *);
int  EnvRemoveClearFunction(void *, char *);
//C        LOCALE void                           EnvIncrementClearReadyLocks(void *);
void  EnvIncrementClearReadyLocks(void *);
//C        LOCALE void                           EnvDecrementClearReadyLocks(void *);
void  EnvDecrementClearReadyLocks(void *);
//C        LOCALE struct construct              *AddConstruct(void *,const char *,const char *,
//C                                                           int (*)(void *,const char *),
//C                                                           void *(*)(void *,const char *),
//C                                                           SYMBOL_HN *(*)(struct constructHeader *),
//C                                                           const char *(*)(void *,struct constructHeader *),
//C                                                           struct defmoduleItemHeader *(*)(struct constructHeader *),
//C                                                           void *(*)(void *,void *),
//C                                                           void (*)(struct constructHeader *,struct constructHeader *),
//C                                                           intBool (*)(void *,void *),
//C                                                           int (*)(void *,void *),
//C                                                           void (*)(void *,void *));
construct * AddConstruct(void *, char *, char *, int  function(void *, char *), void * function(void *, char *), SYMBOL_HN * function(constructHeader *), char * function(void *, constructHeader *), defmoduleItemHeader * function(constructHeader *), void * function(void *, void *), void  function(constructHeader *, constructHeader *), int  function(void *, void *), int  function(void *, void *), void  function(void *, void *));
//C        LOCALE int                            RemoveConstruct(void *,const char *);
int  RemoveConstruct(void *, char *);
//C        LOCALE void                           SetCompilationsWatch(void *,unsigned);
void  SetCompilationsWatch(void *, uint );
//C        LOCALE unsigned                       GetCompilationsWatch(void *);
uint  GetCompilationsWatch(void *);
//C        LOCALE void                           SetPrintWhileLoading(void *,intBool);
void  SetPrintWhileLoading(void *, int );
//C        LOCALE intBool                        GetPrintWhileLoading(void *);
int  GetPrintWhileLoading(void *);
//C        LOCALE int                            ExecutingConstruct(void *);
int  ExecutingConstruct(void *);
//C        LOCALE void                           SetExecutingConstruct(void *,int);
void  SetExecutingConstruct(void *, int );
//C        LOCALE void                           InitializeConstructs(void *);
void  InitializeConstructs(void *);
//C        LOCALE int                          (*SetBeforeResetFunction(void *,int (*)(void *)))(void *);
int  function(void *) SetBeforeResetFunction(void *, int  function(void *));
//C        LOCALE void                           ResetCommand(void *);
void  ResetCommand(void *);
//C        LOCALE void                           ClearCommand(void *);
void  ClearCommand(void *);
//C        LOCALE intBool                        ClearReady(void *);
int  ClearReady(void *);
//C        LOCALE struct construct              *FindConstruct(void *,const char *);
construct * FindConstruct(void *, char *);
//C        LOCALE void                           DeinstallConstructHeader(void *,struct constructHeader *);
void  DeinstallConstructHeader(void *, constructHeader *);
//C        LOCALE void                           DestroyConstructHeader(void *,struct constructHeader *);
void  DestroyConstructHeader(void *, constructHeader *);
//C        LOCALE void                         (*EnvSetParserErrorCallback(void *theEnv,
//C                                                                        void (*functionPtr)(void *,const char *,const char *,
//C                                                                                            const char *,long)))
//C                                                 (void *,const char *,const char *,const char*,long);
void  function(void *, char *, char *, char *, int ) EnvSetParserErrorCallback(void *theEnv, void  function(void *, char *, char *, char *, int )functionPtr);


//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        AddClearFunction(const char *,void (*)(void),int);
//C        LOCALE intBool                        AddResetFunction(const char *,void (*)(void),int);
//C        LOCALE void                           Clear(void);
//C        LOCALE void                           Reset(void);
//C        LOCALE intBool                        RemoveClearFunction(const char *);
//C        LOCALE intBool                        RemoveResetFunction(const char *);
//C     #if (! RUN_TIME) && (! BLOAD_ONLY)
//C        LOCALE int                            Save(const char *);
//C     #endif

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_constrct */




//C     #endif
//C     #ifndef _H_extnfunc
//C     #include "extnfunc.h"
//C     #endif
//C     #ifndef _H_symblcmp
//C     #include "symblcmp.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*        SYMBOL CONSTRUCT COMPILER HEADER FILE        */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements the constructs-to-c feature for       */
/*   atomic data values: symbols, integers, floats, and      */
/*   bit maps.                                               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*                                                           */
/*            Corrected code to remove compiler warnings.    */
/*                                                           */
/*      6.30: Added support for path name argument to        */
/*            constructs-to-c.                               */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_symblcmp
//C     #define _H_symblcmp

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _SYMBLCMP_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                     PrintSymbolReference(void *,FILE *,SYMBOL_HN *);
void  PrintSymbolReference(void *, FILE *, SYMBOL_HN *);
//C        LOCALE void                     PrintFloatReference(void *,FILE *,FLOAT_HN *);
void  PrintFloatReference(void *, FILE *, FLOAT_HN *);
//C        LOCALE void                     PrintIntegerReference(void *,FILE *,INTEGER_HN *);
void  PrintIntegerReference(void *, FILE *, INTEGER_HN *);
//C        LOCALE void                     PrintBitMapReference(void *,FILE *,BITMAP_HN *);
void  PrintBitMapReference(void *, FILE *, BITMAP_HN *);
//C        LOCALE void                     AtomicValuesToCode(void *,const char *,const char *,char *);
void  AtomicValuesToCode(void *, char *, char *, char *);

//C     #endif /* _H_symblcmp */


//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif

//C     #define CONSTRUCT_COMPILER_DATA 41

const CONSTRUCT_COMPILER_DATA = 41;
//C     struct CodeGeneratorItem
//C       {
//C        const char *name;
//C        void (*beforeFunction)(void *);
//C        void (*initFunction)(void *,FILE *,int,int);
//C        int (*generateFunction)(void *,const char *,const char *,char *,int,FILE *,int,int);
//C        int priority;
//C        char **arrayNames;
//C        int arrayCount;
//C        struct CodeGeneratorItem *next;
//C       };
struct CodeGeneratorItem
{
    char *name;
    void  function(void *)beforeFunction;
    void  function(void *, FILE *, int , int )initFunction;
    int  function(void *, char *, char *, char *, int , FILE *, int , int )generateFunction;
    int priority;
    char **arrayNames;
    int arrayCount;
    CodeGeneratorItem *next;
}

//C     struct constructCompilerData
//C       { 
//C        int ImageID;
//C        FILE *HeaderFP;
//C        int MaxIndices;
//C        FILE *ExpressionFP;
//C        FILE *FixupFP;
//C        const char *FilePrefix;
//C        const char *PathName;
//C        char *FileNameBuffer;
//C        intBool ExpressionHeader;
//C        long ExpressionCount;
//C        int ExpressionVersion;
//C        int CodeGeneratorCount;
//C        struct CodeGeneratorItem *ListOfCodeGeneratorItems;
//C       };
struct constructCompilerData
{
    int ImageID;
    FILE *HeaderFP;
    int MaxIndices;
    FILE *ExpressionFP;
    FILE *FixupFP;
    char *FilePrefix;
    char *PathName;
    char *FileNameBuffer;
    int ExpressionHeader;
    int ExpressionCount;
    int ExpressionVersion;
    int CodeGeneratorCount;
    CodeGeneratorItem *ListOfCodeGeneratorItems;
}

//C     #define ConstructCompilerData(theEnv) ((struct constructCompilerData *) GetEnvironmentData(theEnv,CONSTRUCT_COMPILER_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     struct CodeGeneratorFile
//C      {
//C       const char *filePrefix;
//C       const char *pathName;
//C       char *fileNameBuffer;
//C       int id,version;
//C      };
struct CodeGeneratorFile
{
    char *filePrefix;
    char *pathName;
    char *fileNameBuffer;
    int id;
    int version_;
}

//C     #ifdef _CONSCOMP_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                      InitializeConstructCompilerData(void *);
void  InitializeConstructCompilerData(void *);
//C        LOCALE void                      ConstructsToCCommandDefinition(void *);
void  ConstructsToCCommandDefinition(void *);
//C        LOCALE FILE                     *NewCFile(void *,const char *,const char *,char *,int,int,int);
FILE * NewCFile(void *, char *, char *, char *, int , int , int );
//C        LOCALE int                       ExpressionToCode(void *,FILE *,struct expr *);
int  ExpressionToCode(void *, FILE *, expr *);
//C        LOCALE void                      PrintFunctionReference(void *,FILE *,struct FunctionDefinition *);
void  PrintFunctionReference(void *, FILE *, FunctionDefinition *);
//C        LOCALE struct CodeGeneratorItem *AddCodeGeneratorItem(void *,const char *,int,
//C                                                              void (*)(void *),
//C                                                              void (*)(void *,FILE *,int,int),
//C                                                              int (*)(void *,const char *,const char *,char *,int,FILE *,int,int),int);
CodeGeneratorItem * AddCodeGeneratorItem(void *, char *, int , void  function(void *), void  function(void *, FILE *, int , int ), int  function(void *, char *, char *, char *, int , FILE *, int , int ), int );
//C        LOCALE FILE                     *CloseFileIfNeeded(void *,FILE *,int *,int *,int,int *,struct CodeGeneratorFile *);
FILE * CloseFileIfNeeded(void *, FILE *, int *, int *, int , int *, CodeGeneratorFile *);
//C        LOCALE FILE                     *OpenFileIfNeeded(void *,FILE *,const char *,const char *,char *,int,int,int *,
//C                                                          int,FILE *,const char *,char *,int,struct CodeGeneratorFile *);
FILE * OpenFileIfNeeded(void *, FILE *, char *, char *, char *, int , int , int *, int , FILE *, char *, char *, int , CodeGeneratorFile *);
//C        LOCALE void                      MarkConstructBsaveIDs(void *,int);
void  MarkConstructBsaveIDs(void *, int );
//C        LOCALE void                      ConstructHeaderToCode(void *,FILE *,struct constructHeader *,int,int,
//C                                                              int,const char *,const char *);
void  ConstructHeaderToCode(void *, FILE *, constructHeader *, int , int , int , char *, char *);
//C        LOCALE void                      ConstructModuleToCode(void *,FILE *,struct defmodule *,int,int,
//C                                                              int,const char *);
void  ConstructModuleToCode(void *, FILE *, defmodule *, int , int , int , char *);
//C        LOCALE void                      PrintHashedExpressionReference(void *,FILE *,struct expr *,int,int);
void  PrintHashedExpressionReference(void *, FILE *, expr *, int , int );

//C     #endif




//C     #endif
//C     #ifndef _H_modulpsr
//C     #include "modulpsr.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             DEFMODULE PARSER HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: GetConstructNameAndComment API change.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Fixed linkage issue when DEFMODULE_CONSTRUCT   */
/*            compiler flag is set to 0.                     */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_modulpsr
//C     #define _H_modulpsr

//C     struct portConstructItem
//C       {
//C        const char *constructName;
//C        int typeExpected;
//C        struct portConstructItem *next;
//C       };
struct portConstructItem
{
    char *constructName;
    int typeExpected;
    portConstructItem *next;
}

//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _MODULPSR_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE long                           GetNumberOfDefmodules(void *);
int  GetNumberOfDefmodules(void *);
//C        LOCALE void                           SetNumberOfDefmodules(void *,long);
void  SetNumberOfDefmodules(void *, int );
//C        LOCALE void                           AddAfterModuleDefinedFunction(void *,const char *,void (*)(void *),int);
void  AddAfterModuleDefinedFunction(void *, char *, void  function(void *), int );
//C        LOCALE int                            ParseDefmodule(void *,const char *);
int  ParseDefmodule(void *, char *);
//C        LOCALE void                           AddPortConstructItem(void *,const char *,int);
void  AddPortConstructItem(void *, char *, int );
//C        LOCALE struct portConstructItem      *ValidPortConstructItem(void *,const char *);
portConstructItem * ValidPortConstructItem(void *, char *);
//C        LOCALE int                            FindImportExportConflict(void *,const char *,struct defmodule *,const char *);
int  FindImportExportConflict(void *, char *, defmodule *, char *);

//C     #endif /* _H_modulpsr */


//C     #endif
//C     #ifndef _H_utility
//C     #include "utility.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*                 UTILITY HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a set of utility functions useful to    */
/*   other modules. Primarily these are the functions for    */
/*   handling periodic garbage collection and appending      */
/*   string data.                                            */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added CopyString, DeleteString,                */
/*            InsertInString,and EnlargeString functions.    */
/*                                                           */
/*            Used genstrncpy function instead of strncpy    */
/*            function.                                      */
/*                                                           */
/*            Support for typed EXTERNAL_ADDRESS.            */
/*                                                           */
/*            Support for tracked memory (allows memory to   */
/*            be freed if CLIPS is exited while executing).  */
/*                                                           */
/*            Added UTF-8 routines.                          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_utility
//C     #define _H_utility

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     struct callFunctionItem
//C       {
//C        const char *name;
//C        void (*func)(void *);
//C        int priority;
//C        struct callFunctionItem *next;
//C        short int environmentAware;
//C        void *context;
//C       };
struct callFunctionItem
{
    char *name;
    void  function(void *)func;
    int priority;
    callFunctionItem *next;
    short environmentAware;
    void *context;
}

//C     struct callFunctionItemWithArg
//C       {
//C        const char *name;
//C        void (*func)(void *,void *);
//C        int priority;
//C        struct callFunctionItemWithArg *next;
//C        short int environmentAware;
//C        void *context;
//C       };
struct callFunctionItemWithArg
{
    char *name;
    void  function(void *, void *)func;
    int priority;
    callFunctionItemWithArg *next;
    short environmentAware;
    void *context;
}
  
//C     struct trackedMemory
//C       {
//C        void *theMemory;
//C        struct trackedMemory *next;
//C        struct trackedMemory *prev;
//C        size_t memSize;
//C       };
struct trackedMemory
{
    void *theMemory;
    trackedMemory *next;
    trackedMemory *prev;
    size_t memSize;
}

//C     struct garbageFrame
//C       {
//C        short dirty;
//C        short topLevel;
//C        struct garbageFrame *priorFrame;
//C        struct ephemeron *ephemeralSymbolList;
//C        struct ephemeron *ephemeralFloatList;
//C        struct ephemeron *ephemeralIntegerList;
//C        struct ephemeron *ephemeralBitMapList;
//C        struct ephemeron *ephemeralExternalAddressList;
//C        struct multifield *ListOfMultifields;
//C        struct multifield *LastMultifield;
//C       };
struct garbageFrame
{
    short dirty;
    short topLevel;
    garbageFrame *priorFrame;
    ephemeron *ephemeralSymbolList;
    ephemeron *ephemeralFloatList;
    ephemeron *ephemeralIntegerList;
    ephemeron *ephemeralBitMapList;
    ephemeron *ephemeralExternalAddressList;
    multifield *ListOfMultifields;
    multifield *LastMultifield;
}

//C     #define UTILITY_DATA 55

const UTILITY_DATA = 55;
//C     struct utilityData
//C       { 
//C        struct callFunctionItem *ListOfCleanupFunctions;
//C        struct callFunctionItem *ListOfPeriodicFunctions;
//C        short GarbageCollectionLocks;
//C        short PeriodicFunctionsEnabled;
//C        short YieldFunctionEnabled;
//C        void (*YieldTimeFunction)(void);
//C        struct trackedMemory *trackList;
//C        struct garbageFrame MasterGarbageFrame;
//C        struct garbageFrame *CurrentGarbageFrame;
//C       };
struct utilityData
{
    callFunctionItem *ListOfCleanupFunctions;
    callFunctionItem *ListOfPeriodicFunctions;
    short GarbageCollectionLocks;
    short PeriodicFunctionsEnabled;
    short YieldFunctionEnabled;
    void  function()YieldTimeFunction;
    trackedMemory *trackList;
    garbageFrame MasterGarbageFrame;
    garbageFrame *CurrentGarbageFrame;
}

//C     #define UtilityData(theEnv) ((struct utilityData *) GetEnvironmentData(theEnv,UTILITY_DATA))

  /* Is c the start of a utf8 sequence? */
//C     #define IsUTF8Start(ch) (((ch) & 0xC0) != 0x80)
//C     #define IsUTF8MultiByteStart(ch) ((((unsigned char) ch) >= 0xC0) && (((unsigned char) ch) <= 0xF7))
//C     #define IsUTF8MultiByteContinuation(ch) ((((unsigned char) ch) >= 0x80) && (((unsigned char) ch) <= 0xBF))

//C     #ifdef _UTILITY_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeUtilityData(void *);
void  InitializeUtilityData(void *);
//C        LOCALE intBool                        AddCleanupFunction(void *,const char *,void (*)(void *),int);
int  AddCleanupFunction(void *, char *, void  function(void *), int );
//C        LOCALE intBool                        EnvAddPeriodicFunction(void *,const char *,void (*)(void *),int);
int  EnvAddPeriodicFunction(void *, char *, void  function(void *), int );
//C        LOCALE intBool                        AddPeriodicFunction(const char *,void (*)(void),int);
int  AddPeriodicFunction(char *, void  function(), int );
//C        LOCALE intBool                        RemoveCleanupFunction(void *,const char *);
int  RemoveCleanupFunction(void *, char *);
//C        LOCALE intBool                        EnvRemovePeriodicFunction(void *,const char *);
int  EnvRemovePeriodicFunction(void *, char *);
//C        LOCALE char                          *CopyString(void *,const char *);
char * CopyString(void *, char *);
//C        LOCALE void                           DeleteString(void *,char *);
void  DeleteString(void *, char *);
//C        LOCALE const char                    *AppendStrings(void *,const char *,const char *);
char * AppendStrings(void *, char *, char *);
//C        LOCALE const char                    *StringPrintForm(void *,const char *);
char * StringPrintForm(void *, char *);
//C        LOCALE char                          *AppendToString(void *,const char *,char *,size_t *,size_t *);
char * AppendToString(void *, char *, char *, size_t *, size_t *);
//C        LOCALE char                          *InsertInString(void *,const char *,size_t,char *,size_t *,size_t *);
char * InsertInString(void *, char *, size_t , char *, size_t *, size_t *);
//C        LOCALE char                          *AppendNToString(void *,const char *,char *,size_t,size_t *,size_t *);
char * AppendNToString(void *, char *, char *, size_t , size_t *, size_t *);
//C        LOCALE char                          *EnlargeString(void *,size_t,char *,size_t *,size_t *);
char * EnlargeString(void *, size_t , char *, size_t *, size_t *);
//C        LOCALE char                          *ExpandStringWithChar(void *,int,char *,size_t *,size_t *,size_t);
char * ExpandStringWithChar(void *, int , char *, size_t *, size_t *, size_t );
//C        LOCALE struct callFunctionItem       *AddFunctionToCallList(void *,const char *,int,void (*)(void *),
//C                                                                    struct callFunctionItem *,intBool);
callFunctionItem * AddFunctionToCallList(void *, char *, int , void  function(void *), callFunctionItem *, int );
//C        LOCALE struct callFunctionItem       *AddFunctionToCallListWithContext(void *,const char *,int,void (*)(void *),
//C                                                                               struct callFunctionItem *,intBool,void *);
callFunctionItem * AddFunctionToCallListWithContext(void *, char *, int , void  function(void *), callFunctionItem *, int , void *);
//C        LOCALE struct callFunctionItem       *RemoveFunctionFromCallList(void *,const char *,
//C                                                                  struct callFunctionItem *,
//C                                                                  int *);
callFunctionItem * RemoveFunctionFromCallList(void *, char *, callFunctionItem *, int *);
//C        LOCALE void                           DeallocateCallList(void *,struct callFunctionItem *);
void  DeallocateCallList(void *, callFunctionItem *);
//C        LOCALE struct callFunctionItemWithArg *AddFunctionToCallListWithArg(void *,const char *,int,void (*)(void *, void *),
//C                                                                            struct callFunctionItemWithArg *,intBool);
callFunctionItemWithArg * AddFunctionToCallListWithArg(void *, char *, int , void  function(void *, void *), callFunctionItemWithArg *, int );
//C        LOCALE struct callFunctionItemWithArg *AddFunctionToCallListWithArgWithContext(void *,const char *,int,void (*)(void *, void *),
//C                                                                                       struct callFunctionItemWithArg *,intBool,void *);
callFunctionItemWithArg * AddFunctionToCallListWithArgWithContext(void *, char *, int , void  function(void *, void *), callFunctionItemWithArg *, int , void *);
//C        LOCALE struct callFunctionItemWithArg *RemoveFunctionFromCallListWithArg(void *,const char *,
//C                                                                                 struct callFunctionItemWithArg *,
//C                                                                                 int *);
callFunctionItemWithArg * RemoveFunctionFromCallListWithArg(void *, char *, callFunctionItemWithArg *, int *);
//C        LOCALE void                           DeallocateCallListWithArg(void *,struct callFunctionItemWithArg *);
void  DeallocateCallListWithArg(void *, callFunctionItemWithArg *);
//C        LOCALE unsigned long                  ItemHashValue(void *,unsigned short,void *,unsigned long);
uint  ItemHashValue(void *, ushort , void *, uint );
//C        LOCALE void                           YieldTime(void *);
void  YieldTime(void *);
//C        LOCALE void                           EnvIncrementGCLocks(void *);
void  EnvIncrementGCLocks(void *);
//C        LOCALE void                           EnvDecrementGCLocks(void *);
void  EnvDecrementGCLocks(void *);
//C        LOCALE short                          EnablePeriodicFunctions(void *,short);
short  EnablePeriodicFunctions(void *, short );
//C        LOCALE short                          EnableYieldFunction(void *,short);
short  EnableYieldFunction(void *, short );
//C        LOCALE struct trackedMemory          *AddTrackedMemory(void *,void *,size_t);
trackedMemory * AddTrackedMemory(void *, void *, size_t );
//C        LOCALE void                           RemoveTrackedMemory(void *,struct trackedMemory *);
void  RemoveTrackedMemory(void *, trackedMemory *);
//C        LOCALE void                           UTF8Increment(const char *,size_t *);
void  UTF8Increment(char *, size_t *);
//C        LOCALE size_t                         UTF8Offset(const char *,size_t);
size_t  UTF8Offset(char *, size_t );
//C        LOCALE size_t                         UTF8Length(const char *);
size_t  UTF8Length(char *);
//C        LOCALE size_t                         UTF8CharNum(const char *,size_t);
size_t  UTF8CharNum(char *, size_t );
//C        LOCALE void                           RestorePriorGarbageFrame(void *,struct garbageFrame *,struct garbageFrame *,struct dataObject *);
void  RestorePriorGarbageFrame(void *, garbageFrame *, garbageFrame *, dataObject *);
//C        LOCALE void                           CallCleanupFunctions(void *);
void  CallCleanupFunctions(void *);
//C        LOCALE void                           CallPeriodicTasks(void *);
void  CallPeriodicTasks(void *);
//C        LOCALE void                           CleanCurrentGarbageFrame(void *,struct dataObject *);
void  CleanCurrentGarbageFrame(void *, dataObject *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           IncrementGCLocks(void);
//C        LOCALE void                           DecrementGCLocks(void);
//C        LOCALE intBool                        RemovePeriodicFunction(const char *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_utility */




//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif

/**********************************************************************/
/* defmodule                                                          */
/* ----------                                                         */
/* name: The name of the defmodule (stored as a reference in the      */
/*   table).                                                          */
/*                                                                    */
/* ppForm: The pretty print representation of the defmodule (used by  */
/*   the save and ppdefmodule commands).                              */
/*                                                                    */
/* itemsArray: An array of pointers to the module specific data used  */
/*   by each construct specified with the RegisterModuleItem          */
/*   function. The data pointer stored in the array is allocated by   */
/*   the allocateFunction in moduleItem data structure.               */
/*                                                                    */
/* importList: The list of items which are being imported by this     */
/*   module from other modules.                                       */
/*                                                                    */
/* next: A pointer to the next defmodule data structure.              */
/**********************************************************************/
//C     struct defmodule
//C       {
//C        struct symbolHashNode *name;
//C        char *ppForm;
//C        struct defmoduleItemHeader **itemsArray;
//C        struct portItem *importList;
//C        struct portItem *exportList;
//C        unsigned visitedFlag;
//C        long bsaveID;
//C        struct userData *usrData;
//C        struct defmodule *next;
//C       };
struct defmodule
{
    symbolHashNode *name;
    char *ppForm;
    defmoduleItemHeader **itemsArray;
    portItem *importList;
    portItem *exportList;
    uint visitedFlag;
    int bsaveID;
    userData *usrData;
    defmodule *next;
}

//C     struct portItem
//C       {
//C        struct symbolHashNode *moduleName;
//C        struct symbolHashNode *constructType;
//C        struct symbolHashNode *constructName;
//C        struct portItem *next;
//C       };
struct portItem
{
    symbolHashNode *moduleName;
    symbolHashNode *constructType;
    symbolHashNode *constructName;
    portItem *next;
}

//C     struct defmoduleItemHeader
//C       {
//C        struct defmodule *theModule;
//C        struct constructHeader *firstItem;
//C        struct constructHeader *lastItem;
//C       };
struct defmoduleItemHeader
{
    defmodule *theModule;
    constructHeader *firstItem;
    constructHeader *lastItem;
}

//C     #define MIHS (struct defmoduleItemHeader *)

/**********************************************************************/
/* moduleItem                                                         */
/* ----------                                                         */
/* name: The name of the construct which can be placed in a module.   */
/*   For example, "defrule".                                          */
/*                                                                    */
/* allocateFunction: Used to allocate a data structure containing all */
/*   pertinent information related to a specific construct for a      */
/*   given module. For example, the deffacts construct stores a       */
/*   pointer to the first and last deffacts for each each module.     */
/*                                                                    */
/* freeFunction: Used to deallocate a data structure allocated by     */
/*   the allocateFunction. In addition, the freeFunction deletes      */
/*   all constructs of the specified type in the given module.        */
/*                                                                    */
/* bloadModuleReference: Used during a binary load to establish a     */
/*   link between the defmodule data structure and the data structure */
/*   containing all pertinent module information for a specific       */
/*   construct.                                                       */
/*                                                                    */
/* findFunction: Used to determine if a specified construct is in a   */
/*   specific module. The name is the specific construct is passed as */
/*   a string and the function returns a pointer to the specified     */
/*   construct if it exists.                                          */
/*                                                                    */
/* exportable: If TRUE, then the specified construct type can be      */
/*   exported (and hence imported). If FALSE, it can't be exported.   */
/*                                                                    */
/* next: A pointer to the next moduleItem data structure.             */
/**********************************************************************/

//C     struct moduleItem
//C       {
//C        const char *name;
//C        int moduleIndex;
//C        void *(*allocateFunction)(void *);
//C        void  (*freeFunction)(void *,void *);
//C        void *(*bloadModuleReference)(void *,int);
//C        void  (*constructsToCModuleReference)(void *,FILE *,int,int,int);
//C        void *(*findFunction)(void *,const char *);
//C        struct moduleItem *next;
//C       };
struct moduleItem
{
    char *name;
    int moduleIndex;
    void * function(void *)allocateFunction;
    void  function(void *, void *)freeFunction;
    void * function(void *, int )bloadModuleReference;
    void  function(void *, FILE *, int , int , int )constructsToCModuleReference;
    void * function(void *, char *)findFunction;
    moduleItem *next;
}

//C     typedef struct moduleStackItem
//C       {
//C        intBool changeFlag;
//C        struct defmodule *theModule;
//C        struct moduleStackItem *next;
//C       } MODULE_STACK_ITEM;
struct moduleStackItem
{
    int changeFlag;
    defmodule *theModule;
    moduleStackItem *next;
}
alias moduleStackItem MODULE_STACK_ITEM;

//C     #define DEFMODULE_DATA 4

const DEFMODULE_DATA = 4;
//C     struct defmoduleData
//C       {   
//C        struct moduleItem *LastModuleItem;
//C        struct callFunctionItem *AfterModuleChangeFunctions;
//C        MODULE_STACK_ITEM *ModuleStack;
//C        intBool CallModuleChangeFunctions;
//C        struct defmodule *ListOfDefmodules;
//C        struct defmodule *CurrentModule;
//C        struct defmodule *LastDefmodule;
//C        int NumberOfModuleItems;
//C        struct moduleItem *ListOfModuleItems;
//C        long ModuleChangeIndex;
//C        int MainModuleRedefinable;
//C     #if (! RUN_TIME) && (! BLOAD_ONLY)
//C        struct portConstructItem *ListOfPortConstructItems;
//C        long NumberOfDefmodules;
//C        struct callFunctionItem *AfterModuleDefinedFunctions;
//C     #endif
//C     #if CONSTRUCT_COMPILER && (! RUN_TIME)
//C        struct CodeGeneratorItem *DefmoduleCodeItem;
//C     #endif
//C     #if (BLOAD || BLOAD_ONLY || BLOAD_AND_BSAVE) && (! RUN_TIME)
//C        long BNumberOfDefmodules;
//C        long NumberOfPortItems;
//C        struct portItem *PortItemArray;
//C        struct defmodule *DefmoduleArray;
//C     #endif
//C       };
struct defmoduleData
{
    moduleItem *LastModuleItem;
    callFunctionItem *AfterModuleChangeFunctions;
    MODULE_STACK_ITEM *ModuleStack;
    int CallModuleChangeFunctions;
    defmodule *ListOfDefmodules;
    defmodule *CurrentModule;
    defmodule *LastDefmodule;
    int NumberOfModuleItems;
    moduleItem *ListOfModuleItems;
    int ModuleChangeIndex;
    int MainModuleRedefinable;
    portConstructItem *ListOfPortConstructItems;
    int NumberOfDefmodules;
    callFunctionItem *AfterModuleDefinedFunctions;
    CodeGeneratorItem *DefmoduleCodeItem;
    int BNumberOfDefmodules;
    int NumberOfPortItems;
    portItem *PortItemArray;
    defmodule *DefmoduleArray;
}
  
//C     #define DefmoduleData(theEnv) ((struct defmoduleData *) GetEnvironmentData(theEnv,DEFMODULE_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _MODULDEF_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeDefmodules(void *);
void  InitializeDefmodules(void *);
//C        LOCALE void                          *EnvFindDefmodule(void *,const char *);
void * EnvFindDefmodule(void *, char *);
//C        LOCALE const char                    *EnvGetDefmoduleName(void *,void *);
char * EnvGetDefmoduleName(void *, void *);
//C        LOCALE const char                    *EnvGetDefmodulePPForm(void *,void *);
char * EnvGetDefmodulePPForm(void *, void *);
//C        LOCALE void                          *EnvGetNextDefmodule(void *,void *);
void * EnvGetNextDefmodule(void *, void *);
//C        LOCALE void                           RemoveAllDefmodules(void *);
void  RemoveAllDefmodules(void *);
//C        LOCALE int                            AllocateModuleStorage(void);
int  AllocateModuleStorage();
//C        LOCALE int                            RegisterModuleItem(void *,const char *,
//C                                                                 void *(*)(void *),
//C                                                                 void (*)(void *,void *),
//C                                                                 void *(*)(void *,int),
//C                                                                 void (*)(void *,FILE *,int,int,int),
//C                                                                 void *(*)(void *,const char *));
int  RegisterModuleItem(void *, char *, void * function(void *), void  function(void *, void *), void * function(void *, int ), void  function(void *, FILE *, int , int , int ), void * function(void *, char *));
//C        LOCALE void                          *GetModuleItem(void *,struct defmodule *,int);
void * GetModuleItem(void *, defmodule *, int );
//C        LOCALE void                           SetModuleItem(void *,struct defmodule *,int,void *);
void  SetModuleItem(void *, defmodule *, int , void *);
//C        LOCALE void                          *EnvGetCurrentModule(void *);
void * EnvGetCurrentModule(void *);
//C        LOCALE void                          *EnvSetCurrentModule(void *,void *);
void * EnvSetCurrentModule(void *, void *);
//C        LOCALE void                          *GetCurrentModuleCommand(void *);
void * GetCurrentModuleCommand(void *);
//C        LOCALE void                          *SetCurrentModuleCommand(void *);
void * SetCurrentModuleCommand(void *);
//C        LOCALE int                            GetNumberOfModuleItems(void *);
int  GetNumberOfModuleItems(void *);
//C        LOCALE void                           CreateMainModule(void *);
void  CreateMainModule(void *);
//C        LOCALE void                           SetListOfDefmodules(void *,void *);
void  SetListOfDefmodules(void *, void *);
//C        LOCALE struct moduleItem             *GetListOfModuleItems(void *);
moduleItem * GetListOfModuleItems(void *);
//C        LOCALE struct moduleItem             *FindModuleItem(void *,const char *);
moduleItem * FindModuleItem(void *, char *);
//C        LOCALE void                           SaveCurrentModule(void *);
void  SaveCurrentModule(void *);
//C        LOCALE void                           RestoreCurrentModule(void *);
void  RestoreCurrentModule(void *);
//C        LOCALE void                           AddAfterModuleChangeFunction(void *,const char *,void (*)(void *),int);
void  AddAfterModuleChangeFunction(void *, char *, void  function(void *), int );
//C        LOCALE void                           IllegalModuleSpecifierMessage(void *);
void  IllegalModuleSpecifierMessage(void *);
//C        LOCALE void                           AllocateDefmoduleGlobals(void *);
void  AllocateDefmoduleGlobals(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                          *FindDefmodule(const char *);
//C        LOCALE void                          *GetCurrentModule(void);
//C        LOCALE const char                    *GetDefmoduleName(void *);
//C        LOCALE const char                    *GetDefmodulePPForm(void *);
//C        LOCALE void                          *GetNextDefmodule(void *);
//C        LOCALE void                          *SetCurrentModule(void *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_moduldef */


//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _ARGACCES_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE int                            EnvRtnArgCount(void *);
int  EnvRtnArgCount(void *);
//C        LOCALE int                            EnvArgCountCheck(void *,const char *,int,int);
int  EnvArgCountCheck(void *, char *, int , int );
//C        LOCALE int                            EnvArgRangeCheck(void *,const char *,int,int);
int  EnvArgRangeCheck(void *, char *, int , int );
//C        LOCALE const char                    *EnvRtnLexeme(void *,int);
char * EnvRtnLexeme(void *, int );
//C        LOCALE double                         EnvRtnDouble(void *,int);
double  EnvRtnDouble(void *, int );
//C        LOCALE long long                      EnvRtnLong(void *,int);
long  EnvRtnLong(void *, int );
//C        LOCALE struct dataObject             *EnvRtnUnknown(void *,int,struct dataObject *);
dataObject * EnvRtnUnknown(void *, int , dataObject *);
//C        LOCALE int                            EnvArgTypeCheck(void *,const char *,int,int,struct dataObject *);
int  EnvArgTypeCheck(void *, char *, int , int , dataObject *);
//C        LOCALE intBool                        GetNumericArgument(void *,struct expr *,const char *,struct dataObject *,int,int);
int  GetNumericArgument(void *, expr *, char *, dataObject *, int , int );
//C        LOCALE const char                    *GetLogicalName(void *,int,const char *);
char * GetLogicalName(void *, int , char *);
//C        LOCALE const char                    *GetFileName(void *,const char *,int);
char * GetFileName(void *, char *, int );
//C        LOCALE const char                    *GetConstructName(void *,const char *,const char *);
char * GetConstructName(void *, char *, char *);
//C        LOCALE void                           ExpectedCountError(void *,const char *,int,int);
void  ExpectedCountError(void *, char *, int , int );
//C        LOCALE void                           OpenErrorMessage(void *,const char *,const char *);
void  OpenErrorMessage(void *, char *, char *);
//C        LOCALE intBool                        CheckFunctionArgCount(void *,const char *,const char *,int);
int  CheckFunctionArgCount(void *, char *, char *, int );
//C        LOCALE void                           ExpectedTypeError1(void *,const char *,int,const char *);
void  ExpectedTypeError1(void *, char *, int , char *);
//C        LOCALE void                           ExpectedTypeError2(void *,const char *,int);
void  ExpectedTypeError2(void *, char *, int );
//C        LOCALE struct defmodule              *GetModuleName(void *,const char *,int,int *);
defmodule * GetModuleName(void *, char *, int , int *);
//C        LOCALE void                          *GetFactOrInstanceArgument(void *,int,DATA_OBJECT *,const char *);
void * GetFactOrInstanceArgument(void *, int , DATA_OBJECT *, char *);
//C        LOCALE void                           IllegalLogicalNameMessage(void *,const char *);
void  IllegalLogicalNameMessage(void *, char *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C       LOCALE int                             ArgCountCheck(const char *,int,int);
//C       LOCALE int                             ArgRangeCheck(const char *,int,int);
//C       LOCALE int                             ArgTypeCheck(const char *,int,int,DATA_OBJECT_PTR);
//C       LOCALE int                             RtnArgCount(void);
//C       LOCALE double                          RtnDouble(int);
//C       LOCALE const char                     *RtnLexeme(int);
//C       LOCALE long long                       RtnLong(int);
//C       LOCALE DATA_OBJECT_PTR                 RtnUnknown(int,DATA_OBJECT_PTR);

//C     #endif

//C     #endif






//C     #endif
//C     #include "constant.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/05/15            */
   /*                                                     */
   /*                CONSTANTS HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Moved default type constants (NO_DEFAULT,      */
/*            STATIC_DEFAULT, and DYNAMIC_DEFAULT) to        */
/*            constant.h                                     */
/*                                                           */
/*            Added DATA_OBJECT_ARRAY primitive type.        */
/*                                                           */
/*            Added NESTED_RHS constant.                     */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_constant

//C     #define _H_constant

//C     #ifndef FALSE
//C     #define FALSE 0
//C     #endif
//C     #ifndef TRUE
//C     #define TRUE 1
//C     #endif

//C     #define EXACTLY       0
//C     #define AT_LEAST      1
//C     #define NO_MORE_THAN  2
//C     #define RANGE         3

//C     #define OFF           0
//C     #define ON            1
//C     #define LHS           0
//C     #define RHS           1
//C     #define NESTED_RHS    2
//C     #define NEGATIVE      0
//C     #define POSITIVE      1
//C     #define EOS        '\0'

//C     #define INSIDE        0
//C     #define OUTSIDE       1

//C     #define LESS_THAN     0
//C     #define GREATER_THAN  1
//C     #define EQUAL         2

//C     #define GLOBAL_SAVE   0
//C     #define LOCAL_SAVE    1
//C     #define VISIBLE_SAVE  2

//C     #define NO_DEFAULT      0
//C     #define STATIC_DEFAULT  1
//C     #define DYNAMIC_DEFAULT 2

//C     #ifndef WPROMPT_STRING
//C     #define WPROMPT_STRING "wclips"
//C     #endif

//C     #ifndef APPLICATION_NAME
//C     #define APPLICATION_NAME "CLIPS"
//C     #endif

//C     #ifndef COMMAND_PROMPT
//C     #define COMMAND_PROMPT "CLIPS> "
//C     #endif

//C     #ifndef VERSION_STRING
//C     #define VERSION_STRING "6.30"
//C     #endif

//C     #ifndef CREATION_DATE_STRING
//C     #define CREATION_DATE_STRING "3/17/15"
//C     #endif

//C     #ifndef BANNER_STRING
//C     #define BANNER_STRING "         CLIPS (6.30 3/17/15)\n"
//C     #endif

/*************************/
/* TOKEN AND TYPE VALUES */
/*************************/

//C     #define OBJECT_TYPE_NAME               "OBJECT"
//C     #define USER_TYPE_NAME                 "USER"
//C     #define PRIMITIVE_TYPE_NAME            "PRIMITIVE"
//C     #define NUMBER_TYPE_NAME               "NUMBER"
//C     #define INTEGER_TYPE_NAME              "INTEGER"
//C     #define FLOAT_TYPE_NAME                "FLOAT"
//C     #define SYMBOL_TYPE_NAME               "SYMBOL"
//C     #define STRING_TYPE_NAME               "STRING"
//C     #define MULTIFIELD_TYPE_NAME           "MULTIFIELD"
//C     #define LEXEME_TYPE_NAME               "LEXEME"
//C     #define ADDRESS_TYPE_NAME              "ADDRESS"
//C     #define EXTERNAL_ADDRESS_TYPE_NAME     "EXTERNAL-ADDRESS"
//C     #define FACT_ADDRESS_TYPE_NAME         "FACT-ADDRESS"
//C     #define INSTANCE_TYPE_NAME             "INSTANCE"
//C     #define INSTANCE_NAME_TYPE_NAME        "INSTANCE-NAME"
//C     #define INSTANCE_ADDRESS_TYPE_NAME     "INSTANCE-ADDRESS"

/*************************************************************************/
/* The values of these constants should not be changed.  They are set to */
/* start after the primitive type codes in CONSTANT.H.  These codes are  */
/* used to let the generic function bsave image be used whether COOL is  */
/* present or not.                                                       */
/*************************************************************************/

//C     #define OBJECT_TYPE_CODE                9
//C     #define PRIMITIVE_TYPE_CODE            10
//C     #define NUMBER_TYPE_CODE               11
//C     #define LEXEME_TYPE_CODE               12
//C     #define ADDRESS_TYPE_CODE              13
//C     #define INSTANCE_TYPE_CODE             14

/****************************************************/
/* The first 9 primitive types need to retain their */
/* values!! Sorted arrays depend on their values!!  */
/****************************************************/

//C     #define FLOAT                           0
//C     #define INTEGER                         1
//C     #define SYMBOL                          2
//C     #define STRING                          3
//C     #define MULTIFIELD                      4
//C     #define EXTERNAL_ADDRESS                5
//C     #define FACT_ADDRESS                    6
//C     #define INSTANCE_ADDRESS                7
//C     #define INSTANCE_NAME                   8

//C     #define FCALL                          30
//C     #define GCALL                          31
//C     #define PCALL                          32
//C     #define GBL_VARIABLE                   33
//C     #define MF_GBL_VARIABLE                34

//C     #define SF_VARIABLE                    35
//C     #define MF_VARIABLE                    36
//C     #define SF_WILDCARD                    37
//C     #define MF_WILDCARD                    38
//C     #define BITMAPARRAY                    39
//C     #define DATA_OBJECT_ARRAY              40

//C     #define FACT_PN_CMP1                   50
//C     #define FACT_JN_CMP1                   51
//C     #define FACT_JN_CMP2                   52
//C     #define FACT_SLOT_LENGTH               53
//C     #define FACT_PN_VAR1                   54
//C     #define FACT_PN_VAR2                   55
//C     #define FACT_PN_VAR3                   56
//C     #define FACT_JN_VAR1                   57
//C     #define FACT_JN_VAR2                   58
//C     #define FACT_JN_VAR3                   59
//C     #define FACT_PN_CONSTANT1              60
//C     #define FACT_PN_CONSTANT2              61
//C     #define FACT_STORE_MULTIFIELD          62
//C     #define DEFTEMPLATE_PTR                63

//C     #define OBJ_GET_SLOT_PNVAR1            70
//C     #define OBJ_GET_SLOT_PNVAR2            71
//C     #define OBJ_GET_SLOT_JNVAR1            72
//C     #define OBJ_GET_SLOT_JNVAR2            73
//C     #define OBJ_SLOT_LENGTH                74
//C     #define OBJ_PN_CONSTANT                75
//C     #define OBJ_PN_CMP1                    76
//C     #define OBJ_JN_CMP1                    77
//C     #define OBJ_PN_CMP2                    78
//C     #define OBJ_JN_CMP2                    79
//C     #define OBJ_PN_CMP3                    80
//C     #define OBJ_JN_CMP3                    81
//C     #define DEFCLASS_PTR                   82
//C     #define HANDLER_GET                    83
//C     #define HANDLER_PUT                    84

//C     #define DEFGLOBAL_PTR                  90

//C     #define PROC_PARAM                     95
//C     #define PROC_WILD_PARAM                96
//C     #define PROC_GET_BIND                  97
//C     #define PROC_BIND                      98

//C     #define PATTERN_CE                    150
//C     #define AND_CE                        151
//C     #define OR_CE                         152
//C     #define NOT_CE                        153
//C     #define TEST_CE                       154
//C     #define NAND_CE                       155
//C     #define EXISTS_CE                     156
//C     #define FORALL_CE                     157

//C     #define NOT_CONSTRAINT                160
//C     #define AND_CONSTRAINT                161
//C     #define OR_CONSTRAINT                 162
//C     #define PREDICATE_CONSTRAINT          163
//C     #define RETURN_VALUE_CONSTRAINT       164

//C     #define LPAREN                        170
//C     #define RPAREN                        171
//C     #define STOP                          172
//C     #define UNKNOWN_VALUE                 173

//C     #define RVOID                         175

//C     #define INTEGER_OR_FLOAT              180
//C     #define SYMBOL_OR_STRING              181
//C     #define INSTANCE_OR_INSTANCE_NAME     182

//C     typedef long int FACT_ID;

/*************************/
/* Macintosh Definitions */
/*************************/

//C     #define CREATOR_STRING "CLIS"
//C     #define CREATOR_CODE   'CLIS'

//C     #endif






//C     #include "memalloc.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/05/15            */
   /*                                                     */
   /*            MEMORY ALLOCATION HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Memory allocation routines.                      */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed HaltExecution check from the           */
/*            EnvReleaseMem function. DR0863                 */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove compiler warnings.    */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems.                   */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Removed genlongalloc/genlongfree functions.    */
/*                                                           */
/*            Added get_mem and rtn_mem macros.              */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Removed deallocating message parameter from    */
/*            EnvReleaseMem.                                 */
/*                                                           */
/*            Removed support for BLOCK_MEMORY.              */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_memalloc

//C     #include <string.h>
import core.stdc.string;

//C     #define _H_memalloc

//C     struct chunkInfo;
//C     struct blockInfo;
//C     struct memoryPtr;

//C     #ifndef MEM_TABLE_SIZE
//C     #define MEM_TABLE_SIZE 500
//C     #endif
const MEM_TABLE_SIZE = 500;

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _MEMORY_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     struct chunkInfo
//C       {
//C        struct chunkInfo *prevChunk;
//C        struct chunkInfo *nextFree;
//C        struct chunkInfo *lastFree;
//C        long int size;
//C       };
struct chunkInfo
{
    chunkInfo *prevChunk;
    chunkInfo *nextFree;
    chunkInfo *lastFree;
    int size;
}

//C     struct blockInfo
//C       {
//C        struct blockInfo *nextBlock;
//C        struct blockInfo *prevBlock;
//C        struct chunkInfo *nextFree;
//C        long int size;
//C       };
struct blockInfo
{
    blockInfo *nextBlock;
    blockInfo *prevBlock;
    chunkInfo *nextFree;
    int size;
}

//C     struct memoryPtr
//C       {
//C        struct memoryPtr *next;
//C       };
struct memoryPtr
{
    memoryPtr *next;
}

//C     #if (MEM_TABLE_SIZE > 0)
/*
 * Normal memory management case
 */

//C     #define get_struct(theEnv,type)   ((MemoryData(theEnv)->MemoryTable[sizeof(struct type)] == NULL) ?    ((struct type *) genalloc(theEnv,sizeof(struct type))) :   ((MemoryData(theEnv)->TempMemoryPtr = MemoryData(theEnv)->MemoryTable[sizeof(struct type)]),    MemoryData(theEnv)->MemoryTable[sizeof(struct type)] = MemoryData(theEnv)->TempMemoryPtr->next,    ((struct type *) MemoryData(theEnv)->TempMemoryPtr)))

//C     #define rtn_struct(theEnv,type,struct_ptr)   (MemoryData(theEnv)->TempMemoryPtr = (struct memoryPtr *) struct_ptr,   MemoryData(theEnv)->TempMemoryPtr->next = MemoryData(theEnv)->MemoryTable[sizeof(struct type)],    MemoryData(theEnv)->MemoryTable[sizeof(struct type)] = MemoryData(theEnv)->TempMemoryPtr)

//C     #define rtn_sized_struct(theEnv,size,struct_ptr)   (MemoryData(theEnv)->TempMemoryPtr = (struct memoryPtr *) struct_ptr,   MemoryData(theEnv)->TempMemoryPtr->next = MemoryData(theEnv)->MemoryTable[size],    MemoryData(theEnv)->MemoryTable[size] = MemoryData(theEnv)->TempMemoryPtr)

//C     #define get_var_struct(theEnv,type,vsize)   ((((sizeof(struct type) + vsize) <  MEM_TABLE_SIZE) ?     (MemoryData(theEnv)->MemoryTable[sizeof(struct type) + vsize] == NULL) : 1) ?    ((struct type *) genalloc(theEnv,(sizeof(struct type) + vsize))) :   ((MemoryData(theEnv)->TempMemoryPtr = MemoryData(theEnv)->MemoryTable[sizeof(struct type) + vsize]),    MemoryData(theEnv)->MemoryTable[sizeof(struct type) + vsize] = MemoryData(theEnv)->TempMemoryPtr->next,    ((struct type *) MemoryData(theEnv)->TempMemoryPtr)))

//C     #define rtn_var_struct(theEnv,type,vsize,struct_ptr)   (MemoryData(theEnv)->TempSize = sizeof(struct type) + vsize,    ((MemoryData(theEnv)->TempSize < MEM_TABLE_SIZE) ?     (MemoryData(theEnv)->TempMemoryPtr = (struct memoryPtr *) struct_ptr,     MemoryData(theEnv)->TempMemoryPtr->next = MemoryData(theEnv)->MemoryTable[MemoryData(theEnv)->TempSize],      MemoryData(theEnv)->MemoryTable[MemoryData(theEnv)->TempSize] =  MemoryData(theEnv)->TempMemoryPtr) :     (genfree(theEnv,(void *) struct_ptr,MemoryData(theEnv)->TempSize),(struct memoryPtr *) struct_ptr)))

//C     #define get_mem(theEnv,size)   (((size <  MEM_TABLE_SIZE) ?     (MemoryData(theEnv)->MemoryTable[size] == NULL) : 1) ?    ((struct type *) genalloc(theEnv,(size_t) (size))) :   ((MemoryData(theEnv)->TempMemoryPtr = MemoryData(theEnv)->MemoryTable[size]),    MemoryData(theEnv)->MemoryTable[size] = MemoryData(theEnv)->TempMemoryPtr->next,    ((struct type *) MemoryData(theEnv)->TempMemoryPtr)))

//C     #define rtn_mem(theEnv,size,ptr)   (MemoryData(theEnv)->TempSize = size,    ((MemoryData(theEnv)->TempSize < MEM_TABLE_SIZE) ?     (MemoryData(theEnv)->TempMemoryPtr = (struct memoryPtr *) ptr,     MemoryData(theEnv)->TempMemoryPtr->next = MemoryData(theEnv)->MemoryTable[MemoryData(theEnv)->TempSize],      MemoryData(theEnv)->MemoryTable[MemoryData(theEnv)->TempSize] =  MemoryData(theEnv)->TempMemoryPtr) :     (genfree(theEnv,(void *) ptr,MemoryData(theEnv)->TempSize),(struct memoryPtr *) ptr)))

//C     #else // MEM_TABLE_SIZE == 0
/*
 * Debug case (routes all memory management through genalloc/genfree to take advantage of
 * platform, memory debugging aids)
 */
//C     #define get_struct(theEnv,type) ((struct type *) genalloc(theEnv,sizeof(struct type)))

//C     #define rtn_struct(theEnv,type,struct_ptr) (genfree(theEnv,struct_ptr,sizeof(struct type)))

//C     #define rtn_sized_struct(theEnv,size,struct_ptr) (genfree(theEnv,struct_ptr,size))

//C     #define get_var_struct(theEnv,type,vsize) ((struct type *) genalloc(theEnv,(sizeof(struct type) + vsize)))

//C     #define rtn_var_struct(theEnv,type,vsize,struct_ptr) (genfree(theEnv,struct_ptr,sizeof(struct type)+vsize))

//C     #define get_mem(theEnv,size) ((struct type *) genalloc(theEnv,(size_t) (size)))

//C     #define rtn_mem(theEnv,size,ptr) (genfree(theEnv,ptr,size))

//C     #endif

//C     #define GenCopyMemory(type,cnt,dst,src)    memcpy((void *) (dst),(void *) (src),sizeof(type) * (size_t) (cnt))

//C     #define MEMORY_DATA 59

const MEMORY_DATA = 59;
//C     struct memoryData
//C       { 
//C        long int MemoryAmount;
//C        long int MemoryCalls;
//C        intBool ConserveMemory;
//C        int (*OutOfMemoryFunction)(void *,size_t);
//C        struct memoryPtr *TempMemoryPtr;
//C        struct memoryPtr **MemoryTable;
//C        size_t TempSize;
//C       };
struct memoryData
{
    int MemoryAmount;
    int MemoryCalls;
    int ConserveMemory;
    int  function(void *, size_t )OutOfMemoryFunction;
    memoryPtr *TempMemoryPtr;
    memoryPtr **MemoryTable;
    size_t TempSize;
}

//C     #define MemoryData(theEnv) ((struct memoryData *) GetEnvironmentData(theEnv,MEMORY_DATA))

//C        LOCALE void                           InitializeMemory(void *);
void  InitializeMemory(void *);
//C        LOCALE void                          *genalloc(void *,size_t);
void * genalloc(void *, size_t );
//C        LOCALE int                            DefaultOutOfMemoryFunction(void *,size_t);
int  DefaultOutOfMemoryFunction(void *, size_t );
//C        LOCALE int                          (*EnvSetOutOfMemoryFunction(void *,int (*)(void *,size_t)))(void *,size_t);
int  function(void *, size_t ) EnvSetOutOfMemoryFunction(void *, int  function(void *, size_t ));
//C        LOCALE int                            genfree(void *,void *,size_t);
int  genfree(void *, void *, size_t );
//C        LOCALE void                          *genrealloc(void *,void *,size_t,size_t);
void * genrealloc(void *, void *, size_t , size_t );
//C        LOCALE long                           EnvMemUsed(void *);
int  EnvMemUsed(void *);
//C        LOCALE long                           EnvMemRequests(void *);
int  EnvMemRequests(void *);
//C        LOCALE long                           UpdateMemoryUsed(void *,long int);
int  UpdateMemoryUsed(void *, int );
//C        LOCALE long                           UpdateMemoryRequests(void *,long int);
int  UpdateMemoryRequests(void *, int );
//C        LOCALE long                           EnvReleaseMem(void *,long);
int  EnvReleaseMem(void *, int );
//C        LOCALE void                          *gm1(void *,size_t);
void * gm1(void *, size_t );
//C        LOCALE void                          *gm2(void *,size_t);
void * gm2(void *, size_t );
//C        LOCALE void                          *gm3(void *,size_t);
void * gm3(void *, size_t );
//C        LOCALE int                            rm(void *,void *,size_t);
int  rm(void *, void *, size_t );
//C        LOCALE int                            rm3(void *,void *,size_t);
int  rm3(void *, void *, size_t );
//C        LOCALE unsigned long                  PoolSize(void *);
uint  PoolSize(void *);
//C        LOCALE unsigned long                  ActualPoolSize(void *);
uint  ActualPoolSize(void *);
//C        LOCALE void                          *RequestChunk(void *,size_t);
void * RequestChunk(void *, size_t );
//C        LOCALE int                            ReturnChunk(void *,void *,size_t);
int  ReturnChunk(void *, void *, size_t );
//C        LOCALE intBool                        EnvSetConserveMemory(void *,intBool);
int  EnvSetConserveMemory(void *, int );
//C        LOCALE intBool                        EnvGetConserveMemory(void *);
int  EnvGetConserveMemory(void *);
//C        LOCALE void                           genmemcpy(char *,char *,unsigned long);
void  genmemcpy(char *, char *, uint );
//C        LOCALE void                           ReturnAllBlocks(void *);
void  ReturnAllBlocks(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        GetConserveMemory(void);
//C        LOCALE long int                       MemRequests(void);
//C        LOCALE long int                       MemUsed(void);
//C        LOCALE long int                       ReleaseMem(long);
//C        LOCALE intBool                        SetConserveMemory(intBool);
//C        LOCALE int                          (*SetOutOfMemoryFunction(int (*)(void *,size_t)))(void *,size_t);
 
//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_memalloc */






//C     #include "cstrcpsr.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*              CONSTRUCT PARSER MODULE                */
   /*******************************************************/

/*************************************************************/
/* Purpose: Parsing routines and utilities for parsing       */
/*   constructs.                                             */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Made the construct redefinition message more   */
/*            prominent.                                     */
/*                                                           */
/*            Added pragmas to remove compilation warnings.  */
/*                                                           */
/*      6.30: Added code for capturing errors/warnings.      */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW, MAC_MCW, */
/*            and IBM_TBC).                                  */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            GetConstructNameAndComment API change.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_cstrcpsr

//C     #define _H_cstrcpsr

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_scanner
//C     #include "scanner.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CSTRCPSR_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #if ALLOW_ENVIRONMENT_GLOBALS
//C        LOCALE int                            Load(const char *);
//C     #endif

//C        LOCALE int                            EnvLoad(void *,const char *);
int  EnvLoad(void *, char *);
//C        LOCALE int                            LoadConstructsFromLogicalName(void *,const char *);
int  LoadConstructsFromLogicalName(void *, char *);
//C        LOCALE int                            ParseConstruct(void *,const char *,const char *);
int  ParseConstruct(void *, char *, char *);
//C        LOCALE void                           RemoveConstructFromModule(void *,struct constructHeader *);
void  RemoveConstructFromModule(void *, constructHeader *);
//C        LOCALE struct symbolHashNode         *GetConstructNameAndComment(void *,const char *,
//C                                                                         struct token *,const char *,
//C                                                                         void *(*)(void *,const char *),
//C                                                                         int (*)(void *,void *),
//C                                                                         const char *,int,int,int,int);
symbolHashNode * GetConstructNameAndComment(void *, char *, token *, char *, void * function(void *, char *), int  function(void *, void *), char *, int , int , int , int );
//C        LOCALE void                           ImportExportConflictMessage(void *,const char *,const char *,const char *,const char *);
void  ImportExportConflictMessage(void *, char *, char *, char *, char *);
//C     #if (! RUN_TIME) && (! BLOAD_ONLY)
//C        LOCALE void                           FlushParsingMessages(void *);
void  FlushParsingMessages(void *);
//C        LOCALE char                          *EnvGetParsingFileName(void *);
char * EnvGetParsingFileName(void *);
//C        LOCALE void                           EnvSetParsingFileName(void *,const char *);
void  EnvSetParsingFileName(void *, char *);
//C        LOCALE char                          *EnvGetErrorFileName(void *);
char * EnvGetErrorFileName(void *);
//C        LOCALE void                           EnvSetErrorFileName(void *,const char *);
void  EnvSetErrorFileName(void *, char *);
//C        LOCALE char                          *EnvGetWarningFileName(void *);
char * EnvGetWarningFileName(void *);
//C        LOCALE void                           EnvSetWarningFileName(void *,const char *);
void  EnvSetWarningFileName(void *, char *);
//C        LOCALE void                           CreateErrorCaptureRouter(void *);
void  CreateErrorCaptureRouter(void *);
//C        LOCALE void                           DeleteErrorCaptureRouter(void *);
void  DeleteErrorCaptureRouter(void *);
//C     #endif

//C     #endif







//C     #include "filecom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*              FILE COMMANDS HEADER FILE              */
   /*******************************************************/

/*************************************************************/
/* Purpose: Contains the code for file commands including    */
/*   batch, dribble-on, dribble-off, save, load, bsave, and  */
/*   bload.                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added code for capturing errors/warnings.      */
/*                                                           */
/*            Added AwaitingInput flag.                      */
/*                                                           */
             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_filecom

//C     #define _H_filecom

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _FILECOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           FileCommandDefinitions(void *);
void  FileCommandDefinitions(void *);
//C        LOCALE intBool                        EnvDribbleOn(void *,const char *);
int  EnvDribbleOn(void *, char *);
//C        LOCALE intBool                        EnvDribbleActive(void *);
int  EnvDribbleActive(void *);
//C        LOCALE intBool                        EnvDribbleOff(void *);
int  EnvDribbleOff(void *);
//C        LOCALE void                           SetDribbleStatusFunction(void *,int (*)(void *,int));
void  SetDribbleStatusFunction(void *, int  function(void *, int ));
//C        LOCALE int                            LLGetcBatch(void *,const char *,int);
int  LLGetcBatch(void *, char *, int );
//C        LOCALE int                            Batch(void *,const char *);
int  Batch(void *, char *);
//C        LOCALE int                            OpenBatch(void *,const char *,int);
int  OpenBatch(void *, char *, int );
//C        LOCALE int                            OpenStringBatch(void *,const char *,const char *,int);
int  OpenStringBatch(void *, char *, char *, int );
//C        LOCALE int                            RemoveBatch(void *);
int  RemoveBatch(void *);
//C        LOCALE intBool                        BatchActive(void *);
int  BatchActive(void *);
//C        LOCALE void                           CloseAllBatchSources(void *);
void  CloseAllBatchSources(void *);
//C        LOCALE int                            BatchCommand(void *);
int  BatchCommand(void *);
//C        LOCALE int                            BatchStarCommand(void *);
int  BatchStarCommand(void *);
//C        LOCALE int                            EnvBatchStar(void *,const char *);
int  EnvBatchStar(void *, char *);
//C        LOCALE int                            LoadCommand(void *);
int  LoadCommand(void *);
//C        LOCALE int                            LoadStarCommand(void *);
int  LoadStarCommand(void *);
//C        LOCALE int                            SaveCommand(void *);
int  SaveCommand(void *);
//C        LOCALE int                            DribbleOnCommand(void *);
int  DribbleOnCommand(void *);
//C        LOCALE int                            DribbleOffCommand(void *);
int  DribbleOffCommand(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        DribbleActive(void);
//C        LOCALE intBool                        DribbleOn(const char *);
//C        LOCALE intBool                        DribbleOff(void);
//C        LOCALE int                            BatchStar(const char *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_filecom */






//C     #include "strngfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             STRING FUNCTIONS HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added support for UTF-8 strings to str-length, */
/*            str-index, and sub-string functions.           */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_strngfun

//C     #define _H_strngfun

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _STRNGFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #if ALLOW_ENVIRONMENT_GLOBALS
//C        LOCALE int                            Build(const char *);
//C        LOCALE int                            Eval(const char *,DATA_OBJECT_PTR);
//C     #endif

//C        LOCALE int                            EnvBuild(void *,const char *);
int  EnvBuild(void *, char *);
//C        LOCALE int                            EnvEval(void *,const char *,DATA_OBJECT_PTR);
int  EnvEval(void *, char *, DATA_OBJECT_PTR );
//C        LOCALE void                           StringFunctionDefinitions(void *);
void  StringFunctionDefinitions(void *);
//C        LOCALE void                           StrCatFunction(void *,DATA_OBJECT_PTR);
void  StrCatFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           SymCatFunction(void *,DATA_OBJECT_PTR);
void  SymCatFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE long long                      StrLengthFunction(void *);
long  StrLengthFunction(void *);
//C        LOCALE void                           UpcaseFunction(void *,DATA_OBJECT_PTR);
void  UpcaseFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           LowcaseFunction(void *,DATA_OBJECT_PTR);
void  LowcaseFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE long long                      StrCompareFunction(void *);
long  StrCompareFunction(void *);
//C        LOCALE void                          *SubStringFunction(void *);
void * SubStringFunction(void *);
//C        LOCALE void                           StrIndexFunction(void *,DATA_OBJECT_PTR);
void  StrIndexFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           EvalFunction(void *,DATA_OBJECT_PTR);
void  EvalFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE int                            BuildFunction(void *);
int  BuildFunction(void *);
//C        LOCALE void                           StringToFieldFunction(void *,DATA_OBJECT *);
void  StringToFieldFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           StringToField(void *,const char *,DATA_OBJECT *);
void  StringToField(void *, char *, DATA_OBJECT *);

//C     #endif /* _H_strngfun */






//C     #include "envrnmnt.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                ENVRNMNT HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for supporting multiple environments.   */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added code to CreateEnvironment to free        */
/*            already allocated data if one of the malloc    */
/*            calls fail.                                    */
/*                                                           */
/*            Modified AllocateEnvironmentData to print a    */
/*            message if it was unable to allocate memory.   */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added CreateRuntimeEnvironment function.       */
/*                                                           */
/*            Added support for context information when an  */
/*            environment is created (i.e a pointer from the */
/*            CLIPS environment to its parent environment).  */
/*                                                           */
/*      6.30: Added support for passing context information  */
 
/*            to user defined functions and callback         */
/*            functions.                                     */
/*                                                           */
/*            Support for hashing EXTERNAL_ADDRESS data      */
/*            type.                                          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_envrnmnt
//C     #define _H_envrnmnt

//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _ENVRNMNT_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C     #define USER_ENVIRONMENT_DATA 70
//C     #define MAXIMUM_ENVIRONMENT_POSITIONS 100

//C     struct environmentCleanupFunction
//C       {
//C        const char *name;
//C        void (*func)(void *);
//C        int priority;
//C        struct environmentCleanupFunction *next;
//C       };

//C     struct environmentData
//C       {   
//C        unsigned int initialized : 1;
//C        unsigned long environmentIndex;
//C        void *context;
//C        void *routerContext;
//C        void *functionContext;
//C        void *callbackContext;
//C        void **theData;
//C        void (**cleanupFunctions)(void *);
//C        struct environmentCleanupFunction *listOfCleanupEnvironmentFunctions;
//C        struct environmentData *next;
//C       };

//C     typedef struct environmentData ENVIRONMENT_DATA;
//C     typedef struct environmentData * ENVIRONMENT_DATA_PTR;

//C     #define GetEnvironmentData(theEnv,position) (((struct environmentData *) theEnv)->theData[position])
//C     #define SetEnvironmentData(theEnv,position,value) (((struct environmentData *) theEnv)->theData[position] = value)

//C        LOCALE intBool                        AllocateEnvironmentData(void *,unsigned int,unsigned long,void (*)(void *));
//C        LOCALE intBool                        DeallocateEnvironmentData(void);
//C     #if ALLOW_ENVIRONMENT_GLOBALS
//C        LOCALE void                           SetCurrentEnvironment(void *);
//C        LOCALE intBool                        SetCurrentEnvironmentByIndex(unsigned long);
//C        LOCALE void                          *GetEnvironmentByIndex(unsigned long);
//C        LOCALE void                          *GetCurrentEnvironment(void);
//C        LOCALE unsigned long                  GetEnvironmentIndex(void *);
//C     #endif
//C        LOCALE void                          *CreateEnvironment(void);
//C        LOCALE void                          *CreateRuntimeEnvironment(struct symbolHashNode **,struct floatHashNode **,
//C                                                                       struct integerHashNode **,struct bitMapHashNode **);
//C        LOCALE intBool                        DestroyEnvironment(void *);
//C        LOCALE intBool                        AddEnvironmentCleanupFunction(void *,const char *,void (*)(void *),int);
//C        LOCALE void                          *GetEnvironmentContext(void *);
//C        LOCALE void                          *SetEnvironmentContext(void *,void *);
//C        LOCALE void                          *GetEnvironmentRouterContext(void *);
//C        LOCALE void                          *SetEnvironmentRouterContext(void *,void *);
//C        LOCALE void                          *GetEnvironmentFunctionContext(void *);
//C        LOCALE void                          *SetEnvironmentFunctionContext(void *,void *);
//C        LOCALE void                          *GetEnvironmentCallbackContext(void *);
//C        LOCALE void                          *SetEnvironmentCallbackContext(void *,void *);

//C     #endif /* _H_envrnmnt */

//C     #include "commline.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*              COMMAND LINE HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a set of routines for processing        */
/*   commands entered at the top level prompt.               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Refactored several functions and added         */
/*            additional functions for use by an interface   */
/*            layered on top of CLIPS.                       */
/*                                                           */
/*      6.30: Local variables set with the bind function     */
/*            persist until a reset/clear command is issued. */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Metrowerks CodeWarrior (MAC_MCW, IBM_MCW) is   */
/*            no longer supported.                           */
/*                                                           */
/*            UTF-8 support.                                 */
/*                                                           */
/*            Command history and editing support            */
/*                                                           */
/*            Used genstrcpy instead of strcpy.              */
/*                                                           */
             
/*            Added before command execution callback        */
/*            function.                                      */
/*                                                           */
  
/*            Fixed RouteCommand return value.               */
           
/*                                                           */
             
/*            Added AwaitingInput flag.                      */
/*                                                           */
             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_commline

//C     #define _H_commline

//C     #define COMMANDLINE_DATA 40

const COMMANDLINE_DATA = 40;
//C     struct commandLineData
//C       { 
//C        int EvaluatingTopLevelCommand;
//C        int HaltCommandLoopBatch;
//C     #if ! RUN_TIME
//C        struct expr *CurrentCommand;
//C        char *CommandString;
//C        size_t MaximumCharacters;
//C        int ParsingTopLevelCommand;
//C        const char *BannerString;
//C        int (*EventFunction)(void *);
//C        int (*AfterPromptFunction)(void *);
//C        int (*BeforeCommandExecutionFunction)(void *);
//C     #endif
//C       };
struct commandLineData
{
    int EvaluatingTopLevelCommand;
    int HaltCommandLoopBatch;
    expr *CurrentCommand;
    char *CommandString;
    size_t MaximumCharacters;
    int ParsingTopLevelCommand;
    char *BannerString;
    int  function(void *)EventFunction;
    int  function(void *)AfterPromptFunction;
    int  function(void *)BeforeCommandExecutionFunction;
}

//C     #define CommandLineData(theEnv) ((struct commandLineData *) GetEnvironmentData(theEnv,COMMANDLINE_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _COMMLINE_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeCommandLineData(void *);
void  InitializeCommandLineData(void *);
//C        LOCALE int                            ExpandCommandString(void *,int);
int  ExpandCommandString(void *, int );
//C        LOCALE void                           FlushCommandString(void *);
void  FlushCommandString(void *);
//C        LOCALE void                           SetCommandString(void *,const char *);
void  SetCommandString(void *, char *);
//C        LOCALE void                           AppendCommandString(void *,const char *);
void  AppendCommandString(void *, char *);
//C        LOCALE void                           InsertCommandString(void *,const char *,unsigned);
void  InsertCommandString(void *, char *, uint );
//C        LOCALE char                          *GetCommandString(void *);
char * GetCommandString(void *);
//C        LOCALE int                            CompleteCommand(const char *);
int  CompleteCommand(char *);
//C        LOCALE void                           CommandLoop(void *);
void  CommandLoop(void *);
//C        LOCALE void                           CommandLoopBatch(void *);
void  CommandLoopBatch(void *);
//C        LOCALE void                           CommandLoopBatchDriver(void *);
void  CommandLoopBatchDriver(void *);
//C        LOCALE void                           PrintPrompt(void *);
void  PrintPrompt(void *);
//C        LOCALE void                           PrintBanner(void *);
void  PrintBanner(void *);
//C        LOCALE void                           SetAfterPromptFunction(void *,int (*)(void *));
void  SetAfterPromptFunction(void *, int  function(void *));
//C        LOCALE void                           SetBeforeCommandExecutionFunction(void *,int (*)(void *));
void  SetBeforeCommandExecutionFunction(void *, int  function(void *));
//C        LOCALE intBool                        RouteCommand(void *,const char *,int);
int  RouteCommand(void *, char *, int );
//C        LOCALE int                          (*SetEventFunction(void *,int (*)(void *)))(void *);
int  function(void *) SetEventFunction(void *, int  function(void *));
//C        LOCALE intBool                        TopLevelCommand(void *);
int  TopLevelCommand(void *);
//C        LOCALE void                           AppendNCommandString(void *,const char *,unsigned);
void  AppendNCommandString(void *, char *, uint );
//C        LOCALE void                           SetNCommandString(void *,const char *,unsigned);
void  SetNCommandString(void *, char *, uint );
//C        LOCALE const char                    *GetCommandCompletionString(void *,const char *,size_t);
char * GetCommandCompletionString(void *, char *, size_t );
//C        LOCALE intBool                        ExecuteIfCommandComplete(void *);
int  ExecuteIfCommandComplete(void *);
//C        LOCALE void                           CommandLoopOnceThenBatch(void *);
void  CommandLoopOnceThenBatch(void *);
//C        LOCALE intBool                        CommandCompleteAndNotEmpty(void *);
int  CommandCompleteAndNotEmpty(void *);
//C        LOCALE void                           SetHaltCommandLoopBatch(void *,int);
void  SetHaltCommandLoopBatch(void *, int );
//C        LOCALE int                            GetHaltCommandLoopBatch(void *);
int  GetHaltCommandLoopBatch(void *);

//C     #endif





//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #include "router.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/26/15            */
   /*                                                     */
   /*                 ROUTER HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a centralized mechanism for handling    */
/*   input and output requests.                              */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed conversion of '\r' to '\n' from the    */
/*            EnvGetcRouter function.                        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added support for passing context information  */
 
/*            to the router functions.                       */
/*                                                           */
/*      6.30: Fixed issues with passing context to routers.  */
/*                                                           */
/*            Added AwaitingInput flag.                      */
/*                                                           */
             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added STDOUT and STDIN logical name            */
/*            definitions.                                   */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_router
//C     #define _H_router

//C     #ifndef _H_prntutil
//C     #include "prntutil.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*              PRINT UTILITY HEADER FILE              */
   /*******************************************************/

/*************************************************************/
/* Purpose: Utility routines for printing various items      */
/*   and messages.                                           */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Link error occurs for the SlotExistError       */
/*            function when OBJECT_SYSTEM is set to 0 in     */
/*            setup.h. DR0865                                */
/*                                                           */
/*            Added DataObjectToString function.             */
/*                                                           */
/*            Added SlotExistError function.                 */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Support for DATA_OBJECT_ARRAY primitive.       */
/*                                                           */
/*            Support for typed EXTERNAL_ADDRESS.            */
/*                                                           */
/*            Used gensprintf and genstrcat instead of       */
/*            sprintf and strcat.                            */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added code for capturing errors/warnings.      */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_prntutil
//C     #define _H_prntutil

//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #define PRINT_UTILITY_DATA 53

const PRINT_UTILITY_DATA = 53;
//C     struct printUtilityData
//C       { 
//C        intBool PreserveEscapedCharacters;
//C        intBool AddressesToStrings;
//C        intBool InstanceAddressesToNames;
//C       };
struct printUtilityData
{
    int PreserveEscapedCharacters;
    int AddressesToStrings;
    int InstanceAddressesToNames;
}

//C     #define PrintUtilityData(theEnv) ((struct printUtilityData *) GetEnvironmentData(theEnv,PRINT_UTILITY_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _PRNTUTIL_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializePrintUtilityData(void *);
void  InitializePrintUtilityData(void *);
//C        LOCALE void                           PrintInChunks(void *,const char *,const char *);
void  PrintInChunks(void *, char *, char *);
//C        LOCALE void                           PrintFloat(void *,const char *,double);
void  PrintFloat(void *, char *, double );
//C        LOCALE void                           PrintLongInteger(void *,const char *,long long);
void  PrintLongInteger(void *, char *, long );
//C        LOCALE void                           PrintAtom(void *,const char *,int,void *);
void  PrintAtom(void *, char *, int , void *);
//C        LOCALE void                           PrintTally(void *,const char *,long long,const char *,const char *);
void  PrintTally(void *, char *, long , char *, char *);
//C        LOCALE const char                    *FloatToString(void *,double);
char * FloatToString(void *, double );
//C        LOCALE const char                    *LongIntegerToString(void *,long long);
char * LongIntegerToString(void *, long );
//C        LOCALE const char                    *DataObjectToString(void *,DATA_OBJECT *);
char * DataObjectToString(void *, DATA_OBJECT *);
//C        LOCALE void                           SyntaxErrorMessage(void *,const char *);
void  SyntaxErrorMessage(void *, char *);
//C        LOCALE void                           SystemError(void *,const char *,int);
void  SystemError(void *, char *, int );
//C        LOCALE void                           PrintErrorID(void *,const char *,int,int);
void  PrintErrorID(void *, char *, int , int );
//C        LOCALE void                           PrintWarningID(void *,const char *,int,int);
void  PrintWarningID(void *, char *, int , int );
//C        LOCALE void                           CantFindItemErrorMessage(void *,const char *,const char *);
void  CantFindItemErrorMessage(void *, char *, char *);
//C        LOCALE void                           CantDeleteItemErrorMessage(void *,const char *,const char *);
void  CantDeleteItemErrorMessage(void *, char *, char *);
//C        LOCALE void                           AlreadyParsedErrorMessage(void *,const char *,const char *);
void  AlreadyParsedErrorMessage(void *, char *, char *);
//C        LOCALE void                           LocalVariableErrorMessage(void *,const char *);
void  LocalVariableErrorMessage(void *, char *);
//C        LOCALE void                           DivideByZeroErrorMessage(void *,const char *);
void  DivideByZeroErrorMessage(void *, char *);
//C        LOCALE void                           SalienceInformationError(void *,const char *,const char *);
void  SalienceInformationError(void *, char *, char *);
//C        LOCALE void                           SalienceRangeError(void *,int,int);
void  SalienceRangeError(void *, int , int );
//C        LOCALE void                           SalienceNonIntegerError(void *);
void  SalienceNonIntegerError(void *);
//C        LOCALE void                           CantFindItemInFunctionErrorMessage(void *,const char *,const char *,const char *);
void  CantFindItemInFunctionErrorMessage(void *, char *, char *, char *);
//C        LOCALE void                           SlotExistError(void *,const char *,const char *);
void  SlotExistError(void *, char *, char *);

//C     #endif /* _H_prntutil */






//C     #endif

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #define WWARNING "wwarning"
//C     #define WERROR "werror"
//C     #define WTRACE "wtrace"
//C     #define WDIALOG "wdialog"
//C     #define WPROMPT  WPROMPT_STRING
//C     #define WDISPLAY "wdisplay"
//C --  alias WPROMPT_STRING WPROMPT;
//C     #define STDOUT "stdout"
//C     #define STDIN "stdin"

//C     #define ROUTER_DATA 46

const ROUTER_DATA = 46;
//C     struct router
//C       {
//C        const char *name;
//C        int active;
//C        int priority;
//C        short int environmentAware;
//C        void *context;
//C        int (*query)(void *,const char *);
//C        int (*printer)(void *,const char *,const char *);
//C        int (*exiter)(void *,int);
//C        int (*charget)(void *,const char *);
//C        int (*charunget)(void *,int,const char *);
//C        struct router *next;
//C       };
struct router
{
    char *name;
    int active;
    int priority;
    short environmentAware;
    void *context;
    int  function(void *, char *)query;
    int  function(void *, char *, char *)printer;
    int  function(void *, int )exiter;
    int  function(void *, char *)charget;
    int  function(void *, int , char *)charunget;
    router *next;
}

//C     struct routerData
//C       { 
//C        size_t CommandBufferInputCount;
//C        int AwaitingInput;
//C        const char *LineCountRouter;
//C        const char *FastCharGetRouter;
//C        char *FastCharGetString;
//C        long FastCharGetIndex;
//C        struct router *ListOfRouters;
//C        FILE *FastLoadFilePtr;
//C        FILE *FastSaveFilePtr;
//C        int Abort;
//C       };
struct routerData
{
    size_t CommandBufferInputCount;
    int AwaitingInput;
    char *LineCountRouter;
    char *FastCharGetRouter;
    char *FastCharGetString;
    int FastCharGetIndex;
    router *ListOfRouters;
    FILE *FastLoadFilePtr;
    FILE *FastSaveFilePtr;
    int Abort;
}

//C     #define RouterData(theEnv) ((struct routerData *) GetEnvironmentData(theEnv,ROUTER_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _ROUTER_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeDefaultRouters(void *);
void  InitializeDefaultRouters(void *);
//C        LOCALE int                            EnvPrintRouter(void *,const char *,const char *);
int  EnvPrintRouter(void *, char *, char *);
//C        LOCALE int                            EnvGetcRouter(void *,const char *);
int  EnvGetcRouter(void *, char *);
//C        LOCALE int                            EnvUngetcRouter(void *,int,const char *);
int  EnvUngetcRouter(void *, int , char *);
//C        LOCALE void                           EnvExitRouter(void *,int);
void  EnvExitRouter(void *, int );
//C        LOCALE void                           AbortExit(void *);
void  AbortExit(void *);
//C        LOCALE intBool                        EnvAddRouterWithContext(void *,
//C                                                        const char *,int,
//C                                                        int (*)(void *,const char *),
//C                                                        int (*)(void *,const char *,const char *),
//C                                                        int (*)(void *,const char *),
//C                                                        int (*)(void *,int,const char *),
//C                                                        int (*)(void *,int),
//C                                                        void *);
int  EnvAddRouterWithContext(void *, char *, int , int  function(void *, char *), int  function(void *, char *, char *), int  function(void *, char *), int  function(void *, int , char *), int  function(void *, int ), void *);
//C        LOCALE intBool                        EnvAddRouter(void *,
//C                                                        const char *,int,
//C                                                        int (*)(void *,const char *),
//C                                                        int (*)(void *,const char *,const char *),
//C                                                        int (*)(void *,const char *),
//C                                                        int (*)(void *,int,const char *),
//C                                                        int (*)(void *,int));
int  EnvAddRouter(void *, char *, int , int  function(void *, char *), int  function(void *, char *, char *), int  function(void *, char *), int  function(void *, int , char *), int  function(void *, int ));
//C        LOCALE int                            EnvDeleteRouter(void *,const char *);
int  EnvDeleteRouter(void *, char *);
//C        LOCALE int                            QueryRouters(void *,const char *);
int  QueryRouters(void *, char *);
//C        LOCALE int                            EnvDeactivateRouter(void *,const char *);
int  EnvDeactivateRouter(void *, char *);
//C        LOCALE int                            EnvActivateRouter(void *,const char *);
int  EnvActivateRouter(void *, char *);
//C        LOCALE void                           SetFastLoad(void *,FILE *);
void  SetFastLoad(void *, FILE *);
//C        LOCALE void                           SetFastSave(void *,FILE *);
void  SetFastSave(void *, FILE *);
//C        LOCALE FILE                          *GetFastLoad(void *);
FILE * GetFastLoad(void *);
//C        LOCALE FILE                          *GetFastSave(void *);
FILE * GetFastSave(void *);
//C        LOCALE void                           UnrecognizedRouterMessage(void *,const char *);
void  UnrecognizedRouterMessage(void *, char *);
//C        LOCALE void                           ExitCommand(void *);
void  ExitCommand(void *);
//C        LOCALE int                            PrintNRouter(void *,const char *,const char *,unsigned long);
int  PrintNRouter(void *, char *, char *, uint );

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE int                            ActivateRouter(const char *);
//C        LOCALE intBool                        AddRouter(const char *,int,
//C                                                        int (*)(const char *),
//C                                                        int (*)(const char *,const char *),
//C                                                        int (*)(const char *),
//C                                                        int (*)(int,const char *),
//C                                                        int (*)(int));
//C        LOCALE int                            DeactivateRouter(const char *);
//C        LOCALE int                            DeleteRouter(const char *);
//C        LOCALE void                           ExitRouter(int);
//C        LOCALE int                            GetcRouter(const char *);
//C        LOCALE int                            PrintRouter(const char *,const char *);
//C        LOCALE int                            UngetcRouter(int,const char *);
   
//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_router */


//C     #include "filertr.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             FILE I/O ROUTER HEADER FILE             */
   /*******************************************************/

/*************************************************************/
/* Purpose: I/O Router routines which allow files to be used */
/*   as input and output sources.                            */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Added pragmas to remove compilation warnings.  */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Used gengetc and genungetchar rather than      */
/*            getc and ungetc.                               */
/*                                                           */
/*            Replaced BASIC_IO and ADVANCED_IO compiler     */
/*            flags with the single IO_FUNCTIONS compiler    */
/*            flag.                                          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_filertr
//C     #define _H_filertr

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #define FILE_ROUTER_DATA 47
   
const FILE_ROUTER_DATA = 47;
//C     struct fileRouter
//C       {
//C        const char *logicalName;
//C        FILE *stream;
//C        struct fileRouter *next;
//C       };
struct fileRouter
{
    char *logicalName;
    FILE *stream;
    fileRouter *next;
}

//C     struct fileRouterData
//C       { 
//C        struct fileRouter *ListOfFileRouters;
//C       };
struct fileRouterData
{
    fileRouter *ListOfFileRouters;
}

//C     #define FileRouterData(theEnv) ((struct fileRouterData *) GetEnvironmentData(theEnv,FILE_ROUTER_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _FILERTR_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeFileRouter(void *);
void  InitializeFileRouter(void *);
//C        LOCALE FILE                          *FindFptr(void *,const char *);
FILE * FindFptr(void *, char *);
//C        LOCALE int                            OpenAFile(void *,const char *,const char *,const char *);
int  OpenAFile(void *, char *, char *, char *);
//C        LOCALE int                            CloseAllFiles(void *);
int  CloseAllFiles(void *);
//C        LOCALE int                            CloseFile(void *,const char *);
int  CloseFile(void *, char *);
//C        LOCALE int                            FindFile(void *,const char *);
int  FindFile(void *, char *);

//C     #endif /* _H_filertr */






//C     #include "strngrtr.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            STRING I/O ROUTER HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: I/O Router routines which allow strings to be    */
/*   used as input and output sources.                       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Used genstrcpy instead of strcpy.              */
/*                                                           */
             
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_strngrtr
//C     #define _H_strngrtr

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #define STRING_ROUTER_DATA 48

const STRING_ROUTER_DATA = 48;
//C     struct stringRouter
//C       {
//C        const char *name;
//C        const char *readString;
//C        char *writeString;
   //char *str;
//C        size_t currentPosition;
//C        size_t maximumPosition;
//C        int readWriteType;
//C        struct stringRouter *next;
//C       };
struct stringRouter
{
    char *name;
    char *readString;
    char *writeString;
    size_t currentPosition;
    size_t maximumPosition;
    int readWriteType;
    stringRouter *next;
}

//C     struct stringRouterData
//C       { 
//C        struct stringRouter *ListOfStringRouters;
//C       };
struct stringRouterData
{
    stringRouter *ListOfStringRouters;
}

//C     #define StringRouterData(theEnv) ((struct stringRouterData *) GetEnvironmentData(theEnv,STRING_ROUTER_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _STRNGRTR_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

/**************************/
/* I/O ROUTER DEFINITIONS */
/**************************/

//C        LOCALE void                           InitializeStringRouter(void *);
void  InitializeStringRouter(void *);
//C        LOCALE int                            OpenStringSource(void *,const char *,const char *,size_t);
int  OpenStringSource(void *, char *, char *, size_t );
//C        LOCALE int                            OpenTextSource(void *,const char *,const char *,size_t,size_t);
int  OpenTextSource(void *, char *, char *, size_t , size_t );
//C        LOCALE int                            CloseStringSource(void *,const char *);
int  CloseStringSource(void *, char *);
//C        LOCALE int                            OpenStringDestination(void *,const char *,char *,size_t);
int  OpenStringDestination(void *, char *, char *, size_t );
//C        LOCALE int                            CloseStringDestination(void *,const char *);
int  CloseStringDestination(void *, char *);

//C     #endif /* _H_strngrtr */



//C     #include "iofun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*               I/O FUNCTIONS HEADER FILE             */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added the get-char, set-locale, and            */
/*            read-number functions.                         */
/*                                                           */
/*            Modified printing of floats in the format      */
/*            function to use the locale from the set-locale */
/*            function.                                      */
/*                                                           */
/*            Moved IllegalLogicalNameMessage function to    */
/*            argacces.c.                                    */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Removed the undocumented use of t in the       */
/*            printout command to perform the same function  */
/*            as crlf.                                       */
/*                                                           */
/*            Replaced EXT_IO and BASIC_IO compiler flags    */
/*            with IO_FUNCTIONS compiler flag.               */
/*                                                           */
/*            Added a+, w+, rb, ab, r+b, w+b, and a+b modes  */
/*            for the open function.                         */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Added put-char function.                       */
/*                                                           */
/*            Added SetFullCRLF which allows option to       */
/*            specify crlf as \n or \r\n.                    */
/*                                                           */
/*            Added AwaitingInput flag.                      */
/*                                                           */
             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_iofun

//C     #define _H_iofun

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _IOFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           IOFunctionDefinitions(void *);
void  IOFunctionDefinitions(void *);
//C     #if IO_FUNCTIONS
//C        LOCALE intBool                        SetFullCRLF(void *,intBool);
int  SetFullCRLF(void *, int );
//C        LOCALE void                           PrintoutFunction(void *);
void  PrintoutFunction(void *);
//C        LOCALE void                           ReadFunction(void *,DATA_OBJECT_PTR);
void  ReadFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE int                            OpenFunction(void *);
int  OpenFunction(void *);
//C        LOCALE int                            CloseFunction(void *);
int  CloseFunction(void *);
//C        LOCALE int                            GetCharFunction(void *);
int  GetCharFunction(void *);
//C        LOCALE void                           PutCharFunction(void *);
void  PutCharFunction(void *);
//C        LOCALE void                           ReadlineFunction(void *,DATA_OBJECT_PTR);
void  ReadlineFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                          *FormatFunction(void *);
void * FormatFunction(void *);
//C        LOCALE int                            RemoveFunction(void *);
int  RemoveFunction(void *);
//C        LOCALE int                            RenameFunction(void *);
int  RenameFunction(void *);
//C        LOCALE void                           SetLocaleFunction(void *,DATA_OBJECT_PTR);
void  SetLocaleFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           ReadNumberFunction(void *,DATA_OBJECT_PTR);
void  ReadNumberFunction(void *, DATA_OBJECT_PTR );
//C     #endif

//C     #endif /* _H_iofun */







//C     #include "sysdep.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/04/15            */
   /*                                                     */
   /*            SYSTEM DEPENDENT HEADER FILE             */
   /*******************************************************/

/*************************************************************/
/* Purpose: Isolation of system dependent routines.          */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Modified GenOpen to check the file length      */
/*            against the system constant FILENAME_MAX.      */
/*                                                           */
/*      6.24: Support for run-time programs directly passing */
/*            the hash tables for initialization.            */
/*                                                           */
/*            Made gensystem functional for Xcode.           */
 
/*                                                           */
/*            Added BeforeOpenFunction and AfterOpenFunction */
/*            hooks.                                         */
/*                                                           */
/*            Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Updated UNIX_V gentime functionality.          */
/*                                                           */
/*            Removed GenOpen check against FILENAME_MAX.    */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, IBM_ICB, IBM_TBC, IBM_ZTC, and        */
/*            IBM_SC).                                       */
/*                                                           */
/*            Renamed IBM_MSC and WIN_MVC compiler flags     */
/*            and IBM_GCC to WIN_GCC.                        */
/*                                                           */
/*            Added LINUX and DARWIN compiler flags.         */
/*                                                           */
/*            Removed HELP_FUNCTIONS compilation flag and    */
/*            associated functionality.                      */
/*                                                           */
/*            Removed EMACS_EDITOR compilation flag and      */
/*            associated functionality.                      */
/*                                                           */
/*            Combined BASIC_IO and EXT_IO compilation       */
/*            flags into the single IO_FUNCTIONS flag.       */
/*                                                           */
/*            Changed the EX_MATH compilation flag to        */
/*            EXTENDED_MATH_FUNCTIONS.                       */
/*                                                           */
/*            Support for typed EXTERNAL_ADDRESS.            */
/*                                                           */
/*            GenOpen function checks for UTF-8 Byte Order   */
/*            Marker.                                        */
/*                                                           */
/*            Added gengetchar, genungetchar, genprintfile,  */
/*            genstrcpy, genstrncpy, genstrcat, genstrncat,  */
/*            and gensprintf functions.                      */
/*                                                           */
/*            Added SetJmpBuffer function.                   */
/*                                                           */
/*            Added environment argument to genexit.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_sysdep
//C     #define _H_sysdep

//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #include <setjmp.h>
//import core.sys.posix.setjmp: jmp_buf;

//C     #if WIN_MVC
//C     #include <dos.h>
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _SYSDEP_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #if ALLOW_ENVIRONMENT_GLOBALS
//C        LOCALE void                        InitializeEnvironment(void);
//C     #endif
//C        LOCALE void                        EnvInitializeEnvironment(void *,struct symbolHashNode **,struct floatHashNode **,
//C     															   struct integerHashNode **,struct bitMapHashNode **,
//C     															   struct externalAddressHashNode **);
void  EnvInitializeEnvironment(void *, symbolHashNode **, floatHashNode **, integerHashNode **, bitMapHashNode **, externalAddressHashNode **);
//C        LOCALE void                        SetRedrawFunction(void *,void (*)(void *));
void  SetRedrawFunction(void *, void  function(void *));
//C        LOCALE void                        SetPauseEnvFunction(void *,void (*)(void *));
void  SetPauseEnvFunction(void *, void  function(void *));
//C        LOCALE void                        SetContinueEnvFunction(void *,void (*)(void *,int));
void  SetContinueEnvFunction(void *, void  function(void *, int ));
//C        LOCALE void                        (*GetRedrawFunction(void *))(void *);
void  function(void *) GetRedrawFunction(void *);
//C        LOCALE void                        (*GetPauseEnvFunction(void *))(void *);
void  function(void *) GetPauseEnvFunction(void *);
//C        LOCALE void                        (*GetContinueEnvFunction(void *))(void *,int);
void  function(void *, int ) GetContinueEnvFunction(void *);
//C        LOCALE void                        RerouteStdin(void *,int,char *[]);
void  RerouteStdin(void *, int , char **);
//C        LOCALE double                      gentime(void);
double  gentime();
//C        LOCALE void                        gensystem(void *theEnv);
void  gensystem(void *theEnv);
//C        LOCALE void                        VMSSystem(char *);
void  VMSSystem(char *);
//C        LOCALE int                         GenOpenReadBinary(void *,const char *,const char *);
int  GenOpenReadBinary(void *, char *, char *);
//C        LOCALE void                        GetSeekCurBinary(void *,long);
void  GetSeekCurBinary(void *, int );
//C        LOCALE void                        GetSeekSetBinary(void *,long);
void  GetSeekSetBinary(void *, int );
//C        LOCALE void                        GenTellBinary(void *,long *);
void  GenTellBinary(void *, int *);
//C        LOCALE void                        GenCloseBinary(void *);
void  GenCloseBinary(void *);
//C        LOCALE void                        GenReadBinary(void *,void *,size_t);
void  GenReadBinary(void *, void *, size_t );
//C        LOCALE FILE                       *GenOpen(void *,const char *,const char *);
FILE * GenOpen(void *, char *, char *);
//C        LOCALE int                         GenClose(void *,FILE *);
int  GenClose(void *, FILE *);
//C        LOCALE void                        genexit(void *,int);
void  genexit(void *, int );
//C        LOCALE int                         genrand(void);
int  genrand();
//C        LOCALE void                        genseed(int);
void  genseed(int );
//C        LOCALE int                         genremove(const char *);
int  genremove(char *);
//C        LOCALE int                         genrename(const char *,const char *);
int  genrename(char *, char *);
//C        LOCALE char                       *gengetcwd(char *,int);
char * gengetcwd(char *, int );
//C        LOCALE void                        GenWrite(void *,size_t,FILE *);
void  GenWrite(void *, size_t , FILE *);
//C        LOCALE int                       (*EnvSetBeforeOpenFunction(void *,int (*)(void *)))(void *);
int  function(void *) EnvSetBeforeOpenFunction(void *, int  function(void *));
//C        LOCALE int                       (*EnvSetAfterOpenFunction(void *,int (*)(void *)))(void *);
int  function(void *) EnvSetAfterOpenFunction(void *, int  function(void *));
//C        LOCALE int                         gensprintf(char *,const char *,...);
int  gensprintf(char *, char *,...);
//C        LOCALE char                       *genstrcpy(char *,const char *);
char * genstrcpy(char *, char *);
//C        LOCALE char                       *genstrncpy(char *,const char *,size_t);
char * genstrncpy(char *, char *, size_t );
//C        LOCALE char                       *genstrcat(char *,const char *);
char * genstrcat(char *, char *);
//C        LOCALE char                       *genstrncat(char *,const char *,size_t);
char * genstrncat(char *, char *, size_t );
//C        LOCALE void                        SetJmpBuffer(void *,jmp_buf *);
//void  SetJmpBuffer(void *, jmp_buf *);
//C        LOCALE void                        genprintfile(void *,FILE *,const char *);
void  genprintfile(void *, FILE *, char *);
//C        LOCALE int                         gengetchar(void *);
int  gengetchar(void *);
//C        LOCALE int                         genungetchar(void *,int);
int  genungetchar(void *, int );
   
//C     #endif /* _H_sysdep */





//C     #include "bmathfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             BASIC MATH FUNCTIONS MODULE             */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_bmathfun

//C     #define _H_bmathfun

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _BMATHFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                    BasicMathFunctionDefinitions(void *);
void  BasicMathFunctionDefinitions(void *);
//C        LOCALE void                    AdditionFunction(void *,DATA_OBJECT_PTR);
void  AdditionFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                    MultiplicationFunction(void *,DATA_OBJECT_PTR);
void  MultiplicationFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                    SubtractionFunction(void *,DATA_OBJECT_PTR);
void  SubtractionFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                    DivisionFunction(void *,DATA_OBJECT_PTR);
void  DivisionFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE long long               DivFunction(void *);
long  DivFunction(void *);
//C        LOCALE intBool                 SetAutoFloatDividendCommand(void *);
int  SetAutoFloatDividendCommand(void *);
//C        LOCALE intBool                 GetAutoFloatDividendCommand(void *);
int  GetAutoFloatDividendCommand(void *);
//C        LOCALE intBool                 EnvGetAutoFloatDividend(void *);
int  EnvGetAutoFloatDividend(void *);
//C        LOCALE intBool                 EnvSetAutoFloatDividend(void *,int);
int  EnvSetAutoFloatDividend(void *, int );
//C        LOCALE long long               IntegerFunction(void *);
long  IntegerFunction(void *);
//C        LOCALE double                  FloatFunction(void *);
double  FloatFunction(void *);
//C        LOCALE void                    AbsFunction(void *,DATA_OBJECT_PTR);
void  AbsFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                    MinFunction(void *,DATA_OBJECT_PTR);
void  MinFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                    MaxFunction(void *,DATA_OBJECT_PTR);
void  MaxFunction(void *, DATA_OBJECT_PTR );

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                 GetAutoFloatDividend(void);
//C        LOCALE intBool                 SetAutoFloatDividend(int);

//C     #endif

//C     #endif




//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #include "exprnpsr.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            EXPRESSION PARSER HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides routines for parsing expressions.       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Module specifier can be used within an         */
/*            expression to refer to a deffunction or        */
/*            defgeneric exported by the specified module,   */
/*            but not necessarily imported by the current    */
/*            module.                                        */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_exprnpsr

//C     #define _H_exprnpsr

//C     #if (! RUN_TIME)

//C     typedef struct saved_contexts
//C       {
//C        int rtn;
//C        int brk;
//C        struct saved_contexts *nxt;
//C       } SAVED_CONTEXTS;

//C     #endif

//C     #ifndef _H_extnfunc
//C     #include "extnfunc.h"
//C     #endif
//C     #ifndef _H_scanner
//C     #include "scanner.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _EXPRNPSR_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C        LOCALE struct expr                   *Function0Parse(void *,const char *);
//C        LOCALE struct expr                   *Function1Parse(void *,const char *);
//C        LOCALE struct expr                   *Function2Parse(void *,const char *,const char *);
//C        LOCALE void                           PushRtnBrkContexts(void *);
//C        LOCALE void                           PopRtnBrkContexts(void *);
//C        LOCALE intBool                        ReplaceSequenceExpansionOps(void *,struct expr *,struct expr *,
//C                                                                          void *,void *);
//C        LOCALE struct expr                   *CollectArguments(void *,struct expr *,const char *);
//C        LOCALE struct expr                   *ArgumentParse(void *,const char *,int *);
//C        LOCALE struct expr                   *ParseAtomOrExpression(void *,const char *,struct token *);
//C        LOCALE EXPRESSION                    *ParseConstantArguments(void *,const char *,int *);
//C        LOCALE intBool                        EnvSetSequenceOperatorRecognition(void *,int);
//C        LOCALE intBool                        EnvGetSequenceOperatorRecognition(void *);
//C        LOCALE struct expr                   *GroupActions(void *,const char *,struct token *,
//C                                                           int,const char *,int);
//C        LOCALE struct expr                   *RemoveUnneededProgn(void *,struct expr *);

//C     #if (! RUN_TIME)

//C        LOCALE int                            CheckExpressionAgainstRestrictions(void *,struct expr *,
//C                                                                                 const char *,const char *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        SetSequenceOperatorRecognition(int);
//C        LOCALE intBool                        GetSequenceOperatorRecognition(void);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_exprnpsr */




//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #include "utility.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*                 UTILITY HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a set of utility functions useful to    */
/*   other modules. Primarily these are the functions for    */
/*   handling periodic garbage collection and appending      */
/*   string data.                                            */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added CopyString, DeleteString,                */
/*            InsertInString,and EnlargeString functions.    */
/*                                                           */
/*            Used genstrncpy function instead of strncpy    */
/*            function.                                      */
/*                                                           */
/*            Support for typed EXTERNAL_ADDRESS.            */
/*                                                           */
/*            Support for tracked memory (allows memory to   */
/*            be freed if CLIPS is exited while executing).  */
/*                                                           */
/*            Added UTF-8 routines.                          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_utility
//C     #define _H_utility

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     struct callFunctionItem
//C       {
//C        const char *name;
//C        void (*func)(void *);
//C        int priority;
//C        struct callFunctionItem *next;
//C        short int environmentAware;
//C        void *context;
//C       };

//C     struct callFunctionItemWithArg
//C       {
//C        const char *name;
//C        void (*func)(void *,void *);
//C        int priority;
//C        struct callFunctionItemWithArg *next;
//C        short int environmentAware;
//C        void *context;
//C       };
  
//C     struct trackedMemory
//C       {
//C        void *theMemory;
//C        struct trackedMemory *next;
//C        struct trackedMemory *prev;
//C        size_t memSize;
//C       };

//C     struct garbageFrame
//C       {
//C        short dirty;
//C        short topLevel;
//C        struct garbageFrame *priorFrame;
//C        struct ephemeron *ephemeralSymbolList;
//C        struct ephemeron *ephemeralFloatList;
//C        struct ephemeron *ephemeralIntegerList;
//C        struct ephemeron *ephemeralBitMapList;
//C        struct ephemeron *ephemeralExternalAddressList;
//C        struct multifield *ListOfMultifields;
//C        struct multifield *LastMultifield;
//C       };

//C     #define UTILITY_DATA 55

//C     struct utilityData
//C       { 
//C        struct callFunctionItem *ListOfCleanupFunctions;
//C        struct callFunctionItem *ListOfPeriodicFunctions;
//C        short GarbageCollectionLocks;
//C        short PeriodicFunctionsEnabled;
//C        short YieldFunctionEnabled;
//C        void (*YieldTimeFunction)(void);
//C        struct trackedMemory *trackList;
//C        struct garbageFrame MasterGarbageFrame;
//C        struct garbageFrame *CurrentGarbageFrame;
//C       };

//C     #define UtilityData(theEnv) ((struct utilityData *) GetEnvironmentData(theEnv,UTILITY_DATA))

  /* Is c the start of a utf8 sequence? */
//C     #define IsUTF8Start(ch) (((ch) & 0xC0) != 0x80)
//C     #define IsUTF8MultiByteStart(ch) ((((unsigned char) ch) >= 0xC0) && (((unsigned char) ch) <= 0xF7))
//C     #define IsUTF8MultiByteContinuation(ch) ((((unsigned char) ch) >= 0x80) && (((unsigned char) ch) <= 0xBF))

//C     #ifdef _UTILITY_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C        LOCALE void                           InitializeUtilityData(void *);
//C        LOCALE intBool                        AddCleanupFunction(void *,const char *,void (*)(void *),int);
//C        LOCALE intBool                        EnvAddPeriodicFunction(void *,const char *,void (*)(void *),int);
//C        LOCALE intBool                        AddPeriodicFunction(const char *,void (*)(void),int);
//C        LOCALE intBool                        RemoveCleanupFunction(void *,const char *);
//C        LOCALE intBool                        EnvRemovePeriodicFunction(void *,const char *);
//C        LOCALE char                          *CopyString(void *,const char *);
//C        LOCALE void                           DeleteString(void *,char *);
//C        LOCALE const char                    *AppendStrings(void *,const char *,const char *);
//C        LOCALE const char                    *StringPrintForm(void *,const char *);
//C        LOCALE char                          *AppendToString(void *,const char *,char *,size_t *,size_t *);
//C        LOCALE char                          *InsertInString(void *,const char *,size_t,char *,size_t *,size_t *);
//C        LOCALE char                          *AppendNToString(void *,const char *,char *,size_t,size_t *,size_t *);
//C        LOCALE char                          *EnlargeString(void *,size_t,char *,size_t *,size_t *);
//C        LOCALE char                          *ExpandStringWithChar(void *,int,char *,size_t *,size_t *,size_t);
//C        LOCALE struct callFunctionItem       *AddFunctionToCallList(void *,const char *,int,void (*)(void *),
//C                                                                    struct callFunctionItem *,intBool);
//C        LOCALE struct callFunctionItem       *AddFunctionToCallListWithContext(void *,const char *,int,void (*)(void *),
//C                                                                               struct callFunctionItem *,intBool,void *);
//C        LOCALE struct callFunctionItem       *RemoveFunctionFromCallList(void *,const char *,
//C                                                                  struct callFunctionItem *,
//C                                                                  int *);
//C        LOCALE void                           DeallocateCallList(void *,struct callFunctionItem *);
//C        LOCALE struct callFunctionItemWithArg *AddFunctionToCallListWithArg(void *,const char *,int,void (*)(void *, void *),
//C                                                                            struct callFunctionItemWithArg *,intBool);
//C        LOCALE struct callFunctionItemWithArg *AddFunctionToCallListWithArgWithContext(void *,const char *,int,void (*)(void *, void *),
//C                                                                                       struct callFunctionItemWithArg *,intBool,void *);
//C        LOCALE struct callFunctionItemWithArg *RemoveFunctionFromCallListWithArg(void *,const char *,
//C                                                                                 struct callFunctionItemWithArg *,
//C                                                                                 int *);
//C        LOCALE void                           DeallocateCallListWithArg(void *,struct callFunctionItemWithArg *);
//C        LOCALE unsigned long                  ItemHashValue(void *,unsigned short,void *,unsigned long);
//C        LOCALE void                           YieldTime(void *);
//C        LOCALE void                           EnvIncrementGCLocks(void *);
//C        LOCALE void                           EnvDecrementGCLocks(void *);
//C        LOCALE short                          EnablePeriodicFunctions(void *,short);
//C        LOCALE short                          EnableYieldFunction(void *,short);
//C        LOCALE struct trackedMemory          *AddTrackedMemory(void *,void *,size_t);
//C        LOCALE void                           RemoveTrackedMemory(void *,struct trackedMemory *);
//C        LOCALE void                           UTF8Increment(const char *,size_t *);
//C        LOCALE size_t                         UTF8Offset(const char *,size_t);
//C        LOCALE size_t                         UTF8Length(const char *);
//C        LOCALE size_t                         UTF8CharNum(const char *,size_t);
//C        LOCALE void                           RestorePriorGarbageFrame(void *,struct garbageFrame *,struct garbageFrame *,struct dataObject *);
//C        LOCALE void                           CallCleanupFunctions(void *);
//C        LOCALE void                           CallPeriodicTasks(void *);
//C        LOCALE void                           CleanCurrentGarbageFrame(void *,struct dataObject *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           IncrementGCLocks(void);
//C        LOCALE void                           DecrementGCLocks(void);
//C        LOCALE intBool                        RemovePeriodicFunction(const char *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_utility */




//C     #include "watch.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                  WATCH HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Support functions for the watch and unwatch      */
/*   commands.                                               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added EnvSetWatchItem function.                */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_watch
//C     #define _H_watch

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif

//C     #define WATCH_DATA 54

const WATCH_DATA = 54;
//C     struct watchItem
//C       {
//C        const char *name;
//C        unsigned *flag;
//C        int code,priority;
//C        unsigned (*accessFunc)(void *,int,unsigned,struct expr *);
//C        unsigned (*printFunc)(void *,const char *,int,struct expr *);
//C        struct watchItem *next;
//C       };
struct watchItem
{
    char *name;
    uint *flag;
    int code;
    int priority;
    uint  function(void *, int , uint , expr *)accessFunc;
    uint  function(void *, char *, int , expr *)printFunc;
    watchItem *next;
}

//C     struct watchData
//C       { 
//C        struct watchItem *ListOfWatchItems;
//C       };
struct watchData
{
    watchItem *ListOfWatchItems;
}

//C     #define WatchData(theEnv) ((struct watchData *) GetEnvironmentData(theEnv,WATCH_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _WATCH_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE intBool                        EnvWatch(void *,const char *);
int  EnvWatch(void *, char *);
//C        LOCALE intBool                        EnvUnwatch(void *,const char *);
int  EnvUnwatch(void *, char *);
//C        LOCALE void                           InitializeWatchData(void *);   
void  InitializeWatchData(void *);
//C        LOCALE int                            EnvSetWatchItem(void *,const char *,unsigned,struct expr *);
int  EnvSetWatchItem(void *, char *, uint , expr *);
//C        LOCALE int                            EnvGetWatchItem(void *,const char *);
int  EnvGetWatchItem(void *, char *);
//C        LOCALE intBool                        AddWatchItem(void *,const char *,int,unsigned *,int,
//C                                                           unsigned (*)(void *,int,unsigned,struct expr *),
//C                                                           unsigned (*)(void *,const char *,int,struct expr *));
int  AddWatchItem(void *, char *, int , uint *, int , uint  function(void *, int , uint , expr *), uint  function(void *, char *, int , expr *));
//C        LOCALE const char                    *GetNthWatchName(void *,int);
char * GetNthWatchName(void *, int );
//C        LOCALE int                            GetNthWatchValue(void *,int);
int  GetNthWatchValue(void *, int );
//C        LOCALE void                           WatchCommand(void *);
void  WatchCommand(void *);
//C        LOCALE void                           UnwatchCommand(void *);
void  UnwatchCommand(void *);
//C        LOCALE void                           ListWatchItemsCommand(void *);
void  ListWatchItemsCommand(void *);
//C        LOCALE void                           WatchFunctionDefinitions(void *);
void  WatchFunctionDefinitions(void *);
//C        LOCALE int                            GetWatchItemCommand(void *);
int  GetWatchItemCommand(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        Watch(const char *);
//C        LOCALE intBool                        Unwatch(const char *);
//C        LOCALE int                            GetWatchItem(const char *);
//C        LOCALE int                            SetWatchItem(const char *,unsigned,struct expr *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_watch */



//C     #include "modulbsc.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*         DEFMODULE BASIC COMMANDS HEADER FILE        */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements core commands for the deffacts        */
/*   construct such as clear, reset, save, undeffacts,       */
/*   ppdeffacts, list-deffacts, and get-deffacts-list.       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_modulbsc
//C     #define _H_modulbsc

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _MODULBSC_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           DefmoduleBasicCommands(void *);
void  DefmoduleBasicCommands(void *);
//C        LOCALE void                           EnvGetDefmoduleList(void *,DATA_OBJECT_PTR);
void  EnvGetDefmoduleList(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           PPDefmoduleCommand(void *);
void  PPDefmoduleCommand(void *);
//C        LOCALE int                            PPDefmodule(void *,const char *,const char *);
int  PPDefmodule(void *, char *, char *);
//C        LOCALE void                           ListDefmodulesCommand(void *);
void  ListDefmodulesCommand(void *);
//C        LOCALE void                           EnvListDefmodules(void *,const char *);
void  EnvListDefmodules(void *, char *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           GetDefmoduleList(DATA_OBJECT_PTR);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           ListDefmodules(const char *);
//C     #endif

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_modulbsc */


//C     #if BLOAD_ONLY || BLOAD || BLOAD_AND_BSAVE
//C     #include "bload.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                 BLOAD HEADER FILE                   */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_bload
//C     #define _H_bload

//C     #ifndef _H_utility
//C     #include "utility.h"
//C     #endif
//C     #ifndef _H_extnfunc
//C     #include "extnfunc.h"
//C     #endif
//C     #ifndef _H_exprnbin
//C     #include "exprnbin.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*           EXPRESSION BLOAD/BSAVE HEADER FILE        */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements the binary save/load feature for the  */
/*    expression data structure.                             */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_exprnbin
//C     #define _H_exprnbin

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _EXPRNBIN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #define ExpressionPointer(i) ((struct expr *) (((i) == -1L) ? NULL : &ExpressionData(theEnv)->ExpressionArray[i]))
//C     #define HashedExpressionPointer(i) ExpressionPointer(i)

//C        LOCALE void                        AllocateExpressions(void *);
void  AllocateExpressions(void *);
//C        LOCALE void                        RefreshExpressions(void *);
void  RefreshExpressions(void *);
//C        LOCALE void                        ClearBloadedExpressions(void *);
void  ClearBloadedExpressions(void *);
//C        LOCALE void                        FindHashedExpressions(void *);
void  FindHashedExpressions(void *);
//C        LOCALE void                        BsaveHashedExpressions(void *,FILE *);
void  BsaveHashedExpressions(void *, FILE *);
//C        LOCALE void                        BsaveConstructExpressions(void *,FILE *);
void  BsaveConstructExpressions(void *, FILE *);
//C        LOCALE void                        BsaveExpression(void *,struct expr *,FILE *);
void  BsaveExpression(void *, expr *, FILE *);

//C     #endif /* _H_exprnbin */







//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_sysdep
//C     #include "sysdep.h"
//C     #endif
//C     #ifndef _H_symblbin
//C     #include "symblbin.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*           SYMBOL BINARY SAVE HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements the binary save/load feature for      */
/*    atomic data values.                                    */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_symblbin
//C     #define _H_symblbin

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _SYMBLBIN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #define BitMapPointer(i) ((BITMAP_HN *) (SymbolData(theEnv)->BitMapArray[i]))
//C     #define SymbolPointer(i) ((SYMBOL_HN *) (SymbolData(theEnv)->SymbolArray[i]))
//C     #define FloatPointer(i) ((FLOAT_HN *) (SymbolData(theEnv)->FloatArray[i]))
//C     #define IntegerPointer(i) ((INTEGER_HN *) (SymbolData(theEnv)->IntegerArray[i]))

//C        LOCALE void                    MarkNeededAtomicValues(void);
void  MarkNeededAtomicValues();
//C        LOCALE void                    WriteNeededAtomicValues(void *,FILE *);
void  WriteNeededAtomicValues(void *, FILE *);
//C        LOCALE void                    ReadNeededAtomicValues(void *);
void  ReadNeededAtomicValues(void *);
//C        LOCALE void                    InitAtomicValueNeededFlags(void *);
void  InitAtomicValueNeededFlags(void *);
//C        LOCALE void                    FreeAtomicValueStorage(void *);
void  FreeAtomicValueStorage(void *);
//C        LOCALE void                    WriteNeededSymbols(void *,FILE *);
void  WriteNeededSymbols(void *, FILE *);
//C        LOCALE void                    WriteNeededFloats(void *,FILE *);
void  WriteNeededFloats(void *, FILE *);
//C        LOCALE void                    WriteNeededIntegers(void *,FILE *);
void  WriteNeededIntegers(void *, FILE *);
//C        LOCALE void                    ReadNeededSymbols(void *);
void  ReadNeededSymbols(void *);
//C        LOCALE void                    ReadNeededFloats(void *);
void  ReadNeededFloats(void *);
//C        LOCALE void                    ReadNeededIntegers(void *);
void  ReadNeededIntegers(void *);

//C     #endif /* _H_symblbin */



//C     #endif

//C     #define BLOAD_DATA 38

const BLOAD_DATA = 38;
//C     struct bloadData
//C       { 
//C        const char *BinaryPrefixID;
//C        const char *BinaryVersionID;
//C        struct FunctionDefinition **FunctionArray;
//C        int BloadActive;
//C        struct callFunctionItem *BeforeBloadFunctions;
//C        struct callFunctionItem *AfterBloadFunctions;
//C        struct callFunctionItem *ClearBloadReadyFunctions;
//C        struct callFunctionItem *AbortBloadFunctions;
//C       };
struct bloadData
{
    char *BinaryPrefixID;
    char *BinaryVersionID;
    FunctionDefinition **FunctionArray;
    int BloadActive;
    callFunctionItem *BeforeBloadFunctions;
    callFunctionItem *AfterBloadFunctions;
    callFunctionItem *ClearBloadReadyFunctions;
    callFunctionItem *AbortBloadFunctions;
}

//C     #define BloadData(theEnv) ((struct bloadData *) GetEnvironmentData(theEnv,BLOAD_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _BLOAD_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #define FunctionPointer(i) ((struct FunctionDefinition *) (((i) == -1L) ? NULL : BloadData(theEnv)->FunctionArray[i]))

//C        LOCALE void                    InitializeBloadData(void *);
void  InitializeBloadData(void *);
//C        LOCALE int                     BloadCommand(void *);
int  BloadCommand(void *);
//C        LOCALE intBool                 EnvBload(void *,const char *);
int  EnvBload(void *, char *);
//C        LOCALE void                    BloadandRefresh(void *,long,size_t,void (*)(void *,void *,long));
void  BloadandRefresh(void *, int , size_t , void  function(void *, void *, int ));
//C        LOCALE intBool                 Bloaded(void *);
int  Bloaded(void *);
//C        LOCALE void                    AddBeforeBloadFunction(void *,const char *,void (*)(void *),int);
void  AddBeforeBloadFunction(void *, char *, void  function(void *), int );
//C        LOCALE void                    AddAfterBloadFunction(void *,const char *,void (*)(void *),int);
void  AddAfterBloadFunction(void *, char *, void  function(void *), int );
//C        LOCALE void                    AddClearBloadReadyFunction(void *,const char *,int (*)(void *),int);
void  AddClearBloadReadyFunction(void *, char *, int  function(void *), int );
//C        LOCALE void                    AddAbortBloadFunction(void *,const char *,void (*)(void *),int);
void  AddAbortBloadFunction(void *, char *, void  function(void *), int );
//C        LOCALE void                    CannotLoadWithBloadMessage(void *,const char *);
void  CannotLoadWithBloadMessage(void *, char *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS
//C        LOCALE int                     Bload(const char *);
//C     #endif

//C     #endif

//C     #endif

//C     #if BLOAD_AND_BSAVE
//C     #include "bsave.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                 BSAVE HEADER FILE                   */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Used genstrncpy instead of strncpy.            */
/*                                                           */
/*            Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_bsave
//C     #define _H_bsave

//C     struct BinaryItem;

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _BSAVE_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     struct BinaryItem
//C       {
//C        const char *name;
//C        void (*findFunction)(void *);
//C        void (*bloadStorageFunction)(void *);
//C        void (*bloadFunction)(void *);
//C        void (*clearFunction)(void *);
//C        void (*expressionFunction)(void *,FILE *);
//C        void (*bsaveStorageFunction)(void *,FILE *);
//C        void (*bsaveFunction)(void *,FILE *);
//C        int priority;
//C        struct BinaryItem *next;
//C       };
struct BinaryItem
{
    char *name;
    void  function(void *)findFunction;
    void  function(void *)bloadStorageFunction;
    void  function(void *)bloadFunction;
    void  function(void *)clearFunction;
    void  function(void *, FILE *)expressionFunction;
    void  function(void *, FILE *)bsaveStorageFunction;
    void  function(void *, FILE *)bsaveFunction;
    int priority;
    BinaryItem *next;
}

//C     #if BLOAD_AND_BSAVE
//C     typedef struct bloadcntsv
//C       {
//C        long val;
//C        struct bloadcntsv *nxt;
//C       } BLOADCNTSV;
struct bloadcntsv
{
    int val;
    bloadcntsv *nxt;
}
alias bloadcntsv BLOADCNTSV;
//C     #endif

//C     typedef struct bsave_expr
//C       {
//C        unsigned short type;
//C        long value,arg_list,next_arg;
//C       } BSAVE_EXPRESSION;
struct bsave_expr
{
    ushort type;
    int value;
    int argList;
    int nextArg;
}
alias bsave_expr BSAVE_EXPRESSION;

//C     #define CONSTRUCT_HEADER_SIZE 20

const CONSTRUCT_HEADER_SIZE = 20;
//C     #define BSAVE_DATA 39

const BSAVE_DATA = 39;
//C     struct bsaveData
//C       { 
//C        struct BinaryItem *ListOfBinaryItems;
//C     #if BLOAD_AND_BSAVE
//C        BLOADCNTSV *BloadCountSaveTop;
//C     #endif
//C       };
struct bsaveData
{
    BinaryItem *ListOfBinaryItems;
    BLOADCNTSV *BloadCountSaveTop;
}

//C     #define BsaveData(theEnv) ((struct bsaveData *) GetEnvironmentData(theEnv,BSAVE_DATA))

//C        LOCALE void                    InitializeBsaveData(void *);
void  InitializeBsaveData(void *);
//C        LOCALE int                     BsaveCommand(void *);
int  BsaveCommand(void *);
//C     #if BLOAD_AND_BSAVE
//C        LOCALE intBool                 EnvBsave(void *,const char *);
int  EnvBsave(void *, char *);
//C        LOCALE void                    MarkNeededItems(void *,struct expr *);
void  MarkNeededItems(void *, expr *);
//C        LOCALE void                    SaveBloadCount(void *,long);
void  SaveBloadCount(void *, int );
//C        LOCALE void                    RestoreBloadCount(void *,long *);
void  RestoreBloadCount(void *, int *);
//C     #endif
//C        LOCALE intBool                 AddBinaryItem(void *,const char *,int,
//C                                                     void (*)(void *),
//C                                                     void (*)(void *,FILE *),
//C                                                     void (*)(void *,FILE *),
//C                                                     void (*)(void *,FILE *),
//C                                                     void (*)(void *),
//C                                                     void (*)(void *),
//C                                                     void (*)(void *));
int  AddBinaryItem(void *, char *, int , void  function(void *), void  function(void *, FILE *), void  function(void *, FILE *), void  function(void *, FILE *), void  function(void *), void  function(void *), void  function(void *));

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                 Bsave(const char *);

//C     #endif

//C     #endif /* _H_bsave */







//C     #endif

//C     #if DEFRULE_CONSTRUCT
//C     #ifndef _H_ruledef
//C     #include "ruledef.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*                 DEFRULE HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Defines basic defrule primitive functions such   */
/*   as allocating and deallocating, traversing, and finding */
/*   defrule data structures.                                */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed DYNAMIC_SALIENCE and                   */
/*            LOGICAL_DEPENDENCIES compilation flags.        */
/*                                                           */
/*            Removed CONFLICT_RESOLUTION_STRATEGIES         */
/*            compilation flag.                              */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warnings.                             */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added support for hashed memories.             */
/*                                                           */
/*            Added additional developer statistics to help  */
/*            analyze join network performance.              */
/*                                                           */
/*            Added salience groups to improve performance   */
/*            with large numbers of activations of different */
/*            saliences.                                     */
/*                                                           */
/*            Added EnvGetDisjunctCount and                  */
/*            EnvGetNthDisjunct functions.                   */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_ruledef
//C     #define _H_ruledef

//C     #define GetDisjunctIndex(r) ((struct constructHeader *) r)->bsaveID

//C     struct defrule;
//C     struct defruleModule;

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_constrnt
//C     #include "constrnt.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                CONSTRAINT HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides functions for creating and removing     */
/*   constraint records, adding them to the contraint hash   */
/*   table, and enabling and disabling static and dynamic    */
/*   constraint checking.                                    */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Added allowed-classes slot facet.              */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_constrnt
//C     #define _H_constrnt

//C     struct constraintRecord;

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CONSTRNT_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     struct constraintRecord
//C       {
//C        unsigned int anyAllowed : 1;
//C        unsigned int symbolsAllowed : 1;
//C        unsigned int stringsAllowed : 1;
//C        unsigned int floatsAllowed : 1;
//C        unsigned int integersAllowed : 1;
//C        unsigned int instanceNamesAllowed : 1;
//C        unsigned int instanceAddressesAllowed : 1;
//C        unsigned int externalAddressesAllowed : 1;
//C        unsigned int factAddressesAllowed : 1;
//C        unsigned int voidAllowed : 1;
//C        unsigned int anyRestriction : 1;
//C        unsigned int symbolRestriction : 1;
//C        unsigned int stringRestriction : 1;
//C        unsigned int floatRestriction : 1;
//C        unsigned int integerRestriction : 1;
//C        unsigned int classRestriction : 1;
//C        unsigned int instanceNameRestriction : 1;
//C        unsigned int multifieldsAllowed : 1;
//C        unsigned int singlefieldsAllowed : 1;
//C        unsigned short bsaveIndex;
//C        struct expr *classList;
//C        struct expr *restrictionList;
//C        struct expr *minValue;
//C        struct expr *maxValue;
//C        struct expr *minFields;
//C        struct expr *maxFields;
//C        struct constraintRecord *multifield;
//C        struct constraintRecord *next;
//C        int bucket;
//C        int count;
//C       };
struct constraintRecord
{
    uint __bitfield1;
    uint anyAllowed() { return (__bitfield1 >> 0) & 0x1; }
    uint anyAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint symbolsAllowed() { return (__bitfield1 >> 1) & 0x1; }
    uint symbolsAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint stringsAllowed() { return (__bitfield1 >> 2) & 0x1; }
    uint stringsAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint floatsAllowed() { return (__bitfield1 >> 3) & 0x1; }
    uint floatsAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint integersAllowed() { return (__bitfield1 >> 4) & 0x1; }
    uint integersAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffef) | (value << 4); return value; }
    uint instanceNamesAllowed() { return (__bitfield1 >> 5) & 0x1; }
    uint instanceNamesAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffdf) | (value << 5); return value; }
    uint instanceAddressesAllowed() { return (__bitfield1 >> 6) & 0x1; }
    uint instanceAddressesAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffbf) | (value << 6); return value; }
    uint externalAddressesAllowed() { return (__bitfield1 >> 7) & 0x1; }
    uint externalAddressesAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffff7f) | (value << 7); return value; }
    uint factAddressesAllowed() { return (__bitfield1 >> 8) & 0x1; }
    uint factAddressesAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffeff) | (value << 8); return value; }
    uint voidAllowed() { return (__bitfield1 >> 9) & 0x1; }
    uint voidAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffdff) | (value << 9); return value; }
    uint anyRestriction() { return (__bitfield1 >> 10) & 0x1; }
    uint anyRestriction(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffbff) | (value << 10); return value; }
    uint symbolRestriction() { return (__bitfield1 >> 11) & 0x1; }
    uint symbolRestriction(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffff7ff) | (value << 11); return value; }
    uint stringRestriction() { return (__bitfield1 >> 12) & 0x1; }
    uint stringRestriction(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffefff) | (value << 12); return value; }
    uint floatRestriction() { return (__bitfield1 >> 13) & 0x1; }
    uint floatRestriction(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffdfff) | (value << 13); return value; }
    uint integerRestriction() { return (__bitfield1 >> 14) & 0x1; }
    uint integerRestriction(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffbfff) | (value << 14); return value; }
    uint classRestriction() { return (__bitfield1 >> 15) & 0x1; }
    uint classRestriction(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffff7fff) | (value << 15); return value; }
    uint instanceNameRestriction() { return (__bitfield1 >> 16) & 0x1; }
    uint instanceNameRestriction(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffeffff) | (value << 16); return value; }
    uint multifieldsAllowed() { return (__bitfield1 >> 17) & 0x1; }
    uint multifieldsAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffdffff) | (value << 17); return value; }
    uint singlefieldsAllowed() { return (__bitfield1 >> 18) & 0x1; }
    uint singlefieldsAllowed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffbffff) | (value << 18); return value; }
    ushort bsaveIndex;
    expr *classList;
    expr *restrictionList;
    expr *minValue;
    expr *maxValue;
    expr *minFields;
    expr *maxFields;
    constraintRecord *multifield;
    constraintRecord *next;
    int bucket;
    int count;
}

//C     typedef struct constraintRecord CONSTRAINT_RECORD;
alias constraintRecord CONSTRAINT_RECORD;

//C     #define SIZE_CONSTRAINT_HASH  167

const SIZE_CONSTRAINT_HASH = 167;
//C     #define CONSTRAINT_DATA 43

const CONSTRAINT_DATA = 43;
//C     struct constraintData
//C       { 
//C        struct constraintRecord **ConstraintHashtable;
//C        intBool StaticConstraintChecking;
//C        intBool DynamicConstraintChecking;
//C     #if (BLOAD || BLOAD_ONLY || BLOAD_AND_BSAVE) && (! RUN_TIME)
//C        struct constraintRecord *ConstraintArray;
//C        long int NumberOfConstraints;
//C     #endif
//C       };
struct constraintData
{
    constraintRecord **ConstraintHashtable;
    int StaticConstraintChecking;
    int DynamicConstraintChecking;
    constraintRecord *ConstraintArray;
    int NumberOfConstraints;
}

//C     #define ConstraintData(theEnv) ((struct constraintData *) GetEnvironmentData(theEnv,CONSTRAINT_DATA))

//C        LOCALE void                           InitializeConstraints(void *);
void  InitializeConstraints(void *);
//C        LOCALE int                            GDCCommand(void *);
int  GDCCommand(void *);
//C        LOCALE int                            SDCCommand(void *d);
int  SDCCommand(void *d);
//C        LOCALE int                            GSCCommand(void *);
int  GSCCommand(void *);
//C        LOCALE int                            SSCCommand(void *);
int  SSCCommand(void *);
//C        LOCALE intBool                        EnvSetDynamicConstraintChecking(void *,int);
int  EnvSetDynamicConstraintChecking(void *, int );
//C        LOCALE intBool                        EnvGetDynamicConstraintChecking(void *);
int  EnvGetDynamicConstraintChecking(void *);
//C        LOCALE intBool                        EnvSetStaticConstraintChecking(void *,int);
int  EnvSetStaticConstraintChecking(void *, int );
//C        LOCALE intBool                        EnvGetStaticConstraintChecking(void *);
int  EnvGetStaticConstraintChecking(void *);
//C     #if (! BLOAD_ONLY) && (! RUN_TIME)
//C        LOCALE unsigned long                  HashConstraint(struct constraintRecord *);
uint  HashConstraint(constraintRecord *);
//C        LOCALE struct constraintRecord       *AddConstraint(void *,struct constraintRecord *);
constraintRecord * AddConstraint(void *, constraintRecord *);
//C     #endif
//C     #if (! RUN_TIME)
//C        LOCALE void                           RemoveConstraint(void *,struct constraintRecord *);
void  RemoveConstraint(void *, constraintRecord *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        SetDynamicConstraintChecking(int);
//C        LOCALE intBool                        GetDynamicConstraintChecking(void);
//C        LOCALE intBool                        SetStaticConstraintChecking(int);
//C        LOCALE intBool                        GetStaticConstraintChecking(void);

//C     #endif

//C     #endif




//C     #endif
//C     #ifndef _H_cstrccom
//C     #include "cstrccom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*           CONSTRUCT COMMAND HEADER MODULE           */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added ConstructsDeletable function.            */
/*                                                           */
/*      6.30: Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_cstrccom

//C     #define _H_cstrccom

//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CSTRCCOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #if (! RUN_TIME)
//C        LOCALE void                           AddConstructToModule(struct constructHeader *);
void  AddConstructToModule(constructHeader *);
//C     #endif
//C        LOCALE intBool                        DeleteNamedConstruct(void *,const char *,struct construct *);
int  DeleteNamedConstruct(void *, char *, construct *);
//C        LOCALE void                          *FindNamedConstructInModule(void *,const char *,struct construct *);
void * FindNamedConstructInModule(void *, char *, construct *);
//C        LOCALE void                          *FindNamedConstructInModuleOrImports(void *,const char *,struct construct *);
void * FindNamedConstructInModuleOrImports(void *, char *, construct *);
//C        LOCALE void                           UndefconstructCommand(void *,const char *,struct construct *);
void  UndefconstructCommand(void *, char *, construct *);
//C        LOCALE int                            PPConstruct(void *,const char *,const char *,struct construct *);
int  PPConstruct(void *, char *, char *, construct *);
//C        LOCALE SYMBOL_HN                     *GetConstructModuleCommand(void *,const char *,struct construct *);
SYMBOL_HN * GetConstructModuleCommand(void *, char *, construct *);
//C        LOCALE struct defmodule              *GetConstructModule(void *,const char *,struct construct *);
defmodule * GetConstructModule(void *, char *, construct *);
//C        LOCALE intBool                        Undefconstruct(void *,void *,struct construct *);
int  Undefconstruct(void *, void *, construct *);
//C        LOCALE void                           SaveConstruct(void *,void *,const char *,struct construct *);
void  SaveConstruct(void *, void *, char *, construct *);
//C        LOCALE const char                    *GetConstructNameString(struct constructHeader *);
char * GetConstructNameString(constructHeader *);
//C        LOCALE const char                    *EnvGetConstructNameString(void *,struct constructHeader *);
char * EnvGetConstructNameString(void *, constructHeader *);
//C        LOCALE const char                    *GetConstructModuleName(struct constructHeader *);
char * GetConstructModuleName(constructHeader *);
//C        LOCALE SYMBOL_HN                     *GetConstructNamePointer(struct constructHeader *);
SYMBOL_HN * GetConstructNamePointer(constructHeader *);
//C        LOCALE void                           GetConstructListFunction(void *,const char *,DATA_OBJECT_PTR,
//C                                                                       struct construct *);
void  GetConstructListFunction(void *, char *, DATA_OBJECT_PTR , construct *);
//C        LOCALE void                           GetConstructList(void *,DATA_OBJECT_PTR,struct construct *,
//C                                                               struct defmodule *);
void  GetConstructList(void *, DATA_OBJECT_PTR , construct *, defmodule *);
//C        LOCALE void                           ListConstructCommand(void *,const char *,struct construct *);
void  ListConstructCommand(void *, char *, construct *);
//C        LOCALE void                           ListConstruct(void *,struct construct *,const char *,struct defmodule *);
void  ListConstruct(void *, construct *, char *, defmodule *);
//C        LOCALE void                           SetNextConstruct(struct constructHeader *,struct constructHeader *);
void  SetNextConstruct(constructHeader *, constructHeader *);
//C        LOCALE struct defmoduleItemHeader    *GetConstructModuleItem(struct constructHeader *);
defmoduleItemHeader * GetConstructModuleItem(constructHeader *);
//C        LOCALE const char                    *GetConstructPPForm(void *,struct constructHeader *);
char * GetConstructPPForm(void *, constructHeader *);
//C        LOCALE void                           PPConstructCommand(void *,const char *,struct construct *);
void  PPConstructCommand(void *, char *, construct *);
//C        LOCALE struct constructHeader        *GetNextConstructItem(void *,struct constructHeader *,int);
constructHeader * GetNextConstructItem(void *, constructHeader *, int );
//C        LOCALE struct defmoduleItemHeader    *GetConstructModuleItemByIndex(void *,struct defmodule *,int);
defmoduleItemHeader * GetConstructModuleItemByIndex(void *, defmodule *, int );
//C        LOCALE void                           FreeConstructHeaderModule(void *,struct defmoduleItemHeader *,
//C                                                                        struct construct *);
void  FreeConstructHeaderModule(void *, defmoduleItemHeader *, construct *);
//C        LOCALE long                           DoForAllConstructs(void *,
//C                                                                 void (*)(void *,struct constructHeader *,void *),
//C                                                                 int,int,void *);
int  DoForAllConstructs(void *, void  function(void *, constructHeader *, void *), int , int , void *);
//C        LOCALE void                           DoForAllConstructsInModule(void *,void *,
//C                                                                 void (*)(void *,struct constructHeader *,void *),
//C                                                                 int,int,void *);
void  DoForAllConstructsInModule(void *, void *, void  function(void *, constructHeader *, void *), int , int , void *);
//C        LOCALE void                           InitializeConstructHeader(void *,const char *,struct constructHeader *,SYMBOL_HN *);
void  InitializeConstructHeader(void *, char *, constructHeader *, SYMBOL_HN *);
//C        LOCALE void                           SetConstructPPForm(void *,struct constructHeader *,const char *);
void  SetConstructPPForm(void *, constructHeader *, char *);
//C        LOCALE void                          *LookupConstruct(void *,struct construct *,const char *,intBool);
void * LookupConstruct(void *, construct *, char *, int );
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       ConstructPrintWatchAccess(void *,struct construct *,const char *,
//C                                                 EXPRESSION *,
//C                                                 unsigned (*)(void *,void *),
//C                                                 void (*)(void *,unsigned,void *));
uint  ConstructPrintWatchAccess(void *, construct *, char *, EXPRESSION *, uint  function(void *, void *), void  function(void *, uint , void *));
//C        LOCALE unsigned                       ConstructSetWatchAccess(void *,struct construct *,unsigned,
//C                                                 EXPRESSION *,
//C                                                 unsigned (*)(void *,void *),
//C                                                 void (*)(void *,unsigned,void *));
uint  ConstructSetWatchAccess(void *, construct *, uint , EXPRESSION *, uint  function(void *, void *), void  function(void *, uint , void *));
//C     #endif
//C        LOCALE intBool                        ConstructsDeletable(void *);
int  ConstructsDeletable(void *);

//C     #endif



//C     #endif
//C     #ifndef _H_agenda
//C     #include "agenda.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*                 AGENDA HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*   Provides functionality for examining, manipulating,     */
/*   adding, and removing activations from the agenda.       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Removed CONFLICT_RESOLUTION_STRATEGIES and     */
/*            DYNAMIC_SALIENCE compilation flags.            */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added EnvGetActivationBasisPPForm function.    */
/*                                                           */
/*      6.30: Added salience groups to improve performance   */
/*            with large numbers of activations of different */
/*            saliences.                                     */
/*                                                           */
/*            Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_agenda

//C     #define _H_agenda

//C     #ifndef _H_ruledef
//C     #include "ruledef.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_match
//C     #include "match.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                  MATCH HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Added support for hashed memories.             */
/*                                                           */
/*            Added additional members to partialMatch to    */
/*            support changes to the matching algorithm.     */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_match

//C     #define _H_match

//C     struct genericMatch;
//C     struct patternMatch;
//C     struct partialMatch;
//C     struct alphaMatch;
//C     struct multifieldMarker;

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_network
//C     #include "network.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                 NETWORK HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Added support for hashed memories.             */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_network

//C     #define _H_network

//C     struct patternNodeHeader;
//C     struct joinNode;
//C     struct alphaMemoryHash;

//C     #ifndef _H_match
//C     #include "match.h"
//C     #endif

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif

//C     struct patternNodeHeader
//C       {
//C        struct alphaMemoryHash *firstHash;
//C        struct alphaMemoryHash *lastHash;
//C        struct joinNode *entryJoin;
//C        struct expr *rightHash;
//C        unsigned int singlefieldNode : 1;
//C        unsigned int multifieldNode : 1;
//C        unsigned int stopNode : 1;
//C        unsigned int initialize : 1;
//C        unsigned int marked : 1;
//C        unsigned int beginSlot : 1;
//C        unsigned int endSlot : 1;
//C        unsigned int selector : 1;
//C       };
struct patternNodeHeader
{
    alphaMemoryHash *firstHash;
    alphaMemoryHash *lastHash;
    joinNode *entryJoin;
    expr *rightHash;
    uint __bitfield1;
    uint singlefieldNode() { return (__bitfield1 >> 0) & 0x1; }
    uint singlefieldNode(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint multifieldNode() { return (__bitfield1 >> 1) & 0x1; }
    uint multifieldNode(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint stopNode() { return (__bitfield1 >> 2) & 0x1; }
    uint stopNode(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint initialize() { return (__bitfield1 >> 3) & 0x1; }
    uint initialize(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint marked() { return (__bitfield1 >> 4) & 0x1; }
    uint marked(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffef) | (value << 4); return value; }
    uint beginSlot() { return (__bitfield1 >> 5) & 0x1; }
    uint beginSlot(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffdf) | (value << 5); return value; }
    uint endSlot() { return (__bitfield1 >> 6) & 0x1; }
    uint endSlot(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffbf) | (value << 6); return value; }
    uint selector() { return (__bitfield1 >> 7) & 0x1; }
    uint selector(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffff7f) | (value << 7); return value; }
}

//C     struct patternNodeHashEntry
//C       {
//C        void *parent;
//C        void *child;
//C        int type;
//C        void *value;
//C        struct patternNodeHashEntry *next;
//C       };
struct patternNodeHashEntry
{
    void *parent;
    void *child;
    int type;
    void *value;
    patternNodeHashEntry *next;
}

//C     #define SIZE_PATTERN_HASH 16231

const SIZE_PATTERN_HASH = 16231;
//C     struct alphaMemoryHash
//C       {
//C        unsigned long bucket;
//C        struct patternNodeHeader *owner;
//C        struct partialMatch *alphaMemory;
//C        struct partialMatch *endOfQueue;
//C        struct alphaMemoryHash *nextHash;
//C        struct alphaMemoryHash *prevHash;
//C        struct alphaMemoryHash *next;
//C        struct alphaMemoryHash *prev;
//C       };
struct alphaMemoryHash
{
    uint bucket;
    patternNodeHeader *owner;
    partialMatch *alphaMemory;
    partialMatch *endOfQueue;
    alphaMemoryHash *nextHash;
    alphaMemoryHash *prevHash;
    alphaMemoryHash *next;
    alphaMemoryHash *prev;
}

//C     typedef struct alphaMemoryHash ALPHA_MEMORY_HASH;
alias alphaMemoryHash ALPHA_MEMORY_HASH;

//C     #ifndef _H_ruledef
//C     #include "ruledef.h"
//C     #endif

//C     #define INITIAL_BETA_HASH_SIZE 17

const INITIAL_BETA_HASH_SIZE = 17;
//C     struct betaMemory
//C       {
//C        unsigned long size;
//C        unsigned long count;
//C        struct partialMatch **beta;
//C        struct partialMatch **last;
//C       };
struct betaMemory
{
    uint size;
    uint count;
    partialMatch **beta;
    partialMatch **last;
}

//C     struct joinLink
//C       {
//C        char enterDirection;
//C        struct joinNode *join;
//C        struct joinLink *next;
//C        long bsaveID;
//C       };
struct joinLink
{
    char enterDirection;
    joinNode *join;
    joinLink *next;
    int bsaveID;
}
    
//C     struct joinNode
//C       {
//C        unsigned int firstJoin : 1;
//C        unsigned int logicalJoin : 1;
//C        unsigned int joinFromTheRight : 1;
//C        unsigned int patternIsNegated : 1;
//C        unsigned int patternIsExists : 1;
//C        unsigned int initialize : 1;
//C        unsigned int marked : 1;
//C        unsigned int rhsType : 3;
//C        unsigned int depth : 16;
//C        long bsaveID;
//C        long long memoryLeftAdds;
//C        long long memoryRightAdds;
//C        long long memoryLeftDeletes;
//C        long long memoryRightDeletes;
//C        long long memoryCompares;
//C        struct betaMemory *leftMemory;
//C        struct betaMemory *rightMemory;
//C        struct expr *networkTest;
//C        struct expr *secondaryNetworkTest;
//C        struct expr *leftHash;
//C        struct expr *rightHash;
//C        void *rightSideEntryStructure;
//C        struct joinLink *nextLinks;
//C        struct joinNode *lastLevel;
//C        struct joinNode *rightMatchNode;
//C        struct defrule *ruleToActivate;
//C       };
struct joinNode
{
    uint __bitfield1;
    uint firstJoin() { return (__bitfield1 >> 0) & 0x1; }
    uint firstJoin(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint logicalJoin() { return (__bitfield1 >> 1) & 0x1; }
    uint logicalJoin(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint joinFromTheRight() { return (__bitfield1 >> 2) & 0x1; }
    uint joinFromTheRight(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint patternIsNegated() { return (__bitfield1 >> 3) & 0x1; }
    uint patternIsNegated(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint patternIsExists() { return (__bitfield1 >> 4) & 0x1; }
    uint patternIsExists(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffef) | (value << 4); return value; }
    uint initialize() { return (__bitfield1 >> 5) & 0x1; }
    uint initialize(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffdf) | (value << 5); return value; }
    uint marked() { return (__bitfield1 >> 6) & 0x1; }
    uint marked(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffbf) | (value << 6); return value; }
    uint rhsType() { return (__bitfield1 >> 7) & 0x7; }
    uint rhsType(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffc7f) | (value << 7); return value; }
    uint depth() { return (__bitfield1 >> 10) & 0xffff; }
    uint depth(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffc0003ff) | (value << 10); return value; }
    int bsaveID;
    long memoryLeftAdds;
    long memoryRightAdds;
    long memoryLeftDeletes;
    long memoryRightDeletes;
    long memoryCompares;
    betaMemory *leftMemory;
    betaMemory *rightMemory;
    expr *networkTest;
    expr *secondaryNetworkTest;
    expr *leftHash;
    expr *rightHash;
    void *rightSideEntryStructure;
    joinLink *nextLinks;
    joinNode *lastLevel;
    joinNode *rightMatchNode;
    defrule *ruleToActivate;
}

//C     #endif /* _H_network */




//C     #endif
//C     #ifndef _H_pattern
//C     #include "pattern.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                PATTERN HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides the mechanism for recognizing and       */
/*   parsing the various types of patterns that can be used  */
/*   in the LHS of a rule. In version 6.0, the only pattern  */
/*   types provided are for deftemplate and instance         */
/*   patterns.                                               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Added support for hashed alpha memories.       */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_pattern

//C     #define _H_pattern

//C     #ifndef _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #define _STDIO_INCLUDED_
//C     #endif

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     struct patternEntityRecord
//C       {
//C        struct entityRecord base;
//C        void (*decrementBasisCount)(void *,void *);
//C        void (*incrementBasisCount)(void *,void *);
//C        void (*matchFunction)(void *,void *);
//C        intBool (*synchronized)(void *,void *);
//C        intBool (*isDeleted)(void *,void *);
//C       };
struct patternEntityRecord
{
    entityRecord base;
    void  function(void *, void *)decrementBasisCount;
    void  function(void *, void *)incrementBasisCount;
    void  function(void *, void *)matchFunction;
    int  function(void *, void *)synchronized_;
    int  function(void *, void *)isDeleted;
}

//C     typedef struct patternEntityRecord PTRN_ENTITY_RECORD;
alias patternEntityRecord PTRN_ENTITY_RECORD;
//C     typedef struct patternEntityRecord *PTRN_ENTITY_RECORD_PTR;
alias patternEntityRecord *PTRN_ENTITY_RECORD_PTR;

//C     struct patternEntity
//C       {
//C        struct patternEntityRecord *theInfo;
//C        void *dependents;
//C        unsigned busyCount;
//C        unsigned long long timeTag;
//C       };
struct patternEntity
{
    patternEntityRecord *theInfo;
    void *dependents;
    uint busyCount;
    ulong timeTag;
}

//C     typedef struct patternEntity PATTERN_ENTITY;
alias patternEntity PATTERN_ENTITY;
//C     typedef struct patternEntity * PATTERN_ENTITY_PTR;
alias patternEntity *PATTERN_ENTITY_PTR;

//C     struct patternParser;

//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_scanner
//C     #include "scanner.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_match
//C     #include "match.h"
//C     #endif
//C     #ifndef _H_reorder
//C     #include "reorder.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                 REORDER HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides routines necessary for converting the   */
/*   the LHS of a rule into an appropriate form suitable for */
/*   the KB Rete topology. This includes transforming the    */
/*   LHS so there is at most one "or" CE (and this is the    */
/*   first CE of the LHS if it is used), adding initial      */
/*   patterns to the LHS (if no LHS is specified or a "test" */
/*   or "not" CE is the first pattern within an "and" CE),   */
/*   removing redundant CEs, and determining appropriate     */
/*   information on nesting for implementing joins from the  */
/*   right.                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Support for join network changes.              */
/*                                                           */
/*            Changes to the algorithm for processing        */
/*            not/and CE groups.                             */
/*                                                           */
/*            Additional optimizations for combining         */
/*            conditional elements.                          */
/*                                                           */
/*            Added support for hashed alpha memories.       */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_reorder
//C     #define _H_reorder

//C     struct lhsParseNode;

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_ruledef
//C     #include "ruledef.h"
//C     #endif
//C     #ifndef _H_pattern
//C     #include "pattern.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _REORDER_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

/***********************************************************************/
/* lhsParseNode structure: Stores information about the intermediate   */
/*   parsed representation of the lhs of a rule.                       */
/***********************************************************************/
//C     struct lhsParseNode
//C       {
//C        unsigned short type;
//C        void *value;
//C        unsigned int negated : 1;
//C        unsigned int exists : 1;
//C        unsigned int existsNand : 1;
//C        unsigned int logical : 1;
//C        unsigned int multifieldSlot : 1;
//C        unsigned int bindingVariable : 1;
//C        unsigned int derivedConstraints : 1;
//C        unsigned int userCE : 1;
//C        unsigned int whichCE : 7;
//C        unsigned int marked : 1;
//C        unsigned int withinMultifieldSlot : 1;
//C        unsigned short multiFieldsBefore;
//C        unsigned short multiFieldsAfter;
//C        unsigned short singleFieldsBefore;
//C        unsigned short singleFieldsAfter;
//C        struct constraintRecord *constraints;
//C        struct lhsParseNode *referringNode;
//C        struct patternParser *patternType;
//C        short pattern;
//C        short index;
//C        struct symbolHashNode *slot;
//C        short slotNumber;
//C        int beginNandDepth;
//C        int endNandDepth;
//C        int joinDepth;
//C        struct expr *networkTest;
//C        struct expr *externalNetworkTest;
//C        struct expr *secondaryNetworkTest;
//C        struct expr *externalLeftHash;
//C        struct expr *externalRightHash;
//C        struct expr *constantSelector;
//C        struct expr *constantValue;
//C        struct expr *leftHash;
//C        struct expr *rightHash;
//C        struct expr *betaHash;
//C        struct lhsParseNode *expression;
//C        struct lhsParseNode *secondaryExpression;
//C        void *userData;
//C        struct lhsParseNode *right;
//C        struct lhsParseNode *bottom;
//C       };
struct lhsParseNode
{
    ushort type;
    void *value;
    uint __bitfield1;
    uint negated() { return (__bitfield1 >> 0) & 0x1; }
    uint negated(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint exists() { return (__bitfield1 >> 1) & 0x1; }
    uint exists(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint existsNand() { return (__bitfield1 >> 2) & 0x1; }
    uint existsNand(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint logical() { return (__bitfield1 >> 3) & 0x1; }
    uint logical(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint multifieldSlot() { return (__bitfield1 >> 4) & 0x1; }
    uint multifieldSlot(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffef) | (value << 4); return value; }
    uint bindingVariable() { return (__bitfield1 >> 5) & 0x1; }
    uint bindingVariable(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffdf) | (value << 5); return value; }
    uint derivedConstraints() { return (__bitfield1 >> 6) & 0x1; }
    uint derivedConstraints(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffbf) | (value << 6); return value; }
    uint userCE() { return (__bitfield1 >> 7) & 0x1; }
    uint userCE(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffff7f) | (value << 7); return value; }
    uint whichCE() { return (__bitfield1 >> 8) & 0x7f; }
    uint whichCE(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffff80ff) | (value << 8); return value; }
    uint marked() { return (__bitfield1 >> 15) & 0x1; }
    uint marked(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffff7fff) | (value << 15); return value; }
    uint withinMultifieldSlot() { return (__bitfield1 >> 16) & 0x1; }
    uint withinMultifieldSlot(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffeffff) | (value << 16); return value; }
    ushort multiFieldsBefore;
    ushort multiFieldsAfter;
    ushort singleFieldsBefore;
    ushort singleFieldsAfter;
    constraintRecord *constraints;
    lhsParseNode *referringNode;
    patternParser *patternType;
    short pattern;
    short index;
    symbolHashNode *slot;
    short slotNumber;
    int beginNandDepth;
    int endNandDepth;
    int joinDepth;
    expr *networkTest;
    expr *externalNetworkTest;
    expr *secondaryNetworkTest;
    expr *externalLeftHash;
    expr *externalRightHash;
    expr *constantSelector;
    expr *constantValue;
    expr *leftHash;
    expr *rightHash;
    expr *betaHash;
    lhsParseNode *expression;
    lhsParseNode *secondaryExpression;
    void *userData;
    lhsParseNode *right;
    lhsParseNode *bottom;
}

//C        LOCALE struct lhsParseNode           *ReorderPatterns(void *,struct lhsParseNode *,int *);
lhsParseNode * ReorderPatterns(void *, lhsParseNode *, int *);
//C        LOCALE struct lhsParseNode           *CopyLHSParseNodes(void *,struct lhsParseNode *);
lhsParseNode * CopyLHSParseNodes(void *, lhsParseNode *);
//C        LOCALE void                           CopyLHSParseNode(void *,struct lhsParseNode *,struct lhsParseNode *,int);
void  CopyLHSParseNode(void *, lhsParseNode *, lhsParseNode *, int );
//C        LOCALE struct lhsParseNode           *GetLHSParseNode(void *);
lhsParseNode * GetLHSParseNode(void *);
//C        LOCALE void                           ReturnLHSParseNodes(void *,struct lhsParseNode *);
void  ReturnLHSParseNodes(void *, lhsParseNode *);
//C        LOCALE struct lhsParseNode           *ExpressionToLHSParseNodes(void *,struct expr *);
lhsParseNode * ExpressionToLHSParseNodes(void *, expr *);
//C        LOCALE struct expr                   *LHSParseNodesToExpression(void *,struct lhsParseNode *);
expr * LHSParseNodesToExpression(void *, lhsParseNode *);
//C        LOCALE void                           AddInitialPatterns(void *,struct lhsParseNode *);
void  AddInitialPatterns(void *, lhsParseNode *);
//C        LOCALE int                            IsExistsSubjoin(struct lhsParseNode *,int);
int  IsExistsSubjoin(lhsParseNode *, int );
//C        LOCALE struct lhsParseNode           *CombineLHSParseNodes(void *,struct lhsParseNode *,struct lhsParseNode *);
lhsParseNode * CombineLHSParseNodes(void *, lhsParseNode *, lhsParseNode *);
//C        LOCALE void                           AssignPatternMarkedFlag(struct lhsParseNode *,short);
void  AssignPatternMarkedFlag(lhsParseNode *, short );

//C     #endif /* _H_reorder */





//C     #endif
//C     #ifndef _H_constrnt
//C     #include "constrnt.h"
//C     #endif

//C     #define MAXIMUM_NUMBER_OF_PATTERNS 128

const MAXIMUM_NUMBER_OF_PATTERNS = 128;
//C     struct patternParser
//C       {
//C        const char *name;
//C        struct patternEntityRecord *entityType;
//C        int positionInArray;
//C        int (*recognizeFunction)(SYMBOL_HN *);
//C        struct lhsParseNode *(*parseFunction)(void *,const char *,struct token *);
//C        int (*postAnalysisFunction)(void *,struct lhsParseNode *);
//C        struct patternNodeHeader *(*addPatternFunction)(void *,struct lhsParseNode *);
//C        void (*removePatternFunction)(void *,struct patternNodeHeader *);
//C        struct expr *(*genJNConstantFunction)(void *,struct lhsParseNode *,int);
//C        void (*replaceGetJNValueFunction)(void *,struct expr *,struct lhsParseNode *,int);
//C        struct expr *(*genGetJNValueFunction)(void *,struct lhsParseNode *,int);
//C        struct expr *(*genCompareJNValuesFunction)(void *,struct lhsParseNode *,struct lhsParseNode *,int);
//C        struct expr *(*genPNConstantFunction)(void *,struct lhsParseNode *);
//C        void (*replaceGetPNValueFunction)(void *,struct expr *,struct lhsParseNode *);
//C        struct expr *(*genGetPNValueFunction)(void *,struct lhsParseNode *);
//C        struct expr *(*genComparePNValuesFunction)(void *,struct lhsParseNode *,struct lhsParseNode *);
//C        void (*returnUserDataFunction)(void *,void *);
//C        void *(*copyUserDataFunction)(void *,void *);
//C        void (*markIRPatternFunction)(void *,struct patternNodeHeader *,int);
//C        void (*incrementalResetFunction)(void *);
//C        struct lhsParseNode *(*initialPatternFunction)(void *);
//C        void (*codeReferenceFunction)(void *,void *,FILE *,int,int);
//C        int priority;
//C        struct patternParser *next;
//C       };
struct patternParser
{
    char *name;
    patternEntityRecord *entityType;
    int positionInArray;
    int  function(SYMBOL_HN *)recognizeFunction;
    lhsParseNode * function(void *, char *, token *)parseFunction;
    int  function(void *, lhsParseNode *)postAnalysisFunction;
    patternNodeHeader * function(void *, lhsParseNode *)addPatternFunction;
    void  function(void *, patternNodeHeader *)removePatternFunction;
    expr * function(void *, lhsParseNode *, int )genJNConstantFunction;
    void  function(void *, expr *, lhsParseNode *, int )replaceGetJNValueFunction;
    expr * function(void *, lhsParseNode *, int )genGetJNValueFunction;
    expr * function(void *, lhsParseNode *, lhsParseNode *, int )genCompareJNValuesFunction;
    expr * function(void *, lhsParseNode *)genPNConstantFunction;
    void  function(void *, expr *, lhsParseNode *)replaceGetPNValueFunction;
    expr * function(void *, lhsParseNode *)genGetPNValueFunction;
    expr * function(void *, lhsParseNode *, lhsParseNode *)genComparePNValuesFunction;
    void  function(void *, void *)returnUserDataFunction;
    void * function(void *, void *)copyUserDataFunction;
    void  function(void *, patternNodeHeader *, int )markIRPatternFunction;
    void  function(void *)incrementalResetFunction;
    lhsParseNode * function(void *)initialPatternFunction;
    void  function(void *, void *, FILE *, int , int )codeReferenceFunction;
    int priority;
    patternParser *next;
}

//C     struct reservedSymbol
//C       {
//C        const char *theSymbol;
//C        const char *reservedBy;
//C        struct reservedSymbol *next;
//C       };
struct reservedSymbol
{
    char *theSymbol;
    char *reservedBy;
    reservedSymbol *next;
}

//C     #define MAX_POSITIONS 8

const MAX_POSITIONS = 8;
//C     #define PATTERN_DATA 19

const PATTERN_DATA = 19;
//C     struct patternData
//C       { 
//C        struct patternParser *ListOfPatternParsers;
//C        struct patternParser *PatternParserArray[MAX_POSITIONS];
//C        int NextPosition;
//C        struct reservedSymbol *ListOfReservedPatternSymbols;
//C        int WithinNotCE;
//C        int  GlobalSalience;
//C        int GlobalAutoFocus;
//C        struct expr *SalienceExpression;
//C        struct patternNodeHashEntry **PatternHashTable;
//C        unsigned long PatternHashTableSize;
//C       };
struct patternData
{
    patternParser *ListOfPatternParsers;
    patternParser *[8]PatternParserArray;
    int NextPosition;
    reservedSymbol *ListOfReservedPatternSymbols;
    int WithinNotCE;
    int GlobalSalience;
    int GlobalAutoFocus;
    expr *SalienceExpression;
    patternNodeHashEntry **PatternHashTable;
    uint PatternHashTableSize;
}

//C     #define PatternData(theEnv) ((struct patternData *) GetEnvironmentData(theEnv,PATTERN_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _PATTERN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializePatterns(void *);
void  InitializePatterns(void *);
//C        LOCALE int                            AddPatternParser(void *,struct patternParser *);
int  AddPatternParser(void *, patternParser *);
//C        LOCALE struct patternParser          *FindPatternParser(void *,const char *);
patternParser * FindPatternParser(void *, char *);
//C        LOCALE void                           DetachPattern(void *,int,struct patternNodeHeader *);
void  DetachPattern(void *, int , patternNodeHeader *);
//C        LOCALE void                           GetNextPatternEntity(void *,
//C                                                                   struct patternParser **,
//C                                                                   struct patternEntity **);
void  GetNextPatternEntity(void *, patternParser **, patternEntity **);
//C        LOCALE struct patternParser          *GetPatternParser(void *,int);
patternParser * GetPatternParser(void *, int );
//C        LOCALE struct lhsParseNode           *RestrictionParse(void *,const char *,struct token *,int,
//C                                                            struct symbolHashNode *,short,
//C                                                            struct constraintRecord *,short);
lhsParseNode * RestrictionParse(void *, char *, token *, int , symbolHashNode *, short , constraintRecord *, short );
//C        LOCALE int                            PostPatternAnalysis(void *,struct lhsParseNode *);
int  PostPatternAnalysis(void *, lhsParseNode *);
//C        LOCALE void                           PatternNodeHeaderToCode(void *,FILE *,struct patternNodeHeader *,int,int);
void  PatternNodeHeaderToCode(void *, FILE *, patternNodeHeader *, int , int );
//C        LOCALE void                           AddReservedPatternSymbol(void *,const char *,const char *);
void  AddReservedPatternSymbol(void *, char *, char *);
//C        LOCALE intBool                        ReservedPatternSymbol(void *,const char *,const char *);
int  ReservedPatternSymbol(void *, char *, char *);
//C        LOCALE void                           ReservedPatternSymbolErrorMsg(void *,const char *,const char *);
void  ReservedPatternSymbolErrorMsg(void *, char *, char *);
//C        LOCALE void                           AddHashedPatternNode(void *,void *,void *,unsigned short,void *);
void  AddHashedPatternNode(void *, void *, void *, ushort , void *);
//C        LOCALE intBool                        RemoveHashedPatternNode(void *,void *,void *,unsigned short,void *);
int  RemoveHashedPatternNode(void *, void *, void *, ushort , void *);
//C        LOCALE void                          *FindHashedPatternNode(void *,void *,unsigned short,void *);
void * FindHashedPatternNode(void *, void *, ushort , void *);

//C     #endif /* _H_pattern */









//C     #endif

/************************************************************/
/* PATTERNMATCH STRUCTURE:                                  */
/************************************************************/
//C     struct patternMatch
//C       {
//C        struct patternMatch *next;
//C        struct partialMatch *theMatch;
//C        struct patternNodeHeader *matchingPattern;
//C       };
struct patternMatch
{
    patternMatch *next;
    partialMatch *theMatch;
    patternNodeHeader *matchingPattern;
}

/**************************/
/* genericMatch structure */
/**************************/
//C     struct genericMatch
//C       {
//C        union
//C          {
//C           void *theValue;
//C           struct alphaMatch *theMatch;
//C          } gm;
union _N1
{
    void *theValue;
    alphaMatch *theMatch;
}
//C       };
struct genericMatch
{
    _N1 gm;
}

/************************************************************/
/* PARTIALMATCH STRUCTURE:                                  */
/************************************************************/
//C     struct partialMatch
//C       {
//C        unsigned int betaMemory  :  1;
//C        unsigned int busy        :  1;
//C        unsigned int rhsMemory   :  1;
//C        unsigned short bcount; 
//C        unsigned long hashValue;
//C        void *owner;
//C        void *marker;
//C        void *dependents;
//C        struct partialMatch *nextInMemory;
//C        struct partialMatch *prevInMemory;
//C        struct partialMatch *children;
//C        struct partialMatch *rightParent;
//C        struct partialMatch *nextRightChild;
//C        struct partialMatch *prevRightChild;
//C        struct partialMatch *leftParent;
//C        struct partialMatch *nextLeftChild;
//C        struct partialMatch *prevLeftChild;
//C        struct partialMatch *blockList;
//C        struct partialMatch *nextBlocked;
//C        struct partialMatch *prevBlocked;
//C        struct genericMatch binds[1];
//C       };
struct partialMatch
{
    uint __bitfield1;
    uint betaMemory() { return (__bitfield1 >> 0) & 0x1; }
    uint betaMemory(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint busy() { return (__bitfield1 >> 1) & 0x1; }
    uint busy(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint rhsMemory() { return (__bitfield1 >> 2) & 0x1; }
    uint rhsMemory(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    ushort bcount;
    uint hashValue;
    void *owner;
    void *marker;
    void *dependents;
    partialMatch *nextInMemory;
    partialMatch *prevInMemory;
    partialMatch *children;
    partialMatch *rightParent;
    partialMatch *nextRightChild;
    partialMatch *prevRightChild;
    partialMatch *leftParent;
    partialMatch *nextLeftChild;
    partialMatch *prevLeftChild;
    partialMatch *blockList;
    partialMatch *nextBlocked;
    partialMatch *prevBlocked;
    genericMatch [1]binds;
}

/************************************************************/
/* ALPHAMATCH STRUCTURE:                                    */
/************************************************************/
//C     struct alphaMatch
//C       {
//C        struct patternEntity *matchingItem;
//C        struct multifieldMarker *markers;
//C        struct alphaMatch *next;
//C        unsigned long bucket;
//C       };
struct alphaMatch
{
    patternEntity *matchingItem;
    multifieldMarker *markers;
    alphaMatch *next;
    uint bucket;
}

/************************************************************/
/* MULTIFIELDMARKER STRUCTURE: Used in the pattern matching */
/* process to mark the range of fields that the $? and      */
/* $?variables match because a single pattern restriction   */
/* may span zero or more fields..                           */
/************************************************************/
//C     struct multifieldMarker
//C       {
//C        int whichField;
//C        union
//C          {
//C           void *whichSlot;
//C           short int whichSlotNumber;
//C          } where;
union _N2
{
    void *whichSlot;
    short whichSlotNumber;
}
//C         long startPosition;
//C         long endPosition;
//C         struct multifieldMarker *next;
//C        };
struct multifieldMarker
{
    int whichField;
    _N2 where;
    int startPosition;
    int endPosition;
    multifieldMarker *next;
}

//C     #define get_nth_pm_value(thePM,thePos) (thePM->binds[thePos].gm.theValue)
//C     #define get_nth_pm_match(thePM,thePos) (thePM->binds[thePos].gm.theMatch)

//C     #define set_nth_pm_value(thePM,thePos,theVal) (thePM->binds[thePos].gm.theValue = (void *) theVal)
//C     #define set_nth_pm_match(thePM,thePos,theVal) (thePM->binds[thePos].gm.theMatch = theVal)

//C     #endif /* _H_match */






//C     #endif

//C     #define WHEN_DEFINED 0
//C     #define WHEN_ACTIVATED 1
const WHEN_DEFINED = 0;
//C     #define EVERY_CYCLE 2
const WHEN_ACTIVATED = 1;

const EVERY_CYCLE = 2;
//C     #define MAX_DEFRULE_SALIENCE  10000
//C     #define MIN_DEFRULE_SALIENCE -10000
const MAX_DEFRULE_SALIENCE = 10000;
  
const MIN_DEFRULE_SALIENCE = -10000;
/*******************/
/* DATA STRUCTURES */
/*******************/

//C     struct activation
//C       {
//C        struct defrule *theRule;
//C        struct partialMatch *basis;
//C        int salience;
//C        unsigned long long timetag;
//C        int randomID;
//C        struct activation *prev;
//C        struct activation *next;
//C       };
struct activation
{
    defrule *theRule;
    partialMatch *basis;
    int salience;
    ulong timetag;
    int randomID;
    activation *prev;
    activation *next;
}

//C     struct salienceGroup
//C       {
//C        int salience;
//C        struct activation *first;
//C        struct activation *last;
//C        struct salienceGroup *next;
//C        struct salienceGroup *prev;
//C       };
struct salienceGroup
{
    int salience;
    activation *first;
    activation *last;
    salienceGroup *next;
    salienceGroup *prev;
}

//C     typedef struct activation ACTIVATION;
alias activation ACTIVATION;

//C     #define AGENDA_DATA 17

const AGENDA_DATA = 17;
//C     struct agendaData
//C       { 
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchActivations;
//C     #endif
//C        unsigned long NumberOfActivations;
//C        unsigned long long CurrentTimetag;
//C        int AgendaChanged;
//C        intBool SalienceEvaluation;
//C        int Strategy;
//C       };
struct agendaData
{
    uint WatchActivations;
    uint NumberOfActivations;
    ulong CurrentTimetag;
    int AgendaChanged;
    int SalienceEvaluation;
    int Strategy;
}

//C     #define AgendaData(theEnv) ((struct agendaData *) GetEnvironmentData(theEnv,AGENDA_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _AGENDA_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

/****************************************/
/* GLOBAL EXTERNAL FUNCTION DEFINITIONS */
/****************************************/

//C        LOCALE void                    AddActivation(void *,void *,void *);
void  AddActivation(void *, void *, void *);
//C        LOCALE void                    ClearRuleFromAgenda(void *,void *);
void  ClearRuleFromAgenda(void *, void *);
//C        LOCALE void                   *EnvGetNextActivation(void *,void *);
void * EnvGetNextActivation(void *, void *);
//C        LOCALE struct partialMatch    *EnvGetActivationBasis(void *,void *);
partialMatch * EnvGetActivationBasis(void *, void *);
//C        LOCALE const char             *EnvGetActivationName(void *,void *);
char * EnvGetActivationName(void *, void *);
//C        LOCALE struct defrule         *EnvGetActivationRule(void *,void *);
defrule * EnvGetActivationRule(void *, void *);
//C        LOCALE int                     EnvGetActivationSalience(void *,void *);
int  EnvGetActivationSalience(void *, void *);
//C        LOCALE int                     EnvSetActivationSalience(void *,void *,int);
int  EnvSetActivationSalience(void *, void *, int );
//C        LOCALE void                    EnvGetActivationPPForm(void *,char *,size_t,void *);
void  EnvGetActivationPPForm(void *, char *, size_t , void *);
//C        LOCALE void                    EnvGetActivationBasisPPForm(void *,char *,size_t,void *);
void  EnvGetActivationBasisPPForm(void *, char *, size_t , void *);
//C        LOCALE intBool                 MoveActivationToTop(void *,void *);
int  MoveActivationToTop(void *, void *);
//C        LOCALE intBool                 EnvDeleteActivation(void *,void *);
int  EnvDeleteActivation(void *, void *);
//C        LOCALE intBool                 DetachActivation(void *,void *);
int  DetachActivation(void *, void *);
//C        LOCALE void                    EnvAgenda(void *,const char *,void *);
void  EnvAgenda(void *, char *, void *);
//C        LOCALE void                    RemoveActivation(void *,void *,int,int);
void  RemoveActivation(void *, void *, int , int );
//C        LOCALE void                    RemoveAllActivations(void *);
void  RemoveAllActivations(void *);
//C        LOCALE int                     EnvGetAgendaChanged(void *);
int  EnvGetAgendaChanged(void *);
//C        LOCALE void                    EnvSetAgendaChanged(void *,int);
void  EnvSetAgendaChanged(void *, int );
//C        LOCALE unsigned long           GetNumberOfActivations(void *);
uint  GetNumberOfActivations(void *);
//C        LOCALE intBool                 EnvGetSalienceEvaluation(void *);
int  EnvGetSalienceEvaluation(void *);
//C        LOCALE intBool                 EnvSetSalienceEvaluation(void *,intBool);
int  EnvSetSalienceEvaluation(void *, int );
//C        LOCALE void                    EnvRefreshAgenda(void *,void *);
void  EnvRefreshAgenda(void *, void *);
//C        LOCALE void                    EnvReorderAgenda(void *,void *);
void  EnvReorderAgenda(void *, void *);
//C        LOCALE void                    InitializeAgenda(void *);
void  InitializeAgenda(void *);
//C        LOCALE void                   *SetSalienceEvaluationCommand(void *);
void * SetSalienceEvaluationCommand(void *);
//C        LOCALE void                   *GetSalienceEvaluationCommand(void *);
void * GetSalienceEvaluationCommand(void *);
//C        LOCALE void                    RefreshAgendaCommand(void *);
void  RefreshAgendaCommand(void *);
//C        LOCALE void                    RefreshCommand(void *);
void  RefreshCommand(void *);
//C        LOCALE intBool                 EnvRefresh(void *,void *);
int  EnvRefresh(void *, void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                    AgendaCommand(void *);
void  AgendaCommand(void *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                    Agenda(const char *,void *);
//C        LOCALE intBool                 DeleteActivation(void *);
//C        LOCALE struct partialMatch    *GetActivationBasis(void *);
//C        LOCALE const char             *GetActivationName(void *);
//C        LOCALE void                    GetActivationPPForm(char *,unsigned,void *);
//C        LOCALE struct defrule         *GetActivationRule(void *);
//C        LOCALE int                     GetActivationSalience(void *);
//C        LOCALE int                     GetAgendaChanged(void);
//C        LOCALE void                   *GetNextActivation(void *);
//C        LOCALE intBool                 GetSalienceEvaluation(void);
//C        LOCALE intBool                 Refresh(void *);
//C        LOCALE void                    RefreshAgenda(void *);
//C        LOCALE void                    ReorderAgenda(void *);
//C        LOCALE int                     SetActivationSalience(void *,int);
//C        LOCALE void                    SetAgendaChanged(int);
//C        LOCALE intBool                 SetSalienceEvaluation(int);

//C     #endif

//C     #endif






//C     #endif
//C     #ifndef _H_network
//C     #include "network.h"
//C     #endif

//C     struct defrule
//C       {
//C        struct constructHeader header;
//C        int salience;
//C        int localVarCnt;
//C        unsigned int complexity      : 11;
//C        unsigned int afterBreakpoint :  1;
//C        unsigned int watchActivation :  1;
//C        unsigned int watchFiring     :  1;
//C        unsigned int autoFocus       :  1;
//C        unsigned int executing       :  1;
//C        struct expr *dynamicSalience;
//C        struct expr *actions;
//C        struct joinNode *logicalJoin;
//C        struct joinNode *lastJoin;
//C        struct defrule *disjunct;
//C       };
struct defrule
{
    constructHeader header;
    int salience;
    int localVarCnt;
    uint __bitfield1;
    uint complexity() { return (__bitfield1 >> 0) & 0x7ff; }
    uint complexity(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffff800) | (value << 0); return value; }
    uint afterBreakpoint() { return (__bitfield1 >> 11) & 0x1; }
    uint afterBreakpoint(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffff7ff) | (value << 11); return value; }
    uint watchActivation() { return (__bitfield1 >> 12) & 0x1; }
    uint watchActivation(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffefff) | (value << 12); return value; }
    uint watchFiring() { return (__bitfield1 >> 13) & 0x1; }
    uint watchFiring(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffdfff) | (value << 13); return value; }
    uint autoFocus() { return (__bitfield1 >> 14) & 0x1; }
    uint autoFocus(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffbfff) | (value << 14); return value; }
    uint executing() { return (__bitfield1 >> 15) & 0x1; }
    uint executing(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffff7fff) | (value << 15); return value; }
    expr *dynamicSalience;
    expr *actions;
    joinNode *logicalJoin;
    joinNode *lastJoin;
    defrule *disjunct;
}

//C     struct defruleModule
//C       {
//C        struct defmoduleItemHeader header;
//C        struct salienceGroup *groupings;
//C        struct activation *agenda;
//C       };
struct defruleModule
{
    defmoduleItemHeader header;
    salienceGroup *groupings;
    activation *agenda;
}

//C     #ifndef ALPHA_MEMORY_HASH_SIZE
//C     #define ALPHA_MEMORY_HASH_SIZE       63559L
//C     #endif
const ALPHA_MEMORY_HASH_SIZE = 63559;

//C     #define DEFRULE_DATA 16

const DEFRULE_DATA = 16;
//C     struct defruleData
//C       { 
//C        struct construct *DefruleConstruct;
//C        int DefruleModuleIndex;
//C        long long CurrentEntityTimeTag;
//C        struct alphaMemoryHash **AlphaMemoryTable;
//C        intBool BetaMemoryResizingFlag;
//C        struct joinLink *RightPrimeJoins;
//C        struct joinLink *LeftPrimeJoins;

//C     #if DEBUGGING_FUNCTIONS
//C         unsigned WatchRules;
//C         int DeletedRuleDebugFlags;
//C     #endif
//C     #if DEVELOPER && (! RUN_TIME) && (! BLOAD_ONLY)
//C         unsigned WatchRuleAnalysis;
//C     #endif
//C     #if CONSTRUCT_COMPILER && (! RUN_TIME)
//C        struct CodeGeneratorItem *DefruleCodeItem;
//C     #endif
//C       };
struct defruleData
{
    construct *DefruleConstruct;
    int DefruleModuleIndex;
    long CurrentEntityTimeTag;
    alphaMemoryHash **AlphaMemoryTable;
    int BetaMemoryResizingFlag;
    joinLink *RightPrimeJoins;
    joinLink *LeftPrimeJoins;
    uint WatchRules;
    int DeletedRuleDebugFlags;
    CodeGeneratorItem *DefruleCodeItem;
}

//C     #define DefruleData(theEnv) ((struct defruleData *) GetEnvironmentData(theEnv,DEFRULE_DATA))

//C     #define GetPreviousJoin(theJoin)    (((theJoin)->joinFromTheRight) ?     ((struct joinNode *) (theJoin)->rightSideEntryStructure) :     ((theJoin)->lastLevel))
//C     #define GetPatternForJoin(theJoin)    (((theJoin)->joinFromTheRight) ?     NULL :     ((theJoin)->rightSideEntryStructure))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _RULEDEF_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeDefrules(void *);
void  InitializeDefrules(void *);
//C        LOCALE void                          *EnvFindDefrule(void *,const char *);
void * EnvFindDefrule(void *, char *);
//C        LOCALE void                          *EnvFindDefruleInModule(void *,const char *);
void * EnvFindDefruleInModule(void *, char *);
//C        LOCALE void                          *EnvGetNextDefrule(void *,void *);
void * EnvGetNextDefrule(void *, void *);
//C        LOCALE struct defruleModule          *GetDefruleModuleItem(void *,struct defmodule *);
defruleModule * GetDefruleModuleItem(void *, defmodule *);
//C        LOCALE intBool                        EnvIsDefruleDeletable(void *,void *);
int  EnvIsDefruleDeletable(void *, void *);
//C     #if RUN_TIME
//C        LOCALE void                           DefruleRunTimeInitialize(void *,struct joinLink *,struct joinLink *);
//C     #endif
//C     #if RUN_TIME || BLOAD_ONLY || BLOAD || BLOAD_AND_BSAVE
//C        LOCALE void                           AddBetaMemoriesToJoin(void *,struct joinNode *);
void  AddBetaMemoriesToJoin(void *, joinNode *);
//C     #endif
//C        LOCALE long                           EnvGetDisjunctCount(void *,void *);
int  EnvGetDisjunctCount(void *, void *);
//C        LOCALE void                          *EnvGetNthDisjunct(void *,void *,long);
void * EnvGetNthDisjunct(void *, void *, int );
//C        LOCALE const char                    *EnvDefruleModule(void *,void *);
char * EnvDefruleModule(void *, void *);
//C        LOCALE const char                    *EnvGetDefruleName(void *,void *);
char * EnvGetDefruleName(void *, void *);
//C        LOCALE const char                    *EnvGetDefrulePPForm(void *,void *);
char * EnvGetDefrulePPForm(void *, void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE const char                    *DefruleModule(void *);
//C        LOCALE void                          *FindDefrule(const char *);
//C        LOCALE const char                    *GetDefruleName(void *);
//C        LOCALE const char                    *GetDefrulePPForm(void *);
//C        LOCALE void                          *GetNextDefrule(void *);
//C        LOCALE intBool                        IsDefruleDeletable(void *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */


//C     #endif /* _H_ruledef */


//C     #endif
//C     #include "rulebsc.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/04/15            */
   /*                                                     */
   /*         DEFRULE BASIC COMMANDS HEADER FILE          */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements core commands for the defrule         */
/*   construct such as clear, reset, save, undefrule,        */
/*   ppdefrule, list-defrules, and                           */
/*   get-defrule-list.                                       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*            Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Support for join network changes.              */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added code to prevent a clear command from     */
/*            being executed during fact assertions via      */
/*            JoinOperationInProgress mechanism.             */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_rulebsc
//C     #define _H_rulebsc

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _RULEBSC_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           DefruleBasicCommands(void *);
void  DefruleBasicCommands(void *);
//C        LOCALE void                           UndefruleCommand(void *);
void  UndefruleCommand(void *);
//C        LOCALE intBool                        EnvUndefrule(void *,void *);
int  EnvUndefrule(void *, void *);
//C        LOCALE void                           GetDefruleListFunction(void *,DATA_OBJECT_PTR);
void  GetDefruleListFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           EnvGetDefruleList(void *,DATA_OBJECT_PTR,void *);
void  EnvGetDefruleList(void *, DATA_OBJECT_PTR , void *);
//C        LOCALE void                          *DefruleModuleFunction(void *);
void * DefruleModuleFunction(void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           PPDefruleCommand(void *);
void  PPDefruleCommand(void *);
//C        LOCALE int                            PPDefrule(void *,const char *,const char *);
int  PPDefrule(void *, char *, char *);
//C        LOCALE void                           ListDefrulesCommand(void *);
void  ListDefrulesCommand(void *);
//C        LOCALE void                           EnvListDefrules(void *,const char *,void *);
void  EnvListDefrules(void *, char *, void *);
//C        LOCALE unsigned                       EnvGetDefruleWatchFirings(void *,void *);
uint  EnvGetDefruleWatchFirings(void *, void *);
//C        LOCALE unsigned                       EnvGetDefruleWatchActivations(void *,void *);
uint  EnvGetDefruleWatchActivations(void *, void *);
//C        LOCALE void                           EnvSetDefruleWatchFirings(void *,unsigned,void *);
void  EnvSetDefruleWatchFirings(void *, uint , void *);
//C        LOCALE void                           EnvSetDefruleWatchActivations(void *,unsigned,void *);
void  EnvSetDefruleWatchActivations(void *, uint , void *);
//C        LOCALE unsigned                       DefruleWatchAccess(void *,int,unsigned,struct expr *);
uint  DefruleWatchAccess(void *, int , uint , expr *);
//C        LOCALE unsigned                       DefruleWatchPrint(void *,const char *,int,struct expr *);
uint  DefruleWatchPrint(void *, char *, int , expr *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           GetDefruleList(DATA_OBJECT_PTR,void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       GetDefruleWatchActivations(void *);
//C        LOCALE unsigned                       GetDefruleWatchFirings(void *);
//C        LOCALE void                           ListDefrules(const char *,void *);
//C        LOCALE void                           SetDefruleWatchActivations(unsigned,void *);
//C        LOCALE void                           SetDefruleWatchFirings(unsigned,void *);
//C     #endif
//C        LOCALE intBool                        Undefrule(void *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_rulebsc */


//C     #include "engine.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/04/15            */
   /*                                                     */
   /*                 ENGINE HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides functionality primarily associated with */
/*   the run and focus commands.                             */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Removed DYNAMIC_SALIENCE, INCREMENTAL_RESET,   */
/*            and LOGICAL_DEPENDENCIES compilation flags.    */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added access functions to the HaltRules flag.  */
/*                                                           */
/*            Added EnvGetNextFocus, EnvGetFocusChanged, and */
/*            EnvSetFocusChanged functions.                  */
/*                                                           */
/*      6.30: Added additional developer statistics to help  */
/*            analyze join network performance.              */
/*                                                           */
/*            Removed pseudo-facts used in not CEs.          */
/*                                                           */
/*            Added context information for run functions.   */
/*                                                           */
/*            Added before rule firing callback function.    */
 
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added EnvHalt function.                        */
/*                                                           */
/*            Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_engine

//C     #define _H_engine

//C     #ifndef _H_lgcldpnd
//C     #include "lgcldpnd.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*          LOGICAL DEPENDENCIES HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provide support routines for managing truth      */
/*   maintenance using the logical conditional element.      */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Rule with exists CE has incorrect activation.  */
/*            DR0867                                         */
/*                                                           */
/*      6.30: Added support for hashed memories.             */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_lgcldpnd

//C     #define _H_lgcldpnd

//C     struct dependency
//C       {
//C        void *dPtr;
//C        struct dependency *next;
//C       };
struct dependency
{
    void *dPtr;
    dependency *next;
}

//C     #ifndef _H_match
//C     #include "match.h"
//C     #endif
//C     #ifndef _H_pattern
//C     #include "pattern.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _LGCLDPND_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE intBool                        AddLogicalDependencies(void *,struct patternEntity *,int);
int  AddLogicalDependencies(void *, patternEntity *, int );
//C        LOCALE void                           RemoveEntityDependencies(void *,struct patternEntity *);
void  RemoveEntityDependencies(void *, patternEntity *);
//C        LOCALE void                           RemovePMDependencies(void *,struct partialMatch *);
void  RemovePMDependencies(void *, partialMatch *);
//C        LOCALE void                           DestroyPMDependencies(void *,struct partialMatch *);
void  DestroyPMDependencies(void *, partialMatch *);
//C        LOCALE void                           RemoveLogicalSupport(void *,struct partialMatch *);
void  RemoveLogicalSupport(void *, partialMatch *);
//C        LOCALE void                           ForceLogicalRetractions(void *);
void  ForceLogicalRetractions(void *);
//C        LOCALE void                           Dependencies(void *,struct patternEntity *);
void  Dependencies(void *, patternEntity *);
//C        LOCALE void                           Dependents(void *,struct patternEntity *);
void  Dependents(void *, patternEntity *);
//C        LOCALE void                           DependenciesCommand(void *);
void  DependenciesCommand(void *);
//C        LOCALE void                           DependentsCommand(void *);
void  DependentsCommand(void *);
//C        LOCALE void                           ReturnEntityDependencies(void *,struct patternEntity *);
void  ReturnEntityDependencies(void *, patternEntity *);
//C        LOCALE struct partialMatch           *FindLogicalBind(struct joinNode *,struct partialMatch *);
partialMatch * FindLogicalBind(joinNode *, partialMatch *);

//C     #endif /* _H_lgcldpnd */





//C     #endif
//C     #ifndef _H_ruledef
//C     #include "ruledef.h"
//C     #endif
//C     #ifndef _H_network
//C     #include "network.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_retract
//C     #include "retract.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                RETRACT HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose:  Handles join network activity associated with   */
/*   with the removal of a data entity such as a fact or     */
/*   instance.                                               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Rule with exists CE has incorrect activation.  */
/*            DR0867                                         */
/*                                                           */
/*      6.30: Added support for hashed memories.             */
/*                                                           */
/*            Added additional developer statistics to help  */
/*            analyze join network performance.              */
/*                                                           */
/*            Removed pseudo-facts used in not CEs.          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_retract
//C     #define _H_retract

//C     #ifndef _H_match
//C     #include "match.h"
//C     #endif
//C     #ifndef _H_network
//C     #include "network.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _RETRACT_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     struct rdriveinfo
//C       {
//C        struct partialMatch *link;
//C        struct joinNode *jlist;
//C        struct rdriveinfo *next;
//C       };
struct rdriveinfo
{
    partialMatch *link;
    joinNode *jlist;
    rdriveinfo *next;
}

//C     LOCALE void                           NetworkRetract(void *,struct patternMatch *);
void  NetworkRetract(void *, patternMatch *);
//C     LOCALE void                           ReturnPartialMatch(void *,struct partialMatch *);
void  ReturnPartialMatch(void *, partialMatch *);
//C     LOCALE void                           DestroyPartialMatch(void *,struct partialMatch *);
void  DestroyPartialMatch(void *, partialMatch *);
//C     LOCALE void                           FlushGarbagePartialMatches(void *);
void  FlushGarbagePartialMatches(void *);
//C     LOCALE void                           DeletePartialMatches(void *,struct partialMatch *);
void  DeletePartialMatches(void *, partialMatch *);
//C     LOCALE void                           PosEntryRetractBeta(void *,struct partialMatch *,struct partialMatch *,int);
void  PosEntryRetractBeta(void *, partialMatch *, partialMatch *, int );
//C     LOCALE void                           PosEntryRetractAlpha(void *,struct partialMatch *,int);
void  PosEntryRetractAlpha(void *, partialMatch *, int );
//C     LOCALE intBool                        PartialMatchWillBeDeleted(void *,struct partialMatch *);
int  PartialMatchWillBeDeleted(void *, partialMatch *);

//C     #endif /* _H_retract */



//C     #endif

//C     struct focus
//C       {
//C        struct defmodule *theModule;
//C        struct defruleModule *theDefruleModule;
//C        struct focus *next;
//C       };
struct focus
{
    defmodule *theModule;
    defruleModule *theDefruleModule;
    focus *next;
}
  
//C     #define ENGINE_DATA 18

const ENGINE_DATA = 18;
//C     struct engineData
//C       { 
//C        struct defrule *ExecutingRule;
//C        intBool HaltRules;
//C        struct joinNode *TheLogicalJoin;
//C        struct partialMatch *TheLogicalBind;
//C        struct dependency *UnsupportedDataEntities;
//C        int alreadyEntered;
//C        struct callFunctionItem *ListOfRunFunctions;
//C        struct callFunctionItemWithArg *ListOfBeforeRunFunctions;
//C        struct focus *CurrentFocus;
//C        int FocusChanged;
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchStatistics;
//C        unsigned WatchFocus;
//C     #endif
//C        intBool IncrementalResetInProgress;
//C        intBool IncrementalResetFlag;
//C        intBool JoinOperationInProgress;
//C        struct partialMatch *GlobalLHSBinds;
//C        struct partialMatch *GlobalRHSBinds;
//C        struct joinNode *GlobalJoin;
//C        struct partialMatch *GarbagePartialMatches;
//C        struct alphaMatch *GarbageAlphaMatches;
//C        int AlreadyRunning;
//C     #if DEVELOPER
//C        long leftToRightComparisons;
//C        long rightToLeftComparisons;
//C        long leftToRightSucceeds;
//C        long rightToLeftSucceeds;
//C        long leftToRightLoops;
//C        long rightToLeftLoops;
//C        long findNextConflictingComparisons;
//C        long betaHashHTSkips;
//C        long betaHashListSkips;
//C        long unneededMarkerCompare;
//C     #endif
//C       };
struct engineData
{
    defrule *ExecutingRule;
    int HaltRules;
    joinNode *TheLogicalJoin;
    partialMatch *TheLogicalBind;
    dependency *UnsupportedDataEntities;
    int alreadyEntered;
    callFunctionItem *ListOfRunFunctions;
    callFunctionItemWithArg *ListOfBeforeRunFunctions;
    focus *CurrentFocus;
    int FocusChanged;
    uint WatchStatistics;
    uint WatchFocus;
    int IncrementalResetInProgress;
    int IncrementalResetFlag;
    int JoinOperationInProgress;
    partialMatch *GlobalLHSBinds;
    partialMatch *GlobalRHSBinds;
    joinNode *GlobalJoin;
    partialMatch *GarbagePartialMatches;
    alphaMatch *GarbageAlphaMatches;
    int AlreadyRunning;
}

//C     #define EngineData(theEnv) ((struct engineData *) GetEnvironmentData(theEnv,ENGINE_DATA))

//C     #define MAX_PATTERNS_CHECKED 64

const MAX_PATTERNS_CHECKED = 64;
//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _ENGINE_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE long long               EnvRun(void *,long long);
long  EnvRun(void *, long );
//C        LOCALE intBool                 EnvAddRunFunction(void *,const char *,
//C                                                         void (*)(void *),int);
int  EnvAddRunFunction(void *, char *, void  function(void *), int );
//C        LOCALE intBool                 EnvAddRunFunctionWithContext(void *,const char *,
//C                                                                    void (*)(void *),int,void *);
int  EnvAddRunFunctionWithContext(void *, char *, void  function(void *), int , void *);
//C        LOCALE intBool                 EnvRemoveRunFunction(void *,const char *);
int  EnvRemoveRunFunction(void *, char *);
//C        LOCALE intBool                 EnvAddBeforeRunFunction(void *,const char *,
//C                                                         void (*)(void *,void *),int);
int  EnvAddBeforeRunFunction(void *, char *, void  function(void *, void *), int );
//C        LOCALE intBool                 EnvAddBeforeRunFunctionWithContext(void *,const char *,
//C                                                                    void (*)(void *, void *),int,void *);
int  EnvAddBeforeRunFunctionWithContext(void *, char *, void  function(void *, void *), int , void *);
//C        LOCALE intBool                 EnvRemoveBeforeRunFunction(void *,const char *);
int  EnvRemoveBeforeRunFunction(void *, char *);
//C        LOCALE void                    InitializeEngine(void *);
void  InitializeEngine(void *);
//C        LOCALE void                    EnvSetBreak(void *,void *);
void  EnvSetBreak(void *, void *);
//C        LOCALE void                    EnvHalt(void *);
void  EnvHalt(void *);
//C        LOCALE intBool                 EnvRemoveBreak(void *,void *);
int  EnvRemoveBreak(void *, void *);
//C        LOCALE void                    RemoveAllBreakpoints(void *);
void  RemoveAllBreakpoints(void *);
//C        LOCALE void                    EnvShowBreaks(void *,const char *,void *);
void  EnvShowBreaks(void *, char *, void *);
//C        LOCALE intBool                 EnvDefruleHasBreakpoint(void *,void *);
int  EnvDefruleHasBreakpoint(void *, void *);
//C        LOCALE void                    RunCommand(void *);
void  RunCommand(void *);
//C        LOCALE void                    SetBreakCommand(void *);
void  SetBreakCommand(void *);
//C        LOCALE void                    RemoveBreakCommand(void *);
void  RemoveBreakCommand(void *);
//C        LOCALE void                    ShowBreaksCommand(void *);
void  ShowBreaksCommand(void *);
//C        LOCALE void                    HaltCommand(void *);
void  HaltCommand(void *);
//C        LOCALE int                     FocusCommand(void *);
int  FocusCommand(void *);
//C        LOCALE void                    ClearFocusStackCommand(void *);
void  ClearFocusStackCommand(void *);
//C        LOCALE void                    EnvClearFocusStack(void *);
void  EnvClearFocusStack(void *);
//C        LOCALE void                   *EnvGetNextFocus(void *,void *);
void * EnvGetNextFocus(void *, void *);
//C        LOCALE void                    EnvFocus(void *,void *);
void  EnvFocus(void *, void *);
//C        LOCALE int                     EnvGetFocusChanged(void *);
int  EnvGetFocusChanged(void *);
//C        LOCALE void                    EnvSetFocusChanged(void *,int);
void  EnvSetFocusChanged(void *, int );
//C        LOCALE void                    ListFocusStackCommand(void *);
void  ListFocusStackCommand(void *);
//C        LOCALE void                    EnvListFocusStack(void *,const char *);
void  EnvListFocusStack(void *, char *);
//C        LOCALE void                    GetFocusStackFunction(void *,DATA_OBJECT_PTR);
void  GetFocusStackFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                    EnvGetFocusStack(void *,DATA_OBJECT_PTR);
void  EnvGetFocusStack(void *, DATA_OBJECT_PTR );
//C        LOCALE void                   *PopFocusFunction(void *);
void * PopFocusFunction(void *);
//C        LOCALE void                   *GetFocusFunction(void *);
void * GetFocusFunction(void *);
//C        LOCALE void                   *EnvPopFocus(void *);
void * EnvPopFocus(void *);
//C        LOCALE void                   *EnvGetFocus(void *);
void * EnvGetFocus(void *);
//C        LOCALE intBool                 EnvGetHaltRules(void *);
int  EnvGetHaltRules(void *);
//C        LOCALE void                    EnvSetHaltRules(void *,intBool);
void  EnvSetHaltRules(void *, int );
//C        LOCALE struct activation      *NextActivationToFire(void *);
activation * NextActivationToFire(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                 AddBeforeRunFunction(const char *,void (*)(void *),int);
//C        LOCALE intBool                 AddRunFunction(const char *,void (*)(void),int);
//C        LOCALE void                    ClearFocusStack(void);
//C        LOCALE void                    Focus(void *);
//C        LOCALE void                    GetFocusStack(DATA_OBJECT_PTR);
//C        LOCALE void                   *GetFocus(void);
//C        LOCALE int                     GetFocusChanged(void);
//C        LOCALE void                   *GetNextFocus(void *);
//C        LOCALE void                    Halt(void);
//C        LOCALE void                   *PopFocus(void);
//C        LOCALE intBool                 RemoveRunFunction(const char *);
//C        LOCALE long long               Run(long long);
//C        LOCALE void                    SetFocusChanged(int);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE intBool                 DefruleHasBreakpoint(void *);
//C        LOCALE void                    ListFocusStack(const char *);
//C        LOCALE intBool                 RemoveBreak(void *);
//C        LOCALE void                    SetBreak(void *);
//C        LOCALE void                    ShowBreaks(const char *,void *);
//C     #endif

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_engine */






//C     #include "drive.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  12/04/07            */
   /*                                                     */
   /*                  DRIVE HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Handles join network activity associated with    */
/*   with the addition of a data entity such as a fact or    */
/*   instance.                                               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Added support for hashed memories.             */
/*                                                           */
/*            Added additional developer statistics to help  */
/*            analyze join network performance.              */
/*                                                           */
/*            Removed pseudo-facts used in not CE.           */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_drive

//C     #define _H_drive

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_match
//C     #include "match.h"
//C     #endif
//C     #ifndef _H_network
//C     #include "network.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _DRIVE_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        void                           NetworkAssert(void *,struct partialMatch *,struct joinNode *);
void  NetworkAssert(void *, partialMatch *, joinNode *);
//C        intBool                        EvaluateJoinExpression(void *,struct expr *,struct joinNode *);
int  EvaluateJoinExpression(void *, expr *, joinNode *);
//C        void                           NetworkAssertLeft(void *,struct partialMatch *,struct joinNode *,int);
void  NetworkAssertLeft(void *, partialMatch *, joinNode *, int );
//C        void                           NetworkAssertRight(void *,struct partialMatch *,struct joinNode *,int);
void  NetworkAssertRight(void *, partialMatch *, joinNode *, int );
//C        void                           PPDrive(void *,struct partialMatch *,struct partialMatch *,struct joinNode *,int);
void  PPDrive(void *, partialMatch *, partialMatch *, joinNode *, int );
//C        unsigned long                  BetaMemoryHashValue(void *,struct expr *,struct partialMatch *,struct partialMatch *,struct joinNode *);
uint  BetaMemoryHashValue(void *, expr *, partialMatch *, partialMatch *, joinNode *);
//C        intBool                        EvaluateSecondaryNetworkTest(void *,struct partialMatch *,struct joinNode *);
int  EvaluateSecondaryNetworkTest(void *, partialMatch *, joinNode *);
//C        void                           EPMDrive(void *,struct partialMatch *,struct joinNode *,int);
void  EPMDrive(void *, partialMatch *, joinNode *, int );
   
//C     #endif /* _H_drive */





//C     #include "incrrset.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            INCREMENTAL RESET HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides functionality for the incremental       */
/*   reset of the pattern and join networks when a new       */
/*   rule is added.                                          */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Removed INCREMENTAL_RESET compilation flag.    */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Added support for hashed alpha memories and    */
/*            other join network changes.                    */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Modified EnvSetIncrementalReset to check for   */
/*            the existance of rules.                        */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_incrrset

//C     #define _H_incrrset

//C     #ifndef _H_ruledef
//C     #include "ruledef.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _INCRRSET_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           IncrementalReset(void *,struct defrule *);
void  IncrementalReset(void *, defrule *);
//C        LOCALE intBool                        EnvGetIncrementalReset(void *);
int  EnvGetIncrementalReset(void *);
//C        LOCALE intBool                        EnvSetIncrementalReset(void *,intBool);
int  EnvSetIncrementalReset(void *, int );
//C        LOCALE int                            GetIncrementalResetCommand(void *);
int  GetIncrementalResetCommand(void *);
//C        LOCALE int                            SetIncrementalResetCommand(void *);
int  SetIncrementalResetCommand(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        GetIncrementalReset(void);
//C        LOCALE intBool                        SetIncrementalReset(int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_incrrset */









//C     #include "rulecom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             DEFRULE COMMANDS HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides the matches command. Also provides the  */
/*   the developer commands show-joins and rule-complexity.  */
/*   Also provides the initialization routine which          */
/*   registers rule commands found in other modules.         */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed CONFLICT_RESOLUTION_STRATEGIES         */
/*            INCREMENTAL_RESET, and LOGICAL_DEPENDENCIES    */
/*            compilation flags.                             */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added support for hashed memories.             */
/*                                                           */
/*            Improvements to matches command.               */
/*                                                           */
/*            Add join-activity and join-activity-reset      */
/*            commands.                                      */
/*                                                           */
/*            Added get-beta-memory-resizing and             */
/*            set-beta-memory-resizing functions.            */
/*                                                           */
/*            Added timetag function.                        */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_rulecom
//C     #define _H_rulecom

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _RULECOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     struct joinInformation
//C       {
//C        int whichCE;
//C        struct joinNode *theJoin;
//C        int patternBegin;
//C        int patternEnd;
//C        int marked;
//C        struct betaMemory *theMemory;
//C        struct joinNode *nextJoin;
//C       };
struct joinInformation
{
    int whichCE;
    joinNode *theJoin;
    int patternBegin;
    int patternEnd;
    int marked;
    betaMemory *theMemory;
    joinNode *nextJoin;
}

//C     #define VERBOSE  0
//C     #define SUCCINCT 1
const VERBOSE = 0;
//C     #define TERSE    2
const SUCCINCT = 1;

const TERSE = 2;
//C        LOCALE intBool                        EnvGetBetaMemoryResizing(void *);
int  EnvGetBetaMemoryResizing(void *);
//C        LOCALE intBool                        EnvSetBetaMemoryResizing(void *,intBool);
int  EnvSetBetaMemoryResizing(void *, int );
//C        LOCALE int                            GetBetaMemoryResizingCommand(void *);
int  GetBetaMemoryResizingCommand(void *);
//C        LOCALE int                            SetBetaMemoryResizingCommand(void *);
int  SetBetaMemoryResizingCommand(void *);

//C        LOCALE void                           EnvMatches(void *,void *,int,DATA_OBJECT *);
void  EnvMatches(void *, void *, int , DATA_OBJECT *);
//C        LOCALE void                           EnvJoinActivity(void *,void *,int,DATA_OBJECT *);
void  EnvJoinActivity(void *, void *, int , DATA_OBJECT *);
//C        LOCALE void                           DefruleCommands(void *);
void  DefruleCommands(void *);
//C        LOCALE void                           MatchesCommand(void *,DATA_OBJECT *);
void  MatchesCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           JoinActivityCommand(void *,DATA_OBJECT *);
void  JoinActivityCommand(void *, DATA_OBJECT *);
//C        LOCALE long long                      TimetagFunction(void *);
long  TimetagFunction(void *);
//C        LOCALE long                           EnvAlphaJoinCount(void *,void *);
int  EnvAlphaJoinCount(void *, void *);
//C        LOCALE long                           EnvBetaJoinCount(void *,void *);
int  EnvBetaJoinCount(void *, void *);
//C        LOCALE struct joinInformation        *EnvCreateJoinArray(void *,long);
joinInformation * EnvCreateJoinArray(void *, int );
//C        LOCALE void                           EnvFreeJoinArray(void *,struct joinInformation *,long);
void  EnvFreeJoinArray(void *, joinInformation *, int );
//C        LOCALE void                           EnvAlphaJoins(void *,void *,long,struct joinInformation *);
void  EnvAlphaJoins(void *, void *, int , joinInformation *);
//C        LOCALE void                           EnvBetaJoins(void *,void *,long,struct joinInformation *);
void  EnvBetaJoins(void *, void *, int , joinInformation *);
//C        LOCALE void                           JoinActivityResetCommand(void *);
void  JoinActivityResetCommand(void *);
//C     #if DEVELOPER
//C        LOCALE void                           ShowJoinsCommand(void *);
//C        LOCALE long                           RuleComplexityCommand(void *);
//C        LOCALE void                           ShowAlphaHashTable(void *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           Matches(void *,int,DATA_OBJECT *);
//C        LOCALE void                           JoinActivity(void *,int,DATA_OBJECT *);
//C     #endif
//C        LOCALE intBool                        GetBetaMemoryResizing(void);
//C        LOCALE intBool                        SetBetaMemoryResizing(int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_rulecom */
//C     #include "crstrtgy.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*      CONFLICT RESOLUTION STRATEGY HEADER MODULE     */
   /*******************************************************/

/*************************************************************/
/* Purpose: Used to determine where a new activation is      */
/*   placed on the agenda based on the current conflict      */
/*   resolution strategy (depth, breadth, mea, lex,          */
/*   simplicity, or complexity). Also provides the           */
/*   set-strategy and get-strategy commands.                 */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Removed CONFLICT_RESOLUTION_STRATEGIES         */
/*            compilation flag.                              */
/*                                                           */
/*      6.30: Added salience groups to improve performance   */
/*            with large numbers of activations of different */
/*            saliences.                                     */
/*                                                           */
/*            Removed pseudo-facts used for not CEs.         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_crstrtgy

//C     #define _H_crstrtgy

//C     #include "agenda.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*                 AGENDA HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*   Provides functionality for examining, manipulating,     */
/*   adding, and removing activations from the agenda.       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Removed CONFLICT_RESOLUTION_STRATEGIES and     */
/*            DYNAMIC_SALIENCE compilation flags.            */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added EnvGetActivationBasisPPForm function.    */
/*                                                           */
/*      6.30: Added salience groups to improve performance   */
/*            with large numbers of activations of different */
/*            saliences.                                     */
/*                                                           */
/*            Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_agenda

//C     #define _H_agenda

//C     #ifndef _H_ruledef
//C     #include "ruledef.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_match
//C     #include "match.h"
//C     #endif

//C     #define WHEN_DEFINED 0
//C     #define WHEN_ACTIVATED 1
//C     #define EVERY_CYCLE 2

//C     #define MAX_DEFRULE_SALIENCE  10000
//C     #define MIN_DEFRULE_SALIENCE -10000
  
/*******************/
/* DATA STRUCTURES */
/*******************/

//C     struct activation
//C       {
//C        struct defrule *theRule;
//C        struct partialMatch *basis;
//C        int salience;
//C        unsigned long long timetag;
//C        int randomID;
//C        struct activation *prev;
//C        struct activation *next;
//C       };

//C     struct salienceGroup
//C       {
//C        int salience;
//C        struct activation *first;
//C        struct activation *last;
//C        struct salienceGroup *next;
//C        struct salienceGroup *prev;
//C       };

//C     typedef struct activation ACTIVATION;

//C     #define AGENDA_DATA 17

//C     struct agendaData
//C       { 
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchActivations;
//C     #endif
//C        unsigned long NumberOfActivations;
//C        unsigned long long CurrentTimetag;
//C        int AgendaChanged;
//C        intBool SalienceEvaluation;
//C        int Strategy;
//C       };

//C     #define AgendaData(theEnv) ((struct agendaData *) GetEnvironmentData(theEnv,AGENDA_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _AGENDA_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

/****************************************/
/* GLOBAL EXTERNAL FUNCTION DEFINITIONS */
/****************************************/

//C        LOCALE void                    AddActivation(void *,void *,void *);
//C        LOCALE void                    ClearRuleFromAgenda(void *,void *);
//C        LOCALE void                   *EnvGetNextActivation(void *,void *);
//C        LOCALE struct partialMatch    *EnvGetActivationBasis(void *,void *);
//C        LOCALE const char             *EnvGetActivationName(void *,void *);
//C        LOCALE struct defrule         *EnvGetActivationRule(void *,void *);
//C        LOCALE int                     EnvGetActivationSalience(void *,void *);
//C        LOCALE int                     EnvSetActivationSalience(void *,void *,int);
//C        LOCALE void                    EnvGetActivationPPForm(void *,char *,size_t,void *);
//C        LOCALE void                    EnvGetActivationBasisPPForm(void *,char *,size_t,void *);
//C        LOCALE intBool                 MoveActivationToTop(void *,void *);
//C        LOCALE intBool                 EnvDeleteActivation(void *,void *);
//C        LOCALE intBool                 DetachActivation(void *,void *);
//C        LOCALE void                    EnvAgenda(void *,const char *,void *);
//C        LOCALE void                    RemoveActivation(void *,void *,int,int);
//C        LOCALE void                    RemoveAllActivations(void *);
//C        LOCALE int                     EnvGetAgendaChanged(void *);
//C        LOCALE void                    EnvSetAgendaChanged(void *,int);
//C        LOCALE unsigned long           GetNumberOfActivations(void *);
//C        LOCALE intBool                 EnvGetSalienceEvaluation(void *);
//C        LOCALE intBool                 EnvSetSalienceEvaluation(void *,intBool);
//C        LOCALE void                    EnvRefreshAgenda(void *,void *);
//C        LOCALE void                    EnvReorderAgenda(void *,void *);
//C        LOCALE void                    InitializeAgenda(void *);
//C        LOCALE void                   *SetSalienceEvaluationCommand(void *);
//C        LOCALE void                   *GetSalienceEvaluationCommand(void *);
//C        LOCALE void                    RefreshAgendaCommand(void *);
//C        LOCALE void                    RefreshCommand(void *);
//C        LOCALE intBool                 EnvRefresh(void *,void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                    AgendaCommand(void *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                    Agenda(const char *,void *);
//C        LOCALE intBool                 DeleteActivation(void *);
//C        LOCALE struct partialMatch    *GetActivationBasis(void *);
//C        LOCALE const char             *GetActivationName(void *);
//C        LOCALE void                    GetActivationPPForm(char *,unsigned,void *);
//C        LOCALE struct defrule         *GetActivationRule(void *);
//C        LOCALE int                     GetActivationSalience(void *);
//C        LOCALE int                     GetAgendaChanged(void);
//C        LOCALE void                   *GetNextActivation(void *);
//C        LOCALE intBool                 GetSalienceEvaluation(void);
//C        LOCALE intBool                 Refresh(void *);
//C        LOCALE void                    RefreshAgenda(void *);
//C        LOCALE void                    ReorderAgenda(void *);
//C        LOCALE int                     SetActivationSalience(void *,int);
//C        LOCALE void                    SetAgendaChanged(int);
//C        LOCALE intBool                 SetSalienceEvaluation(int);

//C     #endif

//C     #endif






//C     #include "symbol.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/03/15            */
   /*                                                     */
   /*                 SYMBOL HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Manages the atomic data value hash tables for    */
/*   storing symbols, integers, floats, and bit maps.        */
/*   Contains routines for adding entries, examining the     */
/*   hash tables, and performing garbage collection to       */
/*   remove entries no longer in use.                        */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: CLIPS crashing on AMD64 processor in the       */
/*            function used to generate a hash value for     */
/*            integers. DR0871                               */
/*                                                           */
/*            Support for run-time programs directly passing */
/*            the hash tables for initialization.            */
/*                                                           */
/*            Corrected code generating compilation          */
/*            warnings.                                      */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Support for hashing EXTERNAL_ADDRESS data      */
/*            type.                                          */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Used genstrcpy instead of strcpy.              */
/*                                                           */
             
/*            Added support for external address hash table  */
/*            and subtyping.                                 */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added ValueToPointer and EnvValueToPointer     */
/*            macros.                                        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_symbol
//C     #define _H_symbol

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _SYMBOL_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C     #include <stdlib.h>

//C     #ifndef _H_multifld
//C     #include "multifld.h"
//C     #endif

//C     #ifndef SYMBOL_HASH_SIZE
//C     #define SYMBOL_HASH_SIZE       63559L
//C     #endif

//C     #ifndef FLOAT_HASH_SIZE
//C     #define FLOAT_HASH_SIZE         8191
//C     #endif

//C     #ifndef INTEGER_HASH_SIZE
//C     #define INTEGER_HASH_SIZE       8191
//C     #endif

//C     #ifndef BITMAP_HASH_SIZE
//C     #define BITMAP_HASH_SIZE        8191
//C     #endif

//C     #ifndef EXTERNAL_ADDRESS_HASH_SIZE
//C     #define EXTERNAL_ADDRESS_HASH_SIZE        8191
//C     #endif

/************************************************************/
/* symbolHashNode STRUCTURE:                                */
/************************************************************/
//C     struct symbolHashNode
//C       {
//C        struct symbolHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededSymbol : 1;
//C        unsigned int bucket : 29;
//C        const char *contents;
//C       };

/************************************************************/
/* floatHashNode STRUCTURE:                                  */
/************************************************************/
//C     struct floatHashNode
//C       {
//C        struct floatHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededFloat : 1;
//C        unsigned int bucket : 29;
//C        double contents;
//C       };

/************************************************************/
/* integerHashNode STRUCTURE:                               */
/************************************************************/
//C     struct integerHashNode
//C       {
//C        struct integerHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededInteger : 1;
//C        unsigned int bucket : 29;
//C        long long contents;
//C       };

/************************************************************/
/* bitMapHashNode STRUCTURE:                                */
/************************************************************/
//C     struct bitMapHashNode
//C       {
//C        struct bitMapHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededBitMap : 1;
//C        unsigned int bucket : 29;
//C        const char *contents;
//C        unsigned short size;
//C       };

/************************************************************/
/* externalAddressHashNode STRUCTURE:                       */
/************************************************************/
//C     struct externalAddressHashNode
//C       {
//C        struct externalAddressHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int neededPointer : 1;
//C        unsigned int bucket : 29;
//C        void *externalAddress;
//C        unsigned short type;
//C       };

/************************************************************/
/* genericHashNode STRUCTURE:                               */
/************************************************************/
//C     struct genericHashNode
//C       {
//C        struct genericHashNode *next;
//C        long count;
//C        unsigned int permanent : 1;
//C        unsigned int markedEphemeral : 1;
//C        unsigned int needed : 1;
//C        unsigned int bucket : 29;
//C       };

//C     typedef struct symbolHashNode SYMBOL_HN;
//C     typedef struct floatHashNode FLOAT_HN;
//C     typedef struct integerHashNode INTEGER_HN;
//C     typedef struct bitMapHashNode BITMAP_HN;
//C     typedef struct externalAddressHashNode EXTERNAL_ADDRESS_HN;
//C     typedef struct genericHashNode GENERIC_HN;

/**********************************************************/
/* EPHEMERON STRUCTURE: Data structure used to keep track */
/*   of ephemeral symbols, floats, and integers.          */
/*                                                        */
/*   associatedValue: Contains a pointer to the storage   */
/*   structure for the symbol, float, or integer which is */
/*   ephemeral.                                           */
/*                                                        */
/*   next: Contains a pointer to the next ephemeral item  */
/*   in a list of ephemeral items.                        */
/**********************************************************/
//C     struct ephemeron
//C       {
//C        GENERIC_HN *associatedValue;
//C        struct ephemeron *next;
//C       };

/************************************************************/
/* symbolMatch STRUCTURE:                               */
/************************************************************/
//C     struct symbolMatch
//C       {
//C        struct symbolHashNode *match;
//C        struct symbolMatch *next;
//C       };

//C     #define ValueToString(target) (((struct symbolHashNode *) (target))->contents)
//C     #define ValueToDouble(target) (((struct floatHashNode *) (target))->contents)
//C     #define ValueToLong(target) (((struct integerHashNode *) (target))->contents)
//C     #define ValueToInteger(target) ((int) (((struct integerHashNode *) (target))->contents))
//C     #define ValueToBitMap(target) ((void *) ((struct bitMapHashNode *) (target))->contents)
//C     #define ValueToPointer(target) ((void *) target)
//C     #define ValueToExternalAddress(target) ((void *) ((struct externalAddressHashNode *) (target))->externalAddress)

//C     #define EnvValueToString(theEnv,target) (((struct symbolHashNode *) (target))->contents)
//C     #define EnvValueToDouble(theEnv,target) (((struct floatHashNode *) (target))->contents)
//C     #define EnvValueToLong(theEnv,target) (((struct integerHashNode *) (target))->contents)
//C     #define EnvValueToInteger(theEnv,target) ((int) (((struct integerHashNode *) (target))->contents))
//C     #define EnvValueToBitMap(theEnv,target) ((void *) ((struct bitMapHashNode *) (target))->contents)
//C     #define EnvValueToPointer(theEnv,target) ((void *) target)
//C     #define EnvValueToExternalAddress(theEnv,target) ((void *) ((struct externalAddressHashNode *) (target))->externalAddress)

//C     #define IncrementSymbolCount(theValue) (((SYMBOL_HN *) theValue)->count++)
//C     #define IncrementFloatCount(theValue) (((FLOAT_HN *) theValue)->count++)
//C     #define IncrementIntegerCount(theValue) (((INTEGER_HN *) theValue)->count++)
//C     #define IncrementBitMapCount(theValue) (((BITMAP_HN *) theValue)->count++)
//C     #define IncrementExternalAddressCount(theValue) (((EXTERNAL_ADDRESS_HN *) theValue)->count++)

/*==================*/
/* ENVIRONMENT DATA */
/*==================*/

//C     #define SYMBOL_DATA 49

//C     struct symbolData
//C       { 
//C        void *TrueSymbolHN;
//C        void *FalseSymbolHN;
//C        void *PositiveInfinity;
//C        void *NegativeInfinity;
//C        void *Zero;
//C        SYMBOL_HN **SymbolTable;
//C        FLOAT_HN **FloatTable;
//C        INTEGER_HN **IntegerTable;
//C        BITMAP_HN **BitMapTable;
//C        EXTERNAL_ADDRESS_HN **ExternalAddressTable;
//C     #if BLOAD || BLOAD_ONLY || BLOAD_AND_BSAVE || BLOAD_INSTANCES || BSAVE_INSTANCES
//C        long NumberOfSymbols;
//C        long NumberOfFloats;
//C        long NumberOfIntegers;
//C        long NumberOfBitMaps;
//C        long NumberOfExternalAddresses;
//C        SYMBOL_HN **SymbolArray;
//C        struct floatHashNode **FloatArray;
//C        INTEGER_HN **IntegerArray;
//C        BITMAP_HN **BitMapArray;
//C        EXTERNAL_ADDRESS_HN **ExternalAddressArray;
//C     #endif
//C       };

//C     #define SymbolData(theEnv) ((struct symbolData *) GetEnvironmentData(theEnv,SYMBOL_DATA))

//C        LOCALE void                           InitializeAtomTables(void *,struct symbolHashNode **,struct floatHashNode **,
//C                                                                   struct integerHashNode **,struct bitMapHashNode **,
//C                                                                   struct externalAddressHashNode **);
//C        LOCALE void                          *EnvAddSymbol(void *,const char *);
//C        LOCALE SYMBOL_HN                     *FindSymbolHN(void *,const char *);
//C        LOCALE void                          *EnvAddDouble(void *,double);
//C        LOCALE void                          *EnvAddLong(void *,long long);
//C        LOCALE void                          *EnvAddBitMap(void *,void *,unsigned);
//C        LOCALE void                          *EnvAddExternalAddress(void *,void *,unsigned);
//C        LOCALE INTEGER_HN                    *FindLongHN(void *,long long);
//C        LOCALE unsigned long                  HashSymbol(const char *,unsigned long);
//C        LOCALE unsigned long                  HashFloat(double,unsigned long);
//C        LOCALE unsigned long                  HashInteger(long long,unsigned long);
//C        LOCALE unsigned long                  HashBitMap(const char *,unsigned long,unsigned);
//C        LOCALE unsigned long                  HashExternalAddress(void *,unsigned long);
//C        LOCALE void                           DecrementSymbolCount(void *,struct symbolHashNode *);
//C        LOCALE void                           DecrementFloatCount(void *,struct floatHashNode *);
//C        LOCALE void                           DecrementIntegerCount(void *,struct integerHashNode *);
//C        LOCALE void                           DecrementBitMapCount(void *,struct bitMapHashNode *);
//C        LOCALE void                           DecrementExternalAddressCount(void *,struct externalAddressHashNode *);
//C        LOCALE void                           RemoveEphemeralAtoms(void *);
//C        LOCALE struct symbolHashNode        **GetSymbolTable(void *);
//C        LOCALE void                           SetSymbolTable(void *,struct symbolHashNode **);
//C        LOCALE struct floatHashNode          **GetFloatTable(void *);
//C        LOCALE void                           SetFloatTable(void *,struct floatHashNode **);
//C        LOCALE struct integerHashNode       **GetIntegerTable(void *);
//C        LOCALE void                           SetIntegerTable(void *,struct integerHashNode **);
//C        LOCALE struct bitMapHashNode        **GetBitMapTable(void *);
//C        LOCALE void                           SetBitMapTable(void *,struct bitMapHashNode **);
//C        LOCALE struct externalAddressHashNode        
//C                                            **GetExternalAddressTable(void *);
//C        LOCALE void                           SetExternalAddressTable(void *,struct externalAddressHashNode **);
//C        LOCALE void                           RefreshSpecialSymbols(void *);
//C        LOCALE struct symbolMatch            *FindSymbolMatches(void *,const char *,unsigned *,size_t *);
//C        LOCALE void                           ReturnSymbolMatches(void *,struct symbolMatch *);
//C        LOCALE SYMBOL_HN                     *GetNextSymbolMatch(void *,const char *,size_t,SYMBOL_HN *,int,size_t *);
//C        LOCALE void                           ClearBitString(void *,unsigned);
//C        LOCALE void                           SetAtomicValueIndices(void *,int);
//C        LOCALE void                           RestoreAtomicValueBuckets(void *);
//C        LOCALE void                          *EnvFalseSymbol(void *);
//C        LOCALE void                          *EnvTrueSymbol(void *);
//C        LOCALE void                           EphemerateValue(void *,int,void *);
//C        LOCALE void                           EphemerateMultifield(void *,struct multifield *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                          *AddDouble(double);
//C        LOCALE void                          *AddLong(long long);
//C        LOCALE void                          *AddSymbol(const char *);
//C        LOCALE void                          *FalseSymbol(void);
//C        LOCALE void                          *TrueSymbol(void);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_symbol */




//C     #define DEPTH_STRATEGY 0
//C     #define BREADTH_STRATEGY 1
const DEPTH_STRATEGY = 0;
//C     #define LEX_STRATEGY 2
const BREADTH_STRATEGY = 1;
//C     #define MEA_STRATEGY 3
const LEX_STRATEGY = 2;
//C     #define COMPLEXITY_STRATEGY 4
const MEA_STRATEGY = 3;
//C     #define SIMPLICITY_STRATEGY 5
const COMPLEXITY_STRATEGY = 4;
//C     #define RANDOM_STRATEGY 6
const SIMPLICITY_STRATEGY = 5;

const RANDOM_STRATEGY = 6;
//C     #define DEFAULT_STRATEGY DEPTH_STRATEGY

alias DEPTH_STRATEGY DEFAULT_STRATEGY;
//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CRSTRTGY_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           PlaceActivation(void *,ACTIVATION **,ACTIVATION *,struct salienceGroup *);
void  PlaceActivation(void *, ACTIVATION **, ACTIVATION *, salienceGroup *);
//C        LOCALE int                            EnvSetStrategy(void *,int);
int  EnvSetStrategy(void *, int );
//C        LOCALE int                            EnvGetStrategy(void *);
int  EnvGetStrategy(void *);
//C        LOCALE void                          *SetStrategyCommand(void *);
void * SetStrategyCommand(void *);
//C        LOCALE void                          *GetStrategyCommand(void *);
void * GetStrategyCommand(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE int                            SetStrategy(int);
//C        LOCALE int                            GetStrategy(void);

//C     #endif

//C     #endif /* _H_crstrtgy */


//C     #endif

//C     #if DEFFACTS_CONSTRUCT
//C     #include "dffctdef.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*                DEFFACTS HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_dffctdef
//C     #define _H_dffctdef

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_cstrccom
//C     #include "cstrccom.h"
//C     #endif

//C     #define DEFFACTS_DATA 0

const DEFFACTS_DATA = 0;
//C     struct deffactsData
//C       { 
//C        struct construct *DeffactsConstruct;
//C        int DeffactsModuleIndex;  
//C     #if CONSTRUCT_COMPILER && (! RUN_TIME)
//C        struct CodeGeneratorItem *DeffactsCodeItem;
//C     #endif
//C       };
struct deffactsData
{
    construct *DeffactsConstruct;
    int DeffactsModuleIndex;
    CodeGeneratorItem *DeffactsCodeItem;
}
  
//C     struct deffacts
//C       {
//C        struct constructHeader header;
//C        struct expr *assertList;
//C       };
struct deffacts
{
    constructHeader header;
    expr *assertList;
}

//C     struct deffactsModule
//C       {
//C        struct defmoduleItemHeader header;
//C       };
struct deffactsModule
{
    defmoduleItemHeader header;
}

//C     #define DeffactsData(theEnv) ((struct deffactsData *) GetEnvironmentData(theEnv,DEFFACTS_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _DFFCTDEF_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeDeffacts(void *);
void  InitializeDeffacts(void *);
//C        LOCALE void                          *EnvFindDeffacts(void *,const char *);
void * EnvFindDeffacts(void *, char *);
//C        LOCALE void                          *EnvFindDeffactsInModule(void *,const char *);
void * EnvFindDeffactsInModule(void *, char *);
//C        LOCALE void                          *EnvGetNextDeffacts(void *,void *);
void * EnvGetNextDeffacts(void *, void *);
//C        LOCALE void                           CreateInitialFactDeffacts(void);
void  CreateInitialFactDeffacts();
//C        LOCALE intBool                        EnvIsDeffactsDeletable(void *,void *);
int  EnvIsDeffactsDeletable(void *, void *);
//C        LOCALE struct deffactsModule         *GetDeffactsModuleItem(void *,struct defmodule *);
deffactsModule * GetDeffactsModuleItem(void *, defmodule *);
//C        LOCALE const char                    *EnvDeffactsModule(void *,void *);
char * EnvDeffactsModule(void *, void *);
//C        LOCALE const char                    *EnvGetDeffactsName(void *,void *);
char * EnvGetDeffactsName(void *, void *);
//C        LOCALE const char                    *EnvGetDeffactsPPForm(void *,void *);
char * EnvGetDeffactsPPForm(void *, void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                          *FindDeffacts(const char *);
//C        LOCALE void                          *GetNextDeffacts(void *);
//C        LOCALE intBool                        IsDeffactsDeletable(void *);
//C        LOCALE const char                    *DeffactsModule(void *);
//C        LOCALE const char                    *GetDeffactsName(void *);
//C        LOCALE const char                    *GetDeffactsPPForm(void *);
   
//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_dffctdef */


//C     #include "dffctbsc.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*         DEFFACTS BASIC COMMANDS HEADER FILE         */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements core commands for the deffacts        */
/*   construct such as clear, reset, save, undeffacts,       */
/*   ppdeffacts, list-deffacts, and get-deffacts-list.       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_dffctbsc
//C     #define _H_dffctbsc

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _DFFCTBSC_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           DeffactsBasicCommands(void *);
void  DeffactsBasicCommands(void *);
//C        LOCALE void                           UndeffactsCommand(void *);
void  UndeffactsCommand(void *);
//C        LOCALE intBool                        EnvUndeffacts(void *,void *);
int  EnvUndeffacts(void *, void *);
//C        LOCALE void                           GetDeffactsListFunction(void *,DATA_OBJECT_PTR);
void  GetDeffactsListFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           EnvGetDeffactsList(void *,DATA_OBJECT_PTR,void *);
void  EnvGetDeffactsList(void *, DATA_OBJECT_PTR , void *);
//C        LOCALE void                          *DeffactsModuleFunction(void *);
void * DeffactsModuleFunction(void *);
//C        LOCALE void                           PPDeffactsCommand(void *);
void  PPDeffactsCommand(void *);
//C        LOCALE int                            PPDeffacts(void *,const char *,const char *);
int  PPDeffacts(void *, char *, char *);
//C        LOCALE void                           ListDeffactsCommand(void *);
void  ListDeffactsCommand(void *);
//C        LOCALE void                           EnvListDeffacts(void *,const char *,void *);
void  EnvListDeffacts(void *, char *, void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           GetDeffactsList(DATA_OBJECT_PTR,void *);
//C        LOCALE intBool                        Undeffacts(void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           ListDeffacts(const char *,void *);
//C     #endif

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_dffctbsc */

//C     #endif

//C     #if DEFTEMPLATE_CONSTRUCT
//C     #include "tmpltdef.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*               DEFTEMPLATE HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Added support for templates maintaining their  */
/*            own list of facts.                             */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warnings.                             */
/*                                                           */
/*      6.30: Added code for deftemplate run time            */
/*            initialization of hashed comparisons to        */
/*            constants.                                     */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Support for deftemplate slot facets.           */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_tmpltdef
//C     #define _H_tmpltdef

//C     struct deftemplate;
//C     struct templateSlot;
//C     struct deftemplateModule;

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_constrnt
//C     #include "constrnt.h"
//C     #endif
//C     #include "factbld.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                FACT BUILD HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Added support for hashed alpha memories.       */
/*                                                           */
/*            Added support for hashed comparisons to        */
/*            constants.                                     */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_factbld

//C     #define _H_factbld

//C     #ifndef _H_pattern
//C     #include "pattern.h"
//C     #endif
//C     #ifndef _H_network
//C     #include "network.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     struct factPatternNode
//C       {
//C        struct patternNodeHeader header;
//C        long bsaveID;
//C        unsigned short whichField;
//C        unsigned short whichSlot;
//C        unsigned short leaveFields;
//C        struct expr *networkTest;
//C        struct factPatternNode *nextLevel;
//C        struct factPatternNode *lastLevel;
//C        struct factPatternNode *leftNode;
//C        struct factPatternNode *rightNode;
//C       };
struct factPatternNode
{
    patternNodeHeader header;
    int bsaveID;
    ushort whichField;
    ushort whichSlot;
    ushort leaveFields;
    expr *networkTest;
    factPatternNode *nextLevel;
    factPatternNode *lastLevel;
    factPatternNode *leftNode;
    factPatternNode *rightNode;
}

//C     #ifdef _FACTBUILD_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeFactPatterns(void *);
void  InitializeFactPatterns(void *);
//C        LOCALE void                           DestroyFactPatternNetwork(void *,
//C                                                                        struct factPatternNode *);
void  DestroyFactPatternNetwork(void *, factPatternNode *);

//C     #endif /* _H_factbld */
//C     #ifndef _H_factmngr
//C     #include "factmngr.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/04/15            */
   /*                                                     */
   /*              FACTS MANAGER HEADER FILE              */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Added support for templates maintaining their  */
/*            own list of facts.                             */
/*                                                           */
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            AssignFactSlotDefaults function does not       */
/*            properly handle defaults for multifield slots. */
/*            DR0869                                         */
/*                                                           */
/*            Support for ppfact command.                    */
/*                                                           */
/*      6.30: Callback function support for assertion,       */
/*            retraction, and modification of facts.         */
/*                                                           */
/*            Updates to fact pattern entity record.         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Removed unused global variables.               */
/*                                                           */
/*            Added code to prevent a clear command from     */
/*            being executed during fact assertions via      */
/*            JoinOperationInProgress mechanism.             */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_factmngr

//C     #define _H_factmngr

//C     struct fact;

//C     #ifndef _H_facthsh
//C     #include "facthsh.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                 FACT HASHING MODULE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Fact hash table is resizable.                  */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added FactWillBeAsserted.                      */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_facthsh

//C     #define _H_facthsh

//C     struct factHashEntry;

//C     #ifndef _H_factmngr
//C     #include "factmngr.h"
//C     #endif

//C     struct factHashEntry
//C       {
//C        struct fact *theFact;
//C        struct factHashEntry *next;
//C       };
struct factHashEntry
{
    fact *theFact;
    factHashEntry *next;
}

//C     #define SIZE_FACT_HASH 16231

const SIZE_FACT_HASH = 16231;
//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _FACTHSH_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           AddHashedFact(void *,struct fact *,unsigned long);
void  AddHashedFact(void *, fact *, uint );
//C        LOCALE intBool                        RemoveHashedFact(void *,struct fact *);
int  RemoveHashedFact(void *, fact *);
//C        LOCALE unsigned long                  HandleFactDuplication(void *,void *,intBool *);
uint  HandleFactDuplication(void *, void *, int *);
//C        LOCALE intBool                        EnvGetFactDuplication(void *);
int  EnvGetFactDuplication(void *);
//C        LOCALE intBool                        EnvSetFactDuplication(void *,int);
int  EnvSetFactDuplication(void *, int );
//C        LOCALE void                           InitializeFactHashTable(void *);
void  InitializeFactHashTable(void *);
//C        LOCALE void                           ShowFactHashTable(void *);
void  ShowFactHashTable(void *);
//C        LOCALE unsigned long                  HashFact(struct fact *);
uint  HashFact(fact *);
//C        LOCALE intBool                        FactWillBeAsserted(void *,void *);
int  FactWillBeAsserted(void *, void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        GetFactDuplication(void);
//C        LOCALE intBool                        SetFactDuplication(int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_facthsh */


//C     #endif
//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_pattern
//C     #include "pattern.h"
//C     #endif
//C     #include "multifld.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/19/14            */
   /*                                                     */
   /*                MULTIFIELD HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for creating and manipulating           */
/*   multifield values.                                      */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove compiler warnings.    */
/*                                                           */
/*            Moved ImplodeMultifield from multifun.c.       */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Used DataObjectToString instead of             */
/*            ValueToString in implode$ to handle            */
/*            print representation of external addresses.    */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed issue with StoreInMultifield when        */
/*            asserting void values in implied deftemplate   */
/*            facts.                                         */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_multifld

//C     #define _H_multifld

//C     struct field;
//C     struct multifield;

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     struct field
//C       {
//C        unsigned short type;
//C        void *value;
//C       };

//C     struct multifield
//C       {
//C        unsigned busyCount;
//C        long multifieldLength;
//C        struct multifield *next;
//C        struct field theFields[1];
//C       };

//C     typedef struct multifield SEGMENT;
//C     typedef struct multifield * SEGMENT_PTR;
//C     typedef struct multifield * MULTIFIELD_PTR;
//C     typedef struct field FIELD;
//C     typedef struct field * FIELD_PTR;

//C     #define GetMFLength(target)     (((struct multifield *) (target))->multifieldLength)
//C     #define GetMFPtr(target,index)  (&(((struct field *) ((struct multifield *) (target))->theFields)[index-1]))
//C     #define SetMFType(target,index,value)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].type = (unsigned short) (value))
//C     #define SetMFValue(target,index,val)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].value = (void *) (val))
//C     #define GetMFType(target,index)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].type)
//C     #define GetMFValue(target,index)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].value)

//C     #define EnvGetMFLength(theEnv,target)     (((struct multifield *) (target))->multifieldLength)
//C     #define EnvGetMFPtr(theEnv,target,index)  (&(((struct field *) ((struct multifield *) (target))->theFields)[index-1]))
//C     #define EnvSetMFType(theEnv,target,index,value)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].type = (unsigned short) (value))
//C     #define EnvSetMFValue(theEnv,target,index,val)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].value = (void *) (val))
//C     #define EnvGetMFType(theEnv,target,index)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].type)
//C     #define EnvGetMFValue(theEnv,target,index)  (((struct field *) ((struct multifield *) (target))->theFields)[index-1].value)

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _MULTIFLD_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C        LOCALE void                          *CreateMultifield2(void *,long);
//C        LOCALE void                           ReturnMultifield(void *,struct multifield *);
//C        LOCALE void                           MultifieldInstall(void *,struct multifield *);
//C        LOCALE void                           MultifieldDeinstall(void *,struct multifield *);
//C        LOCALE struct multifield             *StringToMultifield(void *,const char *);
//C        LOCALE void                          *EnvCreateMultifield(void *,long);
//C        LOCALE void                           AddToMultifieldList(void *,struct multifield *);
//C        LOCALE void                           FlushMultifields(void *);
//C        LOCALE void                           DuplicateMultifield(void *,struct dataObject *,struct dataObject *);
//C        LOCALE void                           PrintMultifield(void *,const char *,SEGMENT_PTR,long,long,int);
//C        LOCALE intBool                        MultifieldDOsEqual(DATA_OBJECT_PTR,DATA_OBJECT_PTR);
//C        LOCALE void                           StoreInMultifield(void *,DATA_OBJECT *,EXPRESSION *,int);
//C        LOCALE void                          *CopyMultifield(void *,struct multifield *);
//C        LOCALE intBool                        MultifieldsEqual(struct multifield *,struct multifield *);
//C        LOCALE void                          *DOToMultifield(void *,DATA_OBJECT *);
//C        LOCALE unsigned long                  HashMultifield(struct multifield *,unsigned long);
//C        LOCALE struct multifield             *GetMultifieldList(void *);
//C        LOCALE void                          *ImplodeMultifield(void *,DATA_OBJECT *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                          *CreateMultifield(long);
   
//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_multifld */




//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_tmpltdef
//C     #include "tmpltdef.h"
//C     #endif

//C     struct fact
//C       {
//C        struct patternEntity factHeader;
//C        struct deftemplate *whichDeftemplate;
//C        void *list;
//C        long long factIndex;
//C        unsigned long hashValue;
//C        unsigned int garbage : 1;
//C        struct fact *previousFact;
//C        struct fact *nextFact;
//C        struct fact *previousTemplateFact;
//C        struct fact *nextTemplateFact;
//C        struct multifield theProposition;
//C       };
struct fact
{
    patternEntity factHeader;
    deftemplate *whichDeftemplate;
    void *list;
    long factIndex;
    uint hashValue;
    uint __bitfield1;
    uint garbage() { return (__bitfield1 >> 0) & 0x1; }
    uint garbage(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    fact *previousFact;
    fact *nextFact;
    fact *previousTemplateFact;
    fact *nextTemplateFact;
    multifield theProposition;
}
  
//C     #define FACTS_DATA 3

const FACTS_DATA = 3;
//C     struct factsData
//C       {
//C        int ChangeToFactList;
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchFacts;
//C     #endif
//C        struct fact DummyFact;
//C        struct fact *GarbageFacts;
//C        struct fact *LastFact;
//C        struct fact *FactList;
//C        long long NextFactIndex;
//C        unsigned long NumberOfFacts;
//C        struct callFunctionItemWithArg *ListOfAssertFunctions;
//C        struct callFunctionItemWithArg *ListOfRetractFunctions;
//C        struct callFunctionItemWithArg *ListOfModifyFunctions;
//C        struct patternEntityRecord  FactInfo;
//C     #if (! RUN_TIME) && (! BLOAD_ONLY)
//C        struct deftemplate *CurrentDeftemplate;
//C     #endif
//C     #if DEFRULE_CONSTRUCT && (! RUN_TIME) && DEFTEMPLATE_CONSTRUCT && CONSTRUCT_COMPILER
//C        struct CodeGeneratorItem *FactCodeItem;
//C     #endif
//C        struct factHashEntry **FactHashTable;
//C        unsigned long FactHashTableSize;
//C        intBool FactDuplication;
//C     #if DEFRULE_CONSTRUCT
//C        struct fact             *CurrentPatternFact;
//C        struct multifieldMarker *CurrentPatternMarks;
//C     #endif
//C        long LastModuleIndex;
//C       };
struct factsData
{
    int ChangeToFactList;
    uint WatchFacts;
    fact DummyFact;
    fact *GarbageFacts;
    fact *LastFact;
    fact *FactList;
    long NextFactIndex;
    uint NumberOfFacts;
    callFunctionItemWithArg *ListOfAssertFunctions;
    callFunctionItemWithArg *ListOfRetractFunctions;
    callFunctionItemWithArg *ListOfModifyFunctions;
    patternEntityRecord FactInfo;
    deftemplate *CurrentDeftemplate;
    CodeGeneratorItem *FactCodeItem;
    factHashEntry **FactHashTable;
    uint FactHashTableSize;
    int FactDuplication;
    fact *CurrentPatternFact;
    multifieldMarker *CurrentPatternMarks;
    int LastModuleIndex;
}
  
//C     #define FactData(theEnv) ((struct factsData *) GetEnvironmentData(theEnv,FACTS_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _FACTMNGR_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                          *EnvAssert(void *,void *);
void * EnvAssert(void *, void *);
//C        LOCALE void                          *EnvAssertString(void *,const char *);
void * EnvAssertString(void *, char *);
//C        LOCALE struct fact                   *EnvCreateFact(void *,void *);
fact * EnvCreateFact(void *, void *);
//C        LOCALE void                           EnvDecrementFactCount(void *,void *);
void  EnvDecrementFactCount(void *, void *);
//C        LOCALE long long                      EnvFactIndex(void *,void *);
long  EnvFactIndex(void *, void *);
//C        LOCALE intBool                        EnvGetFactSlot(void *,void *,const char *,DATA_OBJECT *);
int  EnvGetFactSlot(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           PrintFactWithIdentifier(void *,const char *,struct fact *);
void  PrintFactWithIdentifier(void *, char *, fact *);
//C        LOCALE void                           PrintFact(void *,const char *,struct fact *,int,int);
void  PrintFact(void *, char *, fact *, int , int );
//C        LOCALE void                           PrintFactIdentifierInLongForm(void *,const char *,void *);
void  PrintFactIdentifierInLongForm(void *, char *, void *);
//C        LOCALE intBool                        EnvRetract(void *,void *);
int  EnvRetract(void *, void *);
//C        LOCALE void                           RemoveAllFacts(void *);
void  RemoveAllFacts(void *);
//C        LOCALE struct fact                   *CreateFactBySize(void *,unsigned);
fact * CreateFactBySize(void *, uint );
//C        LOCALE void                           FactInstall(void *,struct fact *);
void  FactInstall(void *, fact *);
//C        LOCALE void                           FactDeinstall(void *,struct fact *);
void  FactDeinstall(void *, fact *);
//C        LOCALE void                          *EnvGetNextFact(void *,void *);
void * EnvGetNextFact(void *, void *);
//C        LOCALE void                          *GetNextFactInScope(void *theEnv,void *);
void * GetNextFactInScope(void *theEnv, void *);
//C        LOCALE void                           EnvGetFactPPForm(void *,char *,size_t,void *);
void  EnvGetFactPPForm(void *, char *, size_t , void *);
//C        LOCALE int                            EnvGetFactListChanged(void *);
int  EnvGetFactListChanged(void *);
//C        LOCALE void                           EnvSetFactListChanged(void *,int);
void  EnvSetFactListChanged(void *, int );
//C        LOCALE unsigned long                  GetNumberOfFacts(void *);
uint  GetNumberOfFacts(void *);
//C        LOCALE void                           InitializeFacts(void *);
void  InitializeFacts(void *);
//C        LOCALE struct fact                   *FindIndexedFact(void *,long long);
fact * FindIndexedFact(void *, long );
//C        LOCALE void                           EnvIncrementFactCount(void *,void *);
void  EnvIncrementFactCount(void *, void *);
//C        LOCALE void                           PrintFactIdentifier(void *,const char *,void *);
void  PrintFactIdentifier(void *, char *, void *);
//C        LOCALE void                           DecrementFactBasisCount(void *,void *);
void  DecrementFactBasisCount(void *, void *);
//C        LOCALE void                           IncrementFactBasisCount(void *,void *);
void  IncrementFactBasisCount(void *, void *);
//C        LOCALE intBool                        FactIsDeleted(void *,void *);
int  FactIsDeleted(void *, void *);
//C        LOCALE void                           ReturnFact(void *,struct fact *);
void  ReturnFact(void *, fact *);
//C        LOCALE void                           MatchFactFunction(void *,void *);
void  MatchFactFunction(void *, void *);
//C        LOCALE intBool                        EnvPutFactSlot(void *,void *,const char *,DATA_OBJECT *);
int  EnvPutFactSlot(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE intBool                        EnvAssignFactSlotDefaults(void *,void *);
int  EnvAssignFactSlotDefaults(void *, void *);
//C        LOCALE intBool                        CopyFactSlotValues(void *,void *,void *);
int  CopyFactSlotValues(void *, void *, void *);
//C        LOCALE intBool                        DeftemplateSlotDefault(void *,struct deftemplate *,
//C                                                                     struct templateSlot *,DATA_OBJECT *,int);
int  DeftemplateSlotDefault(void *, deftemplate *, templateSlot *, DATA_OBJECT *, int );
//C        LOCALE intBool                        EnvAddAssertFunction(void *,const char *,
//C                                                                   void (*)(void *,void *),int);
int  EnvAddAssertFunction(void *, char *, void  function(void *, void *), int );
//C        LOCALE intBool                        EnvAddAssertFunctionWithContext(void *,const char *,
//C                                                                              void (*)(void *,void *),int,void *);
int  EnvAddAssertFunctionWithContext(void *, char *, void  function(void *, void *), int , void *);
//C        LOCALE intBool                        EnvRemoveAssertFunction(void *,const char *);
int  EnvRemoveAssertFunction(void *, char *);
//C        LOCALE intBool                        EnvAddRetractFunction(void *,const char *,
//C                                                                         void (*)(void *,void *),int);
int  EnvAddRetractFunction(void *, char *, void  function(void *, void *), int );
//C        LOCALE intBool                        EnvAddRetractFunctionWithContext(void *,const char *,
//C                                                                               void (*)(void *,void *),int,void *);
int  EnvAddRetractFunctionWithContext(void *, char *, void  function(void *, void *), int , void *);
//C        LOCALE intBool                        EnvRemoveRetractFunction(void *,const char *);
int  EnvRemoveRetractFunction(void *, char *);
//C        LOCALE intBool                        EnvAddModifyFunction(void *,const char *,
//C                                                                   void (*)(void *,void *,void *),int);
int  EnvAddModifyFunction(void *, char *, void  function(void *, void *, void *), int );
//C        LOCALE intBool                        EnvAddModifyFunctionWithContext(void *,const char *,
//C                                                                              void (*)(void *,void *,void *),int,void *);
int  EnvAddModifyFunctionWithContext(void *, char *, void  function(void *, void *, void *), int , void *);
//C        LOCALE intBool                        EnvRemoveModifyFunction(void *,const char *);
int  EnvRemoveModifyFunction(void *, char *);


//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        AddAssertFunction(const char *,void (*)(void *,void *),int);
//C        LOCALE intBool                        AddModifyFunction(const char *,void (*)(void *,void *,void *),int);
//C        LOCALE intBool                        AddRetractFunction(const char *,void (*)(void *,void *),int);
//C        LOCALE void                          *Assert(void *);
//C        LOCALE void                          *AssertString(const char *);
//C        LOCALE intBool                        AssignFactSlotDefaults(void *);
//C        LOCALE struct fact                   *CreateFact(void *);
//C        LOCALE void                           DecrementFactCount(void *);
//C        LOCALE long long                      FactIndex(void *);
//C        LOCALE int                            GetFactListChanged(void);
//C        LOCALE void                           GetFactPPForm(char *,unsigned,void *);
//C        LOCALE intBool                        GetFactSlot(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                          *GetNextFact(void *);
//C        LOCALE void                           IncrementFactCount(void *);
//C        LOCALE intBool                        PutFactSlot(void *,const char *,DATA_OBJECT *);
//C        LOCALE intBool                        RemoveAssertFunction(const char *);
//C        LOCALE intBool                        RemoveModifyFunction(const char *);
//C        LOCALE intBool                        RemoveRetractFunction(const char *);
//C        LOCALE intBool                        Retract(void *);
//C        LOCALE void                           SetFactListChanged(int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_factmngr */





//C     #endif
//C     #ifndef _H_cstrccom
//C     #include "cstrccom.h"
//C     #endif

//C     struct deftemplate
//C       {
//C        struct constructHeader header;
//C        struct templateSlot *slotList;
//C        unsigned int implied       : 1;
//C        unsigned int watch         : 1;
//C        unsigned int inScope       : 1;
//C        unsigned short numberOfSlots;
//C        long busyCount;
//C        struct factPatternNode *patternNetwork;
//C        struct fact *factList;
//C        struct fact *lastFact;
//C       };
struct deftemplate
{
    constructHeader header;
    templateSlot *slotList;
    uint __bitfield1;
    uint implied() { return (__bitfield1 >> 0) & 0x1; }
    uint implied(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint watch() { return (__bitfield1 >> 1) & 0x1; }
    uint watch(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint inScope() { return (__bitfield1 >> 2) & 0x1; }
    uint inScope(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    ushort numberOfSlots;
    int busyCount;
    factPatternNode *patternNetwork;
    fact *factList;
    fact *lastFact;
}

//C     struct templateSlot
//C       {
//C        struct symbolHashNode *slotName;
//C        unsigned int multislot : 1;
//C        unsigned int noDefault : 1;
//C        unsigned int defaultPresent : 1;
//C        unsigned int defaultDynamic : 1;
//C        CONSTRAINT_RECORD *constraints;
//C        struct expr *defaultList;
//C        struct expr *facetList;
//C        struct templateSlot *next;
//C       };
struct templateSlot
{
    symbolHashNode *slotName;
    uint __bitfield1;
    uint multislot() { return (__bitfield1 >> 0) & 0x1; }
    uint multislot(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint noDefault() { return (__bitfield1 >> 1) & 0x1; }
    uint noDefault(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint defaultPresent() { return (__bitfield1 >> 2) & 0x1; }
    uint defaultPresent(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint defaultDynamic() { return (__bitfield1 >> 3) & 0x1; }
    uint defaultDynamic(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    CONSTRAINT_RECORD *constraints;
    expr *defaultList;
    expr *facetList;
    templateSlot *next;
}

//C     struct deftemplateModule
//C       {
//C        struct defmoduleItemHeader header;
//C       };
struct deftemplateModule
{
    defmoduleItemHeader header;
}

//C     #define DEFTEMPLATE_DATA 5

const DEFTEMPLATE_DATA = 5;
//C     struct deftemplateData
//C       { 
//C        struct construct *DeftemplateConstruct;
//C        int DeftemplateModuleIndex;
//C        struct entityRecord DeftemplatePtrRecord;
//C     #if DEBUGGING_FUNCTIONS
//C        int DeletedTemplateDebugFlags;
//C     #endif
//C     #if CONSTRUCT_COMPILER && (! RUN_TIME)
//C        struct CodeGeneratorItem *DeftemplateCodeItem;
//C     #endif
//C     #if (! RUN_TIME) && (! BLOAD_ONLY)
//C        int DeftemplateError;
//C     #endif
//C       };
struct deftemplateData
{
    construct *DeftemplateConstruct;
    int DeftemplateModuleIndex;
    entityRecord DeftemplatePtrRecord;
    int DeletedTemplateDebugFlags;
    CodeGeneratorItem *DeftemplateCodeItem;
    int DeftemplateError;
}

//C     #define DeftemplateData(theEnv) ((struct deftemplateData *) GetEnvironmentData(theEnv,DEFTEMPLATE_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _TMPLTDEF_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeDeftemplates(void *);
void  InitializeDeftemplates(void *);
//C        LOCALE void                          *EnvFindDeftemplate(void *,const char *);
void * EnvFindDeftemplate(void *, char *);
//C        LOCALE void                          *EnvFindDeftemplateInModule(void *,const char *);
void * EnvFindDeftemplateInModule(void *, char *);
//C        LOCALE void                          *EnvGetNextDeftemplate(void *,void *);
void * EnvGetNextDeftemplate(void *, void *);
//C        LOCALE intBool                        EnvIsDeftemplateDeletable(void *,void *);
int  EnvIsDeftemplateDeletable(void *, void *);
//C        LOCALE void                          *EnvGetNextFactInTemplate(void *,void *,void *);
void * EnvGetNextFactInTemplate(void *, void *, void *);
//C        LOCALE struct deftemplateModule      *GetDeftemplateModuleItem(void *,struct defmodule *);
deftemplateModule * GetDeftemplateModuleItem(void *, defmodule *);
//C        LOCALE void                           ReturnSlots(void *,struct templateSlot *);
void  ReturnSlots(void *, templateSlot *);
//C        LOCALE void                           IncrementDeftemplateBusyCount(void *,void *);
void  IncrementDeftemplateBusyCount(void *, void *);
//C        LOCALE void                           DecrementDeftemplateBusyCount(void *,void *);
void  DecrementDeftemplateBusyCount(void *, void *);
//C        LOCALE void                          *CreateDeftemplateScopeMap(void *,struct deftemplate *);
void * CreateDeftemplateScopeMap(void *, deftemplate *);
//C     #if RUN_TIME
//C        LOCALE void                           DeftemplateRunTimeInitialize(void *);
//C     #endif
//C        LOCALE const char                    *EnvDeftemplateModule(void *,void *);
char * EnvDeftemplateModule(void *, void *);
//C        LOCALE const char                    *EnvGetDeftemplateName(void *,void *);
char * EnvGetDeftemplateName(void *, void *);
//C        LOCALE const char                    *EnvGetDeftemplatePPForm(void *,void *);
char * EnvGetDeftemplatePPForm(void *, void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE const char                    *DeftemplateModule(void *);
//C        LOCALE void                          *FindDeftemplate(const char *);
//C        LOCALE const char                    *GetDeftemplateName(void *);
//C        LOCALE const char                    *GetDeftemplatePPForm(void *);
//C        LOCALE void                          *GetNextDeftemplate(void *);
//C        LOCALE intBool                        IsDeftemplateDeletable(void *);
//C        LOCALE void                          *GetNextFactInTemplate(void *,void *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_tmpltdef */


//C     #include "tmpltbsc.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*       DEFTEMPLATE BASIC COMMANDS HEADER FILE        */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements core commands for the deftemplate     */
/*   construct such as clear, reset, save, undeftemplate,    */
/*   ppdeftemplate, list-deftemplates, and                   */
/*   get-deftemplate-list.                                   */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*            Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove compiler warnings     */
/*            when ENVIRONMENT_API_ONLY flag is set.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_tmpltbsc
//C     #define _H_tmpltbsc

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _TMPLTBSC_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           DeftemplateBasicCommands(void *);
void  DeftemplateBasicCommands(void *);
//C        LOCALE void                           UndeftemplateCommand(void *);
void  UndeftemplateCommand(void *);
//C        LOCALE intBool                        EnvUndeftemplate(void *,void *);
int  EnvUndeftemplate(void *, void *);
//C        LOCALE void                           GetDeftemplateListFunction(void *,DATA_OBJECT_PTR);
void  GetDeftemplateListFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           EnvGetDeftemplateList(void *,DATA_OBJECT_PTR,void *);
void  EnvGetDeftemplateList(void *, DATA_OBJECT_PTR , void *);
//C        LOCALE void                          *DeftemplateModuleFunction(void *);
void * DeftemplateModuleFunction(void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           PPDeftemplateCommand(void *);
void  PPDeftemplateCommand(void *);
//C        LOCALE int                            PPDeftemplate(void *,const char *,const char *);
int  PPDeftemplate(void *, char *, char *);
//C        LOCALE void                           ListDeftemplatesCommand(void *);
void  ListDeftemplatesCommand(void *);
//C        LOCALE void                           EnvListDeftemplates(void *,const char *,void *);
void  EnvListDeftemplates(void *, char *, void *);
//C        LOCALE unsigned                       EnvGetDeftemplateWatch(void *,void *);
uint  EnvGetDeftemplateWatch(void *, void *);
//C        LOCALE void                           EnvSetDeftemplateWatch(void *,unsigned,void *);
void  EnvSetDeftemplateWatch(void *, uint , void *);
//C        LOCALE unsigned                       DeftemplateWatchAccess(void *,int,unsigned,struct expr *);
uint  DeftemplateWatchAccess(void *, int , uint , expr *);
//C        LOCALE unsigned                       DeftemplateWatchPrint(void *,const char *,int,struct expr *);
uint  DeftemplateWatchPrint(void *, char *, int , expr *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           GetDeftemplateList(DATA_OBJECT_PTR,void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       GetDeftemplateWatch(void *);
//C        LOCALE void                           ListDeftemplates(const char *,void *);
//C        LOCALE void                           SetDeftemplateWatch(unsigned,void *);
//C     #endif
//C        LOCALE intBool                        Undeftemplate(void *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_tmpltbsc */


//C     #include "tmpltfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/20/14            */
   /*                                                     */
   /*          DEFTEMPLATE FUNCTION HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Added deftemplate-slot-names,                  */
/*            deftemplate-slot-default-value,                */
/*            deftemplate-slot-cardinality,                  */
/*            deftemplate-slot-allowed-values,               */
/*            deftemplate-slot-range,                        */
/*            deftemplate-slot-types,                        */
/*            deftemplate-slot-multip,                       */
/*            deftemplate-slot-singlep,                      */
/*            deftemplate-slot-existp, and                   */
/*            deftemplate-slot-defaultp functions.           */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Support for deftemplate slot facets.           */
/*                                                           */
/*            Added deftemplate-slot-facet-existp and        */
/*            deftemplate-slot-facet-value functions.        */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Support for modify callback function.          */
/*                                                           */
/*            Added additional argument to function          */
/*            CheckDeftemplateAndSlotArguments to specify    */
/*            the expected number of arguments.              */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added code to prevent a clear command from     */
/*            being executed during fact assertions via      */
/*            Increment/DecrementClearReadyLocks API.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_tmpltfun

//C     #define _H_tmpltfun

//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_scanner
//C     #include "scanner.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_factmngr
//C     #include "factmngr.h"
//C     #endif
//C     #ifndef _H_tmpltdef
//C     #include "tmpltdef.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _TMPLTFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE intBool                        UpdateModifyDuplicate(void *,struct expr *,const char *,void *);
int  UpdateModifyDuplicate(void *, expr *, char *, void *);
//C        LOCALE struct expr                   *ModifyParse(void *,struct expr *,const char *);
expr * ModifyParse(void *, expr *, char *);
//C        LOCALE struct expr                   *DuplicateParse(void *,struct expr *,const char *);
expr * DuplicateParse(void *, expr *, char *);
//C        LOCALE void                           DeftemplateFunctions( void *);
void  DeftemplateFunctions(void *);
//C        LOCALE void                           ModifyCommand(void *,DATA_OBJECT_PTR);
void  ModifyCommand(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           DuplicateCommand(void *,DATA_OBJECT_PTR);
void  DuplicateCommand(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           DeftemplateSlotNamesFunction(void *,DATA_OBJECT *);
void  DeftemplateSlotNamesFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvDeftemplateSlotNames(void *,void *,DATA_OBJECT *);
void  EnvDeftemplateSlotNames(void *, void *, DATA_OBJECT *);
//C        LOCALE void                           DeftemplateSlotDefaultValueFunction(void *,DATA_OBJECT *);
void  DeftemplateSlotDefaultValueFunction(void *, DATA_OBJECT *);
//C        LOCALE intBool                        EnvDeftemplateSlotDefaultValue(void *,void *,const char *,DATA_OBJECT *);
int  EnvDeftemplateSlotDefaultValue(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           DeftemplateSlotCardinalityFunction(void *,DATA_OBJECT *);
void  DeftemplateSlotCardinalityFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvDeftemplateSlotCardinality(void *,void *,const char *,DATA_OBJECT *);
void  EnvDeftemplateSlotCardinality(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           DeftemplateSlotAllowedValuesFunction(void *,DATA_OBJECT *);
void  DeftemplateSlotAllowedValuesFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvDeftemplateSlotAllowedValues(void *,void *,const char *,DATA_OBJECT *);
void  EnvDeftemplateSlotAllowedValues(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           DeftemplateSlotRangeFunction(void *,DATA_OBJECT *);
void  DeftemplateSlotRangeFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvDeftemplateSlotRange(void *,void *,const char *,DATA_OBJECT *);
void  EnvDeftemplateSlotRange(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           DeftemplateSlotTypesFunction(void *,DATA_OBJECT *);
void  DeftemplateSlotTypesFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvDeftemplateSlotTypes(void *,void *,const char *,DATA_OBJECT *);
void  EnvDeftemplateSlotTypes(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE int                            DeftemplateSlotMultiPFunction(void *);
int  DeftemplateSlotMultiPFunction(void *);
//C        LOCALE int                            EnvDeftemplateSlotMultiP(void *,void *,const char *);
int  EnvDeftemplateSlotMultiP(void *, void *, char *);
//C        LOCALE int                            DeftemplateSlotSinglePFunction(void *);
int  DeftemplateSlotSinglePFunction(void *);
//C        LOCALE int                            EnvDeftemplateSlotSingleP(void *,void *,const char *);
int  EnvDeftemplateSlotSingleP(void *, void *, char *);
//C        LOCALE int                            DeftemplateSlotExistPFunction(void *);
int  DeftemplateSlotExistPFunction(void *);
//C        LOCALE int                            EnvDeftemplateSlotExistP(void *,void *,const char *);
int  EnvDeftemplateSlotExistP(void *, void *, char *);
//C        LOCALE void                          *DeftemplateSlotDefaultPFunction(void *);
void * DeftemplateSlotDefaultPFunction(void *);
//C        LOCALE int                            EnvDeftemplateSlotDefaultP(void *,void *,const char *);
int  EnvDeftemplateSlotDefaultP(void *, void *, char *);
//C        LOCALE int                            DeftemplateSlotFacetExistPFunction(void *);
int  DeftemplateSlotFacetExistPFunction(void *);
//C        LOCALE int                            EnvDeftemplateSlotFacetExistP(void *,void *,const char *,const char *);
int  EnvDeftemplateSlotFacetExistP(void *, void *, char *, char *);
//C        LOCALE void                           DeftemplateSlotFacetValueFunction(void *,DATA_OBJECT *);
void  DeftemplateSlotFacetValueFunction(void *, DATA_OBJECT *);
//C        LOCALE int                            EnvDeftemplateSlotFacetValue(void *,void *,const char *,const char *,DATA_OBJECT *);
int  EnvDeftemplateSlotFacetValue(void *, void *, char *, char *, DATA_OBJECT *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           DeftemplateSlotNames(void *,DATA_OBJECT *);
//C        LOCALE intBool                        DeftemplateSlotDefaultValue(void *,const char *,DATA_OBJECT_PTR);
//C        LOCALE void                           DeftemplateSlotCardinality(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           DeftemplateSlotAllowedValues(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           DeftemplateSlotRange(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           DeftemplateSlotTypes(void *,const char *,DATA_OBJECT *);
//C        LOCALE int                            DeftemplateSlotMultiP(void *,const char *);
//C        LOCALE int                            DeftemplateSlotSingleP(void *,const char *);
//C        LOCALE int                            DeftemplateSlotExistP(void *,const char *);
//C        LOCALE int                            DeftemplateSlotDefaultP(void *,const char *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_tmpltfun */




//C     #include "factcom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/04/15            */
   /*                                                     */
   /*               FACT COMMANDS HEADER FILE             */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added code to prevent a clear command from     */
/*            being executed during fact assertions via      */
/*            Increment/DecrementClearReadyLocks API.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_factcom
//C     #define _H_factcom

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _FACTCOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           FactCommandDefinitions(void *);
void  FactCommandDefinitions(void *);
//C        LOCALE void                           AssertCommand(void *,DATA_OBJECT_PTR);
void  AssertCommand(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           RetractCommand(void *);
void  RetractCommand(void *);
//C        LOCALE void                           AssertStringFunction(void *,DATA_OBJECT_PTR);
void  AssertStringFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           FactsCommand(void *);
void  FactsCommand(void *);
//C        LOCALE void                           EnvFacts(void *,const char *,void *,long long,long long,long long);
void  EnvFacts(void *, char *, void *, long , long , long );
//C        LOCALE int                            SetFactDuplicationCommand(void *);
int  SetFactDuplicationCommand(void *);
//C        LOCALE int                            GetFactDuplicationCommand(void *);
int  GetFactDuplicationCommand(void *);
//C        LOCALE int                            SaveFactsCommand(void *);
int  SaveFactsCommand(void *);
//C        LOCALE int                            LoadFactsCommand(void *);
int  LoadFactsCommand(void *);
//C        LOCALE int                            EnvSaveFacts(void *,const char *,int);
int  EnvSaveFacts(void *, char *, int );
//C        LOCALE int                            EnvSaveFactsDriver(void *,const char *,int,struct expr *);
int  EnvSaveFactsDriver(void *, char *, int , expr *);
//C        LOCALE int                            EnvLoadFacts(void *,const char *);
int  EnvLoadFacts(void *, char *);
//C        LOCALE int                            EnvLoadFactsFromString(void *,const char *,long);
int  EnvLoadFactsFromString(void *, char *, int );
//C        LOCALE long long                      FactIndexFunction(void *);
long  FactIndexFunction(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           Facts(const char *,void *,long long,long long,long long);
//C     #endif
//C        LOCALE intBool                        LoadFacts(const char *);
//C        LOCALE intBool                        SaveFacts(const char *,int);
//C        LOCALE intBool                        LoadFactsFromString(const char *,int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_factcom */


//C     #include "factfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*              FACT FUNCTIONS HEADER FILE             */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Added ppfact function.                         */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_factfun
//C     #define _H_factfun

//C     #ifndef _H_factmngr
//C     #include "factmngr.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _FACTFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           FactFunctionDefinitions(void *);
void  FactFunctionDefinitions(void *);
//C        LOCALE void                          *FactRelationFunction(void *);
void * FactRelationFunction(void *);
//C        LOCALE void                          *FactRelation(void *);
void * FactRelation(void *);
//C        LOCALE void                          *EnvFactDeftemplate(void *,void *);
void * EnvFactDeftemplate(void *, void *);
//C        LOCALE int                            FactExistpFunction(void *);
int  FactExistpFunction(void *);
//C        LOCALE int                            EnvFactExistp(void *,void *);
int  EnvFactExistp(void *, void *);
//C        LOCALE void                           FactSlotValueFunction(void *,DATA_OBJECT *);
void  FactSlotValueFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           FactSlotValue(void *,void *,const char *,DATA_OBJECT *);
void  FactSlotValue(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           FactSlotNamesFunction(void *,DATA_OBJECT *);
void  FactSlotNamesFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvFactSlotNames(void *,void *,DATA_OBJECT *);
void  EnvFactSlotNames(void *, void *, DATA_OBJECT *);
//C        LOCALE void                           GetFactListFunction(void *,DATA_OBJECT *);
void  GetFactListFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvGetFactList(void *,DATA_OBJECT *,void *);
void  EnvGetFactList(void *, DATA_OBJECT *, void *);
//C        LOCALE void                           PPFactFunction(void *);
void  PPFactFunction(void *);
//C        LOCALE void                           EnvPPFact(void *,void *,const char *,int);
void  EnvPPFact(void *, void *, char *, int );
//C        LOCALE struct fact                   *GetFactAddressOrIndexArgument(void *,const char *,int,int);
fact * GetFactAddressOrIndexArgument(void *, char *, int , int );

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                          *FactDeftemplate(void *);
//C        LOCALE int                            FactExistp(void *);
//C        LOCALE void                           FactSlotNames(void *,DATA_OBJECT *);
//C        LOCALE void                           GetFactList(DATA_OBJECT_PTR,void *);
//C        LOCALE void                           PPFact(void *,const char *,int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_factfun */

//C     #ifndef _H_factmngr
//C     #include "factmngr.h"
//C     #endif
//C     #include "facthsh.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                 FACT HASHING MODULE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Fact hash table is resizable.                  */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added FactWillBeAsserted.                      */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_facthsh

//C     #define _H_facthsh

//C     struct factHashEntry;

//C     #ifndef _H_factmngr
//C     #include "factmngr.h"
//C     #endif

//C     struct factHashEntry
//C       {
//C        struct fact *theFact;
//C        struct factHashEntry *next;
//C       };

//C     #define SIZE_FACT_HASH 16231

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _FACTHSH_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C        LOCALE void                           AddHashedFact(void *,struct fact *,unsigned long);
//C        LOCALE intBool                        RemoveHashedFact(void *,struct fact *);
//C        LOCALE unsigned long                  HandleFactDuplication(void *,void *,intBool *);
//C        LOCALE intBool                        EnvGetFactDuplication(void *);
//C        LOCALE intBool                        EnvSetFactDuplication(void *,int);
//C        LOCALE void                           InitializeFactHashTable(void *);
//C        LOCALE void                           ShowFactHashTable(void *);
//C        LOCALE unsigned long                  HashFact(struct fact *);
//C        LOCALE intBool                        FactWillBeAsserted(void *,void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        GetFactDuplication(void);
//C        LOCALE intBool                        SetFactDuplication(int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_facthsh */


//C     #endif

//C     #if DEFGLOBAL_CONSTRUCT
//C     #include "globldef.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*                DEFGLOBAL HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warning.                              */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_globldef
//C     #define _H_globldef

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_cstrccom
//C     #include "cstrccom.h"
//C     #endif

//C     #define DEFGLOBAL_DATA 1

const DEFGLOBAL_DATA = 1;
//C     struct defglobalData
//C       { 
//C        struct construct *DefglobalConstruct;
//C        int DefglobalModuleIndex;  
//C        int ChangeToGlobals;
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchGlobals;
//C     #endif
//C        intBool ResetGlobals;
//C        struct entityRecord GlobalInfo;
//C        struct entityRecord DefglobalPtrRecord;
//C        long LastModuleIndex;
//C        struct defmodule *TheDefmodule;
//C     #if CONSTRUCT_COMPILER && (! RUN_TIME)
//C        struct CodeGeneratorItem *DefglobalCodeItem;
//C     #endif
//C       };
struct defglobalData
{
    construct *DefglobalConstruct;
    int DefglobalModuleIndex;
    int ChangeToGlobals;
    uint WatchGlobals;
    int ResetGlobals;
    entityRecord GlobalInfo;
    entityRecord DefglobalPtrRecord;
    int LastModuleIndex;
    defmodule *TheDefmodule;
    CodeGeneratorItem *DefglobalCodeItem;
}

//C     struct defglobal
//C       {
//C        struct constructHeader header;
//C        unsigned int watch   : 1;
//C        unsigned int inScope : 1;
//C        long busyCount;
//C        DATA_OBJECT current;
//C        struct expr *initial;
//C       };
struct defglobal
{
    constructHeader header;
    uint __bitfield1;
    uint watch() { return (__bitfield1 >> 0) & 0x1; }
    uint watch(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint inScope() { return (__bitfield1 >> 1) & 0x1; }
    uint inScope(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    int busyCount;
    DATA_OBJECT current;
    expr *initial;
}

//C     struct defglobalModule
//C       {
//C        struct defmoduleItemHeader header;
//C       };
struct defglobalModule
{
    defmoduleItemHeader header;
}

//C     #define DefglobalData(theEnv) ((struct defglobalData *) GetEnvironmentData(theEnv,DEFGLOBAL_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _GLOBLDEF_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           InitializeDefglobals(void *);
void  InitializeDefglobals(void *);
//C        LOCALE void                          *EnvFindDefglobal(void *,const char *);
void * EnvFindDefglobal(void *, char *);
//C        LOCALE void                          *EnvFindDefglobalInModule(void *,const char *);
void * EnvFindDefglobalInModule(void *, char *);
//C        LOCALE void                          *EnvGetNextDefglobal(void *,void *);
void * EnvGetNextDefglobal(void *, void *);
//C        LOCALE void                           CreateInitialFactDefglobal(void);
void  CreateInitialFactDefglobal();
//C        LOCALE intBool                        EnvIsDefglobalDeletable(void *,void *);
int  EnvIsDefglobalDeletable(void *, void *);
//C        LOCALE struct defglobalModule        *GetDefglobalModuleItem(void *,struct defmodule *);
defglobalModule * GetDefglobalModuleItem(void *, defmodule *);
//C        LOCALE void                           QSetDefglobalValue(void *,struct defglobal *,DATA_OBJECT_PTR,int);
void  QSetDefglobalValue(void *, defglobal *, DATA_OBJECT_PTR , int );
//C        LOCALE struct defglobal              *QFindDefglobal(void *,struct symbolHashNode *);
defglobal * QFindDefglobal(void *, symbolHashNode *);
//C        LOCALE void                           EnvGetDefglobalValueForm(void *,char *,size_t,void *);
void  EnvGetDefglobalValueForm(void *, char *, size_t , void *);
//C        LOCALE int                            EnvGetGlobalsChanged(void *);
int  EnvGetGlobalsChanged(void *);
//C        LOCALE void                           EnvSetGlobalsChanged(void *,int);
void  EnvSetGlobalsChanged(void *, int );
//C        LOCALE intBool                        EnvGetDefglobalValue(void *,const char *,DATA_OBJECT_PTR);
int  EnvGetDefglobalValue(void *, char *, DATA_OBJECT_PTR );
//C        LOCALE intBool                        EnvSetDefglobalValue(void *,const char *,DATA_OBJECT_PTR);
int  EnvSetDefglobalValue(void *, char *, DATA_OBJECT_PTR );
//C        LOCALE void                           UpdateDefglobalScope(void *);
void  UpdateDefglobalScope(void *);
//C        LOCALE void                          *GetNextDefglobalInScope(void *,void *);
void * GetNextDefglobalInScope(void *, void *);
//C        LOCALE int                            QGetDefglobalValue(void *,void *,DATA_OBJECT_PTR);
int  QGetDefglobalValue(void *, void *, DATA_OBJECT_PTR );
//C        LOCALE const char                    *EnvDefglobalModule(void *,void *);
char * EnvDefglobalModule(void *, void *);
//C        LOCALE const char                    *EnvGetDefglobalName(void *,void *);
char * EnvGetDefglobalName(void *, void *);
//C        LOCALE const char                    *EnvGetDefglobalPPForm(void *,void *);
char * EnvGetDefglobalPPForm(void *, void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE const char                    *DefglobalModule(void *);
//C        LOCALE void                          *FindDefglobal(const char *);
//C        LOCALE const char                    *GetDefglobalName(void *);
//C        LOCALE const char                    *GetDefglobalPPForm(void *);
//C        LOCALE intBool                        GetDefglobalValue(const char *,DATA_OBJECT_PTR);
//C        LOCALE void                           GetDefglobalValueForm(char *,unsigned,void *);
//C        LOCALE int                            GetGlobalsChanged(void);
//C        LOCALE void                          *GetNextDefglobal(void *);
//C        LOCALE intBool                        IsDefglobalDeletable(void *);
//C        LOCALE intBool                        SetDefglobalValue(const char *,DATA_OBJECT_PTR);
//C        LOCALE void                           SetGlobalsChanged(int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_globldef */


//C     #include "globlbsc.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*         DEFGLOBAL BASIC COMMANDS HEADER FILE        */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*            Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Moved WatchGlobals global to defglobalData.    */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_globlbsc
//C     #define _H_globlbsc

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _GLOBLBSC_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           DefglobalBasicCommands(void *);
void  DefglobalBasicCommands(void *);
//C        LOCALE void                           UndefglobalCommand(void *);
void  UndefglobalCommand(void *);
//C        LOCALE intBool                        EnvUndefglobal(void *,void *);
int  EnvUndefglobal(void *, void *);
//C        LOCALE void                           GetDefglobalListFunction(void *,DATA_OBJECT_PTR);
void  GetDefglobalListFunction(void *, DATA_OBJECT_PTR );
//C        LOCALE void                           EnvGetDefglobalList(void *,DATA_OBJECT_PTR,void *);
void  EnvGetDefglobalList(void *, DATA_OBJECT_PTR , void *);
//C        LOCALE void                          *DefglobalModuleFunction(void *);
void * DefglobalModuleFunction(void *);
//C        LOCALE void                           PPDefglobalCommand(void *);
void  PPDefglobalCommand(void *);
//C        LOCALE int                            PPDefglobal(void *,const char *,const char *);
int  PPDefglobal(void *, char *, char *);
//C        LOCALE void                           ListDefglobalsCommand(void *);
void  ListDefglobalsCommand(void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       EnvGetDefglobalWatch(void *,void *);
uint  EnvGetDefglobalWatch(void *, void *);
//C        LOCALE void                           EnvListDefglobals(void *,const char *,void *);
void  EnvListDefglobals(void *, char *, void *);
//C        LOCALE void                           EnvSetDefglobalWatch(void *,unsigned,void *);
void  EnvSetDefglobalWatch(void *, uint , void *);
//C     #endif
//C        LOCALE void                           ResetDefglobals(void *);
void  ResetDefglobals(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           GetDefglobalList(DATA_OBJECT_PTR,void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       GetDefglobalWatch(void *);
//C        LOCALE void                           ListDefglobals(const char *,void *);
//C        LOCALE void                           SetDefglobalWatch(unsigned,void *);
//C     #endif
//C        LOCALE intBool                        Undefglobal(void *);
   
//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_globlbsc */


//C     #include "globlcom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            DEFGLOBAL COMMANDS HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_globlcom
//C     #define _H_globlcom

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _GLOBLCOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           DefglobalCommandDefinitions(void *);
void  DefglobalCommandDefinitions(void *);
//C        LOCALE int                            SetResetGlobalsCommand(void *);
int  SetResetGlobalsCommand(void *);
//C        LOCALE intBool                        EnvSetResetGlobals(void *,int);
int  EnvSetResetGlobals(void *, int );
//C        LOCALE int                            GetResetGlobalsCommand(void *);
int  GetResetGlobalsCommand(void *);
//C        LOCALE intBool                        EnvGetResetGlobals(void *);
int  EnvGetResetGlobals(void *);
//C        LOCALE void                           ShowDefglobalsCommand(void *);
void  ShowDefglobalsCommand(void *);
//C        LOCALE void                           EnvShowDefglobals(void *,const char *,void *);
void  EnvShowDefglobals(void *, char *, void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        GetResetGlobals(void);
//C        LOCALE intBool                        SetResetGlobals(int);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           ShowDefglobals(const char *,void *);
//C     #endif

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_globlcom */

//C     #endif

//C     #if DEFFUNCTION_CONSTRUCT
//C     #include "dffnxfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*              DEFFUNCTION HEADER FILE                */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*            Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warning.                              */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added missing initializer for ENTITY_RECORD.   */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_dffnxfun
//C     #define _H_dffnxfun

//C     typedef struct deffunctionStruct DEFFUNCTION;
alias deffunctionStruct DEFFUNCTION;
//C     typedef struct deffunctionModule DEFFUNCTION_MODULE;
alias deffunctionModule DEFFUNCTION_MODULE;

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_cstrccom
//C     #include "cstrccom.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif
//C     #ifdef _DFFNXFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     struct deffunctionModule
//C       {
//C        struct defmoduleItemHeader header;
//C       };
struct deffunctionModule
{
    defmoduleItemHeader header;
}

//C     struct deffunctionStruct
//C       {
//C        struct constructHeader header;
//C        unsigned busy,
//C                 executing;
//C        unsigned short trace;
//C        EXPRESSION *code;
//C        int minNumberOfParameters,
//C            maxNumberOfParameters,
//C            numberOfLocalVars;
//C       };
struct deffunctionStruct
{
    constructHeader header;
    uint busy;
    uint executing;
    ushort trace;
    EXPRESSION *code;
    int minNumberOfParameters;
    int maxNumberOfParameters;
    int numberOfLocalVars;
}
  
//C     #define DEFFUNCTION_DATA 23

const DEFFUNCTION_DATA = 23;
//C     struct deffunctionData
//C       { 
//C        struct construct *DeffunctionConstruct;
//C        int DeffunctionModuleIndex;
//C        ENTITY_RECORD DeffunctionEntityRecord;
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchDeffunctions;
//C     #endif
//C        struct CodeGeneratorItem *DeffunctionCodeItem;
//C        DEFFUNCTION *ExecutingDeffunction;
//C     #if (! BLOAD_ONLY) && (! RUN_TIME)
//C        struct token DFInputToken;
//C     #endif
//C       };
struct deffunctionData
{
    construct *DeffunctionConstruct;
    int DeffunctionModuleIndex;
    ENTITY_RECORD DeffunctionEntityRecord;
    uint WatchDeffunctions;
    CodeGeneratorItem *DeffunctionCodeItem;
    DEFFUNCTION *ExecutingDeffunction;
    token DFInputToken;
}

//C     #define DeffunctionData(theEnv) ((struct deffunctionData *) GetEnvironmentData(theEnv,DEFFUNCTION_DATA))

//C        LOCALE int                            CheckDeffunctionCall(void *,void *,int);
int  CheckDeffunctionCall(void *, void *, int );
//C        LOCALE void                           DeffunctionGetBind(DATA_OBJECT *);
void  DeffunctionGetBind(DATA_OBJECT *);
//C        LOCALE void                           DFRtnUnknown(DATA_OBJECT *);
void  DFRtnUnknown(DATA_OBJECT *);
//C        LOCALE void                           DFWildargs(DATA_OBJECT *);
void  DFWildargs(DATA_OBJECT *);
//C        LOCALE const char                    *EnvDeffunctionModule(void *,void *);
char * EnvDeffunctionModule(void *, void *);
//C        LOCALE void                          *EnvFindDeffunction(void *,const char *);
void * EnvFindDeffunction(void *, char *);
//C        LOCALE void                          *EnvFindDeffunctionInModule(void *,const char *);
void * EnvFindDeffunctionInModule(void *, char *);
//C        LOCALE void                           EnvGetDeffunctionList(void *,DATA_OBJECT *,struct defmodule *);
void  EnvGetDeffunctionList(void *, DATA_OBJECT *, defmodule *);
//C        LOCALE const char                    *EnvGetDeffunctionName(void *,void *);
char * EnvGetDeffunctionName(void *, void *);
//C        LOCALE SYMBOL_HN                     *EnvGetDeffunctionNamePointer(void *,void *);
SYMBOL_HN * EnvGetDeffunctionNamePointer(void *, void *);
//C        LOCALE const char                    *EnvGetDeffunctionPPForm(void *,void *);
char * EnvGetDeffunctionPPForm(void *, void *);
//C        LOCALE void                          *EnvGetNextDeffunction(void *,void *);
void * EnvGetNextDeffunction(void *, void *);
//C        LOCALE int                            EnvIsDeffunctionDeletable(void *,void *);
int  EnvIsDeffunctionDeletable(void *, void *);
//C        LOCALE void                           EnvSetDeffunctionPPForm(void *,void *,const char *);
void  EnvSetDeffunctionPPForm(void *, void *, char *);
//C        LOCALE intBool                        EnvUndeffunction(void *,void *);
int  EnvUndeffunction(void *, void *);
//C        LOCALE void                           GetDeffunctionListFunction(void *,DATA_OBJECT *);
void  GetDeffunctionListFunction(void *, DATA_OBJECT *);
//C        LOCALE void                          *GetDeffunctionModuleCommand(void *);
void * GetDeffunctionModuleCommand(void *);
//C        LOCALE DEFFUNCTION                   *LookupDeffunctionByMdlOrScope(void *,const char *);
DEFFUNCTION * LookupDeffunctionByMdlOrScope(void *, char *);
//C        LOCALE DEFFUNCTION                   *LookupDeffunctionInScope(void *,const char *);
DEFFUNCTION * LookupDeffunctionInScope(void *, char *);
//C     #if (! BLOAD_ONLY) && (! RUN_TIME)
//C        LOCALE void                           RemoveDeffunction(void *,void *);
void  RemoveDeffunction(void *, void *);
//C     #endif
//C        LOCALE void                           SetupDeffunctions(void *);
void  SetupDeffunctions(void *);
//C        LOCALE void                           UndeffunctionCommand(void *);
void  UndeffunctionCommand(void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       EnvGetDeffunctionWatch(void *,void *);
uint  EnvGetDeffunctionWatch(void *, void *);
//C        LOCALE void                           EnvListDeffunctions(void *,const char *,struct defmodule *);
void  EnvListDeffunctions(void *, char *, defmodule *);
//C        LOCALE void                           EnvSetDeffunctionWatch(void *,unsigned,void *);
void  EnvSetDeffunctionWatch(void *, uint , void *);
//C        LOCALE void                           ListDeffunctionsCommand(void *);
void  ListDeffunctionsCommand(void *);
//C        LOCALE void                           PPDeffunctionCommand(void *);
void  PPDeffunctionCommand(void *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE const char                    *DeffunctionModule(void *);
//C        LOCALE void                          *FindDeffunction(const char *);
//C        LOCALE void                           GetDeffunctionList(DATA_OBJECT *,struct defmodule *);
//C        LOCALE const char                    *GetDeffunctionName(void *);
//C        LOCALE const char                    *GetDeffunctionPPForm(void *);
//C        LOCALE void                          *GetNextDeffunction(void *);
//C        LOCALE intBool                        IsDeffunctionDeletable(void *);
//C        LOCALE intBool                        Undeffunction(void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       GetDeffunctionWatch(void *);
//C        LOCALE void                           ListDeffunctions(const char *,struct defmodule *);
//C        LOCALE void                           SetDeffunctionWatch(unsigned,void *);
//C     #endif 

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_dffnxfun */






//C     #endif

//C     #if DEFGENERIC_CONSTRUCT
//C     #include "genrccom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  01/25/15          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when DEBUGGING_FUNCTIONS   */
/*            is set to 0 and PROFILING_FUNCTIONS is set to  */
/*            1.                                             */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_genrccom
//C     #define _H_genrccom

//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_cstrccom
//C     #include "cstrccom.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_genrcfun
//C     #include "genrcfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Removed IMPERATIVE_METHODS compilation flag.   */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when DEBUGGING_FUNCTIONS   */
/*            is set to 0 and PROFILING_FUNCTIONS is set to  */
/*            1.                                             */
/*                                                           */
/*            Fixed typing issue when OBJECT_SYSTEM          */
/*            compiler flag is set to 0.                     */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_genrcfun
//C     #define _H_genrcfun

//C     typedef struct defgenericModule DEFGENERIC_MODULE;
alias defgenericModule DEFGENERIC_MODULE;
//C     typedef struct restriction RESTRICTION;
alias restriction RESTRICTION;
//C     typedef struct method DEFMETHOD;
alias method DEFMETHOD;
//C     typedef struct defgeneric DEFGENERIC;
alias defgeneric DEFGENERIC;

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #if OBJECT_SYSTEM
//C     #ifndef _H_object
//C     #include "object.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                OBJECT SYSTEM DEFINITIONS            */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_object
//C     #define _H_object

//C     typedef struct defclassModule DEFCLASS_MODULE;
alias defclassModule DEFCLASS_MODULE;
//C     typedef struct defclass DEFCLASS;
alias defclass DEFCLASS;
//C     typedef struct packedClassLinks PACKED_CLASS_LINKS;
alias packedClassLinks PACKED_CLASS_LINKS;
//C     typedef struct classLink CLASS_LINK;
alias classLink CLASS_LINK;
//C     typedef struct slotName SLOT_NAME;
alias slotName SLOT_NAME;
//C     typedef struct slotDescriptor SLOT_DESC;
alias slotDescriptor SLOT_DESC;
//C     typedef struct messageHandler HANDLER;
alias messageHandler HANDLER;
//C     typedef struct instance INSTANCE_TYPE;
alias instance INSTANCE_TYPE;
//C     typedef struct instanceSlot INSTANCE_SLOT;
alias instanceSlot INSTANCE_SLOT;

/* Maximum # of simultaneous class hierarchy traversals
   should be a multiple of BITS_PER_BYTE and less than MAX_INT      */

//C     #define MAX_TRAVERSALS  256
//C     #define TRAVERSAL_BYTES 32       /* (MAX_TRAVERSALS / BITS_PER_BYTE) */
const MAX_TRAVERSALS = 256;

const TRAVERSAL_BYTES = 32;
//C     #define VALUE_REQUIRED     0
//C     #define VALUE_PROHIBITED   1
const VALUE_REQUIRED = 0;
//C     #define VALUE_NOT_REQUIRED 2
const VALUE_PROHIBITED = 1;

const VALUE_NOT_REQUIRED = 2;
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_constrnt
//C     #include "constrnt.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_multifld
//C     #include "multifld.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #ifndef _H_match
//C     #include "match.h"
//C     #endif
//C     #ifndef _H_pattern
//C     #include "pattern.h"
//C     #endif

//C     #define GetInstanceSlotLength(sp) GetMFLength(sp->value)

//C     struct packedClassLinks
//C       {
//C        long classCount;
//C        DEFCLASS **classArray;
//C       };
struct packedClassLinks
{
    int classCount;
    DEFCLASS **classArray;
}

//C     struct defclassModule
//C       {
//C        struct defmoduleItemHeader header;
//C       };
struct defclassModule
{
    defmoduleItemHeader header;
}

//C     struct defclass
//C       {
//C        struct constructHeader header;
//C        unsigned installed      : 1;
//C        unsigned system         : 1;
//C        unsigned abstract       : 1;
//C        unsigned reactive       : 1;
//C        unsigned traceInstances : 1;
//C        unsigned traceSlots     : 1;
//C        unsigned id;
//C        unsigned busy,
//C                 hashTableIndex;
//C        PACKED_CLASS_LINKS directSuperclasses,
//C                           directSubclasses,
//C                           allSuperclasses;
//C        SLOT_DESC *slots,
//C                  **instanceTemplate;
//C        unsigned *slotNameMap;
//C        short slotCount;
//C        short localInstanceSlotCount;
//C        short instanceSlotCount;
//C        short maxSlotNameID;
//C        INSTANCE_TYPE *instanceList,
//C                      *instanceListBottom;
//C        HANDLER *handlers;
//C        unsigned *handlerOrderMap;
//C        short handlerCount;
//C        DEFCLASS *nxtHash;
//C        BITMAP_HN *scopeMap;
//C        char traversalRecord[TRAVERSAL_BYTES];
//C       };
struct defclass
{
    constructHeader header;
    uint __bitfield1;
    uint installed() { return (__bitfield1 >> 0) & 0x1; }
    uint installed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint system() { return (__bitfield1 >> 1) & 0x1; }
    uint system(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint abstract_() { return (__bitfield1 >> 2) & 0x1; }
    uint abstract_(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint reactive() { return (__bitfield1 >> 3) & 0x1; }
    uint reactive(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint traceInstances() { return (__bitfield1 >> 4) & 0x1; }
    uint traceInstances(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffef) | (value << 4); return value; }
    uint traceSlots() { return (__bitfield1 >> 5) & 0x1; }
    uint traceSlots(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffdf) | (value << 5); return value; }
    uint id;
    uint busy;
    uint hashTableIndex;
    PACKED_CLASS_LINKS directSuperclasses;
    PACKED_CLASS_LINKS directSubclasses;
    PACKED_CLASS_LINKS allSuperclasses;
    SLOT_DESC *slots;
    SLOT_DESC **instanceTemplate;
    uint *slotNameMap;
    short slotCount;
    short localInstanceSlotCount;
    short instanceSlotCount;
    short maxSlotNameID;
    INSTANCE_TYPE *instanceList;
    INSTANCE_TYPE *instanceListBottom;
    HANDLER *handlers;
    uint *handlerOrderMap;
    short handlerCount;
    DEFCLASS *nxtHash;
    BITMAP_HN *scopeMap;
    char [32]traversalRecord;
}

//C     struct classLink
//C       {
//C        DEFCLASS *cls;
//C        struct classLink *nxt;
//C       };
struct classLink
{
    DEFCLASS *cls;
    classLink *nxt;
}

//C     struct slotName
//C       {
//C        unsigned hashTableIndex,
//C                 use;
//C        short id;
//C        SYMBOL_HN *name,
//C                  *putHandlerName;
//C        struct slotName *nxt;
//C        long bsaveIndex;
//C       };
struct slotName
{
    uint hashTableIndex;
    uint use;
    short id;
    SYMBOL_HN *name;
    SYMBOL_HN *putHandlerName;
    slotName *nxt;
    int bsaveIndex;
}

//C     struct instanceSlot
//C       {
//C        SLOT_DESC *desc;
//C        unsigned valueRequired : 1;
//C        unsigned override      : 1;
//C        unsigned short type;
//C        void *value;
//C       };
struct instanceSlot
{
    SLOT_DESC *desc;
    uint __bitfield1;
    uint valueRequired() { return (__bitfield1 >> 0) & 0x1; }
    uint valueRequired(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint override_() { return (__bitfield1 >> 1) & 0x1; }
    uint override_(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    ushort type;
    void *value;
}

//C     struct slotDescriptor
//C       {
//C        unsigned shared                   : 1;
//C        unsigned multiple                 : 1;
//C        unsigned composite                : 1;
//C        unsigned noInherit                : 1;
//C        unsigned noWrite                  : 1;
//C        unsigned initializeOnly           : 1;
//C        unsigned dynamicDefault           : 1;
//C        unsigned defaultSpecified         : 1;
//C        unsigned noDefault                : 1;
//C        unsigned reactive                 : 1;
//C        unsigned publicVisibility         : 1;
//C        unsigned createReadAccessor       : 1;
//C        unsigned createWriteAccessor      : 1;
//C        unsigned overrideMessageSpecified : 1;
//C        DEFCLASS *cls;
//C        SLOT_NAME *slotName;
//C        SYMBOL_HN *overrideMessage;
//C        void *defaultValue;
//C        CONSTRAINT_RECORD *constraint;
//C        unsigned sharedCount;
//C        long bsaveIndex;
//C        INSTANCE_SLOT sharedValue;
//C       };
struct slotDescriptor
{
    uint __bitfield1;
    uint shared_() { return (__bitfield1 >> 0) & 0x1; }
    uint shared_(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint multiple() { return (__bitfield1 >> 1) & 0x1; }
    uint multiple(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint composite() { return (__bitfield1 >> 2) & 0x1; }
    uint composite(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint noInherit() { return (__bitfield1 >> 3) & 0x1; }
    uint noInherit(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint noWrite() { return (__bitfield1 >> 4) & 0x1; }
    uint noWrite(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffef) | (value << 4); return value; }
    uint initializeOnly() { return (__bitfield1 >> 5) & 0x1; }
    uint initializeOnly(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffdf) | (value << 5); return value; }
    uint dynamicDefault() { return (__bitfield1 >> 6) & 0x1; }
    uint dynamicDefault(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffbf) | (value << 6); return value; }
    uint defaultSpecified() { return (__bitfield1 >> 7) & 0x1; }
    uint defaultSpecified(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffff7f) | (value << 7); return value; }
    uint noDefault() { return (__bitfield1 >> 8) & 0x1; }
    uint noDefault(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffeff) | (value << 8); return value; }
    uint reactive() { return (__bitfield1 >> 9) & 0x1; }
    uint reactive(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffdff) | (value << 9); return value; }
    uint publicVisibility() { return (__bitfield1 >> 10) & 0x1; }
    uint publicVisibility(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffbff) | (value << 10); return value; }
    uint createReadAccessor() { return (__bitfield1 >> 11) & 0x1; }
    uint createReadAccessor(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffff7ff) | (value << 11); return value; }
    uint createWriteAccessor() { return (__bitfield1 >> 12) & 0x1; }
    uint createWriteAccessor(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffefff) | (value << 12); return value; }
    uint overrideMessageSpecified() { return (__bitfield1 >> 13) & 0x1; }
    uint overrideMessageSpecified(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffdfff) | (value << 13); return value; }
    DEFCLASS *cls;
    SLOT_NAME *slotName;
    SYMBOL_HN *overrideMessage;
    void *defaultValue;
    CONSTRAINT_RECORD *constraint;
    uint sharedCount;
    int bsaveIndex;
    INSTANCE_SLOT sharedValue;
}

//C     struct instance
//C       {
//C        struct patternEntity header;
//C        void *partialMatchList;
//C        INSTANCE_SLOT *basisSlots;
//C        unsigned installed            : 1;
//C        unsigned garbage              : 1;
//C        unsigned initSlotsCalled      : 1;
//C        unsigned initializeInProgress : 1;
//C        unsigned reteSynchronized     : 1;
//C        SYMBOL_HN *name;
//C        unsigned hashTableIndex;
//C        unsigned busy;
//C        DEFCLASS *cls;
//C        INSTANCE_TYPE *prvClass,*nxtClass,
//C                      *prvHash,*nxtHash,
//C                      *prvList,*nxtList;
//C        INSTANCE_SLOT **slotAddresses,
//C                      *slots;
//C       };
struct instance
{
    patternEntity header;
    void *partialMatchList;
    INSTANCE_SLOT *basisSlots;
    uint __bitfield1;
    uint installed() { return (__bitfield1 >> 0) & 0x1; }
    uint installed(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint garbage() { return (__bitfield1 >> 1) & 0x1; }
    uint garbage(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint initSlotsCalled() { return (__bitfield1 >> 2) & 0x1; }
    uint initSlotsCalled(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint initializeInProgress() { return (__bitfield1 >> 3) & 0x1; }
    uint initializeInProgress(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint reteSynchronized() { return (__bitfield1 >> 4) & 0x1; }
    uint reteSynchronized(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffef) | (value << 4); return value; }
    SYMBOL_HN *name;
    uint hashTableIndex;
    uint busy;
    DEFCLASS *cls;
    INSTANCE_TYPE *prvClass;
    INSTANCE_TYPE *nxtClass;
    INSTANCE_TYPE *prvHash;
    INSTANCE_TYPE *nxtHash;
    INSTANCE_TYPE *prvList;
    INSTANCE_TYPE *nxtList;
    INSTANCE_SLOT **slotAddresses;
    INSTANCE_SLOT *slots;
}

//C     struct messageHandler
//C       {
//C        unsigned system         : 1;
//C        unsigned type           : 2;
//C        unsigned mark           : 1;
//C        unsigned trace          : 1;
//C        unsigned busy;
//C        SYMBOL_HN *name;
//C        DEFCLASS *cls;
//C        short minParams;
//C        short maxParams;
//C        short localVarCount;
//C        EXPRESSION *actions;
//C        char *ppForm;
//C        struct userData *usrData;
//C       };
struct messageHandler
{
    uint __bitfield1;
    uint system() { return (__bitfield1 >> 0) & 0x1; }
    uint system(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint type() { return (__bitfield1 >> 1) & 0x3; }
    uint type(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff9) | (value << 1); return value; }
    uint mark() { return (__bitfield1 >> 3) & 0x1; }
    uint mark(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint trace() { return (__bitfield1 >> 4) & 0x1; }
    uint trace(uint value) { __bitfield1 = (__bitfield1 & 0xffffffffffffffef) | (value << 4); return value; }
    uint busy;
    SYMBOL_HN *name;
    DEFCLASS *cls;
    short minParams;
    short maxParams;
    short localVarCount;
    EXPRESSION *actions;
    char *ppForm;
    userData *usrData;
}

//C     #endif /* _H_object */





//C     #endif
//C     #endif

//C     struct defgenericModule
//C       {
//C        struct defmoduleItemHeader header;
//C       };
struct defgenericModule
{
    defmoduleItemHeader header;
}

//C     struct restriction
//C       {
//C        void **types;
//C        EXPRESSION *query;
//C        short tcnt;
//C       };
struct restriction
{
    void **types;
    EXPRESSION *query;
    short tcnt;
}

//C     struct method
//C       {
//C        short index;
//C        unsigned busy;
//C        short restrictionCount;
//C        short minRestrictions;
//C        short maxRestrictions;
//C        short localVarCount;
//C        unsigned system : 1;
//C        unsigned trace : 1;
//C        RESTRICTION *restrictions;
//C        EXPRESSION *actions;
//C        char *ppForm;
//C        struct userData *usrData;
//C       };
struct method
{
    short index;
    uint busy;
    short restrictionCount;
    short minRestrictions;
    short maxRestrictions;
    short localVarCount;
    uint __bitfield1;
    uint system() { return (__bitfield1 >> 0) & 0x1; }
    uint system(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint trace() { return (__bitfield1 >> 1) & 0x1; }
    uint trace(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    RESTRICTION *restrictions;
    EXPRESSION *actions;
    char *ppForm;
    userData *usrData;
}

//C     struct defgeneric
//C       {
//C        struct constructHeader header;
//C        unsigned busy,trace;
//C        DEFMETHOD *methods;
//C        short mcnt;
//C        short new_index;
//C       };
struct defgeneric
{
    constructHeader header;
    uint busy;
    uint trace;
    DEFMETHOD *methods;
    short mcnt;
    short new_index;
}

//C     #define DEFGENERIC_DATA 27

const DEFGENERIC_DATA = 27;
//C     struct defgenericData
//C       { 
//C        struct construct *DefgenericConstruct;
//C        int DefgenericModuleIndex;
//C        ENTITY_RECORD GenericEntityRecord;
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchGenerics;
//C        unsigned WatchMethods;
//C     #endif
//C        DEFGENERIC *CurrentGeneric;
//C        DEFMETHOD *CurrentMethod;
//C        DATA_OBJECT *GenericCurrentArgument;
//C     #if (! RUN_TIME) && (! BLOAD_ONLY)
//C        unsigned OldGenericBusySave;
//C     #endif
//C     #if CONSTRUCT_COMPILER && (! RUN_TIME)
//C        struct CodeGeneratorItem *DefgenericCodeItem;
//C     #endif
//C     #if (! BLOAD_ONLY) && (! RUN_TIME)
//C        struct token GenericInputToken;
//C     #endif
//C       };
struct defgenericData
{
    construct *DefgenericConstruct;
    int DefgenericModuleIndex;
    ENTITY_RECORD GenericEntityRecord;
    uint WatchGenerics;
    uint WatchMethods;
    DEFGENERIC *CurrentGeneric;
    DEFMETHOD *CurrentMethod;
    DATA_OBJECT *GenericCurrentArgument;
    uint OldGenericBusySave;
    CodeGeneratorItem *DefgenericCodeItem;
    token GenericInputToken;
}

//C     #define DefgenericData(theEnv) ((struct defgenericData *) GetEnvironmentData(theEnv,DEFGENERIC_DATA))
//C     #define SaveBusyCount(gfunc)    (DefgenericData(theEnv)->OldGenericBusySave = gfunc->busy)
//C     #define RestoreBusyCount(gfunc) (gfunc->busy = DefgenericData(theEnv)->OldGenericBusySave)

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _GENRCFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #if ! RUN_TIME
//C        LOCALE intBool                        ClearDefgenericsReady(void *);
int  ClearDefgenericsReady(void *);
//C        LOCALE void                          *AllocateDefgenericModule(void *);
void * AllocateDefgenericModule(void *);
//C        LOCALE void                           FreeDefgenericModule(void *,void *);
void  FreeDefgenericModule(void *, void *);
//C     #endif

//C     #if (! BLOAD_ONLY) && (! RUN_TIME)

//C        LOCALE int                            ClearDefmethods(void *);
int  ClearDefmethods(void *);
//C        LOCALE int                            RemoveAllExplicitMethods(void *,DEFGENERIC *);
int  RemoveAllExplicitMethods(void *, DEFGENERIC *);
//C        LOCALE void                           RemoveDefgeneric(void *,void *);
void  RemoveDefgeneric(void *, void *);
//C        LOCALE int                            ClearDefgenerics(void *);
int  ClearDefgenerics(void *);
//C        LOCALE void                           MethodAlterError(void *,DEFGENERIC *);
void  MethodAlterError(void *, DEFGENERIC *);
//C        LOCALE void                           DeleteMethodInfo(void *,DEFGENERIC *,DEFMETHOD *);
void  DeleteMethodInfo(void *, DEFGENERIC *, DEFMETHOD *);
//C        LOCALE void                           DestroyMethodInfo(void *,DEFGENERIC *,DEFMETHOD *);
void  DestroyMethodInfo(void *, DEFGENERIC *, DEFMETHOD *);
//C        LOCALE int                            MethodsExecuting(DEFGENERIC *);
int  MethodsExecuting(DEFGENERIC *);
//C     #endif
//C     #if ! OBJECT_SYSTEM
//C        LOCALE intBool                        SubsumeType(int,int);
//C     #endif

//C        LOCALE long                           FindMethodByIndex(DEFGENERIC *,long);
int  FindMethodByIndex(DEFGENERIC *, int );
//C     #if DEBUGGING_FUNCTIONS || PROFILING_FUNCTIONS
//C        LOCALE void                           PrintMethod(void *,char *,size_t,DEFMETHOD *);
void  PrintMethod(void *, char *, size_t , DEFMETHOD *);
//C     #endif
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           PreviewGeneric(void *);
void  PreviewGeneric(void *);
//C     #endif
//C        LOCALE DEFGENERIC                    *CheckGenericExists(void *,const char *,const char *);
DEFGENERIC * CheckGenericExists(void *, char *, char *);
//C        LOCALE long                           CheckMethodExists(void *,const char *,DEFGENERIC *,long);
int  CheckMethodExists(void *, char *, DEFGENERIC *, int );

//C     #if ! OBJECT_SYSTEM
//C        LOCALE const char                    *TypeName(void *,int);
//C     #endif

//C        LOCALE void                           PrintGenericName(void *,const char *,DEFGENERIC *);
void  PrintGenericName(void *, char *, DEFGENERIC *);

//C     #endif /* _H_genrcfun */

//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _GENRCCOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           SetupGenericFunctions(void *);
void  SetupGenericFunctions(void *);
//C        LOCALE void                          *EnvFindDefgeneric(void *,const char *);
void * EnvFindDefgeneric(void *, char *);
//C        LOCALE void                          *EnvFindDefgenericInModule(void *,const char *);
void * EnvFindDefgenericInModule(void *, char *);
//C        LOCALE DEFGENERIC                    *LookupDefgenericByMdlOrScope(void *,const char *);
DEFGENERIC * LookupDefgenericByMdlOrScope(void *, char *);
//C        LOCALE DEFGENERIC                    *LookupDefgenericInScope(void *,const char *);
DEFGENERIC * LookupDefgenericInScope(void *, char *);
//C        LOCALE void                          *EnvGetNextDefgeneric(void *,void *);
void * EnvGetNextDefgeneric(void *, void *);
//C        LOCALE long                           EnvGetNextDefmethod(void *,void *,long);
int  EnvGetNextDefmethod(void *, void *, int );
//C        LOCALE int                            EnvIsDefgenericDeletable(void *,void *);
int  EnvIsDefgenericDeletable(void *, void *);
//C        LOCALE int                            EnvIsDefmethodDeletable(void *,void *,long);
int  EnvIsDefmethodDeletable(void *, void *, int );
//C        LOCALE void                           UndefgenericCommand(void *);
void  UndefgenericCommand(void *);
//C        LOCALE void                          *GetDefgenericModuleCommand(void *);
void * GetDefgenericModuleCommand(void *);
//C        LOCALE void                           UndefmethodCommand(void *);
void  UndefmethodCommand(void *);
//C        LOCALE DEFMETHOD                     *GetDefmethodPointer(void *,long);
DEFMETHOD * GetDefmethodPointer(void *, int );
//C        LOCALE intBool                        EnvUndefgeneric(void *,void *);
int  EnvUndefgeneric(void *, void *);
//C        LOCALE intBool                        EnvUndefmethod(void *,void *,long);
int  EnvUndefmethod(void *, void *, int );
//C     #if ! OBJECT_SYSTEM
//C        LOCALE void                           TypeCommand(void *,DATA_OBJECT *);
//C     #endif
//C     #if DEBUGGING_FUNCTIONS || PROFILING_FUNCTIONS
//C        LOCALE void                           EnvGetDefmethodDescription(void *,char *,size_t,void *,long);
void  EnvGetDefmethodDescription(void *, char *, size_t , void *, int );
//C     #endif
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       EnvGetDefgenericWatch(void *,void *);
uint  EnvGetDefgenericWatch(void *, void *);
//C        LOCALE void                           EnvSetDefgenericWatch(void *,unsigned,void *);
void  EnvSetDefgenericWatch(void *, uint , void *);
//C        LOCALE unsigned                       EnvGetDefmethodWatch(void *,void *,long);
uint  EnvGetDefmethodWatch(void *, void *, int );
//C        LOCALE void                           EnvSetDefmethodWatch(void *,unsigned,void *,long);
void  EnvSetDefmethodWatch(void *, uint , void *, int );
//C        LOCALE void                           PPDefgenericCommand(void *);
void  PPDefgenericCommand(void *);
//C        LOCALE void                           PPDefmethodCommand(void *);
void  PPDefmethodCommand(void *);
//C        LOCALE void                           ListDefmethodsCommand(void *);
void  ListDefmethodsCommand(void *);
//C        LOCALE const char                    *EnvGetDefmethodPPForm(void *,void *,long);
char * EnvGetDefmethodPPForm(void *, void *, int );
//C        LOCALE void                           ListDefgenericsCommand(void *);
void  ListDefgenericsCommand(void *);
//C        LOCALE void                           EnvListDefgenerics(void *,const char *,struct defmodule *);
void  EnvListDefgenerics(void *, char *, defmodule *);
//C        LOCALE void                           EnvListDefmethods(void *,const char *,void *);
void  EnvListDefmethods(void *, char *, void *);
//C     #endif
//C        LOCALE void                           GetDefgenericListFunction(void *,DATA_OBJECT *);
void  GetDefgenericListFunction(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvGetDefgenericList(void *,DATA_OBJECT *,struct defmodule *);
void  EnvGetDefgenericList(void *, DATA_OBJECT *, defmodule *);
//C        LOCALE void                           GetDefmethodListCommand(void *,DATA_OBJECT *);
void  GetDefmethodListCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvGetDefmethodList(void *,void *,DATA_OBJECT *);
void  EnvGetDefmethodList(void *, void *, DATA_OBJECT *);
//C        LOCALE void                           GetMethodRestrictionsCommand(void *,DATA_OBJECT *);
void  GetMethodRestrictionsCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           EnvGetMethodRestrictions(void *,void *,long,DATA_OBJECT *);
void  EnvGetMethodRestrictions(void *, void *, int , DATA_OBJECT *);
//C        LOCALE SYMBOL_HN                     *GetDefgenericNamePointer(void *);
SYMBOL_HN * GetDefgenericNamePointer(void *);
//C        LOCALE void                           SetNextDefgeneric(void *,void *);
void  SetNextDefgeneric(void *, void *);
//C        LOCALE const char                    *EnvDefgenericModule(void *,void *);
char * EnvDefgenericModule(void *, void *);
//C        LOCALE const char                    *EnvGetDefgenericName(void *,void *);
char * EnvGetDefgenericName(void *, void *);
//C        LOCALE const char                    *EnvGetDefgenericPPForm(void *,void *);
char * EnvGetDefgenericPPForm(void *, void *);
//C        LOCALE SYMBOL_HN                     *EnvGetDefgenericNamePointer(void *,void *);
SYMBOL_HN * EnvGetDefgenericNamePointer(void *, void *);
//C        LOCALE void                           EnvSetDefgenericPPForm(void *,void *,const char *);
void  EnvSetDefgenericPPForm(void *, void *, char *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           SetDefgenericPPForm(void *,const char *);
//C        LOCALE const char                    *DefgenericModule(void *);
//C        LOCALE void                          *FindDefgeneric(const char *);
//C        LOCALE void                           GetDefgenericList(DATA_OBJECT *,struct defmodule *);
//C        LOCALE const char                    *GetDefgenericName(void *);
//C        LOCALE const char                    *GetDefgenericPPForm(void *);
//C        LOCALE void                          *GetNextDefgeneric(void *);
//C        LOCALE int                            IsDefgenericDeletable(void *);
//C        LOCALE intBool                        Undefgeneric(void *);
//C        LOCALE void                           GetDefmethodList(void *,DATA_OBJECT_PTR);
//C        LOCALE void                           GetMethodRestrictions(void *,long,DATA_OBJECT *);
//C        LOCALE long                           GetNextDefmethod(void *,long );
//C        LOCALE int                            IsDefmethodDeletable(void *,long );
//C        LOCALE intBool                        Undefmethod(void *,long );
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned                       GetDefgenericWatch(void *);
//C        LOCALE void                           ListDefgenerics(const char *,struct defmodule *);
//C        LOCALE void                           SetDefgenericWatch(unsigned,void *);
//C        LOCALE const char                    *GetDefmethodPPForm(void *,long);
//C        LOCALE unsigned                       GetDefmethodWatch(void *,long);
//C        LOCALE void                           ListDefmethods(const char *,void *);
//C        LOCALE void                           SetDefmethodWatch(unsigned,void *,long);
//C     #endif /* DEBUGGING_FUNCTIONS */
//C     #if DEBUGGING_FUNCTIONS || PROFILING_FUNCTIONS
//C        LOCALE void                           GetDefmethodDescription(char *,int,void *,long );
//C     #endif /* DEBUGGING_FUNCTIONS || PROFILING_FUNCTIONS */

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_genrccom */





//C     #include "genrcfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Removed IMPERATIVE_METHODS compilation flag.   */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when DEBUGGING_FUNCTIONS   */
/*            is set to 0 and PROFILING_FUNCTIONS is set to  */
/*            1.                                             */
/*                                                           */
/*            Fixed typing issue when OBJECT_SYSTEM          */
/*            compiler flag is set to 0.                     */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_genrcfun
//C     #define _H_genrcfun

//C     typedef struct defgenericModule DEFGENERIC_MODULE;
//C     typedef struct restriction RESTRICTION;
//C     typedef struct method DEFMETHOD;
//C     typedef struct defgeneric DEFGENERIC;

//C     #ifndef _STDIO_INCLUDED_
//C     #define _STDIO_INCLUDED_
//C     #include <stdio.h>
//C     #endif

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #if OBJECT_SYSTEM
//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif
//C     #endif

//C     struct defgenericModule
//C       {
//C        struct defmoduleItemHeader header;
//C       };

//C     struct restriction
//C       {
//C        void **types;
//C        EXPRESSION *query;
//C        short tcnt;
//C       };

//C     struct method
//C       {
//C        short index;
//C        unsigned busy;
//C        short restrictionCount;
//C        short minRestrictions;
//C        short maxRestrictions;
//C        short localVarCount;
//C        unsigned system : 1;
//C        unsigned trace : 1;
//C        RESTRICTION *restrictions;
//C        EXPRESSION *actions;
//C        char *ppForm;
//C        struct userData *usrData;
//C       };

//C     struct defgeneric
//C       {
//C        struct constructHeader header;
//C        unsigned busy,trace;
//C        DEFMETHOD *methods;
//C        short mcnt;
//C        short new_index;
//C       };

//C     #define DEFGENERIC_DATA 27

//C     struct defgenericData
//C       { 
//C        struct construct *DefgenericConstruct;
//C        int DefgenericModuleIndex;
//C        ENTITY_RECORD GenericEntityRecord;
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchGenerics;
//C        unsigned WatchMethods;
//C     #endif
//C        DEFGENERIC *CurrentGeneric;
//C        DEFMETHOD *CurrentMethod;
//C        DATA_OBJECT *GenericCurrentArgument;
//C     #if (! RUN_TIME) && (! BLOAD_ONLY)
//C        unsigned OldGenericBusySave;
//C     #endif
//C     #if CONSTRUCT_COMPILER && (! RUN_TIME)
//C        struct CodeGeneratorItem *DefgenericCodeItem;
//C     #endif
//C     #if (! BLOAD_ONLY) && (! RUN_TIME)
//C        struct token GenericInputToken;
//C     #endif
//C       };

//C     #define DefgenericData(theEnv) ((struct defgenericData *) GetEnvironmentData(theEnv,DEFGENERIC_DATA))
//C     #define SaveBusyCount(gfunc)    (DefgenericData(theEnv)->OldGenericBusySave = gfunc->busy)
//C     #define RestoreBusyCount(gfunc) (gfunc->busy = DefgenericData(theEnv)->OldGenericBusySave)

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _GENRCFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C     #if ! RUN_TIME
//C        LOCALE intBool                        ClearDefgenericsReady(void *);
//C        LOCALE void                          *AllocateDefgenericModule(void *);
//C        LOCALE void                           FreeDefgenericModule(void *,void *);
//C     #endif

//C     #if (! BLOAD_ONLY) && (! RUN_TIME)

//C        LOCALE int                            ClearDefmethods(void *);
//C        LOCALE int                            RemoveAllExplicitMethods(void *,DEFGENERIC *);
//C        LOCALE void                           RemoveDefgeneric(void *,void *);
//C        LOCALE int                            ClearDefgenerics(void *);
//C        LOCALE void                           MethodAlterError(void *,DEFGENERIC *);
//C        LOCALE void                           DeleteMethodInfo(void *,DEFGENERIC *,DEFMETHOD *);
//C        LOCALE void                           DestroyMethodInfo(void *,DEFGENERIC *,DEFMETHOD *);
//C        LOCALE int                            MethodsExecuting(DEFGENERIC *);
//C     #endif
//C     #if ! OBJECT_SYSTEM
//C        LOCALE intBool                        SubsumeType(int,int);
//C     #endif

//C        LOCALE long                           FindMethodByIndex(DEFGENERIC *,long);
//C     #if DEBUGGING_FUNCTIONS || PROFILING_FUNCTIONS
//C        LOCALE void                           PrintMethod(void *,char *,size_t,DEFMETHOD *);
//C     #endif
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           PreviewGeneric(void *);
//C     #endif
//C        LOCALE DEFGENERIC                    *CheckGenericExists(void *,const char *,const char *);
//C        LOCALE long                           CheckMethodExists(void *,const char *,DEFGENERIC *,long);

//C     #if ! OBJECT_SYSTEM
//C        LOCALE const char                    *TypeName(void *,int);
//C     #endif

//C        LOCALE void                           PrintGenericName(void *,const char *,DEFGENERIC *);

//C     #endif /* _H_genrcfun */

//C     #endif

//C     #if OBJECT_SYSTEM
//C     #include "classcom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  01/04/15          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_classcom
//C     #define _H_classcom

//C     #define CONVENIENCE_MODE  0
//C     #define CONSERVATION_MODE 1
const CONVENIENCE_MODE = 0;

const CONSERVATION_MODE = 1;
//C     #ifndef _H_cstrccom
//C     #include "cstrccom.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CLASSCOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE const char             *EnvGetDefclassName(void *,void *);
char * EnvGetDefclassName(void *, void *);
//C        LOCALE const char             *EnvGetDefclassPPForm(void *,void *);
char * EnvGetDefclassPPForm(void *, void *);
//C        LOCALE struct defmoduleItemHeader 
//C                                      *EnvGetDefclassModule(void *,void *);
defmoduleItemHeader * EnvGetDefclassModule(void *, void *);
//C        LOCALE const char             *EnvDefclassModule(void *,void *);
char * EnvDefclassModule(void *, void *);
//C        LOCALE SYMBOL_HN              *GetDefclassNamePointer(void *);
SYMBOL_HN * GetDefclassNamePointer(void *);
//C        LOCALE void                    SetNextDefclass(void *,void *);
void  SetNextDefclass(void *, void *);
//C        LOCALE void                    EnvSetDefclassPPForm(void *,void *,char *);
void  EnvSetDefclassPPForm(void *, void *, char *);

//C        LOCALE void                   *EnvFindDefclass(void *,const char *);
void * EnvFindDefclass(void *, char *);
//C        LOCALE void                   *EnvFindDefclassInModule(void *,const char *);
void * EnvFindDefclassInModule(void *, char *);
//C        LOCALE DEFCLASS               *LookupDefclassByMdlOrScope(void *,const char *);
DEFCLASS * LookupDefclassByMdlOrScope(void *, char *);
//C        LOCALE DEFCLASS               *LookupDefclassInScope(void *,const char *);
DEFCLASS * LookupDefclassInScope(void *, char *);
//C        LOCALE DEFCLASS               *LookupDefclassAnywhere(void *,struct defmodule *,const char *);
DEFCLASS * LookupDefclassAnywhere(void *, defmodule *, char *);
//C        LOCALE intBool                 DefclassInScope(void *,DEFCLASS *,struct defmodule *);
int  DefclassInScope(void *, DEFCLASS *, defmodule *);
//C        LOCALE void                   *EnvGetNextDefclass(void *,void *);
void * EnvGetNextDefclass(void *, void *);
//C        LOCALE intBool                 EnvIsDefclassDeletable(void *,void *);
int  EnvIsDefclassDeletable(void *, void *);

//C        LOCALE void                    UndefclassCommand(void *);
void  UndefclassCommand(void *);
//C        LOCALE unsigned short          EnvSetClassDefaultsMode(void *,unsigned short);
ushort  EnvSetClassDefaultsMode(void *, ushort );
//C        LOCALE unsigned short          EnvGetClassDefaultsMode(void *);
ushort  EnvGetClassDefaultsMode(void *);
//C        LOCALE void                   *GetClassDefaultsModeCommand(void *);
void * GetClassDefaultsModeCommand(void *);
//C        LOCALE void                   *SetClassDefaultsModeCommand(void *);
void * SetClassDefaultsModeCommand(void *);

//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                    PPDefclassCommand(void *);
void  PPDefclassCommand(void *);
//C        LOCALE void                    ListDefclassesCommand(void *);
void  ListDefclassesCommand(void *);
//C        LOCALE void                    EnvListDefclasses(void *,const char *,struct defmodule *);
void  EnvListDefclasses(void *, char *, defmodule *);
//C        LOCALE unsigned                EnvGetDefclassWatchInstances(void *,void *);
uint  EnvGetDefclassWatchInstances(void *, void *);
//C        LOCALE void                    EnvSetDefclassWatchInstances(void *,unsigned,void *);
void  EnvSetDefclassWatchInstances(void *, uint , void *);
//C        LOCALE unsigned                EnvGetDefclassWatchSlots(void *,void *);
uint  EnvGetDefclassWatchSlots(void *, void *);
//C        LOCALE void                    EnvSetDefclassWatchSlots(void *,unsigned,void *);
void  EnvSetDefclassWatchSlots(void *, uint , void *);
//C        LOCALE unsigned                DefclassWatchAccess(void *,int,unsigned,EXPRESSION *);
uint  DefclassWatchAccess(void *, int , uint , EXPRESSION *);
//C        LOCALE unsigned                DefclassWatchPrint(void *,const char *,int,EXPRESSION *);
uint  DefclassWatchPrint(void *, char *, int , EXPRESSION *);
//C     #endif

//C        LOCALE void                    GetDefclassListFunction(void *,DATA_OBJECT *);
void  GetDefclassListFunction(void *, DATA_OBJECT *);
//C        LOCALE void                    EnvGetDefclassList(void *,DATA_OBJECT *,struct defmodule *);
void  EnvGetDefclassList(void *, DATA_OBJECT *, defmodule *);
//C        LOCALE intBool                 EnvUndefclass(void *,void *);
int  EnvUndefclass(void *, void *);
//C        LOCALE intBool                 HasSuperclass(DEFCLASS *,DEFCLASS *);
int  HasSuperclass(DEFCLASS *, DEFCLASS *);

//C        LOCALE SYMBOL_HN              *CheckClassAndSlot(void *,const char *,DEFCLASS **);
SYMBOL_HN * CheckClassAndSlot(void *, char *, DEFCLASS **);

//C     #if (! BLOAD_ONLY) && (! RUN_TIME)
//C        LOCALE void                    SaveDefclasses(void *,void *,const char *);
void  SaveDefclasses(void *, void *, char *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE const char             *DefclassModule(void *);
//C        LOCALE void                   *FindDefclass(const char *);
//C        LOCALE void                    GetDefclassList(DATA_OBJECT *,struct defmodule *);
//C        LOCALE unsigned short          GetClassDefaultsMode(void);
//C        LOCALE struct defmoduleItemHeader 
//C                                      *GetDefclassModule(void *);
//C        LOCALE const char             *GetDefclassName(void *);
//C        LOCALE const char             *GetDefclassPPForm(void *);
//C        LOCALE unsigned                GetDefclassWatchInstances(void *);
//C        LOCALE unsigned                GetDefclassWatchSlots(void *);
//C        LOCALE void                   *GetNextDefclass(void *);
//C        LOCALE intBool                 IsDefclassDeletable(void *);
//C        LOCALE void                    ListDefclasses(const char *,struct defmodule *);
//C        LOCALE unsigned short          SetClassDefaultsMode(unsigned short);
//C        LOCALE void                    SetDefclassWatchInstances(unsigned,void *);
//C        LOCALE void                    SetDefclassWatchSlots(unsigned,void *);
//C        LOCALE intBool                 Undefclass(void *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_classcom */
//C     #include "classexm.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
                                      
/*      6.24: The DescribeClass macros were incorrectly      */
/*            defined. DR0862                                */
/*                                                           */
/*            Added allowed-classes slot facet.              */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Added EnvSlotDefaultP function.                */
/*                                                           */
/*            Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Used gensprintf and genstrcat instead of       */
/*            sprintf and strcat.                            */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_classexm
//C     #define _H_classexm

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CLASSEXM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #if DEBUGGING_FUNCTIONS

//C        LOCALE void                           BrowseClassesCommand(void *);
void  BrowseClassesCommand(void *);
//C        LOCALE void                           EnvBrowseClasses(void *,const char *,void *);
void  EnvBrowseClasses(void *, char *, void *);
//C        LOCALE void                           DescribeClassCommand(void *);
void  DescribeClassCommand(void *);
//C        LOCALE void                           EnvDescribeClass(void *,const char *,void *);
void  EnvDescribeClass(void *, char *, void *);

//C     #endif /* DEBUGGING_FUNCTIONS */

//C        LOCALE const char                    *GetCreateAccessorString(void *);
char * GetCreateAccessorString(void *);
//C        LOCALE void                          *GetDefclassModuleCommand(void *);
void * GetDefclassModuleCommand(void *);
//C        LOCALE intBool                        SuperclassPCommand(void *);
int  SuperclassPCommand(void *);
//C        LOCALE intBool                        EnvSuperclassP(void *,void *,void *);
int  EnvSuperclassP(void *, void *, void *);
//C        LOCALE intBool                        SubclassPCommand(void *);
int  SubclassPCommand(void *);
//C        LOCALE intBool                        EnvSubclassP(void *,void *,void *);
int  EnvSubclassP(void *, void *, void *);
//C        LOCALE int                            SlotExistPCommand(void *);
int  SlotExistPCommand(void *);
//C        LOCALE intBool                        EnvSlotExistP(void *,void *,const char *,intBool);
int  EnvSlotExistP(void *, void *, char *, int );
//C        LOCALE int                            MessageHandlerExistPCommand(void *);
int  MessageHandlerExistPCommand(void *);
//C        LOCALE intBool                        SlotWritablePCommand(void *);
int  SlotWritablePCommand(void *);
//C        LOCALE intBool                        EnvSlotWritableP(void *,void *,const char *);
int  EnvSlotWritableP(void *, void *, char *);
//C        LOCALE intBool                        SlotInitablePCommand(void *);
int  SlotInitablePCommand(void *);
//C        LOCALE intBool                        EnvSlotInitableP(void *,void *,const char *);
int  EnvSlotInitableP(void *, void *, char *);
//C        LOCALE intBool                        SlotPublicPCommand(void *);
int  SlotPublicPCommand(void *);
//C        LOCALE intBool                        EnvSlotPublicP(void *,void *,const char *);
int  EnvSlotPublicP(void *, void *, char *);
//C        LOCALE intBool                        SlotDirectAccessPCommand(void *);
int  SlotDirectAccessPCommand(void *);
//C        LOCALE intBool                        EnvSlotDirectAccessP(void *,void *,const char *);
int  EnvSlotDirectAccessP(void *, void *, char *);
//C        LOCALE void                           SlotDefaultValueCommand(void *,DATA_OBJECT_PTR);
void  SlotDefaultValueCommand(void *, DATA_OBJECT_PTR );
//C        LOCALE intBool                        EnvSlotDefaultValue(void *,void *,const char *,DATA_OBJECT_PTR);
int  EnvSlotDefaultValue(void *, void *, char *, DATA_OBJECT_PTR );
//C        LOCALE int                            ClassExistPCommand(void *);
int  ClassExistPCommand(void *);
//C        LOCALE int                            EnvSlotDefaultP(void *,void *,const char *);
int  EnvSlotDefaultP(void *, void *, char *);
  
//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           BrowseClasses(const char *,void *);
//C        LOCALE void                           DescribeClass(const char *,void *);
//C     #endif
//C        LOCALE intBool                        SlotDirectAccessP(void *,const char *);
//C        LOCALE intBool                        SlotExistP(void *,const char *,intBool);
//C        LOCALE intBool                        SlotInitableP(void *,const char *);
//C        LOCALE intBool                        SlotPublicP(void *,const char *);
//C        LOCALE int                            SlotDefaultP(void *,const char *);
//C        LOCALE intBool                        SlotWritableP(void *,const char *);
//C        LOCALE intBool                        SubclassP(void *,void *);
//C        LOCALE intBool                        SuperclassP(void *,void *);
//C        LOCALE intBool                        SlotDefaultValue(void *,const char *,DATA_OBJECT_PTR);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_classexm */
//C     #include "classinf.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                            */
/*      6.24: Added allowed-classes slot facet.              */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_classinf
//C     #define _H_classinf

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CLASSINF_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE intBool                        ClassAbstractPCommand(void *);
int  ClassAbstractPCommand(void *);
//C     #if DEFRULE_CONSTRUCT
//C        LOCALE intBool                        ClassReactivePCommand(void *);
int  ClassReactivePCommand(void *);
//C     #endif
//C        LOCALE void                          *ClassInfoFnxArgs(void *,const char *,int *);
void * ClassInfoFnxArgs(void *, char *, int *);
//C        LOCALE void                           ClassSlotsCommand(void *,DATA_OBJECT *);
void  ClassSlotsCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           ClassSuperclassesCommand(void *,DATA_OBJECT *);
void  ClassSuperclassesCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           ClassSubclassesCommand(void *,DATA_OBJECT *);
void  ClassSubclassesCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           GetDefmessageHandlersListCmd(void *,DATA_OBJECT *);
void  GetDefmessageHandlersListCmd(void *, DATA_OBJECT *);
//C        LOCALE void                           SlotFacetsCommand(void *,DATA_OBJECT *);
void  SlotFacetsCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           SlotSourcesCommand(void *,DATA_OBJECT *);
void  SlotSourcesCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           SlotTypesCommand(void *,DATA_OBJECT *);
void  SlotTypesCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           SlotAllowedValuesCommand(void *,DATA_OBJECT *);
void  SlotAllowedValuesCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           SlotAllowedClassesCommand(void *,DATA_OBJECT *);
void  SlotAllowedClassesCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           SlotRangeCommand(void *,DATA_OBJECT *);
void  SlotRangeCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           SlotCardinalityCommand(void *,DATA_OBJECT *);
void  SlotCardinalityCommand(void *, DATA_OBJECT *);
//C        LOCALE intBool                        EnvClassAbstractP(void *,void *);
int  EnvClassAbstractP(void *, void *);
//C     #if DEFRULE_CONSTRUCT
//C        LOCALE intBool                        EnvClassReactiveP(void *,void *);
int  EnvClassReactiveP(void *, void *);
//C     #endif
//C        LOCALE void                           EnvClassSlots(void *,void *,DATA_OBJECT *,int);
void  EnvClassSlots(void *, void *, DATA_OBJECT *, int );
//C        LOCALE void                           EnvGetDefmessageHandlerList(void *,void *,DATA_OBJECT *,int);
void  EnvGetDefmessageHandlerList(void *, void *, DATA_OBJECT *, int );
//C        LOCALE void                           EnvClassSuperclasses(void *,void *,DATA_OBJECT *,int);
void  EnvClassSuperclasses(void *, void *, DATA_OBJECT *, int );
//C        LOCALE void                           EnvClassSubclasses(void *,void *,DATA_OBJECT *,int);
void  EnvClassSubclasses(void *, void *, DATA_OBJECT *, int );
//C        LOCALE void                           ClassSubclassAddresses(void *,void *,DATA_OBJECT *,int);
void  ClassSubclassAddresses(void *, void *, DATA_OBJECT *, int );
//C        LOCALE void                           EnvSlotFacets(void *,void *,const char *,DATA_OBJECT *);
void  EnvSlotFacets(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           EnvSlotSources(void *,void *,const char *,DATA_OBJECT *);
void  EnvSlotSources(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           EnvSlotTypes(void *,void *,const char *,DATA_OBJECT *);
void  EnvSlotTypes(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           EnvSlotAllowedValues(void *,void *,const char *,DATA_OBJECT *);
void  EnvSlotAllowedValues(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           EnvSlotAllowedClasses(void *,void *,const char *,DATA_OBJECT *);
void  EnvSlotAllowedClasses(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           EnvSlotRange(void *,void *,const char *,DATA_OBJECT *);
void  EnvSlotRange(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE void                           EnvSlotCardinality(void *,void *,const char *,DATA_OBJECT *);
void  EnvSlotCardinality(void *, void *, char *, DATA_OBJECT *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE intBool                        ClassAbstractP(void *);
//C     #if DEFRULE_CONSTRUCT
//C        LOCALE intBool                        ClassReactiveP(void *);
//C     #endif
//C        LOCALE void                           ClassSlots(void *,DATA_OBJECT *,int);
//C        LOCALE void                           ClassSubclasses(void *,DATA_OBJECT *,int);
//C        LOCALE void                           ClassSuperclasses(void *,DATA_OBJECT *,int);
//C        LOCALE void                           SlotAllowedValues(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           SlotAllowedClasses(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           SlotCardinality(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           SlotFacets(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           SlotRange(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           SlotSources(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           SlotTypes(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                           GetDefmessageHandlerList(void *,DATA_OBJECT *,int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_classinf */





//C     #include "classini.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Added allowed-classes slot facet.              */
/*                                                           */
/*            Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warning.                              */
/*                                                           */
/*      6.30: Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Support for hashed alpha memories.             */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_classini
//C     #define _H_classini

//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif

//C     #if OBJECT_SYSTEM

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CLASSINI_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     LOCALE void SetupObjectSystem(void *);
void  SetupObjectSystem(void *);
//C     #if RUN_TIME
//C     LOCALE void ObjectsRunTimeInitialize(void *,DEFCLASS *[],SLOT_NAME *[],DEFCLASS *[],unsigned);
//C     #else
//C     LOCALE void CreateSystemClasses(void *);
void  CreateSystemClasses(void *);
//C     #endif

//C     #endif

//C     #endif





//C     #include "classpsr.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added allowed-classes slot facet.               */
/*                                                            */
/*            Converted INSTANCE_PATTERN_MATCHING to          */
/*            DEFRULE_CONSTRUCT.                              */
/*                                                            */
/*            Renamed BOOLEAN macro type to intBool.          */
/*                                                            */
/*      6.30: Added support to allow CreateClassScopeMap to   */
/*            be used by other functions.                     */
/*                                                            */
/*            Changed integer type/precision.                 */
/*                                                            */
/*            GetConstructNameAndComment API change.          */
/*                                                            */
/*            Added const qualifiers to remove C++            */
/*            deprecation warnings.                           */
/*                                                            */
/*            Converted API macros to function calls.         */
/*                                                            */
/*************************************************************/

//C     #ifndef _H_classpsr
//C     #define _H_classpsr

//C     #if OBJECT_SYSTEM && (! BLOAD_ONLY) && (! RUN_TIME)

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _CLASSPSR_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     LOCALE int ParseDefclass(void *,const char *);
int  ParseDefclass(void *, char *);

//C     #if DEFMODULE_CONSTRUCT
//C     LOCALE void *CreateClassScopeMap(void *,DEFCLASS *);
void * CreateClassScopeMap(void *, DEFCLASS *);
//C     #endif

//C     #endif

//C     #endif



//C     #include "defins.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  02/04/15          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            GetConstructNameAndComment API change.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_defins
//C     #define _H_defins

//C     #if DEFINSTANCES_CONSTRUCT

//C     struct definstances;

//C     #ifndef _H_conscomp
//C     #include "conscomp.h"
//C     #endif
//C     #ifndef _H_constrct
//C     #include "constrct.h"
//C     #endif
//C     #ifndef _H_cstrccom
//C     #include "cstrccom.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif

//C     typedef struct definstancesModule
//C       {
//C        struct defmoduleItemHeader header;
//C       } DEFINSTANCES_MODULE;
struct definstancesModule
{
    defmoduleItemHeader header;
}
alias definstancesModule DEFINSTANCES_MODULE;

//C     typedef struct definstances
//C       {
//C        struct constructHeader header;
//C        unsigned busy;
//C        EXPRESSION *mkinstance;
//C       } DEFINSTANCES;
struct definstances
{
    constructHeader header;
    uint busy;
    EXPRESSION *mkinstance;
}
alias definstances DEFINSTANCES;

//C     #define DEFINSTANCES_DATA 22

const DEFINSTANCES_DATA = 22;
//C     struct definstancesData
//C       { 
//C        struct construct *DefinstancesConstruct;
//C        int DefinstancesModuleIndex;
//C     #if CONSTRUCT_COMPILER && (! RUN_TIME)
//C        struct CodeGeneratorItem *DefinstancesCodeItem;
//C     #endif
//C       };
struct definstancesData
{
    construct *DefinstancesConstruct;
    int DefinstancesModuleIndex;
    CodeGeneratorItem *DefinstancesCodeItem;
}

//C     #define DefinstancesData(theEnv) ((struct definstancesData *) GetEnvironmentData(theEnv,DEFINSTANCES_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _DEFINS_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE const char                    *EnvDefinstancesModule(void *,void *);
char * EnvDefinstancesModule(void *, void *);
//C        LOCALE const char                    *EnvDefinstancesModuleName(void *,void *);
char * EnvDefinstancesModuleName(void *, void *);
//C        LOCALE void                          *EnvFindDefinstances(void *,const char *);
void * EnvFindDefinstances(void *, char *);
//C        LOCALE void                          *EnvFindDefinstancesInModule(void *,const char *);
void * EnvFindDefinstancesInModule(void *, char *);
//C        LOCALE void                           EnvGetDefinstancesList(void *,DATA_OBJECT *,struct defmodule *);
void  EnvGetDefinstancesList(void *, DATA_OBJECT *, defmodule *);
//C        LOCALE const char                    *EnvGetDefinstancesName(void *,void *);
char * EnvGetDefinstancesName(void *, void *);
//C        LOCALE SYMBOL_HN                     *EnvGetDefinstancesNamePointer(void *,void *);
SYMBOL_HN * EnvGetDefinstancesNamePointer(void *, void *);
//C        LOCALE const char                    *EnvGetDefinstancesPPForm(void *,void *);
char * EnvGetDefinstancesPPForm(void *, void *);
//C        LOCALE void                          *EnvGetNextDefinstances(void *,void *);
void * EnvGetNextDefinstances(void *, void *);
//C        LOCALE int                            EnvIsDefinstancesDeletable(void *,void *);
int  EnvIsDefinstancesDeletable(void *, void *);
//C        LOCALE void                           EnvSetDefinstancesPPForm(void *,void *,const char *);
void  EnvSetDefinstancesPPForm(void *, void *, char *);
//C        LOCALE intBool                        EnvUndefinstances(void *,void *);
int  EnvUndefinstances(void *, void *);
//C        LOCALE void                           GetDefinstancesListFunction(void *,DATA_OBJECT *);
void  GetDefinstancesListFunction(void *, DATA_OBJECT *);
//C        LOCALE void                          *GetDefinstancesModuleCommand(void *);
void * GetDefinstancesModuleCommand(void *);
//C        LOCALE void                           SetupDefinstances(void *);
void  SetupDefinstances(void *);
//C        LOCALE void                           UndefinstancesCommand(void *);
void  UndefinstancesCommand(void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           PPDefinstancesCommand(void *);
void  PPDefinstancesCommand(void *);
//C        LOCALE void                           ListDefinstancesCommand(void *);
void  ListDefinstancesCommand(void *);
//C        LOCALE void                           EnvListDefinstances(void *,const char *,struct defmodule *);
void  EnvListDefinstances(void *, char *, defmodule *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE const char                    *DefinstancesModule(void *);
//C        LOCALE void                          *FindDefinstances(const char *);
//C        LOCALE void                           GetDefinstancesList(DATA_OBJECT *,struct defmodule *);
//C        LOCALE const char                    *GetDefinstancesName(void *);
//C        LOCALE const char                    *GetDefinstancesPPForm(void *);
//C        LOCALE void                          *GetNextDefinstances(void *);
//C        LOCALE int                            IsDefinstancesDeletable(void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           ListDefinstances(const char *,struct defmodule *);
//C     #endif
//C        LOCALE intBool                        Undefinstances(void *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* DEFINSTANCES_CONSTRUCT */

//C     #endif /* _H_defins */




//C     #include "inscom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/22/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Loading a binary instance file from a run-time */
/*            program caused a bus error. DR0866             */
/*                                                           */
/*            Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_inscom
//C     #define _H_inscom

//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif

//C     #ifndef _H_insfun
//C     #include "insfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                INSTANCE FUNCTIONS MODULE            */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*            Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Link error occurs for the SlotExistError       */
/*            function when OBJECT_SYSTEM is set to 0 in     */
/*            setup.h. DR0865                                */
/*                                                           */
/*            Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Moved EvaluateAndStoreInDataObject to          */
/*            evaluatn.c                                     */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed slot override default ?NONE bug.         */
/*                                                           */
//*************************************************************/

//C     #ifndef _H_insfun
//C     #define _H_insfun

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif

//C     #ifndef _H_pattern
//C     #include "pattern.h"
//C     #endif

//C     typedef struct igarbage
//C       {
//C        INSTANCE_TYPE *ins;
//C        struct igarbage *nxt;
//C       } IGARBAGE;
struct igarbage
{
    INSTANCE_TYPE *ins;
    igarbage *nxt;
}
alias igarbage IGARBAGE;

//C     #define INSTANCE_TABLE_HASH_SIZE 8191
//C     #define InstanceSizeHeuristic(ins)      sizeof(INSTANCE_TYPE)
const INSTANCE_TABLE_HASH_SIZE = 8191;

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _INSFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           EnvIncrementInstanceCount(void *,void *);
void  EnvIncrementInstanceCount(void *, void *);
//C        LOCALE void                           EnvDecrementInstanceCount(void *,void *);
void  EnvDecrementInstanceCount(void *, void *);
//C        LOCALE void                           InitializeInstanceTable(void *);
void  InitializeInstanceTable(void *);
//C        LOCALE void                           CleanupInstances(void *);
void  CleanupInstances(void *);
//C        LOCALE unsigned                       HashInstance(SYMBOL_HN *);
uint  HashInstance(SYMBOL_HN *);
//C        LOCALE void                           DestroyAllInstances(void *);
void  DestroyAllInstances(void *);
//C        LOCALE void                           RemoveInstanceData(void *,INSTANCE_TYPE *);
void  RemoveInstanceData(void *, INSTANCE_TYPE *);
//C        LOCALE INSTANCE_TYPE                 *FindInstanceBySymbol(void *,SYMBOL_HN *);
INSTANCE_TYPE * FindInstanceBySymbol(void *, SYMBOL_HN *);
//C        LOCALE INSTANCE_TYPE                 *FindInstanceInModule(void *,SYMBOL_HN *,struct defmodule *,
//C                                                struct defmodule *,unsigned);
INSTANCE_TYPE * FindInstanceInModule(void *, SYMBOL_HN *, defmodule *, defmodule *, uint );
//C        LOCALE INSTANCE_SLOT                 *FindInstanceSlot(void *,INSTANCE_TYPE *,SYMBOL_HN *);
INSTANCE_SLOT * FindInstanceSlot(void *, INSTANCE_TYPE *, SYMBOL_HN *);
//C        LOCALE int                            FindInstanceTemplateSlot(void *,DEFCLASS *,SYMBOL_HN *);
int  FindInstanceTemplateSlot(void *, DEFCLASS *, SYMBOL_HN *);
//C        LOCALE int                            PutSlotValue(void *,INSTANCE_TYPE *,INSTANCE_SLOT *,DATA_OBJECT *,DATA_OBJECT *,const char *);
int  PutSlotValue(void *, INSTANCE_TYPE *, INSTANCE_SLOT *, DATA_OBJECT *, DATA_OBJECT *, char *);
//C        LOCALE int                            DirectPutSlotValue(void *,INSTANCE_TYPE *,INSTANCE_SLOT *,DATA_OBJECT *,DATA_OBJECT *);
int  DirectPutSlotValue(void *, INSTANCE_TYPE *, INSTANCE_SLOT *, DATA_OBJECT *, DATA_OBJECT *);
//C        LOCALE intBool                        ValidSlotValue(void *,DATA_OBJECT *,SLOT_DESC *,INSTANCE_TYPE *,const char *);
int  ValidSlotValue(void *, DATA_OBJECT *, SLOT_DESC *, INSTANCE_TYPE *, char *);
//C        LOCALE INSTANCE_TYPE                 *CheckInstance(void *,const char *);
INSTANCE_TYPE * CheckInstance(void *, char *);
//C        LOCALE void                           NoInstanceError(void *,const char *,const char *);
void  NoInstanceError(void *, char *, char *);
//C        LOCALE void                           StaleInstanceAddress(void *,const char *,int);
void  StaleInstanceAddress(void *, char *, int );
//C        LOCALE int                            EnvGetInstancesChanged(void *);
int  EnvGetInstancesChanged(void *);
//C        LOCALE void                           EnvSetInstancesChanged(void *,int);
void  EnvSetInstancesChanged(void *, int );
//C        LOCALE void                           PrintSlot(void *,const char *,SLOT_DESC *,INSTANCE_TYPE *,const char *);
void  PrintSlot(void *, char *, SLOT_DESC *, INSTANCE_TYPE *, char *);
//C        LOCALE void                           PrintInstanceNameAndClass(void *,const char *,INSTANCE_TYPE *,intBool);
void  PrintInstanceNameAndClass(void *, char *, INSTANCE_TYPE *, int );
//C        LOCALE void                           PrintInstanceName(void *,const char *,void *);
void  PrintInstanceName(void *, char *, void *);
//C        LOCALE void                           PrintInstanceLongForm(void *,const char *,void *);
void  PrintInstanceLongForm(void *, char *, void *);
//C     #if DEFRULE_CONSTRUCT && OBJECT_SYSTEM
//C        LOCALE void                           DecrementObjectBasisCount(void *,void *);
void  DecrementObjectBasisCount(void *, void *);
//C        LOCALE void                           IncrementObjectBasisCount(void *,void *);
void  IncrementObjectBasisCount(void *, void *);
//C        LOCALE void                           MatchObjectFunction(void *,void *);
void  MatchObjectFunction(void *, void *);
//C        LOCALE intBool                        NetworkSynchronized(void *,void *);
int  NetworkSynchronized(void *, void *);
//C        LOCALE intBool                        InstanceIsDeleted(void *,void *);
int  InstanceIsDeleted(void *, void *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           DecrementInstanceCount(void *);
//C        LOCALE int                            GetInstancesChanged(void);
//C        LOCALE void                           IncrementInstanceCount(void *);
//C        LOCALE void                           SetInstancesChanged(int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_insfun */







//C     #endif

//C     #define INSTANCE_DATA 29

const INSTANCE_DATA = 29;
//C     struct instanceData
//C       { 
//C        INSTANCE_TYPE DummyInstance;
//C        INSTANCE_TYPE **InstanceTable;
//C        int MaintainGarbageInstances;
//C        int MkInsMsgPass;
//C        int ChangesToInstances;
//C        IGARBAGE *InstanceGarbageList;
//C        struct patternEntityRecord InstanceInfo;
//C        INSTANCE_TYPE *InstanceList;  
//C        unsigned long GlobalNumberOfInstances;
//C        INSTANCE_TYPE *CurrentInstance;
//C        INSTANCE_TYPE *InstanceListBottom;
//C        intBool ObjectModDupMsgValid;
//C       };
struct instanceData
{
    INSTANCE_TYPE DummyInstance;
    INSTANCE_TYPE **InstanceTable;
    int MaintainGarbageInstances;
    int MkInsMsgPass;
    int ChangesToInstances;
    IGARBAGE *InstanceGarbageList;
    patternEntityRecord InstanceInfo;
    INSTANCE_TYPE *InstanceList;
    uint GlobalNumberOfInstances;
    INSTANCE_TYPE *CurrentInstance;
    INSTANCE_TYPE *InstanceListBottom;
    int ObjectModDupMsgValid;
}

//C     #define InstanceData(theEnv) ((struct instanceData *) GetEnvironmentData(theEnv,INSTANCE_DATA))

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _INSCOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           SetupInstances(void *);
void  SetupInstances(void *);
//C        LOCALE intBool                        EnvDeleteInstance(void *,void *);
int  EnvDeleteInstance(void *, void *);
//C        LOCALE intBool                        EnvUnmakeInstance(void *,void *);
int  EnvUnmakeInstance(void *, void *);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                           InstancesCommand(void *);
void  InstancesCommand(void *);
//C        LOCALE void                           PPInstanceCommand(void *);
void  PPInstanceCommand(void *);
//C        LOCALE void                           EnvInstances(void *,const char *,void *,const char *,int);
void  EnvInstances(void *, char *, void *, char *, int );
//C     #endif
//C        LOCALE void                          *EnvMakeInstance(void *,const char *);
void * EnvMakeInstance(void *, char *);
//C        LOCALE void                          *EnvCreateRawInstance(void *,void *,const char *);
void * EnvCreateRawInstance(void *, void *, char *);
//C        LOCALE void                          *EnvFindInstance(void *,void *,const char *,unsigned);
void * EnvFindInstance(void *, void *, char *, uint );
//C        LOCALE int                            EnvValidInstanceAddress(void *,void *);
int  EnvValidInstanceAddress(void *, void *);
//C        LOCALE void                           EnvDirectGetSlot(void *,void *,const char *,DATA_OBJECT *);
void  EnvDirectGetSlot(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE int                            EnvDirectPutSlot(void *,void *,const char *,DATA_OBJECT *);
int  EnvDirectPutSlot(void *, void *, char *, DATA_OBJECT *);
//C        LOCALE const char                    *EnvGetInstanceName(void *,void *);
char * EnvGetInstanceName(void *, void *);
//C        LOCALE void                          *EnvGetInstanceClass(void *,void *);
void * EnvGetInstanceClass(void *, void *);
//C        LOCALE unsigned long GetGlobalNumberOfInstances(void *);
uint  GetGlobalNumberOfInstances(void *);
//C        LOCALE void                          *EnvGetNextInstance(void *,void *);
void * EnvGetNextInstance(void *, void *);
//C        LOCALE void                          *GetNextInstanceInScope(void *,void *);
void * GetNextInstanceInScope(void *, void *);
//C        LOCALE void                          *EnvGetNextInstanceInClass(void *,void *,void *);
void * EnvGetNextInstanceInClass(void *, void *, void *);
//C        LOCALE void                          *EnvGetNextInstanceInClassAndSubclasses(void *,void **,void *,DATA_OBJECT *);
void * EnvGetNextInstanceInClassAndSubclasses(void *, void **, void *, DATA_OBJECT *);
//C        LOCALE void                           EnvGetInstancePPForm(void *,char *,size_t,void *);
void  EnvGetInstancePPForm(void *, char *, size_t , void *);
//C        LOCALE void                           ClassCommand(void *,DATA_OBJECT *);
void  ClassCommand(void *, DATA_OBJECT *);
//C        LOCALE intBool                        DeleteInstanceCommand(void *);
int  DeleteInstanceCommand(void *);
//C        LOCALE intBool                        UnmakeInstanceCommand(void *);
int  UnmakeInstanceCommand(void *);
//C        LOCALE void                           SymbolToInstanceName(void *,DATA_OBJECT *);
void  SymbolToInstanceName(void *, DATA_OBJECT *);
//C        LOCALE void                          *InstanceNameToSymbol(void *);
void * InstanceNameToSymbol(void *);
//C        LOCALE void                           InstanceAddressCommand(void *,DATA_OBJECT *);
void  InstanceAddressCommand(void *, DATA_OBJECT *);
//C        LOCALE void                           InstanceNameCommand(void *,DATA_OBJECT *);
void  InstanceNameCommand(void *, DATA_OBJECT *);
//C        LOCALE intBool                        InstanceAddressPCommand(void *);
int  InstanceAddressPCommand(void *);
//C        LOCALE intBool                        InstanceNamePCommand(void *);
int  InstanceNamePCommand(void *);
//C        LOCALE intBool                        InstancePCommand(void *);
int  InstancePCommand(void *);
//C        LOCALE intBool                        InstanceExistPCommand(void *);
int  InstanceExistPCommand(void *);
//C        LOCALE intBool                        CreateInstanceHandler(void *);
int  CreateInstanceHandler(void *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE const char                    *GetInstanceName(void *);
//C        LOCALE void                          *CreateRawInstance(void *,const char *);
//C        LOCALE intBool                        DeleteInstance(void *);
//C        LOCALE void                           DirectGetSlot(void *,const char *,DATA_OBJECT *);
//C        LOCALE int                            DirectPutSlot(void *,const char *,DATA_OBJECT *);
//C        LOCALE void                          *FindInstance(void *,const char *,unsigned);
//C        LOCALE void                          *GetInstanceClass(void *);
//C        LOCALE void                           GetInstancePPForm(char *,unsigned,void *);
//C        LOCALE void                          *GetNextInstance(void *);
//C        LOCALE void                          *GetNextInstanceInClass(void *,void *);
//C        LOCALE void                          *GetNextInstanceInClassAndSubclasses(void **,void *,DATA_OBJECT *);
//C        LOCALE void                           Instances(const char *,void *,const char *,int);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void                          *MakeInstance(const char *);
//C     #endif
//C        LOCALE intBool                        UnmakeInstance(void *);
//C        LOCALE int                            ValidInstanceAddress(void *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_inscom */





//C     #include "insfile.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  02/04/15          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove compiler warnings.    */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_insfile
//C     #define _H_insfile

//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif

//C     #define INSTANCE_FILE_DATA 30

const INSTANCE_FILE_DATA = 30;
//C     #if BLOAD_INSTANCES || BSAVE_INSTANCES
//C     struct instanceFileData
//C       { 
//C        const char *InstanceBinaryPrefixID;
//C        const char *InstanceBinaryVersionID;
//C        unsigned long BinaryInstanceFileSize;

//C     #if BLOAD_INSTANCES
//C        unsigned long BinaryInstanceFileOffset;
//C        char *CurrentReadBuffer;
//C        unsigned long CurrentReadBufferSize;
//C        unsigned long CurrentReadBufferOffset;
//C     #endif
//C       };
struct instanceFileData
{
    char *InstanceBinaryPrefixID;
    char *InstanceBinaryVersionID;
    uint BinaryInstanceFileSize;
    uint BinaryInstanceFileOffset;
    char *CurrentReadBuffer;
    uint CurrentReadBufferSize;
    uint CurrentReadBufferOffset;
}

//C     #define InstanceFileData(theEnv) ((struct instanceFileData *) GetEnvironmentData(theEnv,INSTANCE_FILE_DATA))

//C     #endif /* BLOAD_INSTANCES || BSAVE_INSTANCES */

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _INSFILE_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                           SetupInstanceFileCommands(void *);
void  SetupInstanceFileCommands(void *);
//C        LOCALE long                           SaveInstancesCommand(void *);
int  SaveInstancesCommand(void *);
//C        LOCALE long                           LoadInstancesCommand(void *);
int  LoadInstancesCommand(void *);
//C        LOCALE long                           RestoreInstancesCommand(void *);
int  RestoreInstancesCommand(void *);
//C        LOCALE long                           EnvSaveInstancesDriver(void *,const char *,int,EXPRESSION *,intBool);
int  EnvSaveInstancesDriver(void *, char *, int , EXPRESSION *, int );
//C        LOCALE long                           EnvSaveInstances(void *,const char *,int);
int  EnvSaveInstances(void *, char *, int );
//C     #if BSAVE_INSTANCES
//C        LOCALE long                           BinarySaveInstancesCommand(void *);
int  BinarySaveInstancesCommand(void *);
//C        LOCALE long                           EnvBinarySaveInstancesDriver(void *,const char *,int,EXPRESSION *,intBool);
int  EnvBinarySaveInstancesDriver(void *, char *, int , EXPRESSION *, int );
//C        LOCALE long                           EnvBinarySaveInstances(void *,const char *,int);
int  EnvBinarySaveInstances(void *, char *, int );
//C     #endif
//C     #if BLOAD_INSTANCES
//C        LOCALE long                           BinaryLoadInstancesCommand(void *);
int  BinaryLoadInstancesCommand(void *);
//C        LOCALE long                           EnvBinaryLoadInstances(void *,const char *);
int  EnvBinaryLoadInstances(void *, char *);
//C     #endif
//C        LOCALE long                           EnvLoadInstances(void *,const char *);
int  EnvLoadInstances(void *, char *);
//C        LOCALE long                           EnvLoadInstancesFromString(void *,const char *,int);
int  EnvLoadInstancesFromString(void *, char *, int );
//C        LOCALE long                           EnvRestoreInstances(void *,const char *);
int  EnvRestoreInstances(void *, char *);
//C        LOCALE long                           EnvRestoreInstancesFromString(void *,const char *,int);
int  EnvRestoreInstancesFromString(void *, char *, int );

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C     #if BLOAD_INSTANCES
//C        LOCALE long                           BinaryLoadInstances(const char *);
//C     #endif
//C     #if BSAVE_INSTANCES
//C        LOCALE long                           BinarySaveInstances(const char *,int);
//C     #endif
//C        LOCALE long                           LoadInstances(const char *);
//C        LOCALE long                           LoadInstancesFromString(const char *,int);
//C        LOCALE long                           RestoreInstances(const char *);
//C        LOCALE long                           RestoreInstancesFromString(const char *,int);
//C        LOCALE long                           SaveInstances(const char *,int);
   
//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_insfile */



//C     #include "insfun.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                INSTANCE FUNCTIONS MODULE            */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*            Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Link error occurs for the SlotExistError       */
/*            function when OBJECT_SYSTEM is set to 0 in     */
/*            setup.h. DR0865                                */
/*                                                           */
/*            Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Moved EvaluateAndStoreInDataObject to          */
/*            evaluatn.c                                     */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed slot override default ?NONE bug.         */
/*                                                           */
//*************************************************************/

//C     #ifndef _H_insfun
//C     #define _H_insfun

//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_moduldef
//C     #include "moduldef.h"
//C     #endif
//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif

//C     #ifndef _H_pattern
//C     #include "pattern.h"
//C     #endif

//C     typedef struct igarbage
//C       {
//C        INSTANCE_TYPE *ins;
//C        struct igarbage *nxt;
//C       } IGARBAGE;

//C     #define INSTANCE_TABLE_HASH_SIZE 8191
//C     #define InstanceSizeHeuristic(ins)      sizeof(INSTANCE_TYPE)

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _INSFUN_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C        LOCALE void                           EnvIncrementInstanceCount(void *,void *);
//C        LOCALE void                           EnvDecrementInstanceCount(void *,void *);
//C        LOCALE void                           InitializeInstanceTable(void *);
//C        LOCALE void                           CleanupInstances(void *);
//C        LOCALE unsigned                       HashInstance(SYMBOL_HN *);
//C        LOCALE void                           DestroyAllInstances(void *);
//C        LOCALE void                           RemoveInstanceData(void *,INSTANCE_TYPE *);
//C        LOCALE INSTANCE_TYPE                 *FindInstanceBySymbol(void *,SYMBOL_HN *);
//C        LOCALE INSTANCE_TYPE                 *FindInstanceInModule(void *,SYMBOL_HN *,struct defmodule *,
//C                                                struct defmodule *,unsigned);
//C        LOCALE INSTANCE_SLOT                 *FindInstanceSlot(void *,INSTANCE_TYPE *,SYMBOL_HN *);
//C        LOCALE int                            FindInstanceTemplateSlot(void *,DEFCLASS *,SYMBOL_HN *);
//C        LOCALE int                            PutSlotValue(void *,INSTANCE_TYPE *,INSTANCE_SLOT *,DATA_OBJECT *,DATA_OBJECT *,const char *);
//C        LOCALE int                            DirectPutSlotValue(void *,INSTANCE_TYPE *,INSTANCE_SLOT *,DATA_OBJECT *,DATA_OBJECT *);
//C        LOCALE intBool                        ValidSlotValue(void *,DATA_OBJECT *,SLOT_DESC *,INSTANCE_TYPE *,const char *);
//C        LOCALE INSTANCE_TYPE                 *CheckInstance(void *,const char *);
//C        LOCALE void                           NoInstanceError(void *,const char *,const char *);
//C        LOCALE void                           StaleInstanceAddress(void *,const char *,int);
//C        LOCALE int                            EnvGetInstancesChanged(void *);
//C        LOCALE void                           EnvSetInstancesChanged(void *,int);
//C        LOCALE void                           PrintSlot(void *,const char *,SLOT_DESC *,INSTANCE_TYPE *,const char *);
//C        LOCALE void                           PrintInstanceNameAndClass(void *,const char *,INSTANCE_TYPE *,intBool);
//C        LOCALE void                           PrintInstanceName(void *,const char *,void *);
//C        LOCALE void                           PrintInstanceLongForm(void *,const char *,void *);
//C     #if DEFRULE_CONSTRUCT && OBJECT_SYSTEM
//C        LOCALE void                           DecrementObjectBasisCount(void *,void *);
//C        LOCALE void                           IncrementObjectBasisCount(void *,void *);
//C        LOCALE void                           MatchObjectFunction(void *,void *);
//C        LOCALE intBool                        NetworkSynchronized(void *,void *);
//C        LOCALE intBool                        InstanceIsDeleted(void *,void *);
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void                           DecrementInstanceCount(void *);
//C        LOCALE int                            GetInstancesChanged(void);
//C        LOCALE void                           IncrementInstanceCount(void *);
//C        LOCALE void                           SetInstancesChanged(int);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_insfun */







//C     #include "msgcom.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/22/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Removed IMPERATIVE_MESSAGE_HANDLERS            */
/*                    compilation flag.                      */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warnings.                             */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added DeallocateMessageHandlerData to          */
/*            deallocate message handler environment data.   */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_msgcom
//C     #define _H_msgcom

//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif

//C     #ifndef _H_msgpass
//C     #include "msgpass.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose: Message-passing support functions                */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Removed IMPERATIVE_MESSAGE_HANDLERS and        */
/*            AUXILIARY_MESSAGE_HANDLERS compilation flags.  */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: The return value of DirectMessage indicates    */
/*            whether an execution error has occurred.       */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_msgpass
//C     #define _H_msgpass

//C     #define GetActiveInstance(theEnv) ((INSTANCE_TYPE *) GetNthMessageArgument(theEnv,0)->value)

//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif

//C     typedef struct messageHandlerLink
//C       {
//C        HANDLER *hnd;
//C        struct messageHandlerLink *nxt;
//C        struct messageHandlerLink *nxtInStack;
//C       } HANDLER_LINK;
struct messageHandlerLink
{
    HANDLER *hnd;
    messageHandlerLink *nxt;
    messageHandlerLink *nxtInStack;
}
alias messageHandlerLink HANDLER_LINK;

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _MSGPASS_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE intBool          DirectMessage(void *,SYMBOL_HN *,INSTANCE_TYPE *,
//C                                              DATA_OBJECT *,EXPRESSION *);
int  DirectMessage(void *, SYMBOL_HN *, INSTANCE_TYPE *, DATA_OBJECT *, EXPRESSION *);
//C        LOCALE void             EnvSend(void *,DATA_OBJECT *,const char *,const char *,DATA_OBJECT *);
void  EnvSend(void *, DATA_OBJECT *, char *, char *, DATA_OBJECT *);
//C        LOCALE void             DestroyHandlerLinks(void *,HANDLER_LINK *);
void  DestroyHandlerLinks(void *, HANDLER_LINK *);
//C        LOCALE void             SendCommand(void *,DATA_OBJECT *);
void  SendCommand(void *, DATA_OBJECT *);
//C        LOCALE DATA_OBJECT     *GetNthMessageArgument(void *,int);
DATA_OBJECT * GetNthMessageArgument(void *, int );

//C        LOCALE int              NextHandlerAvailable(void *);
int  NextHandlerAvailable(void *);
//C        LOCALE void             CallNextHandler(void *,DATA_OBJECT *);
void  CallNextHandler(void *, DATA_OBJECT *);

//C        LOCALE void             FindApplicableOfName(void *,DEFCLASS *,HANDLER_LINK *[],
//C                                                     HANDLER_LINK *[],SYMBOL_HN *);
void  FindApplicableOfName(void *, DEFCLASS *, HANDLER_LINK **, HANDLER_LINK **, SYMBOL_HN *);
//C        LOCALE HANDLER_LINK    *JoinHandlerLinks(void *,HANDLER_LINK *[],HANDLER_LINK *[],SYMBOL_HN *);
HANDLER_LINK * JoinHandlerLinks(void *, HANDLER_LINK **, HANDLER_LINK **, SYMBOL_HN *);

//C        LOCALE void             PrintHandlerSlotGetFunction(void *,const char *,void *);
void  PrintHandlerSlotGetFunction(void *, char *, void *);
//C        LOCALE intBool          HandlerSlotGetFunction(void *,void *,DATA_OBJECT *);
int  HandlerSlotGetFunction(void *, void *, DATA_OBJECT *);
//C        LOCALE void             PrintHandlerSlotPutFunction(void *,const char *,void *);
void  PrintHandlerSlotPutFunction(void *, char *, void *);
//C        LOCALE intBool          HandlerSlotPutFunction(void *,void *,DATA_OBJECT *);
int  HandlerSlotPutFunction(void *, void *, DATA_OBJECT *);
//C        LOCALE void             DynamicHandlerGetSlot(void *,DATA_OBJECT *);
void  DynamicHandlerGetSlot(void *, DATA_OBJECT *);
//C        LOCALE void             DynamicHandlerPutSlot(void *,DATA_OBJECT *);
void  DynamicHandlerPutSlot(void *, DATA_OBJECT *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void             Send(DATA_OBJECT *,const char *,const char *,DATA_OBJECT *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_object */







//C     #endif

//C     #define MESSAGE_HANDLER_DATA 32

const MESSAGE_HANDLER_DATA = 32;
//C     struct messageHandlerData
//C       { 
//C        ENTITY_RECORD HandlerGetInfo;
//C        ENTITY_RECORD HandlerPutInfo;
//C        SYMBOL_HN *INIT_SYMBOL;
//C        SYMBOL_HN *DELETE_SYMBOL;
//C        SYMBOL_HN *CREATE_SYMBOL;
//C     #if DEBUGGING_FUNCTIONS
//C        unsigned WatchHandlers;
//C        unsigned WatchMessages;
//C     #endif
//C        const char *hndquals[4];
//C        SYMBOL_HN *SELF_SYMBOL;
//C        SYMBOL_HN *CurrentMessageName;
//C        HANDLER_LINK *CurrentCore;
//C        HANDLER_LINK *TopOfCore;
//C        HANDLER_LINK *NextInCore;
//C        HANDLER_LINK *OldCore;
//C       };
struct messageHandlerData
{
    ENTITY_RECORD HandlerGetInfo;
    ENTITY_RECORD HandlerPutInfo;
    SYMBOL_HN *INIT_SYMBOL;
    SYMBOL_HN *DELETE_SYMBOL;
    SYMBOL_HN *CREATE_SYMBOL;
    uint WatchHandlers;
    uint WatchMessages;
    char *[4]hndquals;
    SYMBOL_HN *SELF_SYMBOL;
    SYMBOL_HN *CurrentMessageName;
    HANDLER_LINK *CurrentCore;
    HANDLER_LINK *TopOfCore;
    HANDLER_LINK *NextInCore;
    HANDLER_LINK *OldCore;
}

//C     #define MessageHandlerData(theEnv) ((struct messageHandlerData *) GetEnvironmentData(theEnv,MESSAGE_HANDLER_DATA))


//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _MSGCOM_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C     #define INIT_STRING   "init"
//C     #define DELETE_STRING "delete"
//C     #define PRINT_STRING  "print"
//C     #define CREATE_STRING "create"

//C        LOCALE void             SetupMessageHandlers(void *);
void  SetupMessageHandlers(void *);
//C        LOCALE const char      *EnvGetDefmessageHandlerName(void *,void *,int);
char * EnvGetDefmessageHandlerName(void *, void *, int );
//C        LOCALE const char      *EnvGetDefmessageHandlerType(void *,void *,int);
char * EnvGetDefmessageHandlerType(void *, void *, int );
//C        LOCALE int              EnvGetNextDefmessageHandler(void *,void *,int);
int  EnvGetNextDefmessageHandler(void *, void *, int );
//C        LOCALE HANDLER         *GetDefmessageHandlerPointer(void *,int);
HANDLER * GetDefmessageHandlerPointer(void *, int );
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE unsigned         EnvGetDefmessageHandlerWatch(void *,void *,int);
uint  EnvGetDefmessageHandlerWatch(void *, void *, int );
//C        LOCALE void             EnvSetDefmessageHandlerWatch(void *,int,void *,int);
void  EnvSetDefmessageHandlerWatch(void *, int , void *, int );
//C     #endif
//C        LOCALE unsigned         EnvFindDefmessageHandler(void *,void *,const char *,const char *);
uint  EnvFindDefmessageHandler(void *, void *, char *, char *);
//C        LOCALE int              EnvIsDefmessageHandlerDeletable(void *,void *,int);
int  EnvIsDefmessageHandlerDeletable(void *, void *, int );
//C        LOCALE void             UndefmessageHandlerCommand(void *);
void  UndefmessageHandlerCommand(void *);
//C        LOCALE int              EnvUndefmessageHandler(void *,void *,int);
int  EnvUndefmessageHandler(void *, void *, int );
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE void             PPDefmessageHandlerCommand(void *);
void  PPDefmessageHandlerCommand(void *);
//C        LOCALE void             ListDefmessageHandlersCommand(void *);
void  ListDefmessageHandlersCommand(void *);
//C        LOCALE void             PreviewSendCommand(void *); 
void  PreviewSendCommand(void *);
//C        LOCALE const char      *EnvGetDefmessageHandlerPPForm(void *,void *,int);
char * EnvGetDefmessageHandlerPPForm(void *, void *, int );
//C        LOCALE void             EnvListDefmessageHandlers(void *,const char *,void *,int);
void  EnvListDefmessageHandlers(void *, char *, void *, int );
//C        LOCALE void             EnvPreviewSend(void *,const char *,void *,const char *);
void  EnvPreviewSend(void *, char *, void *, char *);
//C        LOCALE long             DisplayHandlersInLinks(void *,const char *,PACKED_CLASS_LINKS *,int);
int  DisplayHandlersInLinks(void *, char *, PACKED_CLASS_LINKS *, int );
//C     #endif

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE unsigned         FindDefmessageHandler(void *,const char *,const char *);
//C        LOCALE const char      *GetDefmessageHandlerName(void *,int);
//C        LOCALE const char      *GetDefmessageHandlerType(void *,int);
//C        LOCALE int              GetNextDefmessageHandler(void *,int);
//C        LOCALE int              IsDefmessageHandlerDeletable(void *,int);
//C        LOCALE int              UndefmessageHandler(void *,int);
//C     #if DEBUGGING_FUNCTIONS
//C        LOCALE const char      *GetDefmessageHandlerPPForm(void *,int);
//C        LOCALE unsigned         GetDefmessageHandlerWatch(void *,int);
//C        LOCALE void             ListDefmessageHandlers(const char *,void *,int);
//C        LOCALE void             PreviewSend(const char *,void *,const char *);
//C        LOCALE void             SetDefmessageHandlerWatch(int,void *,int);
//C     #endif /* DEBUGGING_FUNCTIONS */

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_msgcom */





//C     #include "msgpass.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose: Message-passing support functions                */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Removed IMPERATIVE_MESSAGE_HANDLERS and        */
/*            AUXILIARY_MESSAGE_HANDLERS compilation flags.  */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: The return value of DirectMessage indicates    */
/*            whether an execution error has occurred.       */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_msgpass
//C     #define _H_msgpass

//C     #define GetActiveInstance(theEnv) ((INSTANCE_TYPE *) GetNthMessageArgument(theEnv,0)->value)

//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif

//C     typedef struct messageHandlerLink
//C       {
//C        HANDLER *hnd;
//C        struct messageHandlerLink *nxt;
//C        struct messageHandlerLink *nxtInStack;
//C       } HANDLER_LINK;

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _MSGPASS_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif

//C        LOCALE intBool          DirectMessage(void *,SYMBOL_HN *,INSTANCE_TYPE *,
//C                                              DATA_OBJECT *,EXPRESSION *);
//C        LOCALE void             EnvSend(void *,DATA_OBJECT *,const char *,const char *,DATA_OBJECT *);
//C        LOCALE void             DestroyHandlerLinks(void *,HANDLER_LINK *);
//C        LOCALE void             SendCommand(void *,DATA_OBJECT *);
//C        LOCALE DATA_OBJECT     *GetNthMessageArgument(void *,int);

//C        LOCALE int              NextHandlerAvailable(void *);
//C        LOCALE void             CallNextHandler(void *,DATA_OBJECT *);

//C        LOCALE void             FindApplicableOfName(void *,DEFCLASS *,HANDLER_LINK *[],
//C                                                     HANDLER_LINK *[],SYMBOL_HN *);
//C        LOCALE HANDLER_LINK    *JoinHandlerLinks(void *,HANDLER_LINK *[],HANDLER_LINK *[],SYMBOL_HN *);

//C        LOCALE void             PrintHandlerSlotGetFunction(void *,const char *,void *);
//C        LOCALE intBool          HandlerSlotGetFunction(void *,void *,DATA_OBJECT *);
//C        LOCALE void             PrintHandlerSlotPutFunction(void *,const char *,void *);
//C        LOCALE intBool          HandlerSlotPutFunction(void *,void *,DATA_OBJECT *);
//C        LOCALE void             DynamicHandlerGetSlot(void *,DATA_OBJECT *);
//C        LOCALE void             DynamicHandlerPutSlot(void *,DATA_OBJECT *);

//C     #if ALLOW_ENVIRONMENT_GLOBALS

//C        LOCALE void             Send(DATA_OBJECT *,const char *,const char *,DATA_OBJECT *);

//C     #endif /* ALLOW_ENVIRONMENT_GLOBALS */

//C     #endif /* _H_object */







//C     #include "objrtmch.h"
   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Removed INCREMENTAL_RESET and                  */
/*            LOGICAL_DEPENDENCIES compilation flags.        */
/*                                                           */
/*            Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Modified the QueueObjectMatchAction function   */
/*            so that instance retract actions always occur  */
/*            before instance assert and modify actions.     */
/*            This prevents the pattern matching process     */
/*            from attempting the evaluation of a join       */
/*            expression that accesses the slots of a        */
/*            retracted instance.                            */
/*                                                           */
/*            Added support for hashed alpha memories.       */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added support for hashed comparisons to        */
/*            constants.                                     */
/*                                                           */
/*************************************************************/

//C     #ifndef _H_objrtmch
//C     #define _H_objrtmch

//C     #if DEFRULE_CONSTRUCT && OBJECT_SYSTEM

//C     #define OBJECT_ASSERT  1
//C     #define OBJECT_RETRACT 2
const OBJECT_ASSERT = 1;
//C     #define OBJECT_MODIFY  3
const OBJECT_RETRACT = 2;

const OBJECT_MODIFY = 3;
//C     #ifndef _H_evaluatn
//C     #include "evaluatn.h"
//C     #endif
//C     #ifndef _H_expressn
//C     #include "expressn.h"
//C     #endif
//C     #ifndef _H_match
//C     #include "match.h"
//C     #endif
//C     #ifndef _H_network
//C     #include "network.h"
//C     #endif
//C     #ifndef _H_object
//C     #include "object.h"
//C     #endif
//C     #ifndef _H_symbol
//C     #include "symbol.h"
//C     #endif

//C     typedef struct classBitMap
//C       {
//C        unsigned short maxid;
//C        char map[1];
//C       } CLASS_BITMAP;
struct classBitMap
{
    ushort maxid;
    char [1]map;
}
alias classBitMap CLASS_BITMAP;

//C     #define ClassBitMapSize(bmp) ((sizeof(CLASS_BITMAP) +                                      (sizeof(char) * (bmp->maxid / BITS_PER_BYTE))))

//C     typedef struct slotBitMap
//C       {
//C        unsigned short maxid;
//C        char map[1];
//C       } SLOT_BITMAP;
struct slotBitMap
{
    ushort maxid;
    char [1]map;
}
alias slotBitMap SLOT_BITMAP;

//C     #define SlotBitMapSize(bmp) ((sizeof(SLOT_BITMAP) +                                      (sizeof(char) * (bmp->maxid / BITS_PER_BYTE))))

//C     typedef struct objectAlphaNode OBJECT_ALPHA_NODE;
alias objectAlphaNode OBJECT_ALPHA_NODE;

//C     typedef struct objectPatternNode
//C       {
//C        unsigned blocked        : 1;
//C        unsigned multifieldNode : 1;
//C        unsigned endSlot        : 1;
//C        unsigned selector       : 1;
//C        unsigned whichField     : 8;
//C        unsigned short leaveFields;
//C        unsigned long long matchTimeTag;
//C        int slotNameID;
//C        EXPRESSION *networkTest;
//C        struct objectPatternNode *nextLevel;
//C        struct objectPatternNode *lastLevel;
//C        struct objectPatternNode *leftNode;
//C        struct objectPatternNode *rightNode;
//C        OBJECT_ALPHA_NODE *alphaNode;
//C        long bsaveID;
//C       } OBJECT_PATTERN_NODE;
struct objectPatternNode
{
    uint __bitfield1;
    uint blocked() { return (__bitfield1 >> 0) & 0x1; }
    uint blocked(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffe) | (value << 0); return value; }
    uint multifieldNode() { return (__bitfield1 >> 1) & 0x1; }
    uint multifieldNode(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffd) | (value << 1); return value; }
    uint endSlot() { return (__bitfield1 >> 2) & 0x1; }
    uint endSlot(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffffb) | (value << 2); return value; }
    uint selector() { return (__bitfield1 >> 3) & 0x1; }
    uint selector(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffffff7) | (value << 3); return value; }
    uint whichField() { return (__bitfield1 >> 4) & 0xff; }
    uint whichField(uint value) { __bitfield1 = (__bitfield1 & 0xfffffffffffff00f) | (value << 4); return value; }
    ushort leaveFields;
    ulong matchTimeTag;
    int slotNameID;
    EXPRESSION *networkTest;
    objectPatternNode *nextLevel;
    objectPatternNode *lastLevel;
    objectPatternNode *leftNode;
    objectPatternNode *rightNode;
    OBJECT_ALPHA_NODE *alphaNode;
    int bsaveID;
}
alias objectPatternNode OBJECT_PATTERN_NODE;

//C     struct objectAlphaNode
//C       {
//C        struct patternNodeHeader header;
//C        unsigned long long matchTimeTag;
//C        BITMAP_HN *classbmp,*slotbmp;
//C        OBJECT_PATTERN_NODE *patternNode;
//C        struct objectAlphaNode *nxtInGroup,
//C                               *nxtTerminal;
//C        long bsaveID;
//C       };
struct objectAlphaNode
{
    patternNodeHeader header;
    ulong matchTimeTag;
    BITMAP_HN *classbmp;
    BITMAP_HN *slotbmp;
    OBJECT_PATTERN_NODE *patternNode;
    objectAlphaNode *nxtInGroup;
    objectAlphaNode *nxtTerminal;
    int bsaveID;
}

//C     typedef struct objectMatchAction
//C       {
//C        int type;
//C        INSTANCE_TYPE *ins;
//C        SLOT_BITMAP *slotNameIDs;
//C        struct objectMatchAction *nxt;
//C       } OBJECT_MATCH_ACTION;
struct objectMatchAction
{
    int type;
    INSTANCE_TYPE *ins;
    SLOT_BITMAP *slotNameIDs;
    objectMatchAction *nxt;
}
alias objectMatchAction OBJECT_MATCH_ACTION;

//C     #ifdef LOCALE
//C     #undef LOCALE
//C     #endif

//C     #ifdef _OBJRTMCH_SOURCE_
//C     #define LOCALE
//C     #else
//C     #define LOCALE extern
//C     #endif
//C -- alias extern LOCALE;

//C        LOCALE void                  ObjectMatchDelay(void *,DATA_OBJECT *);
void  ObjectMatchDelay(void *, DATA_OBJECT *);
//C        LOCALE intBool               SetDelayObjectPatternMatching(void *,int);
int  SetDelayObjectPatternMatching(void *, int );
//C        LOCALE intBool               GetDelayObjectPatternMatching(void *);
int  GetDelayObjectPatternMatching(void *);
//C        LOCALE OBJECT_PATTERN_NODE  *ObjectNetworkPointer(void *);
OBJECT_PATTERN_NODE * ObjectNetworkPointer(void *);
//C        LOCALE OBJECT_ALPHA_NODE    *ObjectNetworkTerminalPointer(void *);
OBJECT_ALPHA_NODE * ObjectNetworkTerminalPointer(void *);
//C        LOCALE void                  SetObjectNetworkPointer(void *,OBJECT_PATTERN_NODE *);
void  SetObjectNetworkPointer(void *, OBJECT_PATTERN_NODE *);
//C        LOCALE void                  SetObjectNetworkTerminalPointer(void *,OBJECT_ALPHA_NODE *);
void  SetObjectNetworkTerminalPointer(void *, OBJECT_ALPHA_NODE *);
//C        LOCALE void                  ObjectNetworkAction(void *,int,INSTANCE_TYPE *,int);
void  ObjectNetworkAction(void *, int , INSTANCE_TYPE *, int );
//C        LOCALE void                  ResetObjectMatchTimeTags(void *);
void  ResetObjectMatchTimeTags(void *);

//C     #endif /* DEFRULE_CONSTRUCT && OBJECT_SYSTEM */

//C     #endif /* _H_objrtmch */



//C     #endif


//C     #endif



