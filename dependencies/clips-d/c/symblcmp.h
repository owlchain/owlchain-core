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

#ifndef _H_symblcmp
#define _H_symblcmp

#ifndef _STDIO_INCLUDED_
#define _STDIO_INCLUDED_
#include <stdio.h>
#endif

#ifndef _H_symbol
#include "symbol.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _SYMBLCMP_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                     PrintSymbolReference(void *,FILE *,SYMBOL_HN *);
   LOCALE void                     PrintFloatReference(void *,FILE *,FLOAT_HN *);
   LOCALE void                     PrintIntegerReference(void *,FILE *,INTEGER_HN *);
   LOCALE void                     PrintBitMapReference(void *,FILE *,BITMAP_HN *);
   LOCALE void                     AtomicValuesToCode(void *,const char *,const char *,char *);

#endif /* _H_symblcmp */


