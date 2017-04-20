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
/* Revision History:                                          */
/*                                                            */
/*      6.24: Converted INSTANCE_PATTERN_MATCHING to          */
/*            DEFRULE_CONSTRUCT.                              */
/*                                                            */
/*            Renamed BOOLEAN macro type to intBool.          */
/*                                                            */
/*      6.30: Changed integer type/precision.                 */
/*                                                            */
/*            Support for long long integers.                 */
/*                                                            */
/*            Added const qualifiers to remove C++            */
/*            deprecation warnings.                           */
/*                                                            */
/*************************************************************/

#ifndef _H_clsltpsr
#define _H_clsltpsr

#if OBJECT_SYSTEM && (! BLOAD_ONLY) && (! RUN_TIME)

#define MATCH_RLN            "pattern-match"
#define REACTIVE_RLN         "reactive"
#define NONREACTIVE_RLN      "non-reactive"

#ifndef _H_object
#include "object.h"
#endif

typedef struct tempSlotLink
  {
   SLOT_DESC *desc;
   struct tempSlotLink *nxt;
  } TEMP_SLOT_LINK;

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _CLSLTPSR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

LOCALE TEMP_SLOT_LINK *ParseSlot(void *,const char *,TEMP_SLOT_LINK *,PACKED_CLASS_LINKS *,int,int);
LOCALE void DeleteSlots(void *,TEMP_SLOT_LINK *);

#ifndef _CLSLTPSR_SOURCE_
#endif

#endif

#endif





