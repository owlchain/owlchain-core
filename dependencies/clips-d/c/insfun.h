   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                INSTANCE FUNCTIONS MODULE            */
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
/*            Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*            Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Link error occurs for the SlotExistError       */
/*            function when OBJECT_SYSTEM is set to 0 in     */
/*            setup.h. DR0865                                */
/*                                                           */
/*            Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Moved EvaluateAndStoreInDataObject to          */
/*            evaluatn.c                                     */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed slot override default ?NONE bug.         */
/*                                                           */
//*************************************************************/

#ifndef _H_insfun
#define _H_insfun

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_moduldef
#include "moduldef.h"
#endif
#ifndef _H_object
#include "object.h"
#endif

#ifndef _H_pattern
#include "pattern.h"
#endif

typedef struct igarbage
  {
   INSTANCE_TYPE *ins;
   struct igarbage *nxt;
  } IGARBAGE;

#define INSTANCE_TABLE_HASH_SIZE 8191
#define InstanceSizeHeuristic(ins)      sizeof(INSTANCE_TYPE)

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INSFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           EnvIncrementInstanceCount(void *,void *);
   LOCALE void                           EnvDecrementInstanceCount(void *,void *);
   LOCALE void                           InitializeInstanceTable(void *);
   LOCALE void                           CleanupInstances(void *);
   LOCALE unsigned                       HashInstance(SYMBOL_HN *);
   LOCALE void                           DestroyAllInstances(void *);
   LOCALE void                           RemoveInstanceData(void *,INSTANCE_TYPE *);
   LOCALE INSTANCE_TYPE                 *FindInstanceBySymbol(void *,SYMBOL_HN *);
   LOCALE INSTANCE_TYPE                 *FindInstanceInModule(void *,SYMBOL_HN *,struct defmodule *,
                                           struct defmodule *,unsigned);
   LOCALE INSTANCE_SLOT                 *FindInstanceSlot(void *,INSTANCE_TYPE *,SYMBOL_HN *);
   LOCALE int                            FindInstanceTemplateSlot(void *,DEFCLASS *,SYMBOL_HN *);
   LOCALE int                            PutSlotValue(void *,INSTANCE_TYPE *,INSTANCE_SLOT *,DATA_OBJECT *,DATA_OBJECT *,const char *);
   LOCALE int                            DirectPutSlotValue(void *,INSTANCE_TYPE *,INSTANCE_SLOT *,DATA_OBJECT *,DATA_OBJECT *);
   LOCALE intBool                        ValidSlotValue(void *,DATA_OBJECT *,SLOT_DESC *,INSTANCE_TYPE *,const char *);
   LOCALE INSTANCE_TYPE                 *CheckInstance(void *,const char *);
   LOCALE void                           NoInstanceError(void *,const char *,const char *);
   LOCALE void                           StaleInstanceAddress(void *,const char *,int);
   LOCALE int                            EnvGetInstancesChanged(void *);
   LOCALE void                           EnvSetInstancesChanged(void *,int);
   LOCALE void                           PrintSlot(void *,const char *,SLOT_DESC *,INSTANCE_TYPE *,const char *);
   LOCALE void                           PrintInstanceNameAndClass(void *,const char *,INSTANCE_TYPE *,intBool);
   LOCALE void                           PrintInstanceName(void *,const char *,void *);
   LOCALE void                           PrintInstanceLongForm(void *,const char *,void *);
#if DEFRULE_CONSTRUCT && OBJECT_SYSTEM
   LOCALE void                           DecrementObjectBasisCount(void *,void *);
   LOCALE void                           IncrementObjectBasisCount(void *,void *);
   LOCALE void                           MatchObjectFunction(void *,void *);
   LOCALE intBool                        NetworkSynchronized(void *,void *);
   LOCALE intBool                        InstanceIsDeleted(void *,void *);
#endif

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE void                           DecrementInstanceCount(void *);
   LOCALE int                            GetInstancesChanged(void);
   LOCALE void                           IncrementInstanceCount(void *);
   LOCALE void                           SetInstancesChanged(int);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_insfun */







