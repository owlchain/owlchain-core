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
/*      6.23: Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Removed IMPERATIVE_METHODS compilation flag.   */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when DEBUGGING_FUNCTIONS   */
/*            is set to 0 and PROFILING_FUNCTIONS is set to  */
/*            1.                                             */
/*                                                           */
/*            Fixed typing issue when OBJECT_SYSTEM          */
/*            compiler flag is set to 0.                     */
/*                                                           */
/*************************************************************/

#ifndef _H_genrcfun
#define _H_genrcfun

typedef struct defgenericModule DEFGENERIC_MODULE;
typedef struct restriction RESTRICTION;
typedef struct method DEFMETHOD;
typedef struct defgeneric DEFGENERIC;

#ifndef _STDIO_INCLUDED_
#define _STDIO_INCLUDED_
#include <stdio.h>
#endif

#ifndef _H_conscomp
#include "conscomp.h"
#endif
#ifndef _H_constrct
#include "constrct.h"
#endif
#ifndef _H_moduldef
#include "moduldef.h"
#endif
#ifndef _H_symbol
#include "symbol.h"
#endif
#ifndef _H_expressn
#include "expressn.h"
#endif
#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#if OBJECT_SYSTEM
#ifndef _H_object
#include "object.h"
#endif
#endif

struct defgenericModule
  {
   struct defmoduleItemHeader header;
  };

struct restriction
  {
   void **types;
   EXPRESSION *query;
   short tcnt;
  };

struct method
  {
   short index;
   unsigned busy;
   short restrictionCount;
   short minRestrictions;
   short maxRestrictions;
   short localVarCount;
   unsigned system : 1;
   unsigned trace : 1;
   RESTRICTION *restrictions;
   EXPRESSION *actions;
   char *ppForm;
   struct userData *usrData;
  };

struct defgeneric
  {
   struct constructHeader header;
   unsigned busy,trace;
   DEFMETHOD *methods;
   short mcnt;
   short new_index;
  };

#define DEFGENERIC_DATA 27

struct defgenericData
  { 
   struct construct *DefgenericConstruct;
   int DefgenericModuleIndex;
   ENTITY_RECORD GenericEntityRecord;
#if DEBUGGING_FUNCTIONS
   unsigned WatchGenerics;
   unsigned WatchMethods;
#endif
   DEFGENERIC *CurrentGeneric;
   DEFMETHOD *CurrentMethod;
   DATA_OBJECT *GenericCurrentArgument;
#if (! RUN_TIME) && (! BLOAD_ONLY)
   unsigned OldGenericBusySave;
#endif
#if CONSTRUCT_COMPILER && (! RUN_TIME)
   struct CodeGeneratorItem *DefgenericCodeItem;
#endif
#if (! BLOAD_ONLY) && (! RUN_TIME)
   struct token GenericInputToken;
#endif
  };

#define DefgenericData(theEnv) ((struct defgenericData *) GetEnvironmentData(theEnv,DEFGENERIC_DATA))
#define SaveBusyCount(gfunc)    (DefgenericData(theEnv)->OldGenericBusySave = gfunc->busy)
#define RestoreBusyCount(gfunc) (gfunc->busy = DefgenericData(theEnv)->OldGenericBusySave)

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _GENRCFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ! RUN_TIME
   LOCALE intBool                        ClearDefgenericsReady(void *);
   LOCALE void                          *AllocateDefgenericModule(void *);
   LOCALE void                           FreeDefgenericModule(void *,void *);
#endif

#if (! BLOAD_ONLY) && (! RUN_TIME)

   LOCALE int                            ClearDefmethods(void *);
   LOCALE int                            RemoveAllExplicitMethods(void *,DEFGENERIC *);
   LOCALE void                           RemoveDefgeneric(void *,void *);
   LOCALE int                            ClearDefgenerics(void *);
   LOCALE void                           MethodAlterError(void *,DEFGENERIC *);
   LOCALE void                           DeleteMethodInfo(void *,DEFGENERIC *,DEFMETHOD *);
   LOCALE void                           DestroyMethodInfo(void *,DEFGENERIC *,DEFMETHOD *);
   LOCALE int                            MethodsExecuting(DEFGENERIC *);
#endif
#if ! OBJECT_SYSTEM
   LOCALE intBool                        SubsumeType(int,int);
#endif

   LOCALE long                           FindMethodByIndex(DEFGENERIC *,long);
#if DEBUGGING_FUNCTIONS || PROFILING_FUNCTIONS
   LOCALE void                           PrintMethod(void *,char *,size_t,DEFMETHOD *);
#endif
#if DEBUGGING_FUNCTIONS
   LOCALE void                           PreviewGeneric(void *);
#endif
   LOCALE DEFGENERIC                    *CheckGenericExists(void *,const char *,const char *);
   LOCALE long                           CheckMethodExists(void *,const char *,DEFGENERIC *,long);

#if ! OBJECT_SYSTEM
   LOCALE const char                    *TypeName(void *,int);
#endif

   LOCALE void                           PrintGenericName(void *,const char *,DEFGENERIC *);

#endif /* _H_genrcfun */

