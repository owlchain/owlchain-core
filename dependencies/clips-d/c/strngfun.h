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

#ifndef _H_strngfun

#define _H_strngfun

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _STRNGFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ALLOW_ENVIRONMENT_GLOBALS
   LOCALE int                            Build(const char *);
   LOCALE int                            Eval(const char *,DATA_OBJECT_PTR);
#endif

   LOCALE int                            EnvBuild(void *,const char *);
   LOCALE int                            EnvEval(void *,const char *,DATA_OBJECT_PTR);
   LOCALE void                           StringFunctionDefinitions(void *);
   LOCALE void                           StrCatFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           SymCatFunction(void *,DATA_OBJECT_PTR);
   LOCALE long long                      StrLengthFunction(void *);
   LOCALE void                           UpcaseFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           LowcaseFunction(void *,DATA_OBJECT_PTR);
   LOCALE long long                      StrCompareFunction(void *);
   LOCALE void                          *SubStringFunction(void *);
   LOCALE void                           StrIndexFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           EvalFunction(void *,DATA_OBJECT_PTR);
   LOCALE int                            BuildFunction(void *);
   LOCALE void                           StringToFieldFunction(void *,DATA_OBJECT *);
   LOCALE void                           StringToField(void *,const char *,DATA_OBJECT *);

#endif /* _H_strngfun */






