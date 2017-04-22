   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            PREDICATE FUNCTIONS HEADER FILE          */
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
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*************************************************************/

#ifndef _H_prdctfun

#define _H_prdctfun

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _PRDCTFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           PredicateFunctionDefinitions(void *);
   LOCALE intBool                        EqFunction(void *);
   LOCALE intBool                        NeqFunction(void *);
   LOCALE intBool                        StringpFunction(void *);
   LOCALE intBool                        SymbolpFunction(void *);
   LOCALE intBool                        LexemepFunction(void *);
   LOCALE intBool                        NumberpFunction(void *);
   LOCALE intBool                        FloatpFunction(void *);
   LOCALE intBool                        IntegerpFunction(void *);
   LOCALE intBool                        MultifieldpFunction(void *);
   LOCALE intBool                        PointerpFunction(void *);
   LOCALE intBool                        NotFunction(void *);
   LOCALE intBool                        AndFunction(void *);
   LOCALE intBool                        OrFunction(void *);
   LOCALE intBool                        LessThanOrEqualFunction(void *);
   LOCALE intBool                        GreaterThanOrEqualFunction(void *);
   LOCALE intBool                        LessThanFunction(void *);
   LOCALE intBool                        GreaterThanFunction(void *);
   LOCALE intBool                        NumericEqualFunction(void *);
   LOCALE intBool                        NumericNotEqualFunction(void *);
   LOCALE intBool                        OddpFunction(void *);
   LOCALE intBool                        EvenpFunction(void *);

#endif /* _H_prdctfun */



