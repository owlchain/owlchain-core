   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*                 DEFRULE HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Defines basic defrule primitive functions such   */
/*   as allocating and deallocating, traversing, and finding */
/*   defrule data structures.                                */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed DYNAMIC_SALIENCE and                   */
/*            LOGICAL_DEPENDENCIES compilation flags.        */
/*                                                           */
/*            Removed CONFLICT_RESOLUTION_STRATEGIES         */
/*            compilation flag.                              */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warnings.                             */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added support for hashed memories.             */
/*                                                           */
/*            Added additional developer statistics to help  */
/*            analyze join network performance.              */
/*                                                           */
/*            Added salience groups to improve performance   */
/*            with large numbers of activations of different */
/*            saliences.                                     */
/*                                                           */
/*            Added EnvGetDisjunctCount and                  */
/*            EnvGetNthDisjunct functions.                   */
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

#ifndef _H_ruledef
#define _H_ruledef

#define GetDisjunctIndex(r) ((struct constructHeader *) r)->bsaveID

struct defrule;
struct defruleModule;

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
#ifndef _H_cstrccom
#include "cstrccom.h"
#endif
#ifndef _H_agenda
#include "agenda.h"
#endif
#ifndef _H_network
#include "network.h"
#endif

struct defrule
  {
   struct constructHeader header;
   int salience;
   int localVarCnt;
   unsigned int complexity      : 11;
   unsigned int afterBreakpoint :  1;
   unsigned int watchActivation :  1;
   unsigned int watchFiring     :  1;
   unsigned int autoFocus       :  1;
   unsigned int executing       :  1;
   struct expr *dynamicSalience;
   struct expr *actions;
   struct joinNode *logicalJoin;
   struct joinNode *lastJoin;
   struct defrule *disjunct;
  };

struct defruleModule
  {
   struct defmoduleItemHeader header;
   struct salienceGroup *groupings;
   struct activation *agenda;
  };

#ifndef ALPHA_MEMORY_HASH_SIZE
#define ALPHA_MEMORY_HASH_SIZE       63559L
#endif

#define DEFRULE_DATA 16

struct defruleData
  { 
   struct construct *DefruleConstruct;
   int DefruleModuleIndex;
   long long CurrentEntityTimeTag;
   struct alphaMemoryHash **AlphaMemoryTable;
   intBool BetaMemoryResizingFlag;
   struct joinLink *RightPrimeJoins;
   struct joinLink *LeftPrimeJoins;

#if DEBUGGING_FUNCTIONS
    unsigned WatchRules;
    int DeletedRuleDebugFlags;
#endif
#if DEVELOPER && (! RUN_TIME) && (! BLOAD_ONLY)
    unsigned WatchRuleAnalysis;
#endif
#if CONSTRUCT_COMPILER && (! RUN_TIME)
   struct CodeGeneratorItem *DefruleCodeItem;
#endif
  };

#define DefruleData(theEnv) ((struct defruleData *) GetEnvironmentData(theEnv,DEFRULE_DATA))

#define GetPreviousJoin(theJoin) \
   (((theJoin)->joinFromTheRight) ? \
    ((struct joinNode *) (theJoin)->rightSideEntryStructure) : \
    ((theJoin)->lastLevel))
#define GetPatternForJoin(theJoin) \
   (((theJoin)->joinFromTheRight) ? \
    NULL : \
    ((theJoin)->rightSideEntryStructure))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _RULEDEF_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InitializeDefrules(void *);
   LOCALE void                          *EnvFindDefrule(void *,const char *);
   LOCALE void                          *EnvFindDefruleInModule(void *,const char *);
   LOCALE void                          *EnvGetNextDefrule(void *,void *);
   LOCALE struct defruleModule          *GetDefruleModuleItem(void *,struct defmodule *);
   LOCALE intBool                        EnvIsDefruleDeletable(void *,void *);
#if RUN_TIME
   LOCALE void                           DefruleRunTimeInitialize(void *,struct joinLink *,struct joinLink *);
#endif
#if RUN_TIME || BLOAD_ONLY || BLOAD || BLOAD_AND_BSAVE
   LOCALE void                           AddBetaMemoriesToJoin(void *,struct joinNode *);
#endif
   LOCALE long                           EnvGetDisjunctCount(void *,void *);
   LOCALE void                          *EnvGetNthDisjunct(void *,void *,long);
   LOCALE const char                    *EnvDefruleModule(void *,void *);
   LOCALE const char                    *EnvGetDefruleName(void *,void *);
   LOCALE const char                    *EnvGetDefrulePPForm(void *,void *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE const char                    *DefruleModule(void *);
   LOCALE void                          *FindDefrule(const char *);
   LOCALE const char                    *GetDefruleName(void *);
   LOCALE const char                    *GetDefrulePPForm(void *);
   LOCALE void                          *GetNextDefrule(void *);
   LOCALE intBool                        IsDefruleDeletable(void *);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */


#endif /* _H_ruledef */


