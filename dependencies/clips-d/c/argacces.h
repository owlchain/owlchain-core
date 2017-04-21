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

#ifndef _H_argacces

#define _H_argacces

#ifndef _H_expressn
#include "expressn.h"
#endif
#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_moduldef
#include "moduldef.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _ARGACCES_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE int                            EnvRtnArgCount(void *);
   LOCALE int                            EnvArgCountCheck(void *,const char *,int,int);
   LOCALE int                            EnvArgRangeCheck(void *,const char *,int,int);
   LOCALE const char                    *EnvRtnLexeme(void *,int);
   LOCALE double                         EnvRtnDouble(void *,int);
   LOCALE long long                      EnvRtnLong(void *,int);
   LOCALE struct dataObject             *EnvRtnUnknown(void *,int,struct dataObject *);
   LOCALE int                            EnvArgTypeCheck(void *,const char *,int,int,struct dataObject *);
   LOCALE intBool                        GetNumericArgument(void *,struct expr *,const char *,struct dataObject *,int,int);
   LOCALE const char                    *GetLogicalName(void *,int,const char *);
   LOCALE const char                    *GetFileName(void *,const char *,int);
   LOCALE const char                    *GetConstructName(void *,const char *,const char *);
   LOCALE void                           ExpectedCountError(void *,const char *,int,int);
   LOCALE void                           OpenErrorMessage(void *,const char *,const char *);
   LOCALE intBool                        CheckFunctionArgCount(void *,const char *,const char *,int);
   LOCALE void                           ExpectedTypeError1(void *,const char *,int,const char *);
   LOCALE void                           ExpectedTypeError2(void *,const char *,int);
   LOCALE struct defmodule              *GetModuleName(void *,const char *,int,int *);
   LOCALE void                          *GetFactOrInstanceArgument(void *,int,DATA_OBJECT *,const char *);
   LOCALE void                           IllegalLogicalNameMessage(void *,const char *);

#if ALLOW_ENVIRONMENT_GLOBALS

  LOCALE int                             ArgCountCheck(const char *,int,int);
  LOCALE int                             ArgRangeCheck(const char *,int,int);
  LOCALE int                             ArgTypeCheck(const char *,int,int,DATA_OBJECT_PTR);
  LOCALE int                             RtnArgCount(void);
  LOCALE double                          RtnDouble(int);
  LOCALE const char                     *RtnLexeme(int);
  LOCALE long long                       RtnLong(int);
  LOCALE DATA_OBJECT_PTR                 RtnUnknown(int,DATA_OBJECT_PTR);

#endif

#endif






