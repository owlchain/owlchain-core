   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*       DEFMODULE CONSTRUCT COMPILER HEADER FILE      */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements the constructs-to-c feature for the   */
/*    defmodule construct.                                   */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added support for path name argument to        */
/*            constructs-to-c.                               */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_modulcmp

#define _H_modulcmp

#ifndef _STDIO_INCLUDED_
#define _STDIO_INCLUDED_
#include <stdio.h>
#endif

#ifndef _H_moduldef
#include "moduldef.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MODULCMP_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           DefmoduleCompilerSetup(void *);
   LOCALE void                           PrintDefmoduleReference(void *,FILE *,struct defmodule *);

#endif /* _H_modulcmp */
