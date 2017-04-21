   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*               DEFTEMPLATE HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Added support for templates maintaining their  */
/*            own list of facts.                             */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warnings.                             */
/*                                                           */
/*      6.30: Added code for deftemplate run time            */
/*            initialization of hashed comparisons to        */
/*            constants.                                     */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Support for deftemplate slot facets.           */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Changed find construct functionality so that   */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

#ifndef _H_tmpltdef
#define _H_tmpltdef

struct deftemplate;
struct templateSlot;
struct deftemplateModule;

#ifndef _H_conscomp
#include "conscomp.h"
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
#ifndef _H_constrct
#include "constrct.h"
#endif
#ifndef _H_moduldef
#include "moduldef.h"
#endif
#ifndef _H_constrnt
#include "constrnt.h"
#endif
#include "factbld.h"
#ifndef _H_factmngr
#include "factmngr.h"
#endif
#ifndef _H_cstrccom
#include "cstrccom.h"
#endif

struct deftemplate
  {
   struct constructHeader header;
   struct templateSlot *slotList;
   unsigned int implied       : 1;
   unsigned int watch         : 1;
   unsigned int inScope       : 1;
   unsigned short numberOfSlots;
   long busyCount;
   struct factPatternNode *patternNetwork;
   struct fact *factList;
   struct fact *lastFact;
  };

struct templateSlot
  {
   struct symbolHashNode *slotName;
   unsigned int multislot : 1;
   unsigned int noDefault : 1;
   unsigned int defaultPresent : 1;
   unsigned int defaultDynamic : 1;
   CONSTRAINT_RECORD *constraints;
   struct expr *defaultList;
   struct expr *facetList;
   struct templateSlot *next;
  };

struct deftemplateModule
  {
   struct defmoduleItemHeader header;
  };

#define DEFTEMPLATE_DATA 5

struct deftemplateData
  { 
   struct construct *DeftemplateConstruct;
   int DeftemplateModuleIndex;
   struct entityRecord DeftemplatePtrRecord;
#if DEBUGGING_FUNCTIONS
   int DeletedTemplateDebugFlags;
#endif
#if CONSTRUCT_COMPILER && (! RUN_TIME)
   struct CodeGeneratorItem *DeftemplateCodeItem;
#endif
#if (! RUN_TIME) && (! BLOAD_ONLY)
   int DeftemplateError;
#endif
  };

#define DeftemplateData(theEnv) ((struct deftemplateData *) GetEnvironmentData(theEnv,DEFTEMPLATE_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _TMPLTDEF_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InitializeDeftemplates(void *);
   LOCALE void                          *EnvFindDeftemplate(void *,const char *);
   LOCALE void                          *EnvFindDeftemplateInModule(void *,const char *);
   LOCALE void                          *EnvGetNextDeftemplate(void *,void *);
   LOCALE intBool                        EnvIsDeftemplateDeletable(void *,void *);
   LOCALE void                          *EnvGetNextFactInTemplate(void *,void *,void *);
   LOCALE struct deftemplateModule      *GetDeftemplateModuleItem(void *,struct defmodule *);
   LOCALE void                           ReturnSlots(void *,struct templateSlot *);
   LOCALE void                           IncrementDeftemplateBusyCount(void *,void *);
   LOCALE void                           DecrementDeftemplateBusyCount(void *,void *);
   LOCALE void                          *CreateDeftemplateScopeMap(void *,struct deftemplate *);
#if RUN_TIME
   LOCALE void                           DeftemplateRunTimeInitialize(void *);
#endif
   LOCALE const char                    *EnvDeftemplateModule(void *,void *);
   LOCALE const char                    *EnvGetDeftemplateName(void *,void *);
   LOCALE const char                    *EnvGetDeftemplatePPForm(void *,void *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE const char                    *DeftemplateModule(void *);
   LOCALE void                          *FindDeftemplate(const char *);
   LOCALE const char                    *GetDeftemplateName(void *);
   LOCALE const char                    *GetDeftemplatePPForm(void *);
   LOCALE void                          *GetNextDeftemplate(void *);
   LOCALE intBool                        IsDeftemplateDeletable(void *);
   LOCALE void                          *GetNextFactInTemplate(void *,void *);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_tmpltdef */


