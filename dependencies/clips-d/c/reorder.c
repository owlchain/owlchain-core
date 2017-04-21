   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  06/14/14            */
   /*                                                     */
   /*                    REORDER MODULE                   */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides routines necessary for converting the   */
/*   the LHS of a rule into an appropriate form suitable for */
/*   the KB Rete topology. This includes transforming the    */
/*   LHS so there is at most one "or" CE (and this is the    */
/*   first CE of the LHS if it is used), adding initial      */
/*   patterns to the LHS (if no LHS is specified or a "test" */
/*   or "not" CE is the first pattern within an "and" CE),   */
/*   removing redundant CEs, and determining appropriate     */
/*   information on nesting for implementing joins from the  */
/*   right.                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Support for join network changes.              */
/*                                                           */
/*            Changes to the algorithm for processing        */
/*            not/and CE groups.                             */
/*                                                           */
/*            Additional optimizations for combining         */
/*            conditional elements.                          */
/*                                                           */
/*            Added support for hashed alpha memories.       */
/*                                                           */
/*************************************************************/

#define _REORDER_SOURCE_

#include "setup.h"

#if (! RUN_TIME) && (! BLOAD_ONLY) && DEFRULE_CONSTRUCT

#include <stdio.h>
#define _STDIO_INCLUDED_

#include "cstrnutl.h"
#include "envrnmnt.h"
#include "extnfunc.h"
#include "memalloc.h"
#include "pattern.h"
#include "prntutil.h"
#include "router.h"
#include "rulelhs.h"

#if DEVELOPER && DEBUGGING_FUNCTIONS
#include "watch.h"
#include "rulepsr.h"
#endif

#include "reorder.h"

struct variableReference
   { 
    struct symbolHashNode *name;
    int depth;
    struct variableReference *next;
   };
 
struct groupReference
   { 
    struct lhsParseNode *theGroup;
    int depth;
    struct groupReference *next;
   };
     
/***************************************/
/* LOCAL INTERNAL FUNCTION DEFINITIONS */
/***************************************/

   static struct lhsParseNode    *ReverseAndOr(void *,struct lhsParseNode *,struct lhsParseNode *,int);
   static struct lhsParseNode    *PerformReorder1(void *,struct lhsParseNode *,int *,int);
   static struct lhsParseNode    *PerformReorder2(void *,struct lhsParseNode *,int *,int);
   static struct lhsParseNode    *CompressCEs(void *,struct lhsParseNode *,int *,int);
   static void                    IncrementNandDepth(void *,struct lhsParseNode *,int);
   static struct lhsParseNode    *CreateInitialPattern(void *);
   static struct lhsParseNode    *ReorderDriver(void *,struct lhsParseNode *,int *,int,int);
   static struct lhsParseNode    *AddRemainingInitialPatterns(void *,struct lhsParseNode *);
   static struct lhsParseNode    *AssignPatternIndices(struct lhsParseNode *,short,int,short);
   static void                    PropagateIndexSlotPatternValues(struct lhsParseNode *,
                                                                  short,short,
                                                                  struct symbolHashNode *,
                                                                  short);
   static void                    PropagateJoinDepth(struct lhsParseNode *,short);
   static void                    PropagateNandDepth(struct lhsParseNode *,int,int);
   static void                    MarkExistsNands(struct lhsParseNode *);
   static int                     PropagateWhichCE(struct lhsParseNode *,int);
   /*
   static void                    PrintNodes(void *,const char *,struct lhsParseNode *);
   */
   
/********************************************/
/* ReorderPatterns: Reorders a group of CEs */     
/*   to accommodate KB Rete topology.       */
/********************************************/
globle struct lhsParseNode *ReorderPatterns(
  void *theEnv,
  struct lhsParseNode *theLHS,
  int *anyChange)
  {
   struct lhsParseNode *newLHS, *tempLHS, *lastLHS;

   /*=============================================*/
   /* If the LHS of the rule was left unspecified */
   /* (e.g., (defrule x => ...)), then nothing    */
   /* more needs to be done.                      */
   /*=============================================*/

   if (theLHS == NULL) return(theLHS);
   
   /*===========================================================*/
   /* The LHS of a rule is enclosed within an implied "and" CE. */
   /*===========================================================*/

   newLHS = GetLHSParseNode(theEnv);
   newLHS->type = AND_CE;
   newLHS->right = theLHS;

   /*==============================================================*/
   /* Mark the nodes to indicate which CE they're associated with. */
   /*==============================================================*/
   
   PropagateWhichCE(newLHS,0);
   
   /*=======================================================*/
   /* Reorder the patterns to support the KB Rete topology. */
   /*=======================================================*/

   newLHS = ReorderDriver(theEnv,newLHS,anyChange,1,1);
   newLHS = ReorderDriver(theEnv,newLHS,anyChange,2,1);

   /*===========================================*/
   /* The top level and CE may have disappeared */
   /* as a result of pattern compression.       */
   /*===========================================*/

   if (newLHS->type == OR_CE)
     {
      for (tempLHS = newLHS->right, lastLHS = NULL;
           tempLHS != NULL;
           lastLHS = tempLHS, tempLHS = tempLHS->bottom)
        {
         if (tempLHS->type != AND_CE)
           {
            theLHS = GetLHSParseNode(theEnv);
            theLHS->type = AND_CE;
            theLHS->right = tempLHS;
            theLHS->bottom = tempLHS->bottom;
            tempLHS->bottom = NULL;
            if (lastLHS == NULL)
              { newLHS->right = theLHS; }
            else
              { lastLHS->bottom = theLHS; }
            tempLHS = theLHS;
           }
        }
     }
   else if (newLHS->type != AND_CE)
     {
      theLHS = newLHS;
      newLHS = GetLHSParseNode(theEnv);
      newLHS->type = AND_CE;
      newLHS->right = theLHS;
     }

   /*================================================*/
   /* Mark exist not/and groups within the patterns. */
   /*================================================*/

   if (newLHS->type == OR_CE)
     {
      for (theLHS = newLHS->right;
           theLHS != NULL;
           theLHS = theLHS->bottom)
        { MarkExistsNands(theLHS->right); }
     }
   else
     { MarkExistsNands(newLHS->right); }

   /*=====================================================*/
   /* Add initial patterns where needed (such as before a */
   /* "test" CE or "not" CE which is the first CE within  */
   /* an "and" CE).                                       */
   /*=====================================================*/

   AddInitialPatterns(theEnv,newLHS);

   /*===========================================================*/
   /* Number the user specified patterns. Patterns added while  */
   /* analyzing the rule (such as placing initial-fact patterns */
   /* before not CEs) are not numbered so that there is no      */
   /* confusion when an error message refers to a CE. Also      */
   /* propagate field and slot values throughout each pattern.  */
   /*===========================================================*/

   if (newLHS->type == OR_CE) theLHS = newLHS->right;
   else theLHS = newLHS;

   for (;
        theLHS != NULL;
        theLHS = theLHS->bottom)
     { AssignPatternIndices(theLHS->right,1,1,0); }

   /*===========================*/
   /* Return the processed LHS. */
   /*===========================*/

   return(newLHS);
  }

/******************************************/
/* ReorderDriver: Reorders a group of CEs */
/*   to accommodate KB Rete topology.     */
/******************************************/
static struct lhsParseNode *ReorderDriver(
  void *theEnv,
  struct lhsParseNode *theLHS,
  int *anyChange,
  int pass,
  int depth)
  {
   struct lhsParseNode *argPtr;
   struct lhsParseNode *before, *save;
   int change, newChange;
   *anyChange = FALSE;

   /*===================================*/
   /* Continue processing the LHS until */
   /* no more changes have been made.   */
   /*===================================*/

   change = TRUE;
   while (change)
     {
      /*==================================*/
      /* No change yet on this iteration. */
      /*==================================*/

      change = FALSE;

      /*=======================================*/
      /* Reorder the current level of the LHS. */
      /*=======================================*/

      if ((theLHS->type == AND_CE) ||
          (theLHS->type == NOT_CE) ||
          (theLHS->type == OR_CE))
        {
         if (pass == 1) theLHS = PerformReorder1(theEnv,theLHS,&newChange,depth);
         else theLHS = PerformReorder2(theEnv,theLHS,&newChange,depth);

         if (newChange)
           {
            *anyChange = TRUE;
            change = TRUE;
           }

         theLHS = CompressCEs(theEnv,theLHS,&newChange,depth);

         if (newChange)
           {
            *anyChange = TRUE;
            change = TRUE;
           }
        }

      /*=====================================================*/
      /* Recursively reorder CEs at lower levels in the LHS. */
      /*=====================================================*/

      before = NULL;
      argPtr = theLHS->right;

      while (argPtr != NULL)
        {
         /*==================================*/
         /* Remember the next CE to reorder. */
         /*==================================*/

         save = argPtr->bottom;

         /*============================================*/
         /* Reorder the current CE at the lower level. */
         /*============================================*/

         if ((argPtr->type == AND_CE) ||
             (argPtr->type == NOT_CE) ||
             (argPtr->type == OR_CE))
           {
            if (before == NULL)
              {
               argPtr->bottom = NULL;
               theLHS->right = ReorderDriver(theEnv,argPtr,&newChange,pass,depth+1);
               theLHS->right->bottom = save;
               before = theLHS->right;
              }
            else
              {
               argPtr->bottom = NULL;
               before->bottom = ReorderDriver(theEnv,argPtr,&newChange,pass,depth+1);
               before->bottom->bottom = save;
               before = before->bottom;
              }

            if (newChange)
              {
               *anyChange = TRUE;
               change = TRUE;
              }
           }
         else
           { before = argPtr; }

         /*====================================*/
         /* Move on to the next CE to reorder. */
         /*====================================*/

         argPtr = save;
        }
     }

   /*===========================*/
   /* Return the reordered LHS. */
   /*===========================*/

   return(theLHS);
  }

/********************/
/* MarkExistsNands: */
/********************/
static void MarkExistsNands(
  struct lhsParseNode *theLHS)
  {      
   int currentDepth = 1;
   struct lhsParseNode *tmpLHS;
    
   while (theLHS != NULL)
     {
      if (IsExistsSubjoin(theLHS,currentDepth))
        {
         theLHS->existsNand = TRUE;
         
         for (tmpLHS = theLHS;
              tmpLHS != NULL;
              tmpLHS = tmpLHS->bottom)
           {
            tmpLHS->beginNandDepth--;
            if (tmpLHS->endNandDepth <= currentDepth)
              { break; }
            else
              { tmpLHS->endNandDepth--; }
           }
        }
      
      currentDepth = theLHS->endNandDepth;
      theLHS = theLHS->bottom;
     }
  }

/****************************************************************/
/* AddInitialPatterns: Add initial patterns to CEs where needed */
/*   (such as before a "test" CE or "not" CE which is the first */
/*   CE within an "and" CE).                                    */
/****************************************************************/
globle void AddInitialPatterns(
  void *theEnv,
  struct lhsParseNode *theLHS)
  {
   struct lhsParseNode *thePattern;

   /*====================================================*/
   /* If there are multiple disjuncts for the rule, then */
   /* add initial patterns to each disjunct separately.  */
   /*====================================================*/

   if (theLHS->type == OR_CE)
     {
      for (thePattern = theLHS->right;
           thePattern != NULL;
           thePattern = thePattern->bottom)
        { AddInitialPatterns(theEnv,thePattern); }

      return;
     }

   /*================================*/
   /* Handle the remaining patterns. */
   /*================================*/

   theLHS->right = AddRemainingInitialPatterns(theEnv,theLHS->right);
  }

/***********************************************************/
/* PerformReorder1: Reorders a group of CEs to accommodate */
/*   KB Rete topology. The first pass of this function     */
/*   transforms or CEs into equivalent forms.              */
/***********************************************************/
static struct lhsParseNode *PerformReorder1(
  void *theEnv,
  struct lhsParseNode *theLHS,
  int *newChange,
  int depth)
  {
   struct lhsParseNode *argPtr, *lastArg, *nextArg;
   struct lhsParseNode *tempArg, *newNode;
   int count;
   int change;

   /*======================================================*/
   /* Loop through the CEs as long as changes can be made. */
   /*======================================================*/

   change = TRUE;
   *newChange = FALSE;

   while (change)
     {
      change = FALSE;
      count = 1;
      lastArg = NULL;

      for (argPtr = theLHS->right;
           argPtr != NULL;)
        {
         /*=============================================================*/
         /* Convert and/or CE combinations into or/and CE combinations. */
         /*=============================================================*/

         if ((theLHS->type == AND_CE) && (argPtr->type == OR_CE))
           {
            theLHS = ReverseAndOr(theEnv,theLHS,argPtr->right,count);

            change = TRUE;
            *newChange = TRUE;
            break;
           }

         /*==============================================================*/
         /* Convert not/or CE combinations into and/not CE combinations. */
         /*==============================================================*/

         else if ((theLHS->type == NOT_CE) && (argPtr->type == OR_CE))
           {
            change = TRUE;
            *newChange = TRUE;

            tempArg = argPtr->right;

            argPtr->right = NULL;
            argPtr->bottom = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);
            theLHS->type = AND_CE;
            theLHS->right = tempArg;

            while (tempArg != NULL)
              {
               newNode = GetLHSParseNode(theEnv);
               CopyLHSParseNode(theEnv,newNode,tempArg,FALSE);
               newNode->right = tempArg->right;
               newNode->bottom = NULL;

               tempArg->type = NOT_CE;
               tempArg->negated = FALSE;
               tempArg->exists = FALSE;
               tempArg->existsNand = FALSE;
               tempArg->logical = FALSE;
               tempArg->value = NULL;
               tempArg->expression = NULL;
               tempArg->secondaryExpression = NULL;
               tempArg->right = newNode;

               tempArg = tempArg->bottom;
              }

            break;
           }

         /*=====================================*/
         /* Remove duplication of or CEs within */
         /* or CEs and and CEs within and CEs.  */
         /*=====================================*/

         else if (((theLHS->type == OR_CE) && (argPtr->type == OR_CE)) ||
                  ((theLHS->type == AND_CE) && (argPtr->type == AND_CE)))
           {
            if (argPtr->logical) theLHS->logical = TRUE;

            change = TRUE;
            *newChange = TRUE;
            tempArg = argPtr->right;
            nextArg = argPtr->bottom;
            argPtr->right = NULL;
            argPtr->bottom = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);

            if (lastArg == NULL)
              { theLHS->right = tempArg; }
            else
              { lastArg->bottom = tempArg; }

            argPtr = tempArg;
            while (tempArg->bottom != NULL) tempArg = tempArg->bottom;
            tempArg->bottom = nextArg;
           }

         /*===================================================*/
         /* If no changes are needed, move on to the next CE. */
         /*===================================================*/

         else
           {
            count++;
            lastArg = argPtr;
            argPtr = argPtr->bottom;
           }
        }
     }

   /*===========================*/
   /* Return the reordered LHS. */
   /*===========================*/

   return(theLHS);
  }

/***********************************************************/
/* PerformReorder2: Reorders a group of CEs to accommodate */
/*   KB Rete topology. The second pass performs all other  */
/*   transformations not associated with the or CE.        */
/***********************************************************/
static struct lhsParseNode *PerformReorder2(
  void *theEnv,
  struct lhsParseNode *theLHS,
  int *newChange,
  int depth)
  {
   struct lhsParseNode *argPtr;
   int change;

   /*======================================================*/
   /* Loop through the CEs as long as changes can be made. */
   /*======================================================*/

   change = TRUE;
   *newChange = FALSE;

   while (change)
     {
      change = FALSE;

      for (argPtr = theLHS->right;
           argPtr != NULL;)
        {
         /*=======================================================*/
         /* A sequence of three not CEs grouped within each other */
         /* can be replaced with a single not CE. For example,    */
         /* (not (not (not (a)))) can be replaced with (not (a)). */
         /*=======================================================*/
         
         if ((theLHS->type == NOT_CE) &&
             (argPtr->type == NOT_CE) &&
             (argPtr->right != NULL) &&
             (argPtr->right->type == NOT_CE))
           {
            change = TRUE;
            *newChange = TRUE; 
            
            theLHS->right = argPtr->right->right;

            argPtr->right->right = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);

            break;
           }

         /*==========================================*/
         /* Replace two not CEs containing a pattern */
         /* CE with an exists pattern CE.            */
         /*==========================================*/

         else if ((theLHS->type == NOT_CE) && 
                  (argPtr->type == NOT_CE) &&
                  (argPtr->right != NULL) &&
                  (argPtr->right->type == PATTERN_CE))
           {
            change = TRUE;
            *newChange = TRUE;

            CopyLHSParseNode(theEnv,theLHS,argPtr->right,FALSE);

            theLHS->negated = TRUE;
            theLHS->exists = TRUE;
            theLHS->existsNand = FALSE;
            theLHS->right = argPtr->right->right;

            argPtr->right->networkTest = NULL; 
            argPtr->right->externalNetworkTest = NULL;
            argPtr->right->secondaryNetworkTest = NULL;
            argPtr->right->externalRightHash = NULL;
            argPtr->right->externalLeftHash = NULL;
            argPtr->right->leftHash = NULL;
            argPtr->right->rightHash = NULL;
            argPtr->right->betaHash = NULL;
            argPtr->right->expression = NULL;
            argPtr->right->secondaryExpression = NULL;
            argPtr->right->userData = NULL;
            argPtr->right->right = NULL;
            argPtr->right->bottom = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);
            break;
           }
         
         /*======================================*/
         /* Replace not CEs containing a pattern */
         /* CE with a negated pattern CE.        */
         /*======================================*/

         else if ((theLHS->type == NOT_CE) && (argPtr->type == PATTERN_CE))
           {
            change = TRUE;
            *newChange = TRUE;

            CopyLHSParseNode(theEnv,theLHS,argPtr,FALSE);

            theLHS->negated = TRUE;
            theLHS->exists = FALSE;
            theLHS->existsNand = FALSE;
            theLHS->right = argPtr->right;

            argPtr->networkTest = NULL; 
            argPtr->externalNetworkTest = NULL;
            argPtr->secondaryNetworkTest = NULL;
            argPtr->externalRightHash = NULL;
            argPtr->externalLeftHash = NULL;
            argPtr->constantSelector = NULL;
            argPtr->constantValue = NULL;
            argPtr->leftHash = NULL;
            argPtr->rightHash = NULL;
            argPtr->betaHash = NULL;
            argPtr->expression = NULL;
            argPtr->secondaryExpression = NULL;
            argPtr->userData = NULL;
            argPtr->right = NULL;
            argPtr->bottom = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);
            break;
           }

         /*============================================================*/
         /* Replace "and" and "not" CEs contained within a not CE with */
         /* just the and CE, but increment the nand depths of the      */
         /* pattern contained within.                                  */
         /*============================================================*/

         else if ((theLHS->type == NOT_CE) &&
                  ((argPtr->type == AND_CE) ||  (argPtr->type == NOT_CE)))
           {
            change = TRUE;
            *newChange = TRUE;

            theLHS->type = argPtr->type;

            theLHS->negated = argPtr->negated;
            theLHS->exists = argPtr->exists;
            theLHS->existsNand = argPtr->existsNand;
            theLHS->value = argPtr->value;
            theLHS->logical = argPtr->logical;
            theLHS->right = argPtr->right;
            argPtr->right = NULL;
            argPtr->bottom = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);

            IncrementNandDepth(theEnv,theLHS->right,TRUE);
            break;
           }

         /*===================================================*/
         /* If no changes are needed, move on to the next CE. */
         /*===================================================*/

         else
           {
            argPtr = argPtr->bottom;
           }
        }
     }

   /*===========================*/
   /* Return the reordered LHS. */
   /*===========================*/

   return(theLHS);
  }

/**************************************************/
/* ReverseAndOr: Switches and/or CEs into         */
/*   equivalent or/and CEs. For example:          */
/*                                                */
/*     (and (or a b) (or c d))                    */
/*                                                */
/*   would be converted to                        */
/*                                                */
/*     (or (and a (or c d)) (and b (or c d))),    */
/*                                                */
/*   if the "or" CE being expanded was (or a b).  */
/**************************************************/
static struct lhsParseNode *ReverseAndOr(
  void *theEnv,
  struct lhsParseNode *listOfCEs,
  struct lhsParseNode *orCE,
  int orPosition)
  {
   int count;
   struct lhsParseNode *listOfExpandedOrCEs = NULL;
   struct lhsParseNode *lastExpandedOrCE = NULL;
   struct lhsParseNode *copyOfCEs, *replaceCE;

   /*========================================================*/
   /* Loop through each of the CEs contained within the "or" */
   /* CE that is being expanded into the enclosing "and" CE. */
   /*========================================================*/

   while (orCE != NULL)
     {
      /*===============================*/
      /* Make a copy of the and/or CE. */
      /*===============================*/

      copyOfCEs = CopyLHSParseNodes(theEnv,listOfCEs);

      /*====================================================*/
      /* Get a pointer to the "or" CE being expanded in the */
      /* copy just made based on the position of the "or"   */
      /* CE in the original and/or CE (e.g., 1st, 2nd).     */
      /*====================================================*/

      for (count = 1, replaceCE = copyOfCEs->right;
           count != orPosition;
           count++, replaceCE = replaceCE->bottom)
        { /* Do Nothing*/ }

      /*===================================================*/
      /* Delete the contents of the "or" CE being expanded */
      /* in the copy of the and/or CE. From the example    */
      /* above, (and (or a b) (or c d)) would be replaced  */
      /* with (and (or) (or c d)). Note that the "or" CE   */
      /* is still left as a placeholder.                   */
      /*===================================================*/

      ReturnLHSParseNodes(theEnv,replaceCE->right);

      /*======================================================*/
      /* Copy the current CE being examined in the "or" CE to */
      /* the placeholder left in the and/or CE. From the      */
      /* example above, (and (or) (or c d)) would be replaced */
      /* with (and a (or c d)) if the "a" pattern from the    */
      /* "or" CE was being examined or (and b (or c d)) if    */
      /* the "b" pattern from the "or" CE was being examined. */
      /*======================================================*/

      CopyLHSParseNode(theEnv,replaceCE,orCE,TRUE);
      replaceCE->right = CopyLHSParseNodes(theEnv,orCE->right);

      /*====================================*/
      /* Add the newly expanded "and" CE to */
      /* the list of CEs already expanded.  */
      /*====================================*/

      if (lastExpandedOrCE == NULL)
        {
         listOfExpandedOrCEs = copyOfCEs;
         copyOfCEs->bottom = NULL;
         lastExpandedOrCE = copyOfCEs;
        }
      else
        {
         lastExpandedOrCE->bottom = copyOfCEs;
         copyOfCEs->bottom = NULL;
         lastExpandedOrCE = copyOfCEs;
        }

      /*=======================================================*/
      /* Move on to the next CE in the "or" CE being expanded. */
      /*=======================================================*/

      orCE = orCE->bottom;
     }

   /*=====================================================*/
   /* Release the original and/or CE list to free memory. */
   /*=====================================================*/

   ReturnLHSParseNodes(theEnv,listOfCEs);

   /*================================================*/
   /* Wrap an or CE around the list of expanded CEs. */
   /*================================================*/

   copyOfCEs = GetLHSParseNode(theEnv);
   copyOfCEs->type = OR_CE;
   copyOfCEs->right = listOfExpandedOrCEs;

   /*================================*/
   /* Return the newly expanded CEs. */
   /*================================*/

   return(copyOfCEs);
  }

/****************/
/* CompressCEs: */
/****************/
static struct lhsParseNode *CompressCEs(
  void *theEnv,
  struct lhsParseNode *theLHS,
  int *newChange,
  int depth)
  {
   struct lhsParseNode *argPtr, *lastArg, *nextArg;
   struct lhsParseNode *tempArg;
   int change;
   struct expr *e1, *e2;

   /*======================================================*/
   /* Loop through the CEs as long as changes can be made. */
   /*======================================================*/

   change = TRUE;
   *newChange = FALSE;

   while (change)
     {
      change = FALSE;
      lastArg = NULL;

      for (argPtr = theLHS->right;
           argPtr != NULL;)
        {
         /*=====================================*/
         /* Remove duplication of or CEs within */
         /* or CEs and and CEs within and CEs.  */
         /*=====================================*/

         if (((theLHS->type == OR_CE) && (argPtr->type == OR_CE)) ||
             ((theLHS->type == AND_CE) && (argPtr->type == AND_CE)))
           {
            if (argPtr->logical) theLHS->logical = TRUE;

            change = TRUE;
            *newChange = TRUE;
            tempArg = argPtr->right;
            nextArg = argPtr->bottom;
            argPtr->right = NULL;
            argPtr->bottom = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);

            if (lastArg == NULL)
              { theLHS->right = tempArg; }
            else
              { lastArg->bottom = tempArg; }

            argPtr = tempArg;
            while (tempArg->bottom != NULL) tempArg = tempArg->bottom;
            tempArg->bottom = nextArg;
           }

         /*=======================================================*/
         /* Replace not CEs containing a test CE with just a test */
         /* CE with the original test CE condition negated.       */
         /*=======================================================*/

         else if ((theLHS->type == NOT_CE) && (argPtr->type == TEST_CE))
           {
            change = TRUE;
            *newChange = TRUE;

            tempArg = GetLHSParseNode(theEnv);
            tempArg->type = FCALL;
            tempArg->value = ExpressionData(theEnv)->PTR_NOT;
            tempArg->bottom = argPtr->expression;
            argPtr->expression = tempArg;

            CopyLHSParseNode(theEnv,theLHS,argPtr,TRUE);
            ReturnLHSParseNodes(theEnv,argPtr);
            theLHS->right = NULL;
            break;
           }

         /*==============================*/
         /* Two adjacent test CEs within */
         /* an and CE can be combined.   */
         /*==============================*/

         else if ((theLHS->type == AND_CE) && (argPtr->type == TEST_CE) &&
                  ((argPtr->bottom != NULL) ? argPtr->bottom->type == TEST_CE :
                                              FALSE) &&
                   (argPtr->beginNandDepth == argPtr->endNandDepth) &&
                   (argPtr->endNandDepth == argPtr->bottom->beginNandDepth))
           {
            change = TRUE;
            *newChange = TRUE;

            argPtr->expression = CombineLHSParseNodes(theEnv,argPtr->expression,argPtr->bottom->expression);
            argPtr->bottom->expression = NULL;

            tempArg = argPtr->bottom;
            argPtr->bottom = tempArg->bottom;
            tempArg->bottom = NULL;

            ReturnLHSParseNodes(theEnv,tempArg);
           }

         /*========================================================*/
         /* A test CE can be attached to the preceding pattern CE. */
         /*========================================================*/

         else if ((theLHS->type == AND_CE) && (argPtr->type == PATTERN_CE) &&
                  ((argPtr->bottom != NULL) ? argPtr->bottom->type == TEST_CE :
                                              FALSE) &&
                   (argPtr->negated == FALSE) &&
                   (argPtr->exists == FALSE) &&
                   (argPtr->beginNandDepth == argPtr->endNandDepth) &&
                   (argPtr->endNandDepth == argPtr->bottom->beginNandDepth))
           {
            int endNandDepth;
            change = TRUE;
            *newChange = TRUE;
            
            endNandDepth = argPtr->bottom->endNandDepth;
            
            if (argPtr->negated || argPtr->exists)
              {
               e1 = LHSParseNodesToExpression(theEnv,argPtr->secondaryExpression);
               e2 = LHSParseNodesToExpression(theEnv,argPtr->bottom->expression);
               e1 = CombineExpressions(theEnv,e1,e2);
               ReturnLHSParseNodes(theEnv,argPtr->secondaryExpression);
               argPtr->secondaryExpression = ExpressionToLHSParseNodes(theEnv,e1);
               ReturnExpression(theEnv,e1);
              }
            else
              {
               argPtr->expression = CombineLHSParseNodes(theEnv,argPtr->expression,argPtr->bottom->expression);
               argPtr->bottom->expression = NULL;
              }
            
            if ((theLHS->right == argPtr) && ((argPtr->beginNandDepth - 1) == endNandDepth))
              {
               if (argPtr->negated)
                 {
                  argPtr->negated = FALSE;
                  argPtr->exists = TRUE;
                  e1 = LHSParseNodesToExpression(theEnv,argPtr->secondaryExpression);
                  e1 = NegateExpression(theEnv,e1);
                  ReturnLHSParseNodes(theEnv,argPtr->secondaryExpression);
                  argPtr->secondaryExpression = ExpressionToLHSParseNodes(theEnv,e1);
                  ReturnExpression(theEnv,e1);
                 }
               else if (argPtr->exists)
                 {
                  argPtr->negated = TRUE;
                  argPtr->exists = FALSE;
                  e1 = LHSParseNodesToExpression(theEnv,argPtr->secondaryExpression);
                  e1 = NegateExpression(theEnv,e1);
                  ReturnLHSParseNodes(theEnv,argPtr->secondaryExpression);
                  argPtr->secondaryExpression = ExpressionToLHSParseNodes(theEnv,e1);
                  ReturnExpression(theEnv,e1);
                 }
               else
                 {
                  argPtr->negated = TRUE;
                 }
               PropagateNandDepth(argPtr,endNandDepth,endNandDepth);
              }

            /*========================================*/
            /* Detach the test CE from its parent and */
            /* dispose of the data structures.        */
            /*========================================*/
            
            tempArg = argPtr->bottom;
            argPtr->bottom = tempArg->bottom;
            tempArg->bottom = NULL;

            ReturnLHSParseNodes(theEnv,tempArg);
           }

         /*=====================================*/
         /* Replace and CEs containing a single */
         /* test CE with just a test CE.        */
         /*=====================================*/

         else if ((theLHS->type == AND_CE) && (argPtr->type == TEST_CE) &&
                  (theLHS->right == argPtr) && (argPtr->bottom == NULL))
           {
            change = TRUE;
            *newChange = TRUE;

            CopyLHSParseNode(theEnv,theLHS,argPtr,TRUE);
            theLHS->right = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);
            break;
           }

         /*=======================================================*/
         /* Replace and CEs containing a single pattern CE with   */
         /* just a pattern CE if this is not the top most and CE. */
         /*=======================================================*/

         else if ((theLHS->type == AND_CE) && (argPtr->type == PATTERN_CE) &&
                  (theLHS->right == argPtr) && (argPtr->bottom == NULL) && (depth > 1))
           {
            change = TRUE;
            *newChange = TRUE;

            CopyLHSParseNode(theEnv,theLHS,argPtr,FALSE);

            theLHS->right = argPtr->right;

            argPtr->networkTest = NULL; 
            argPtr->externalNetworkTest = NULL;
            argPtr->secondaryNetworkTest = NULL;
            argPtr->externalRightHash = NULL;
            argPtr->externalLeftHash = NULL;
            argPtr->constantSelector = NULL;
            argPtr->constantValue = NULL;
            argPtr->leftHash = NULL;
            argPtr->rightHash = NULL;
            argPtr->betaHash = NULL;
            argPtr->expression = NULL;
            argPtr->secondaryExpression = NULL;
            argPtr->userData = NULL;
            argPtr->right = NULL;
            argPtr->bottom = NULL;
            ReturnLHSParseNodes(theEnv,argPtr);
            break;
           }

         /*===================================================*/
         /* If no changes are needed, move on to the next CE. */
         /*===================================================*/

         else
           {
            lastArg = argPtr;
            argPtr = argPtr->bottom;
           }
        }
     }

   /*===========================*/
   /* Return the reordered LHS. */
   /*===========================*/

   return(theLHS);
  }

/*********************************************************************/
/* CopyLHSParseNodes: Copies a linked group of conditional elements. */
/*********************************************************************/
globle struct lhsParseNode *CopyLHSParseNodes(
  void *theEnv,
  struct lhsParseNode *listOfCEs)
  {
   struct lhsParseNode *newList;

   if (listOfCEs == NULL)
     { return(NULL); }

   newList = get_struct(theEnv,lhsParseNode);
   CopyLHSParseNode(theEnv,newList,listOfCEs,TRUE);

   newList->right = CopyLHSParseNodes(theEnv,listOfCEs->right);
   newList->bottom = CopyLHSParseNodes(theEnv,listOfCEs->bottom);

   return(newList);
  }

/**********************************************************/
/* CopyLHSParseNode: Copies a single conditional element. */
/**********************************************************/
globle void CopyLHSParseNode(
  void *theEnv,
  struct lhsParseNode *dest,
  struct lhsParseNode *src,
  int duplicate)
  {
   dest->type = src->type;
   dest->value = src->value;
   dest->negated = src->negated;
   dest->exists = src->exists;
   dest->existsNand = src->existsNand;
   dest->bindingVariable = src->bindingVariable;
   dest->withinMultifieldSlot = src->withinMultifieldSlot;
   dest->multifieldSlot = src->multifieldSlot;
   dest->multiFieldsBefore = src->multiFieldsBefore;
   dest->multiFieldsAfter = src->multiFieldsAfter;
   dest->singleFieldsBefore = src->singleFieldsBefore;
   dest->singleFieldsAfter = src->singleFieldsAfter;
   dest->logical = src->logical;
   dest->userCE = src->userCE;
   dest->marked = src->marked;
   dest->whichCE = src->whichCE;
   dest->referringNode = src->referringNode;
   dest->patternType = src->patternType;
   dest->pattern = src->pattern;
   dest->index = src->index;
   dest->slot = src->slot;
   dest->slotNumber = src->slotNumber;
   dest->beginNandDepth = src->beginNandDepth;
   dest->endNandDepth = src->endNandDepth;
   dest->joinDepth = src->joinDepth;

   /*==========================================================*/
   /* The duplicate flag controls whether pointers to existing */
   /* data structures are used when copying some slots or if   */
   /* new copies of the data structures are made.              */
   /*==========================================================*/

   if (duplicate)
     {
      dest->networkTest = CopyExpression(theEnv,src->networkTest);
      dest->externalNetworkTest = CopyExpression(theEnv,src->externalNetworkTest);
      dest->secondaryNetworkTest = CopyExpression(theEnv,src->secondaryNetworkTest);
      dest->externalRightHash = CopyExpression(theEnv,src->externalRightHash);
      dest->externalLeftHash = CopyExpression(theEnv,src->externalLeftHash);
      dest->constantSelector = CopyExpression(theEnv,src->constantSelector);
      dest->constantValue = CopyExpression(theEnv,src->constantValue);
      dest->leftHash = CopyExpression(theEnv,src->leftHash);
      dest->betaHash = CopyExpression(theEnv,src->betaHash);
      dest->rightHash = CopyExpression(theEnv,src->rightHash);
      if (src->userData == NULL)
        { dest->userData = NULL; }
      else if (src->patternType->copyUserDataFunction == NULL)
        { dest->userData = src->userData; }
      else
        { dest->userData = (*src->patternType->copyUserDataFunction)(theEnv,src->userData); }
      dest->expression = CopyLHSParseNodes(theEnv,src->expression);
      dest->secondaryExpression = CopyLHSParseNodes(theEnv,src->secondaryExpression);
      dest->constraints = CopyConstraintRecord(theEnv,src->constraints);
      if (dest->constraints != NULL) dest->derivedConstraints = TRUE;
      else dest->derivedConstraints = FALSE;
     }
   else
     {
      dest->networkTest = src->networkTest;
      dest->externalNetworkTest = src->externalNetworkTest;
      dest->secondaryNetworkTest = src->secondaryNetworkTest;
      dest->externalRightHash = src->externalRightHash;
      dest->externalLeftHash = src->externalLeftHash;
      dest->constantSelector = src->constantSelector;
      dest->constantValue = src->constantValue;
      dest->leftHash = src->leftHash;
      dest->betaHash = src->betaHash;
      dest->rightHash = src->rightHash;
      dest->userData = src->userData;
      dest->expression = src->expression;
      dest->secondaryExpression = src->secondaryExpression;
      dest->derivedConstraints = FALSE;
      dest->constraints = src->constraints;
     }
  }

/****************************************************/
/* GetLHSParseNode: Creates an empty node structure */
/*   used for building conditional elements.        */
/****************************************************/
globle struct lhsParseNode *GetLHSParseNode(
  void *theEnv)
  {
   struct lhsParseNode *newNode;

   newNode = get_struct(theEnv,lhsParseNode);
   newNode->type = UNKNOWN_VALUE;
   newNode->value = NULL;
   newNode->negated = FALSE;
   newNode->exists = FALSE;
   newNode->existsNand = FALSE;
   newNode->bindingVariable = FALSE;
   newNode->withinMultifieldSlot = FALSE;
   newNode->multifieldSlot = FALSE;
   newNode->multiFieldsBefore = 0;
   newNode->multiFieldsAfter = 0;
   newNode->singleFieldsBefore = 0;
   newNode->singleFieldsAfter = 0;
   newNode->logical = FALSE;
   newNode->derivedConstraints = FALSE;
   newNode->userCE = TRUE;
   newNode->marked = FALSE;
   newNode->whichCE = 0;
   newNode->constraints = NULL;
   newNode->referringNode = NULL;
   newNode->patternType = NULL;
   newNode->pattern = -1;
   newNode->index = -1;
   newNode->slot = NULL;
   newNode->slotNumber = -1;
   newNode->beginNandDepth = 1;
   newNode->endNandDepth = 1;
   newNode->joinDepth = 0;
   newNode->userData = NULL;
   newNode->networkTest = NULL;
   newNode->externalNetworkTest = NULL;
   newNode->secondaryNetworkTest = NULL;
   newNode->externalRightHash = NULL;
   newNode->externalLeftHash = NULL;
   newNode->constantSelector = NULL;
   newNode->constantValue = NULL;
   newNode->leftHash = NULL;
   newNode->betaHash = NULL;
   newNode->rightHash = NULL;
   newNode->expression = NULL;
   newNode->secondaryExpression = NULL;
   newNode->right = NULL;
   newNode->bottom = NULL;

   return(newNode);
  }

/********************************************************/
/* ReturnLHSParseNodes:  Returns a multiply linked list */
/*   of lhsParseNode structures to the memory manager.  */
/********************************************************/
globle void ReturnLHSParseNodes(
  void *theEnv,
  struct lhsParseNode *waste)
  {
   if (waste != NULL)
     {
      ReturnExpression(theEnv,waste->networkTest);
      ReturnExpression(theEnv,waste->externalNetworkTest);
      ReturnExpression(theEnv,waste->secondaryNetworkTest);
      ReturnExpression(theEnv,waste->externalRightHash);
      ReturnExpression(theEnv,waste->externalLeftHash);
      ReturnExpression(theEnv,waste->constantSelector);
      ReturnExpression(theEnv,waste->constantValue);
      ReturnExpression(theEnv,waste->leftHash);
      ReturnExpression(theEnv,waste->betaHash);
      ReturnExpression(theEnv,waste->rightHash);
      ReturnLHSParseNodes(theEnv,waste->right);
      ReturnLHSParseNodes(theEnv,waste->bottom);
      ReturnLHSParseNodes(theEnv,waste->expression);
      ReturnLHSParseNodes(theEnv,waste->secondaryExpression);
      if (waste->derivedConstraints) RemoveConstraint(theEnv,waste->constraints);
      if ((waste->userData != NULL) &&
          (waste->patternType->returnUserDataFunction != NULL))
        { (*waste->patternType->returnUserDataFunction)(theEnv,waste->userData); }
      rtn_struct(theEnv,lhsParseNode,waste);
     }
  }

/********************************************************/
/* ExpressionToLHSParseNodes: Copies an expression into */
/*   the equivalent lhsParseNode data structures.       */
/********************************************************/
globle struct lhsParseNode *ExpressionToLHSParseNodes(
  void *theEnv,
  struct expr *expressionList)
  {
   struct lhsParseNode *newList, *theList;
   struct FunctionDefinition *theFunction;
   int i, theRestriction;

   /*===========================================*/
   /* A NULL expression requires no conversion. */
   /*===========================================*/

   if (expressionList == NULL) return(NULL);

   /*====================================*/
   /* Recursively convert the expression */
   /* to lhsParseNode data structures.   */
   /*====================================*/

   newList = GetLHSParseNode(theEnv);
   newList->type = expressionList->type;
   newList->value = expressionList->value;
   newList->right = ExpressionToLHSParseNodes(theEnv,expressionList->nextArg);
   newList->bottom = ExpressionToLHSParseNodes(theEnv,expressionList->argList);

   /*==================================================*/
   /* If the expression is a function call, then store */
   /* the constraint information for the functions     */
   /* arguments in the lshParseNode data structures.   */
   /*==================================================*/

   if (newList->type != FCALL) return(newList);

   theFunction = (struct FunctionDefinition *) newList->value;
   for (theList = newList->bottom, i = 1;
        theList != NULL;
        theList = theList->right, i++)
     {
      if (theList->type == SF_VARIABLE)
        {
         theRestriction = GetNthRestriction(theFunction,i);
         theList->constraints = ArgumentTypeToConstraintRecord(theEnv,theRestriction);
         theList->derivedConstraints = TRUE;
        }
     }

   /*==================================*/
   /* Return the converted expression. */
   /*==================================*/

   return(newList);
  }

/******************************************************************/
/* LHSParseNodesToExpression: Copies lhsParseNode data structures */
/*   into the equivalent expression data structures.              */
/******************************************************************/
globle struct expr *LHSParseNodesToExpression(
  void *theEnv,
  struct lhsParseNode *nodeList)
  {
   struct expr *newList;

   if (nodeList == NULL)
     { return(NULL); }

   newList = get_struct(theEnv,expr);
   newList->type = nodeList->type;
   newList->value = nodeList->value;
   newList->nextArg = LHSParseNodesToExpression(theEnv,nodeList->right);
   newList->argList = LHSParseNodesToExpression(theEnv,nodeList->bottom);

   return(newList);
  }

/************************************************************/
/* IncrementNandDepth: Increments the nand depth of a group */
/*   of CEs. The nand depth is used to indicate the nesting */
/*   of not/and or not/not CEs which are implemented using  */
/*   joins from the right. A single pattern within a "not"  */
/*   CE does not require a join from the right and its nand */
/*   depth is normally not increased (except when it's      */
/*   within a not/and or not/not CE. The begin nand depth   */
/*   indicates the current nesting for a CE. The end nand   */
/*   depth indicates the nand depth in the following CE     */
/*   (assuming that the next CE is not the beginning of a   */
/*   new group of nand CEs). All but the last CE in a nand  */
/*   group should have the same begin and end nand depths.  */
/*   Since a single CE can be the last CE of several nand   */
/*   groups, it is possible to have an end nand depth that  */
/*   is more than 1 less than the begin nand depth of the   */
/*   CE.                                                    */
/************************************************************/
static void IncrementNandDepth(
  void *theEnv,
  struct lhsParseNode *theLHS,
  int lastCE)
  {
   /*======================================*/
   /* Loop through each CE in the group of */
   /* CEs having its nand depth increased. */
   /*======================================*/

   for (;
        theLHS != NULL;
        theLHS = theLHS->bottom)
     {
      /*=========================================================*/
      /* Increment the begin nand depth of pattern and test CEs. */
      /* The last CE in the original list doesn't have its end   */
      /* nand depth incremented. All other last CEs in other CEs */
      /* entered recursively do have their end depth incremented */
      /* (unless the last CE in the recursively entered CE is    */
      /* the same last CE as contained in the original group     */
      /* when this function was first entered).                  */
      /*=========================================================*/

      if ((theLHS->type == PATTERN_CE) || (theLHS->type == TEST_CE))
        {
         theLHS->beginNandDepth++;

         if (lastCE == FALSE) theLHS->endNandDepth++;
         else if (theLHS->bottom != NULL) theLHS->endNandDepth++;
        }

      /*==============================================*/
      /* Recursively increase the nand depth of other */
      /* CEs contained within the CE having its nand  */
      /* depth increased.                             */
      /*==============================================*/

      else if ((theLHS->type == AND_CE) || (theLHS->type == NOT_CE))
        {
         IncrementNandDepth(theEnv,theLHS->right,
                            (lastCE ? (theLHS->bottom == NULL) : FALSE));
        }

      /*=====================================*/
      /* All or CEs should have been removed */
      /* from the LHS at this point.         */
      /*=====================================*/

      else if (theLHS->type == OR_CE)
        { SystemError(theEnv,"REORDER",1); }
     }
  }

/***********************************************************/
/* CreateInitialPattern: Creates a default pattern used in */
/*  the LHS of a rule under certain cirmustances (such as  */
/*  when a "not" or "test" CE is the first CE in an "and"  */
/*  CE or when no CEs are specified in the LHS of a rule.  */
/***********************************************************/
static struct lhsParseNode *CreateInitialPattern(
  void *theEnv)
  {
   struct lhsParseNode *topNode;

   /*==========================================*/
   /* Create the top most node of the pattern. */
   /*==========================================*/

   topNode = GetLHSParseNode(theEnv);
   topNode->type = PATTERN_CE;
   topNode->userCE = FALSE;
   topNode->bottom = NULL;
   
   return(topNode);
  }

/*****************************************************************/
/* AddRemainingInitialPatterns: Finishes adding initial patterns */
/*   where needed on the LHS of a rule. Assumes that an initial  */
/*   pattern has been added to the beginning of the rule if one  */
/*   was needed.                                                 */
/*****************************************************************/
static struct lhsParseNode *AddRemainingInitialPatterns(
  void *theEnv,
  struct lhsParseNode *theLHS)
  {
   struct lhsParseNode *lastNode = NULL, *thePattern, *rv = theLHS;
   int currentDepth = 1;
   
   while (theLHS != NULL)
     {
      if ((theLHS->type == TEST_CE) &&
          (theLHS->beginNandDepth  > currentDepth))
        {
         thePattern = CreateInitialPattern(theEnv);
         thePattern->beginNandDepth = theLHS->beginNandDepth;
         thePattern->endNandDepth = theLHS->beginNandDepth;
         thePattern->logical = theLHS->logical;
         thePattern->existsNand = theLHS->existsNand;
         theLHS->existsNand = FALSE;
     
         thePattern->bottom = theLHS;
               
         if (lastNode == NULL)
           { rv = thePattern; }
         else
           { lastNode->bottom = thePattern; }
        }
        
      lastNode = theLHS;
      currentDepth = theLHS->endNandDepth;
      theLHS = theLHS->bottom;
     }
     
   return(rv);
  }   

/*************************************************************/
/* AssignPatternIndices: For each pattern CE in the LHS of a */
/*   rule, determines the pattern index for the CE. A simple */
/*   1 to N numbering can't be used since a join from the    */
/*   right only counts as a single CE to other CEs outside   */
/*   the lexical scope of the join from the right. For       */
/*   example, the patterns in the following LHS              */
/*                                                           */
/*     (a) (not (b) (c) (d)) (e)                             */
/*                                                           */
/*   would be assigned the following numbers: a-1, b-2, c-3, */
/*   d-4, and e-3.                                           */
/*************************************************************/
static struct lhsParseNode *AssignPatternIndices(
  struct lhsParseNode *theLHS,
  short startIndex,
  int nandDepth,
  short joinDepth)
  {
   struct lhsParseNode *theField;

   /*====================================*/
   /* Loop through the CEs at this level */
   /* assigning each CE a pattern index. */
   /*====================================*/

   while (theLHS != NULL)
     {
      /*============================================================*/
      /* If we're entering a group of CEs requiring a join from the */
      /* right, compute the pattern indices for that group and then */
      /* proceed with the next CE in this group. A join from the    */
      /* right only counts as one CE on this level regardless of    */
      /* the number of CEs it contains. If the end of this level is */
      /* encountered while processing the join from right, then     */
      /* return to the previous level.                              */
      /*============================================================*/

      if (theLHS->beginNandDepth > nandDepth)
        {
         theLHS = AssignPatternIndices(theLHS,startIndex,theLHS->beginNandDepth,joinDepth);
         if (theLHS->endNandDepth < nandDepth) return(theLHS);
         startIndex++;
         joinDepth++;
        }

      /*=====================================================*/
      /* A test CE is not assigned a pattern index, however, */
      /* if it is the last CE at the end of this level, then */
      /* return to the previous level. If this is the first  */
      /* CE in a group, it will have a join created so the   */
      /* depth should be incremented.                        */
      /*=====================================================*/

      else if (theLHS->type == TEST_CE)
        {
         if (joinDepth == 0)
           { joinDepth++; }
         theLHS->joinDepth = joinDepth - 1;
         PropagateJoinDepth(theLHS->expression,(short) (joinDepth - 1));
         PropagateNandDepth(theLHS->expression,theLHS->beginNandDepth,theLHS->endNandDepth);
         if (theLHS->endNandDepth < nandDepth) return(theLHS);
        }

      /*==========================================================*/
      /* The fields of a pattern CE need to be assigned a pattern */
      /* index, field index, and/or slot names. If this CE is the */
      /* last CE at the end of this level, then return to the     */
      /* previous level.                                          */
      /*==========================================================*/

      else if (theLHS->type == PATTERN_CE)
        {
         if (theLHS->expression != NULL)
           {
            PropagateJoinDepth(theLHS->expression,(short) joinDepth);
            PropagateNandDepth(theLHS->expression,theLHS->beginNandDepth,theLHS->endNandDepth);
           }
           
         theLHS->pattern = startIndex;
         theLHS->joinDepth = joinDepth;
         PropagateJoinDepth(theLHS->right,joinDepth);
         PropagateNandDepth(theLHS->right,theLHS->beginNandDepth,theLHS->endNandDepth);
         for (theField = theLHS->right; theField != NULL; theField = theField->right)
           {
            theField->pattern = startIndex;
            PropagateIndexSlotPatternValues(theField,theField->pattern,
                                            theField->index,theField->slot,
                                            theField->slotNumber);
           }

         if (theLHS->endNandDepth < nandDepth) return(theLHS);
         startIndex++;
         joinDepth++;
        }

      /*=========================*/
      /* Move on to the next CE. */
      /*=========================*/

      theLHS = theLHS->bottom;
     }

   /*========================================*/
   /* There are no more CEs left to process. */
   /* Return to the previous level.          */
   /*========================================*/

   return(NULL);
  }

/***********************************************************/
/* PropagateIndexSlotPatternValues: Assigns pattern, field */
/*   and slot identifiers to a field in a pattern.         */
/***********************************************************/
static void PropagateIndexSlotPatternValues(
  struct lhsParseNode *theField,
  short thePattern,
  short theIndex,
  struct symbolHashNode *theSlot,
  short theSlotNumber)
  {
   struct lhsParseNode *tmpNode, *andField;

   /*=============================================*/
   /* A NULL field does not have to be processed. */
   /*=============================================*/

   if (theField == NULL) return;

   /*=====================================================*/
   /* Assign the appropriate identifiers for a multifield */
   /* slot by calling this routine recursively.           */
   /*=====================================================*/

   if (theField->multifieldSlot)
     {
      theField->pattern = thePattern;
      if (theIndex > 0) theField->index = theIndex;
      theField->slot = theSlot;
      theField->slotNumber = theSlotNumber;

      for (tmpNode = theField->bottom;
           tmpNode != NULL;
           tmpNode = tmpNode->right)
        {
         tmpNode->pattern = thePattern;
         tmpNode->slot = theSlot;
         PropagateIndexSlotPatternValues(tmpNode,thePattern,tmpNode->index,
                                         theSlot,theSlotNumber);
        }

      return;
     }

   /*=======================================================*/
   /* Loop through each of the or'ed constraints (connected */
   /* by a |) in this field of the pattern.                 */
   /*=======================================================*/

   for (theField = theField->bottom;
        theField != NULL;
        theField = theField->bottom)
     {
      /*===========================================================*/
      /* Loop through each of the and'ed constraints (connected by */
      /* a &) in this field of the pattern. Assign the pattern,    */
      /* field, and slot identifiers.                              */
      /*===========================================================*/

      for (andField = theField; andField != NULL; andField = andField->right)
        {
         andField->pattern = thePattern;
         if (theIndex > 0) andField->index = theIndex;
         andField->slot = theSlot;
         andField->slotNumber = theSlotNumber;
        }
     }
   }

/***************************************************/
/* AssignPatternMarkedFlag: Recursively assigns    */
/*   value to the marked field of a LHSParseNode.  */
/***************************************************/
globle void AssignPatternMarkedFlag(
  struct lhsParseNode *theField,
  short markedValue)
  {
   while (theField != NULL)
     {
      theField->marked = markedValue;
      if (theField->bottom != NULL)
        { AssignPatternMarkedFlag(theField->bottom,markedValue); }
      if (theField->expression != NULL)
        { AssignPatternMarkedFlag(theField->expression,markedValue); }
      if (theField->secondaryExpression != NULL)
        { AssignPatternMarkedFlag(theField->secondaryExpression,markedValue); }
      theField = theField->right;
     }
  }

/*****************************************************************/
/* PropagateJoinDepth: Recursively assigns a joinDepth to each   */
/*   node in a LHS node by following the right and bottom links. */
/*****************************************************************/
static void PropagateJoinDepth(
  struct lhsParseNode *theField,
  short joinDepth)
  {
   while (theField != NULL)
     {
      theField->joinDepth = joinDepth;
      if (theField->bottom != NULL)
        { PropagateJoinDepth(theField->bottom,joinDepth); }
      if (theField->expression != NULL)
        { PropagateJoinDepth(theField->expression,joinDepth); }
      if (theField->secondaryExpression != NULL)
        { PropagateJoinDepth(theField->secondaryExpression,joinDepth); }
      theField = theField->right;
     }
  }

/**************************************************************/
/* PropagateNandDepth: Recursively assigns the not/and (nand) */
/*   depth to each node in a LHS node by following the right, */
/*   bottom, and expression links.                            */
/**************************************************************/
static void PropagateNandDepth(
  struct lhsParseNode *theField,
  int beginDepth,
  int endDepth)
  { 
   if (theField == NULL) return;
   
   for (; theField != NULL; theField = theField->right)
      { 
       theField->beginNandDepth = beginDepth;
       theField->endNandDepth = endDepth;
       PropagateNandDepth(theField->expression,beginDepth,endDepth);
       PropagateNandDepth(theField->secondaryExpression,beginDepth,endDepth);
       PropagateNandDepth(theField->bottom,beginDepth,endDepth);
      }
  }

/*****************************************/
/* PropagateWhichCE: Recursively assigns */
/*   an index indicating the user CE.    */
/*****************************************/
static int PropagateWhichCE(
  struct lhsParseNode *theField,
  int whichCE)
  {
   while (theField != NULL)
     {
      if ((theField->type == PATTERN_CE) || (theField->type == TEST_CE))
        { whichCE++; }
        
      theField->whichCE = whichCE;
      
      whichCE = PropagateWhichCE(theField->right,whichCE);
      PropagateWhichCE(theField->expression,whichCE);
      
      theField = theField->bottom;
     }
     
   return whichCE;
  }

/********************/
/* IsExistsSubjoin: */
/********************/
globle int IsExistsSubjoin(
  struct lhsParseNode *theLHS,
  int parentDepth)
  {
   int startDepth = theLHS->beginNandDepth;
   
   if ((startDepth - parentDepth) != 2)
     { return(FALSE); }
     
   while (theLHS->endNandDepth >= startDepth)
     { theLHS = theLHS->bottom; }
   
   if (theLHS->endNandDepth <= parentDepth)
     { return(TRUE); }

   return(FALSE);
  }

/***************************************************************************/
/* CombineLHSParseNodes: Combines two expressions into a single equivalent */
/*   expression. Mainly serves to merge expressions containing "and"       */
/*   and "or" expressions without unnecessary duplication of the "and"     */
/*   and "or" expressions (i.e., two "and" expressions can be merged by    */
/*   placing them as arguments within another "and" expression, but it     */
/*   is more efficient to add the arguments of one of the "and"            */
/*   expressions to the list of arguments for the other and expression).   */
/***************************************************************************/
globle struct lhsParseNode *CombineLHSParseNodes(
  void *theEnv,
  struct lhsParseNode *expr1,
  struct lhsParseNode *expr2)
  {
   struct lhsParseNode *tempPtr;

   /*===========================================================*/
   /* If the 1st expression is NULL, return the 2nd expression. */
   /*===========================================================*/

   if (expr1 == NULL) return(expr2);

   /*===========================================================*/
   /* If the 2nd expression is NULL, return the 1st expression. */
   /*===========================================================*/

   if (expr2 == NULL) return(expr1);

   /*============================================================*/
   /* If the 1st expression is an "and" expression, and the 2nd  */
   /* expression is not an "and" expression, then include the    */
   /* 2nd expression in the argument list of the 1st expression. */
   /*============================================================*/

   if ((expr1->value == ExpressionData(theEnv)->PTR_AND) &&
       (expr2->value != ExpressionData(theEnv)->PTR_AND))
     {
      tempPtr = expr1->bottom;
      if (tempPtr == NULL)
        {
         rtn_struct(theEnv,lhsParseNode,expr1);
         return(expr2);
        }

      while (tempPtr->right != NULL)
        { tempPtr = tempPtr->right; }

      tempPtr->right = expr2;
      return(expr1);
     }

   /*============================================================*/
   /* If the 2nd expression is an "and" expression, and the 1st  */
   /* expression is not an "and" expression, then include the    */
   /* 1st expression in the argument list of the 2nd expression. */
   /*============================================================*/

   if ((expr1->value != ExpressionData(theEnv)->PTR_AND) &&
       (expr2->value == ExpressionData(theEnv)->PTR_AND))
     {
      tempPtr = expr2->bottom;
      if (tempPtr == NULL)
        {
         rtn_struct(theEnv,lhsParseNode,expr2);
         return(expr1);
        }

      expr2->bottom = expr1;
      expr1->right = tempPtr;

      return(expr2);
     }

   /*===========================================================*/
   /* If both expressions are "and" expressions, then add the   */
   /* 2nd expression to the argument list of the 1st expression */
   /* and throw away the extraneous "and" expression.           */
   /*===========================================================*/

   if ((expr1->value == ExpressionData(theEnv)->PTR_AND) &&
       (expr2->value == ExpressionData(theEnv)->PTR_AND))
     {
      tempPtr = expr1->bottom;
      if (tempPtr == NULL)
        {
         rtn_struct(theEnv,lhsParseNode,expr1);
         return(expr2);
        }

      while (tempPtr->right != NULL)
        { tempPtr = tempPtr->right; }

      tempPtr->right = expr2->bottom;
      rtn_struct(theEnv,lhsParseNode,expr2);

      return(expr1);
     }

   /*=====================================================*/
   /* If neither expression is an "and" expression, then  */
   /* create an "and" expression and add both expressions */
   /* to the argument list of that "and" expression.      */
   /*=====================================================*/

   tempPtr = GetLHSParseNode(theEnv);
   tempPtr->type = FCALL;
   tempPtr->value = ExpressionData(theEnv)->PTR_AND;
   
   tempPtr->bottom = expr1;
   expr1->right = expr2;
   return(tempPtr);
  }

/**********************************************/
/* PrintNodes: Debugging routine which prints */
/*   the representation of a CE.              */
/**********************************************/
/*
static void PrintNodes(
  void *theEnv,
  const char *fileid,
  struct lhsParseNode *theNode)
  {
   if (theNode == NULL) return;

   while (theNode != NULL)
     {
      switch (theNode->type)
        {
         case PATTERN_CE:
           EnvPrintRouter(theEnv,fileid,"(");
           if (theNode->negated) EnvPrintRouter(theEnv,fileid,"n");
           if (theNode->exists) EnvPrintRouter(theEnv,fileid,"x");
           if (theNode->logical) EnvPrintRouter(theEnv,fileid,"l");
           PrintLongInteger(theEnv,fileid,(long long) theNode->beginNandDepth);
           EnvPrintRouter(theEnv,fileid,"-");
           PrintLongInteger(theEnv,fileid,(long long) theNode->endNandDepth);
           EnvPrintRouter(theEnv,fileid," ");
           EnvPrintRouter(theEnv,fileid,ValueToString(theNode->right->bottom->value));
           EnvPrintRouter(theEnv,fileid,")");
           break;

         case TEST_CE:
           EnvPrintRouter(theEnv,fileid,"(test ");
           PrintLongInteger(theEnv,fileid,(long long) theNode->beginNandDepth);
           EnvPrintRouter(theEnv,fileid,"-");
           PrintLongInteger(theEnv,fileid,(long long) theNode->endNandDepth);
           EnvPrintRouter(theEnv,fileid,")");
           break;

         case NOT_CE:
           if (theNode->logical) EnvPrintRouter(theEnv,fileid,"(lnot ");
           else EnvPrintRouter(theEnv,fileid,"(not ");;
           PrintNodes(theEnv,fileid,theNode->right);
           EnvPrintRouter(theEnv,fileid,")");
           break;

         case OR_CE:
           if (theNode->logical) EnvPrintRouter(theEnv,fileid,"(lor ");
           else EnvPrintRouter(theEnv,fileid,"(or ");
           PrintNodes(theEnv,fileid,theNode->right);
           EnvPrintRouter(theEnv,fileid,")");
           break;

         case AND_CE:
           if (theNode->logical) EnvPrintRouter(theEnv,fileid,"(land ");
           else EnvPrintRouter(theEnv,fileid,"(and ");
           PrintNodes(theEnv,fileid,theNode->right);
           EnvPrintRouter(theEnv,fileid,")");
           break;

         default:
           EnvPrintRouter(theEnv,fileid,"(unknown)");
           break;

        }

      theNode = theNode->bottom;
      if (theNode != NULL) EnvPrintRouter(theEnv,fileid," ");
     }

   return;
  }
*/

#endif

