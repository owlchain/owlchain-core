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

#ifndef _H_setup
#define _H_setup

/****************************************************************/
/* -------------------- COMPILER FLAGS ------------------------ */
/****************************************************************/

/*********************************************************************/
/* Flag denoting the environment in which the executable is to run.  */
/* Only one of these flags should be turned on (set to 1) at a time. */
/*********************************************************************/

#ifndef UNIX_V
#define UNIX_V  0   /* UNIX System V, 4.2bsd, or HP Unix, presumably with gcc */
#endif

#ifndef UNIX_7
#define UNIX_7  0   /* UNIX System III Version 7 or Sun Unix, presumably with gcc */
#endif

#ifndef LINUX
#define LINUX   0   /* Untested, presumably with gcc */
#endif

#ifndef DARWIN
#define DARWIN  0   /* Darwin Mac OS 10.10.2, presumably with gcc or Xcode 6.2 with Console */
#endif

#ifndef MAC_XCD
#define MAC_XCD 0   /* MacOS 10.10.2, with Xcode 6.2 and Cocoa GUI */
#endif

#ifndef WIN_MVC
#define WIN_MVC 0   /* Windows 7, with Visual Studio 2013 */
#endif

/* The following are unsupported: */

#ifndef WIN_GCC
#define WIN_GCC 0   /* Windows XP, with DJGPP 3.21 */
#endif

#ifndef VAX_VMS                    
#define VAX_VMS 0   /* VAX VMS */
#endif

/* Use GENERIC if nothing else is used. */

#ifndef GENERIC
#if (! UNIX_V) && (! LINUX) && (! UNIX_7) && \
    (! MAC_XCD) && (! DARWIN) && \
    (! WIN_MVC) && (! WIN_GCC) && \
    (! VAX_VMS)
#define GENERIC 1   /* Generic (any machine)                   */
#else
#define GENERIC 0   /* Generic (any machine)                   */
#endif
#endif

#if WIN_MVC
#define IBM 1
#else
#define IBM 0
#endif

/***********************************************/
/* Some definitions for use with declarations. */
/***********************************************/

#define VOID_ARG void
#define STD_SIZE size_t

#define intBool int
#define globle

/*******************************************/
/* RUN_TIME:  Specifies whether a run-time */
/*   module is being created.              */
/*******************************************/

#ifndef RUN_TIME
#define RUN_TIME 0
#endif

/*************************************************/
/* DEFRULE_CONSTRUCT: Determines whether defrule */
/*   construct is included.                      */
/*************************************************/

#ifndef DEFRULE_CONSTRUCT
#define DEFRULE_CONSTRUCT 1
#endif

/************************************************/
/* DEFMODULE_CONSTRUCT:  Determines whether the */
/*   defmodule construct is included.           */
/************************************************/

#ifndef DEFMODULE_CONSTRUCT
#define DEFMODULE_CONSTRUCT 1
#endif

/****************************************************/
/* DEFTEMPLATE_CONSTRUCT:  Determines whether facts */
/*   and the deftemplate construct are included.    */
/****************************************************/

#ifndef DEFTEMPLATE_CONSTRUCT
#define DEFTEMPLATE_CONSTRUCT 1
#endif

#if ! DEFRULE_CONSTRUCT
#undef DEFTEMPLATE_CONSTRUCT
#define DEFTEMPLATE_CONSTRUCT 0
#endif

/************************************************************/
/* FACT_SET_QUERIES: Determines if fact-set query functions */
/*  such as any-factp and do-for-all-facts are included.    */
/************************************************************/

#ifndef FACT_SET_QUERIES
#define FACT_SET_QUERIES 1
#endif

#if ! DEFTEMPLATE_CONSTRUCT
#undef FACT_SET_QUERIES
#define FACT_SET_QUERIES        0
#endif

/****************************************************/
/* DEFFACTS_CONSTRUCT:  Determines whether deffacts */
/*   construct is included.                         */
/****************************************************/

#ifndef DEFFACTS_CONSTRUCT
#define DEFFACTS_CONSTRUCT 1
#endif

#if ! DEFTEMPLATE_CONSTRUCT
#undef DEFFACTS_CONSTRUCT
#define DEFFACTS_CONSTRUCT 0
#endif

/************************************************/
/* DEFGLOBAL_CONSTRUCT:  Determines whether the */
/*   defglobal construct is included.           */
/************************************************/

#ifndef DEFGLOBAL_CONSTRUCT
#define DEFGLOBAL_CONSTRUCT 1
#endif

/**********************************************/
/* DEFFUNCTION_CONSTRUCT:  Determines whether */
/*   deffunction construct is included.       */
/**********************************************/

#ifndef DEFFUNCTION_CONSTRUCT
#define DEFFUNCTION_CONSTRUCT 1
#endif

/*********************************************/
/* DEFGENERIC_CONSTRUCT:  Determines whether */
/*   generic functions  are included.        */
/*********************************************/

#ifndef DEFGENERIC_CONSTRUCT
#define DEFGENERIC_CONSTRUCT 1
#endif

/*****************************************************************/
/* OBJECT_SYSTEM:  Determines whether object system is included. */
/*   The MULTIFIELD_FUNCTIONS flag should also be on if you want */
/*   to be able to manipulate multi-field slots.                 */
/*****************************************************************/

#ifndef OBJECT_SYSTEM
#define OBJECT_SYSTEM 1
#endif

/*****************************************************************/
/* DEFINSTANCES_CONSTRUCT: Determines whether the definstances   */
/*   construct is enabled.                                       */
/*****************************************************************/

#ifndef DEFINSTANCES_CONSTRUCT
#define DEFINSTANCES_CONSTRUCT      1
#endif

#if ! OBJECT_SYSTEM
#undef DEFINSTANCES_CONSTRUCT
#define DEFINSTANCES_CONSTRUCT      0
#endif

/********************************************************************/
/* INSTANCE_SET_QUERIES: Determines if instance-set query functions */
/*  such as any-instancep and do-for-all-instances are included.    */
/********************************************************************/

#ifndef INSTANCE_SET_QUERIES
#define INSTANCE_SET_QUERIES 1
#endif

#if ! OBJECT_SYSTEM
#undef INSTANCE_SET_QUERIES
#define INSTANCE_SET_QUERIES        0
#endif

/******************************************************************/
/* Check for consistencies associated with the defrule construct. */
/******************************************************************/

#if (! DEFTEMPLATE_CONSTRUCT) && (! OBJECT_SYSTEM)
#undef DEFRULE_CONSTRUCT
#define DEFRULE_CONSTRUCT 0
#endif

/*******************************************************************/
/* BLOAD/BSAVE_INSTANCES: Determines if the save/restore-instances */
/*  functions can be enhanced to perform more quickly by using     */
/*  binary files                                                   */
/*******************************************************************/

#ifndef BLOAD_INSTANCES
#define BLOAD_INSTANCES 1
#endif
#ifndef BSAVE_INSTANCES
#define BSAVE_INSTANCES 1
#endif

#if ! OBJECT_SYSTEM
#undef BLOAD_INSTANCES
#undef BSAVE_INSTANCES
#define BLOAD_INSTANCES             0
#define BSAVE_INSTANCES             0
#endif

/****************************************************************/
/* EXTENDED MATH PACKAGE FLAG: If this is on, then the extended */
/* math package functions will be available for use, (normal    */
/* default). If this flag is off, then the extended math        */
/* functions will not be available, and the 30K or so of space  */
/* they require will be free. Usually a concern only on PC type */
/* machines.                                                    */
/****************************************************************/

#ifndef EXTENDED_MATH_FUNCTIONS
#define EXTENDED_MATH_FUNCTIONS 1
#endif

/****************************************************************/
/* TEXT PROCESSING : Turn on this flag for support of the       */
/* hierarchical lookup system.                                  */
/****************************************************************/

#ifndef TEXTPRO_FUNCTIONS
#define TEXTPRO_FUNCTIONS 1
#endif

/*************************************************************************/
/* BLOAD_ONLY:      Enables bload command and disables the load command. */
/* BLOAD:           Enables bload command.                               */
/* BLOAD_AND_BSAVE: Enables bload, and bsave commands.                   */
/*************************************************************************/

#ifndef BLOAD_ONLY
#define BLOAD_ONLY 0
#endif
#ifndef BLOAD
#define BLOAD 0
#endif
#ifndef BLOAD_AND_BSAVE
#define BLOAD_AND_BSAVE 1
#endif

#if RUN_TIME
#undef BLOAD_ONLY
#define BLOAD_ONLY      0
#undef BLOAD
#define BLOAD           0
#undef BLOAD_AND_BSAVE
#define BLOAD_AND_BSAVE 0
#endif

/********************************************************************/
/* CONSTRUCT COMPILER: If this flag is turned on, you can generate  */
/*   C code representing the constructs in the current environment. */
/*   With the RUN_TIME flag set, this code can be compiled and      */
/*   linked to create a stand-alone run-time executable.            */
/********************************************************************/

#ifndef CONSTRUCT_COMPILER
#define  CONSTRUCT_COMPILER 1
#endif

#if CONSTRUCT_COMPILER
#define API_HEADER "clips.h"
#endif

/************************************************/
/* IO_FUNCTIONS: Includes printout, read, open, */
/*   close, format, and readline functions.     */
/************************************************/

#ifndef IO_FUNCTIONS
#define IO_FUNCTIONS 1
#endif

/************************************************/
/* STRING_FUNCTIONS: Includes string functions: */
/*   str-length, str-compare, upcase, lowcase,  */
/*   sub-string, str-index, and eval.           */
/************************************************/

#ifndef STRING_FUNCTIONS
#define STRING_FUNCTIONS 1
#endif

/*********************************************/
/* MULTIFIELD_FUNCTIONS: Includes multifield */
/*   functions:  mv-subseq, mv-delete,       */
/*   mv-append, str-explode, str-implode.    */
/*********************************************/

#ifndef MULTIFIELD_FUNCTIONS
#define MULTIFIELD_FUNCTIONS 1
#endif

/****************************************************/
/* DEBUGGING_FUNCTIONS: Includes functions such as  */
/*   rules, facts, matches, ppdefrule, etc.         */
/****************************************************/

#ifndef DEBUGGING_FUNCTIONS
#define DEBUGGING_FUNCTIONS 1
#endif

/***************************************************/
/* PROFILING_FUNCTIONS: Enables code for profiling */
/*   constructs and user functions.                */
/***************************************************/

#ifndef PROFILING_FUNCTIONS
#define PROFILING_FUNCTIONS 1
#endif

/*******************************************************************/
/* WINDOW_INTERFACE : Set this flag if you are recompiling any of  */
/*   the machine specific GUI interfaces. Currently, when enabled, */
/*   this flag disables the more processing used by the help       */
/*   system. This flag also prevents any input or output being     */
/*   directly sent to stdin or stdout.                             */
/*******************************************************************/

#ifndef WINDOW_INTERFACE
#define WINDOW_INTERFACE 0
#endif

/*************************************************************/
/* ALLOW_ENVIRONMENT_GLOBALS: If enabled, tracks the current */
/*   environment and allows environments to be referred to   */
/*   by index. If disabled, CLIPS makes no use of global     */
/*   variables.                                              */
/*************************************************************/

#ifndef ALLOW_ENVIRONMENT_GLOBALS
#define ALLOW_ENVIRONMENT_GLOBALS 0
#endif

/********************************************/
/* DEVELOPER: Enables code for debugging a  */
/*   development version of the executable. */
/********************************************/

#ifndef DEVELOPER
#define DEVELOPER 0
#endif

#if DEVELOPER
#include <assert.h>
#define Bogus(x) assert(! (x))
#else
#define Bogus(x)
#endif

/***************************/
/* Environment Definitions */
/***************************/

#include "envrnmnt.h"

/*************************************************/
/* Any user defined global setup information can */
/* be included in the file usrsetup.h which is   */
/* an empty file in the baseline version.        */
/*************************************************/

#include "usrsetup.h"

#endif	/* _H_setup */










