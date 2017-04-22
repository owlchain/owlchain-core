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
/*                                                            */
/*      6.24: Added allowed-classes slot facet.              */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_classinf
#define _H_classinf

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _CLASSINF_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE intBool                        ClassAbstractPCommand(void *);
#if DEFRULE_CONSTRUCT
   LOCALE intBool                        ClassReactivePCommand(void *);
#endif
   LOCALE void                          *ClassInfoFnxArgs(void *,const char *,int *);
   LOCALE void                           ClassSlotsCommand(void *,DATA_OBJECT *);
   LOCALE void                           ClassSuperclassesCommand(void *,DATA_OBJECT *);
   LOCALE void                           ClassSubclassesCommand(void *,DATA_OBJECT *);
   LOCALE void                           GetDefmessageHandlersListCmd(void *,DATA_OBJECT *);
   LOCALE void                           SlotFacetsCommand(void *,DATA_OBJECT *);
   LOCALE void                           SlotSourcesCommand(void *,DATA_OBJECT *);
   LOCALE void                           SlotTypesCommand(void *,DATA_OBJECT *);
   LOCALE void                           SlotAllowedValuesCommand(void *,DATA_OBJECT *);
   LOCALE void                           SlotAllowedClassesCommand(void *,DATA_OBJECT *);
   LOCALE void                           SlotRangeCommand(void *,DATA_OBJECT *);
   LOCALE void                           SlotCardinalityCommand(void *,DATA_OBJECT *);
   LOCALE intBool                        EnvClassAbstractP(void *,void *);
#if DEFRULE_CONSTRUCT
   LOCALE intBool                        EnvClassReactiveP(void *,void *);
#endif
   LOCALE void                           EnvClassSlots(void *,void *,DATA_OBJECT *,int);
   LOCALE void                           EnvGetDefmessageHandlerList(void *,void *,DATA_OBJECT *,int);
   LOCALE void                           EnvClassSuperclasses(void *,void *,DATA_OBJECT *,int);
   LOCALE void                           EnvClassSubclasses(void *,void *,DATA_OBJECT *,int);
   LOCALE void                           ClassSubclassAddresses(void *,void *,DATA_OBJECT *,int);
   LOCALE void                           EnvSlotFacets(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           EnvSlotSources(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           EnvSlotTypes(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           EnvSlotAllowedValues(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           EnvSlotAllowedClasses(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           EnvSlotRange(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           EnvSlotCardinality(void *,void *,const char *,DATA_OBJECT *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE intBool                        ClassAbstractP(void *);
#if DEFRULE_CONSTRUCT
   LOCALE intBool                        ClassReactiveP(void *);
#endif
   LOCALE void                           ClassSlots(void *,DATA_OBJECT *,int);
   LOCALE void                           ClassSubclasses(void *,DATA_OBJECT *,int);
   LOCALE void                           ClassSuperclasses(void *,DATA_OBJECT *,int);
   LOCALE void                           SlotAllowedValues(void *,const char *,DATA_OBJECT *);
   LOCALE void                           SlotAllowedClasses(void *,const char *,DATA_OBJECT *);
   LOCALE void                           SlotCardinality(void *,const char *,DATA_OBJECT *);
   LOCALE void                           SlotFacets(void *,const char *,DATA_OBJECT *);
   LOCALE void                           SlotRange(void *,const char *,DATA_OBJECT *);
   LOCALE void                           SlotSources(void *,const char *,DATA_OBJECT *);
   LOCALE void                           SlotTypes(void *,const char *,DATA_OBJECT *);
   LOCALE void                           GetDefmessageHandlerList(void *,DATA_OBJECT *,int);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_classinf */





