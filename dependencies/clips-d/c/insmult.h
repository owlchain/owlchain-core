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
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*************************************************************/

#ifndef _H_insmult
#define _H_insmult

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INSMULT_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if (! RUN_TIME)
   LOCALE void                           SetupInstanceMultifieldCommands(void *);
#endif

   LOCALE void                           MVSlotReplaceCommand(void *,DATA_OBJECT *);
   LOCALE void                           MVSlotInsertCommand(void *,DATA_OBJECT *);
   LOCALE void                           MVSlotDeleteCommand(void *,DATA_OBJECT *);
   LOCALE intBool                        DirectMVReplaceCommand(void *);
   LOCALE intBool                        DirectMVInsertCommand(void *);
   LOCALE intBool                        DirectMVDeleteCommand(void *);

#endif /* _H_insmult */



