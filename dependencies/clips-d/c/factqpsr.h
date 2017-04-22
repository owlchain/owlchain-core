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
/*      Gary D. Riley                                        */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Added fact-set queries.                        */
/*                                                           */
/*            Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Fixed memory leaks when error occurred.        */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_factqpsr
#define _H_factqpsr

#if FACT_SET_QUERIES && (! RUN_TIME)

#ifndef _H_expressn
#include "expressn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _FACTQPSR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE EXPRESSION                    *FactParseQueryNoAction(void *,EXPRESSION *,const char *);
   LOCALE EXPRESSION                    *FactParseQueryAction(void *,EXPRESSION *,const char *);

#endif /* FACT_SET_QUERIES && (! RUN_TIME) */

#endif /* _H_factqpsr */
