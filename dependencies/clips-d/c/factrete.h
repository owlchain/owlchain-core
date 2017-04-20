   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*        FACT RETE ACCESS FUNCTIONS HEADER FILE       */
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
/*      6.24: Removed INCREMENTAL_RESET compilation flag.    */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Support for hashing optimizations.             */
/*                                                           */
/*************************************************************/

#ifndef _H_factrete

#define _H_factrete

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _FACTRETE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE intBool                        FactPNGetVar1(void *,void *,DATA_OBJECT_PTR);
   LOCALE intBool                        FactPNGetVar2(void *,void *,DATA_OBJECT_PTR);
   LOCALE intBool                        FactPNGetVar3(void *,void *,DATA_OBJECT_PTR);
   LOCALE intBool                        FactJNGetVar1(void *,void *,DATA_OBJECT_PTR);
   LOCALE intBool                        FactJNGetVar2(void *,void *,DATA_OBJECT_PTR);
   LOCALE intBool                        FactJNGetVar3(void *,void *,DATA_OBJECT_PTR);
   LOCALE intBool                        FactSlotLength(void *,void *,DATA_OBJECT_PTR);
   LOCALE int                            FactJNCompVars1(void *,void *,DATA_OBJECT_PTR);
   LOCALE int                            FactJNCompVars2(void *,void *,DATA_OBJECT_PTR);
   LOCALE int                            FactPNCompVars1(void *,void *,DATA_OBJECT_PTR);
   LOCALE intBool                        FactPNConstant1(void *,void *,DATA_OBJECT_PTR);
   LOCALE intBool                        FactPNConstant2(void *,void *,DATA_OBJECT_PTR);
   LOCALE int                            FactStoreMultifield(void *,void *,DATA_OBJECT_PTR);
   LOCALE unsigned short                 AdjustFieldPosition(void *,struct multifieldMarker *,
                                                             unsigned short,unsigned short,int *);

#endif


