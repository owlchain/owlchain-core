   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*            INSTANCE PRIMITIVE SUPPORT MODULE        */
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
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_insmngr
#define _H_insmngr

#ifndef _H_object
#include "object.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INSMNGR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InitializeInstanceCommand(void *,DATA_OBJECT *);
   LOCALE void                           MakeInstanceCommand(void *,DATA_OBJECT *);
   LOCALE SYMBOL_HN                     *GetFullInstanceName(void *,INSTANCE_TYPE *);
   LOCALE INSTANCE_TYPE                 *BuildInstance(void *,SYMBOL_HN *,DEFCLASS *,intBool);
   LOCALE void                           InitSlotsCommand(void *,DATA_OBJECT *);
   LOCALE intBool                        QuashInstance(void *,INSTANCE_TYPE *);

#if DEFRULE_CONSTRUCT && OBJECT_SYSTEM
   LOCALE void                           InactiveInitializeInstance(void *,DATA_OBJECT *);
   LOCALE void                           InactiveMakeInstance(void *,DATA_OBJECT *);
#endif

#endif /* _H_insmngr */







