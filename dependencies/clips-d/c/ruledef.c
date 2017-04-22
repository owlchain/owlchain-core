   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*                   DEFRULE MODULE                    */
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
/*            Changed find construct functionality so that    */
/*            imported modules are search when locating a    */
/*            named construct.                               */
/*                                                           */
/*************************************************************/

#define _RULEDEF_SOURCE_

#include "setup.h"

#if DEFRULE_CONSTRUCT

#include <stdio.h>
#define _STDIO_INCLUDED_

#include "agenda.h"
#include "drive.h"
#include "engine.h"
#include "envrnmnt.h"
#include "memalloc.h"
#include "pattern.h"
#include "retract.h"
#include "reteutil.h"
#include "rulebsc.h"
#include "rulecom.h"
#include "rulepsr.h"
#include "ruledlt.h"

#if BLOAD || BLOAD_AND_BSAVE || BLOAD_ONLY
#include "bload.h"
#include "rulebin.h"
#endif

#if CONSTRUCT_COMPILER && (! RUN_TIME)
#include "rulecmp.h"
#endif

#include "ruledef.h"

/***************************************/
/* LOCAL INTERNAL FUNCTION DEFINITIONS */
/***************************************/

   static void                   *AllocateModule(void *);
   static void                    ReturnModule(void *,void *);
   static void                    InitializeDefruleModules(void *);
   static void                    DeallocateDefruleData(void *);
   static void                    DestroyDefruleAction(void *,struct constructHeader *,void *);
#if RUN_TIME   
   static void                    AddBetaMemoriesToRule(void *,struct joinNode *);
#endif

/**********************************************************/
/* InitializeDefrules: Initializes the defrule construct. */
/**********************************************************/
globle void InitializeDefrules(
  void *theEnv)
  {   
   unsigned long i;
   AllocateEnvironmentData(theEnv,DEFRULE_DATA,sizeof(struct defruleData),DeallocateDefruleData);

   InitializeEngine(theEnv);
   InitializeAgenda(theEnv);
   InitializePatterns(theEnv);
   InitializeDefruleModules(theEnv);

   AddReservedPatternSymbol(theEnv,"and",NULL);
   AddReservedPatternSymbol(theEnv,"not",NULL);
   AddReservedPatternSymbol(theEnv,"or",NULL);
   AddReservedPatternSymbol(theEnv,"test",NULL);
   AddReservedPatternSymbol(theEnv,"logical",NULL);
   AddReservedPatternSymbol(theEnv,"exists",NULL);
   AddReservedPatternSymbol(theEnv,"forall",NULL);

   DefruleBasicCommands(theEnv);

   DefruleCommands(theEnv);

   DefruleData(theEnv)->DefruleConstruct =
      AddConstruct(theEnv,"defrule","defrules",
                   ParseDefrule,EnvFindDefrule,
                   GetConstructNamePointer,GetConstructPPForm,
                   GetConstructModuleItem,EnvGetNextDefrule,SetNextConstruct,
                   EnvIsDefruleDeletable,EnvUndefrule,ReturnDefrule);

   DefruleData(theEnv)->AlphaMemoryTable = (ALPHA_MEMORY_HASH **)
                  gm3(theEnv,sizeof (ALPHA_MEMORY_HASH *) * ALPHA_MEMORY_HASH_SIZE);

   for (i = 0; i < ALPHA_MEMORY_HASH_SIZE; i++) DefruleData(theEnv)->AlphaMemoryTable[i] = NULL;

   DefruleData(theEnv)->BetaMemoryResizingFlag = TRUE;
   
   DefruleData(theEnv)->RightPrimeJoins = NULL;
   DefruleData(theEnv)->LeftPrimeJoins = NULL;   
  }
  
/**************************************************/
/* DeallocateDefruleData: Deallocates environment */
/*    data for the defrule construct.             */
/**************************************************/
static void DeallocateDefruleData(
  void *theEnv)
  {
   struct defruleModule *theModuleItem;
   void *theModule;
   struct activation *theActivation, *tmpActivation;
   struct salienceGroup *theGroup, *tmpGroup;

#if BLOAD || BLOAD_AND_BSAVE
   if (Bloaded(theEnv))
     { return; }
#endif
   
   DoForAllConstructs(theEnv,DestroyDefruleAction,DefruleData(theEnv)->DefruleModuleIndex,FALSE,NULL);

   for (theModule = EnvGetNextDefmodule(theEnv,NULL);
        theModule != NULL;
        theModule = EnvGetNextDefmodule(theEnv,theModule))
     {
      theModuleItem = (struct defruleModule *)
                      GetModuleItem(theEnv,(struct defmodule *) theModule,
                                    DefruleData(theEnv)->DefruleModuleIndex);
                                    
      theActivation = theModuleItem->agenda;
      while (theActivation != NULL)
        {
         tmpActivation = theActivation->next;
         
         rtn_struct(theEnv,activation,theActivation);
         
         theActivation = tmpActivation;
        }
        
      theGroup = theModuleItem->groupings;
      while (theGroup != NULL)
        {
         tmpGroup = theGroup->next;
         
         rtn_struct(theEnv,salienceGroup,theGroup);
         
         theGroup = tmpGroup;
        }        

#if ! RUN_TIME                                    
      rtn_struct(theEnv,defruleModule,theModuleItem);
#endif
     }   
     
   rm3(theEnv,DefruleData(theEnv)->AlphaMemoryTable,sizeof (ALPHA_MEMORY_HASH *) * ALPHA_MEMORY_HASH_SIZE);
  }
  
/********************************************************/
/* DestroyDefruleAction: Action used to remove defrules */
/*   as a result of DestroyEnvironment.                 */
/********************************************************/
static void DestroyDefruleAction(
  void *theEnv,
  struct constructHeader *theConstruct,
  void *buffer)
  {
#if MAC_XCD
#pragma unused(buffer)
#endif
   struct defrule *theDefrule = (struct defrule *) theConstruct;
   
   DestroyDefrule(theEnv,theDefrule);
  }

/*****************************************************/
/* InitializeDefruleModules: Initializes the defrule */
/*   construct for use with the defmodule construct. */
/*****************************************************/
static void InitializeDefruleModules(
  void *theEnv)
  {
   DefruleData(theEnv)->DefruleModuleIndex = RegisterModuleItem(theEnv,"defrule",
                                    AllocateModule,
                                    ReturnModule,
#if BLOAD_AND_BSAVE || BLOAD || BLOAD_ONLY
                                    BloadDefruleModuleReference,
#else
                                    NULL,
#endif
#if CONSTRUCT_COMPILER && (! RUN_TIME)
                                    DefruleCModuleReference,
#else
                                    NULL,
#endif
                                    EnvFindDefruleInModule);
  }

/***********************************************/
/* AllocateModule: Allocates a defrule module. */
/***********************************************/
static void *AllocateModule(
  void *theEnv)
  {
   struct defruleModule *theItem;

   theItem = get_struct(theEnv,defruleModule);
   theItem->agenda = NULL;
   theItem->groupings = NULL;
   return((void *) theItem);
  }

/*********************************************/
/* ReturnModule: Deallocates a defrule module. */
/*********************************************/
static void ReturnModule(
  void *theEnv,
  void *theItem)
  {
   FreeConstructHeaderModule(theEnv,(struct defmoduleItemHeader *) theItem,DefruleData(theEnv)->DefruleConstruct);
   rtn_struct(theEnv,defruleModule,theItem);
  }

/************************************************************/
/* GetDefruleModuleItem: Returns a pointer to the defmodule */
/*  item for the specified defrule or defmodule.            */
/************************************************************/
globle struct defruleModule *GetDefruleModuleItem(
  void *theEnv,
  struct defmodule *theModule)
  {   
   return((struct defruleModule *) GetConstructModuleItemByIndex(theEnv,theModule,DefruleData(theEnv)->DefruleModuleIndex)); 
  }

/*******************************************************************/
/* EnvFindDefrule: Searches for a defrule in the list of defrules. */
/*   Returns a pointer to the defrule if found, otherwise NULL.    */
/*******************************************************************/
globle void *EnvFindDefrule(
  void *theEnv,
  const char *defruleName)
  {   
   return(FindNamedConstructInModuleOrImports(theEnv,defruleName,DefruleData(theEnv)->DefruleConstruct)); 
  }

/*******************************************************************/
/* EnvFindDefruleInModule: Searches for a defrule in the list of defrules. */
/*   Returns a pointer to the defrule if found, otherwise NULL.    */
/*******************************************************************/
globle void *EnvFindDefruleInModule(
  void *theEnv,
  const char *defruleName)
  {   
   return(FindNamedConstructInModule(theEnv,defruleName,DefruleData(theEnv)->DefruleConstruct));
  }

/************************************************************/
/* EnvGetNextDefrule: If passed a NULL pointer, returns the */
/*   first defrule in the ListOfDefrules. Otherwise returns */
/*   the next defrule following the defrule passed as an    */
/*   argument.                                              */
/************************************************************/
globle void *EnvGetNextDefrule(
  void *theEnv,
  void *defrulePtr)
  {   
   return((void *) GetNextConstructItem(theEnv,(struct constructHeader *) defrulePtr,DefruleData(theEnv)->DefruleModuleIndex)); 
  }

/*******************************************************/
/* EnvIsDefruleDeletable: Returns TRUE if a particular */
/*   defrule can be deleted, otherwise returns FALSE.  */
/*******************************************************/
globle intBool EnvIsDefruleDeletable(
  void *theEnv,
  void *vTheDefrule)
  {
   struct defrule *theDefrule;

   if (! ConstructsDeletable(theEnv))
     { return FALSE; }

   for (theDefrule = (struct defrule *) vTheDefrule;
        theDefrule != NULL;
        theDefrule = theDefrule->disjunct)
     { if (theDefrule->executing) return(FALSE); }

   if (EngineData(theEnv)->JoinOperationInProgress) return(FALSE);

   return(TRUE);
  }

/***********************************************************/
/* EnvGetDisjunctCount: Returns the number of disjuncts of */
/*   a rule (permutations caused by the use of or CEs).    */
/***********************************************************/
globle long EnvGetDisjunctCount(
  void *theEnv,
  void *vTheDefrule)
  {
   struct defrule *theDefrule;
   long count = 0;

   for (theDefrule = (struct defrule *) vTheDefrule;
        theDefrule != NULL;
        theDefrule = theDefrule->disjunct)
     { count++; }

   return(count);
  }

/**********************************************************/
/* EnvGetNthDisjunct: Returns the nth disjunct of a rule. */
/*   The disjunct indices run from 1 to N rather than 0   */
/*   to N - 1.                                            */
/**********************************************************/
globle void *EnvGetNthDisjunct(
  void *theEnv,
  void *vTheDefrule,
  long index)
  {
   struct defrule *theDefrule;
   long count = 0;

   for (theDefrule = (struct defrule *) vTheDefrule;
        theDefrule != NULL;
        theDefrule = theDefrule->disjunct)
     {
      count++;
      if (count == index)
        { return theDefrule; }
     }

   return(NULL);
  }

#if RUN_TIME

/******************************************/
/* DefruleRunTimeInitialize:  Initializes */
/*   defrule in a run-time module.        */
/******************************************/
globle void DefruleRunTimeInitialize(
  void *theEnv,
  struct joinLink *rightPrime,
  struct joinLink *leftPrime)
  {
   struct defmodule *theModule;
   struct defrule *theRule, *theDisjunct;

   DefruleData(theEnv)->RightPrimeJoins = rightPrime;
   DefruleData(theEnv)->LeftPrimeJoins = leftPrime;   

   SaveCurrentModule(theEnv);

   for (theModule = (struct defmodule *) EnvGetNextDefmodule(theEnv,NULL);
        theModule != NULL;
        theModule = (struct defmodule *) EnvGetNextDefmodule(theEnv,theModule))
     {
      EnvSetCurrentModule(theEnv,(void *) theModule);
      for (theRule = (struct defrule *) EnvGetNextDefrule(theEnv,NULL);
           theRule != NULL;
           theRule = (struct defrule *) EnvGetNextDefrule(theEnv,theRule))
        { 
         for (theDisjunct = theRule;
              theDisjunct != NULL;
              theDisjunct = theDisjunct->disjunct)
           { AddBetaMemoriesToRule(theEnv,theDisjunct->lastJoin); }
        }
     }
     
   RestoreCurrentModule(theEnv);
  }


/******************************************/
/* AddBetaMemoriesToRule:     */
/******************************************/
static void AddBetaMemoriesToRule(
  void *theEnv,
  struct joinNode *theNode)
  {
   AddBetaMemoriesToJoin(theEnv,theNode);
   
   if (theNode->lastLevel != NULL)
     { AddBetaMemoriesToRule(theEnv,theNode->lastLevel); }
     
   if (theNode->joinFromTheRight)
     { AddBetaMemoriesToRule(theEnv,(struct joinNode *) theNode->rightSideEntryStructure); }
  }
  
#endif /* RUN_TIME */

#if RUN_TIME || BLOAD_ONLY || BLOAD || BLOAD_AND_BSAVE

/**************************/
/* AddBetaMemoriesToJoin: */
/**************************/
globle void AddBetaMemoriesToJoin(
  void *theEnv,
  struct joinNode *theNode)
  {   
   if ((theNode->leftMemory != NULL) || (theNode->rightMemory != NULL))
     { return; }

   if ((! theNode->firstJoin) || theNode->patternIsExists || theNode-> patternIsNegated || theNode->joinFromTheRight)
     {
      if (theNode->leftHash == NULL)
        {
         theNode->leftMemory = get_struct(theEnv,betaMemory); 
         theNode->leftMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
         theNode->leftMemory->beta[0] = NULL;
         theNode->leftMemory->size = 1;
         theNode->leftMemory->count = 0;
         theNode->leftMemory->last = NULL;
        }
      else
        {
         theNode->leftMemory = get_struct(theEnv,betaMemory); 
         theNode->leftMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         memset(theNode->leftMemory->beta,0,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         theNode->leftMemory->size = INITIAL_BETA_HASH_SIZE;
         theNode->leftMemory->count = 0;
         theNode->leftMemory->last = NULL;
        }

      if (theNode->firstJoin && (theNode->patternIsExists || theNode-> patternIsNegated || theNode->joinFromTheRight))
        {
         theNode->leftMemory->beta[0] = CreateEmptyPartialMatch(theEnv); 
         theNode->leftMemory->beta[0]->owner = theNode;
        }
     }
   else
     { theNode->leftMemory = NULL; }

   if (theNode->joinFromTheRight)
     {
      if (theNode->leftHash == NULL)
        {
         theNode->rightMemory = get_struct(theEnv,betaMemory); 
         theNode->rightMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
         theNode->rightMemory->last = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
         theNode->rightMemory->beta[0] = NULL;
         theNode->rightMemory->last[0] = NULL;
         theNode->rightMemory->size = 1;
         theNode->rightMemory->count = 0;
        }
      else
        {
         theNode->rightMemory = get_struct(theEnv,betaMemory); 
         theNode->rightMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         theNode->rightMemory->last = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         memset(theNode->rightMemory->beta,0,sizeof(struct partialMatch **) * INITIAL_BETA_HASH_SIZE);
         memset(theNode->rightMemory->last,0,sizeof(struct partialMatch **) * INITIAL_BETA_HASH_SIZE);
         theNode->rightMemory->size = INITIAL_BETA_HASH_SIZE;
         theNode->rightMemory->count = 0;
        }
     }
   else if (theNode->rightSideEntryStructure == NULL)
     {
      theNode->rightMemory = get_struct(theEnv,betaMemory); 
      theNode->rightMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
      theNode->rightMemory->last = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
      theNode->rightMemory->beta[0] = CreateEmptyPartialMatch(theEnv);
      theNode->rightMemory->beta[0]->owner = theNode;
      theNode->rightMemory->beta[0]->rhsMemory = TRUE;
      theNode->rightMemory->last[0] = theNode->rightMemory->beta[0];
      theNode->rightMemory->size = 1;
      theNode->rightMemory->count = 1;    
     }
   else
     { theNode->rightMemory = NULL; }
  }

#endif /* RUN_TIME || BLOAD_ONLY || BLOAD || BLOAD_AND_BSAVE */

/*##################################*/
/* Additional Environment Functions */
/*##################################*/

globle const char *EnvDefruleModule(
  void *theEnv,
  void *theDefrule)
  {
   return GetConstructModuleName((struct constructHeader *) theDefrule);
  }

globle const char *EnvGetDefruleName(
  void *theEnv,
  void *theDefrule)
  {
   return GetConstructNameString((struct constructHeader *) theDefrule);
  }

globle const char *EnvGetDefrulePPForm(
  void *theEnv,
  void *theDefrule)
  {
   return GetConstructPPForm(theEnv,(struct constructHeader *) theDefrule);
  }

/*#####################################*/
/* ALLOW_ENVIRONMENT_GLOBALS Functions */
/*#####################################*/

#if ALLOW_ENVIRONMENT_GLOBALS

globle const char *DefruleModule(
  void *theDefrule)
  {
   return EnvDefruleModule(GetCurrentEnvironment(),theDefrule);
  }

globle void *FindDefrule(
  const char *defruleName)
  {
   return EnvFindDefrule(GetCurrentEnvironment(),defruleName);
  }

globle const char *GetDefruleName(
  void *theDefrule)
  {
   return EnvGetDefruleName(GetCurrentEnvironment(),theDefrule);
  }

globle const char *GetDefrulePPForm(
  void *theDefrule)
  {
   return EnvGetDefrulePPForm(GetCurrentEnvironment(),theDefrule);
  }

globle void *GetNextDefrule(
  void *defrulePtr)
  {
   return EnvGetNextDefrule(GetCurrentEnvironment(),defrulePtr);
  }

globle intBool IsDefruleDeletable(
  void *vTheDefrule)
  {
   return EnvIsDefruleDeletable(GetCurrentEnvironment(),vTheDefrule);
  }

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* DEFRULE_CONSTRUCT */


