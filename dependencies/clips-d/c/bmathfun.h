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

#ifndef _H_bmathfun

#define _H_bmathfun

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _BMATHFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                    BasicMathFunctionDefinitions(void *);
   LOCALE void                    AdditionFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    MultiplicationFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    SubtractionFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    DivisionFunction(void *,DATA_OBJECT_PTR);
   LOCALE long long               DivFunction(void *);
   LOCALE intBool                 SetAutoFloatDividendCommand(void *);
   LOCALE intBool                 GetAutoFloatDividendCommand(void *);
   LOCALE intBool                 EnvGetAutoFloatDividend(void *);
   LOCALE intBool                 EnvSetAutoFloatDividend(void *,int);
   LOCALE long long               IntegerFunction(void *);
   LOCALE double                  FloatFunction(void *);
   LOCALE void                    AbsFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    MinFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    MaxFunction(void *,DATA_OBJECT_PTR);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE intBool                 GetAutoFloatDividend(void);
   LOCALE intBool                 SetAutoFloatDividend(int);

#endif

#endif




