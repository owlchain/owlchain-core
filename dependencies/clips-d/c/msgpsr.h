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
/*      6.23: Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Removed IMPERATIVE_MESSAGE_HANDLERS            */
/*                    compilation flag.                      */
/*                                                           */
/*      6.30: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            GetConstructNameAndComment API change.         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Fixed linkage issue when BLOAD_AND_SAVE        */
/*            compiler flag is set to 0.                     */
/*                                                           */
/*************************************************************/

#ifndef _H_msgpsr
#define _H_msgpsr

#if OBJECT_SYSTEM && (! BLOAD_ONLY) && (! RUN_TIME)

#define SELF_STRING     "self"

#ifndef _H_object
#include "object.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MSGCOM_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE int              ParseDefmessageHandler(void *,const char *);
   LOCALE void             CreateGetAndPutHandlers(void *,SLOT_DESC *);

#endif /* OBJECT_SYSTEM && (! BLOAD_ONLY) && (! RUN_TIME) */

#endif /* _H_msgpsr */



