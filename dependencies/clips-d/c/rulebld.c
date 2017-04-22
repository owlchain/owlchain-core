   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                  RULE BUILD MODULE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides routines to ntegrates a set of pattern  */
/*   and join tests associated with a rule into the pattern  */
/*   and join networks. The joins are integrated into the    */
/*   join network by routines in this module. The pattern    */
/*   is integrated by calling the external routine           */
/*   associated with the pattern parser that originally      */
/*   parsed the pattern.                                     */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed INCREMENTAL_RESET compilation flag.    */
/*                                                           */
/*            Corrected code to remove compiler warnings.    */
/*                                                           */
/*      6.30: Changes to constructing join network.          */
/*                                                           */
/*            Added support for hashed memories.             */
/*                                                           */
/*************************************************************/

#define _RULEBLD_SOURCE_

#include "setup.h"

#if DEFRULE_CONSTRUCT && (! RUN_TIME) && (! BLOAD_ONLY)

#include <stdio.h>
#define _STDIO_INCLUDED_
#include <stdlib.h>

#include "constant.h"
#include "envrnmnt.h"
#include "constrct.h"
#include "drive.h"
#include "incrrset.h"
#include "memalloc.h"
#include "pattern.h"
#include "reteutil.h"
#include "router.h"
#include "rulebld.h"
#include "rulepsr.h"
#include "watch.h"

/***************************************/
/* LOCAL INTERNAL FUNCTION DEFINITIONS */
/***************************************/

   static struct joinNode        *FindShareableJoin(struct joinLink *,struct joinNode *,intBool,void *,unsigned,unsigned,
                                                    unsigned,unsigned,struct expr *,struct expr *,
                                                    struct expr *,struct expr *);
   static int                     TestJoinForReuse(struct joinNode *,unsigned,unsigned,
                                                   unsigned,unsigned,struct expr *,struct expr *,
                                                   struct expr *,struct expr *);
   static struct joinNode        *CreateNewJoin(void *,struct expr *,struct expr *,struct joinNode *,void *,
                                                int,int,int,struct expr *,struct expr *);
   static void                    AttachTestCEsToPatternCEs(void *,struct lhsParseNode *);

/****************************************************************/
/* ConstructJoins: Integrates a set of pattern and join tests   */
/*   associated with a rule into the pattern and join networks. */
/****************************************************************/
globle struct joinNode *ConstructJoins(
  void *theEnv,
  int logicalJoin,
  struct lhsParseNode *theLHS,
  int startDepth,
  struct joinNode *lastJoin,
  int tryToReuse,
  int firstJoin)
  {
   struct patternNodeHeader *lastPattern;
   struct joinNode *listOfJoins = NULL;
   struct joinNode *oldJoin;
   int joinNumber = 1;
   int isLogical, isExists;
   struct joinNode *lastRightJoin;
   int lastIteration = FALSE;
   int rhsType;
   struct expr *leftHash, *rightHash;
   void *rhsStruct;
   struct lhsParseNode *nextLHS;
   struct expr *networkTest, *secondaryNetworkTest, *secondaryExternalTest;
   int joinFromTheRight;
   struct joinLink *theLinks;
   intBool useLinks;

   /*===================================================*/
   /* Remove any test CEs from the LHS and attach their */
   /* expression to the closest preceeding non-negated  */
   /* join at the same not/and depth.                   */
   /*===================================================*/

   if (startDepth == 1)
     { AttachTestCEsToPatternCEs(theEnv,theLHS); }

   if (theLHS == NULL)
     {
      lastJoin = FindShareableJoin(DefruleData(theEnv)->RightPrimeJoins,NULL,TRUE,NULL,TRUE,
                                   FALSE,FALSE,FALSE,NULL,NULL,NULL,NULL);
                                        
      if (lastJoin == NULL)
        { lastJoin = CreateNewJoin(theEnv,NULL,NULL,NULL,NULL,FALSE,FALSE,FALSE,NULL,NULL); }
     }

   /*=====================================================*/
   /* Process each pattern CE in the rule. At this point, */
   /* there should be no and/or/not CEs in the LHS.       */
   /*=====================================================*/

   while (theLHS != NULL)
     {
      /*======================================================*/
      /* Find the beginning of the next group of patterns. If */
      /* the current pattern is not the beginning of a "join  */
      /* from the right" group of patterns, then the next     */
      /* pattern is the next pattern. Otherwise skip over all */
      /* the patterns that belong to the group of subjoins.   */
      /*======================================================*/
             
      nextLHS = theLHS->bottom;
      secondaryExternalTest = NULL;

      if (theLHS->endNandDepth > startDepth)
        {
         while ((nextLHS != NULL) &&
                (nextLHS->endNandDepth > startDepth))
           { nextLHS = nextLHS->bottom; }
         
         /*====================================================*/
         /* Variable nextLHS is now pointing to the end of the */
         /* not/and group beginning with variable theLHS. If   */ 
         /* the end depth of the group is less than the depth  */
         /* of the current enclosing not/and group, then this  */
         /* is the last iteration for the enclosing group.     */
         /*====================================================*/
           
         if (nextLHS != NULL)
           {
            if (nextLHS->endNandDepth < startDepth)
              { lastIteration = TRUE; }
           }
           
         if (nextLHS != NULL)
           { nextLHS = nextLHS->bottom; }
           
         if ((nextLHS != NULL) && (nextLHS->type == TEST_CE) && (nextLHS->beginNandDepth >= startDepth))
           { 
            secondaryExternalTest = nextLHS->networkTest;
            nextLHS = nextLHS->bottom; 
           }
        }       

      /*=======================================*/
      /* Is this the last pattern to be added? */
      /*=======================================*/
      
      if (nextLHS == NULL)
        { lastIteration = TRUE; }
      else if (theLHS->endNandDepth < startDepth)
        { lastIteration = TRUE; } 
      else if ((nextLHS->type == TEST_CE) &&
               (theLHS->beginNandDepth > startDepth) &&
               (nextLHS->endNandDepth < startDepth))
        { lastIteration = TRUE; } 

      /*===============================================*/
      /* If the pattern is a join from the right, then */
      /* construct the subgroup of patterns and use    */
      /* that as the RHS of the join to be added.      */
      /*===============================================*/
                                         
      if (theLHS->beginNandDepth > startDepth)
        {
         joinFromTheRight = TRUE;
         isExists = theLHS->existsNand;

         lastRightJoin = ConstructJoins(theEnv,logicalJoin,theLHS,startDepth+1,lastJoin,tryToReuse,firstJoin);
            
         rhsStruct = lastRightJoin;
         rhsType = 0;
         lastPattern = NULL;
         networkTest = theLHS->externalNetworkTest;
         secondaryNetworkTest = secondaryExternalTest;
         leftHash = theLHS->externalLeftHash;
         rightHash = theLHS->externalRightHash;
        } 
        
      /*=======================================================*/
      /* Otherwise, add the pattern to the appropriate pattern */
      /* network and use the pattern node containing the alpha */
      /* memory as the RHS of the join to be added.            */
      /*=======================================================*/
      
      else if (theLHS->right == NULL)
        {
         joinFromTheRight = FALSE;
         rhsType = 0;
         lastPattern = NULL;
         rhsStruct = NULL;
         lastRightJoin = NULL;
         isExists = theLHS->exists;
         networkTest = theLHS->networkTest;
         secondaryNetworkTest = theLHS->secondaryNetworkTest;
         leftHash = NULL;
         rightHash = NULL;
        }
      else
        {
         joinFromTheRight = FALSE;
         rhsType = theLHS->patternType->positionInArray;
         lastPattern = (*theLHS->patternType->addPatternFunction)(theEnv,theLHS);
         rhsStruct = lastPattern;
         lastRightJoin = NULL;
         isExists = theLHS->exists;
         networkTest = theLHS->networkTest;
         secondaryNetworkTest = theLHS->secondaryNetworkTest;
         leftHash = theLHS->leftHash;
         rightHash = theLHS->rightHash;
        }      

      /*======================================================*/
      /* Determine if the join being added is a logical join. */
      /*======================================================*/

      if ((startDepth == 1) && (joinNumber == logicalJoin)) isLogical = TRUE;
      else isLogical = FALSE;

      /*===============================================*/
      /* Get the list of joins which could potentially */
      /* be reused in place of the join being added.   */
      /*===============================================*/

      useLinks = TRUE;
      if (lastJoin != NULL)
        { theLinks = lastJoin->nextLinks; }
      else if (theLHS->right == NULL)
        { theLinks = DefruleData(theEnv)->RightPrimeJoins; }
      else if (lastPattern != NULL)
        { 
         listOfJoins = lastPattern->entryJoin;
         theLinks = NULL;
         useLinks = FALSE;
        }
      else
        { theLinks = lastRightJoin->nextLinks; }

      /*=======================================================*/
      /* Determine if the next join to be added can be shared. */
      /*=======================================================*/

      if ((tryToReuse == TRUE) &&
          ((oldJoin = FindShareableJoin(theLinks,listOfJoins,useLinks,rhsStruct,firstJoin,
                                        theLHS->negated,isExists,isLogical,
                                        networkTest,secondaryNetworkTest,
                                        leftHash,rightHash)) != NULL) )
        {
#if DEBUGGING_FUNCTIONS
         if ((EnvGetWatchItem(theEnv,"compilations") == TRUE) && GetPrintWhileLoading(theEnv))
           { EnvPrintRouter(theEnv,WDIALOG,"=j"); }
#endif
         lastJoin = oldJoin;
        }
      else
        {
         tryToReuse = FALSE;
         if (! joinFromTheRight)
           {
            lastJoin = CreateNewJoin(theEnv,networkTest,secondaryNetworkTest,lastJoin,
                                     lastPattern,FALSE,(int) theLHS->negated, isExists,
                                     leftHash,rightHash);
            lastJoin->rhsType = rhsType;
           }
         else
           {
            lastJoin = CreateNewJoin(theEnv,networkTest,secondaryNetworkTest,lastJoin,
                                     lastRightJoin,TRUE,(int) theLHS->negated, isExists,
                                     leftHash,rightHash);
            lastJoin->rhsType = rhsType;
           }
        }
      
      /*============================================*/
      /* If we've reached the end of the subgroup,  */
      /* then return the last join of the subgroup. */
      /*============================================*/
      
      if (lastIteration)
        { break; }
        
      /*=======================================*/
      /* Move on to the next join to be added. */
      /*=======================================*/

      theLHS = nextLHS;
      joinNumber++;
      firstJoin = FALSE;
     }

   /*=================================================*/
   /* Add the final join which stores the activations */
   /* of the rule. This join is never shared.         */
   /*=================================================*/
   
   if (startDepth == 1)
     {
      lastJoin = CreateNewJoin(theEnv,NULL,NULL,lastJoin,NULL,
                               FALSE,FALSE,FALSE,NULL,NULL);
     }

   /*===================================================*/
   /* If compilations are being watched, put a carriage */
   /* return after all of the =j's and +j's             */
   /*===================================================*/

#if DEBUGGING_FUNCTIONS
   if ((startDepth == 1) &&
       (EnvGetWatchItem(theEnv,"compilations") == TRUE) && 
       GetPrintWhileLoading(theEnv))
     { EnvPrintRouter(theEnv,WDIALOG,"\n"); }
#endif

   /*=============================*/
   /* Return the last join added. */
   /*=============================*/

   return(lastJoin);
  }

/****************************************************************/
/* AttachTestCEsToPatternCEs: Attaches the expressions found in */
/*   test CEs to the closest preceeding pattern CE that is not  */
/*   negated and is at the same not/and depth.                  */
/****************************************************************/
static void AttachTestCEsToPatternCEs(
  void *theEnv,
  struct lhsParseNode *theLHS)
  {
   struct lhsParseNode *lastNode, *tempNode, *lastLastNode;

   if (theLHS == NULL) return;

   /*=============================================================*/
   /* Attach test CEs that can be attached directly to a pattern. */
   /*=============================================================*/
   
   lastLastNode = NULL;
   lastNode = theLHS;
   theLHS = lastNode->bottom;
   
   while (theLHS != NULL)
     {
      /*================================================================*/
      /* Skip over any CE that's not a TEST CE as we're only interested */
      /* in attaching a TEST CE to a preceding pattern CE. Update the   */
      /* variables that track the preceding pattern.                    */
      /*================================================================*/
      
      if (theLHS->type != TEST_CE)
        {
         lastLastNode = lastNode;
         lastNode = theLHS;
         theLHS = theLHS->bottom;
         continue;
        }

      /*=====================================================*/
      /* If this is the beginning of a new NOT/AND CE group, */
      /* then we can't attach this TEST CE to a preceding    */
      /* pattern CE and should skip over it.                 */
      /*=====================================================*/
      
      /*================================================*/
      /* Case #2                                        */
      /*    Pattern CE                                  */
      /*       Depth Begin: N                           */
      /*       Depth End:   N                           */
      /*    Test CE                                     */
      /*       Depth Begin: M where M > N               */
      /*       Depth End:   -                           */
      /*                                                */
      /*    (defrule example                            */
      /*       (a)                                      */
      /*       (not (and (test (> 1 0))                 */
      /*                 (b)))                          */
      /*       =>)                                      */
      /*                                                */
      /* Case #8                                        */
      /*    Pattern CE                                  */
      /*       Depth Begin: N                           */
      /*       Depth End:   M where M < N               */
      /*    Test CE                                     */
      /*       Depth Begin: R where R > M               */
      /*       Depth End:   -                           */
      /*                                                */
      /*    (defrule example                            */
      /*       (not (and (a)                            */
      /*                 (c)))                          */
      /*       (not (and (test (> 1 0))                 */
      /*                 (b)))                          */
      /*       =>)                                      */
      /*                                                */
      /* This situation will not occur with the current */
      /* implementation. The initial pattern will be    */
      /* added before the test CE so that there is a    */
      /* pattern CE beginning the not/and or exists/and */
      /* pattern group.                                 */
      /*================================================*/
      
      if (theLHS->beginNandDepth > lastNode->endNandDepth)
        {
         lastLastNode = lastNode;
         lastNode = theLHS;
         theLHS = theLHS->bottom;
         continue;
        }
        
      /*==============================================================*/
      /* If the preceding pattern was the end of a NOT/AND CE group,  */
      /* then we can't attach this TEST CE to a preceding pattern and */
      /* should skip over it. The logic for handling the test CE will */
      /* be triggered when the joins are constructed. Note that the   */
      /* endNandDepth will never be greater than the beginNandDepth.  */
      /*==============================================================*/

      if (lastNode->beginNandDepth > lastNode->endNandDepth)
        {
         lastLastNode = lastNode;
         lastNode = theLHS;
         theLHS = theLHS->bottom;
         continue;
        }

      /*===================================================*/
      /* If the TEST CE does not close the preceding CE... */
      /*===================================================*/
         
      /*===================================================*/
      /* Case #1                                           */
      /*    Pattern CE                                     */
      /*       Depth Begin: N                              */
      /*       Depth End:   N                              */
      /*    Test CE                                        */
      /*       Depth Begin: N                              */
      /*       Depth End:   N                              */
      /*                                                   */
      /*    (defrule example                               */
      /*       (a ?x)                                      */
      /*       (test (> ?x 0))                             */
      /*       =>)                                         */
      /*                                                   */
      /* The test expression can be directly attached to   */
      /* the network expression for the preceding pattern. */
      /*===================================================*/
         
      if (theLHS->beginNandDepth == theLHS->endNandDepth)
        {
         /*==============================================================*/
         /* If the preceding pattern was a NOT or EXISTS CE containing   */
         /* a single pattern, then attached the TEST CE to the secondary */
         /* test, otherwise combine it with the primary network test.    */
         /*==============================================================*/
            
         if (lastNode->negated)
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }
         else
           {
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,theLHS->networkTest);
           }
        }
          
      /*=================================================================*/
      /* Otherwise the TEST CE closes a prior NOT/AND  or EXISTS/AND CE. */
      /*=================================================================*/

      /*==================================================*/
      /* If these are the first two patterns in the rule. */
      /*==================================================*/
      
      /*=========*/
      /* Case #3 */
      /*=========*/
      
      else if (lastLastNode == NULL)
        {
         /*=========================================================*/
         /* The prior pattern is a single pattern within a not/and. */
         /*                                                         */
         /*    (defrule example                                     */
         /*       (not (and (b)                                     */
         /*                 (test (= 1 1))))                        */
         /*       =>)                                               */
         /*                                                         */
         /* Collapse the nand pattern.                              */
         /*=========================================================*/
         
         if ((lastNode->negated == FALSE) &&
             (lastNode->existsNand == FALSE))
           {
            lastNode->beginNandDepth = theLHS->endNandDepth;
            
            lastNode->negated = TRUE;
            
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,lastNode->externalNetworkTest);
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,theLHS->networkTest);
            lastNode->externalNetworkTest = NULL;
           }
         
         /*=================================================================*/
         /* The prior pattern is a single negated pattern within a not/and. */
         /*                                                                 */
         /*    (defrule example                                             */
         /*       (not (and (not (b))                                       */
         /*                 (test (= 1 1))))                                */
         /*       =>)                                                       */
         /*                                                                 */
         /*=================================================================*/
         
         else if ((lastNode->negated == TRUE) &&
                  (lastNode->exists == FALSE) &&
                  (lastNode->existsNand == FALSE))
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }

         /*================================================================*/
         /* The prior pattern is a single exists pattern within a not/and. */
         /*                                                                */
         /*    (defrule example                                            */
         /*       (not (and (exists (b))                                   */
         /*                 (test (= 1 1))))                               */
         /*       =>)                                                      */
         /*                                                                */
         /*================================================================*/
            
         else if ((lastNode->negated == TRUE) &&
                  (lastNode->exists == TRUE) &&
                  (lastNode->existsNand == FALSE))
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }

         /*=============================================================*/
         /* The prior pattern is a single pattern within an exists/and. */
         /*                                                             */
         /*    (defrule example                                         */
         /*       (exists (and (b)                                      */
         /*                    (test (= 1 1))))                         */
         /*       =>)                                                   */
         /*                                                             */
         /* Collapse the exists pattern.                                */
         /*=============================================================*/
         
         else if ((lastNode->negated == FALSE) &&
                  (lastNode->exists == FALSE) &&
                  (lastNode->existsNand == TRUE))
           {
            lastNode->beginNandDepth = theLHS->endNandDepth;
            
            lastNode->existsNand = FALSE;
            lastNode->exists = TRUE;
            lastNode->negated = TRUE;
               
            /*===================================================*/
            /* For the first two patterns, there shouldn't be an */
            /* externalNetwork test, but this code is included   */
            /* to match the other cases where patterns are       */
            /* collapsed.                                        */
            /*===================================================*/
            
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,lastNode->externalNetworkTest);
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,theLHS->networkTest);
            lastNode->externalNetworkTest = NULL;
           }

         /*=======================================*/
         /* The prior pattern is a single negated */
         /* pattern within an exists/and.         */
         /*                                       */
         /*    (defrule example                   */
         /*       (exists (and (not (b))          */
         /*                    (test (= 1 1))))   */
         /*       =>)                             */
         /*                                       */
         /*=======================================*/
            
         else if ((lastNode->negated == TRUE) &&
                  (lastNode->exists == FALSE) &&
                  (lastNode->existsNand == TRUE))
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }

         /*======================================*/
         /* The prior pattern is a single exists */
         /* pattern within an exists/and.        */
         /*                                      */
         /*    (defrule example                  */
         /*       (exists (and (exists (b))      */
         /*                    (test (= 1 1))))  */
         /*       =>)                            */
         /*                                      */
         /* Collapse the exists pattern.         */
         /*======================================*/
         
         else if ((lastNode->negated == TRUE) &&
                  (lastNode->exists == TRUE) &&
                  (lastNode->existsNand == TRUE))
           {
            lastNode->beginNandDepth = theLHS->endNandDepth;
            
            lastNode->existsNand = FALSE;

            /*===================================================*/
            /* For the first two patterns, there shouldn't be an */
            /* externalNetwork test, but this code is included   */
            /* to match the other cases where patterns are       */
            /* collapsed.                                        */
            /*===================================================*/
            
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,lastNode->externalNetworkTest);
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
            lastNode->externalNetworkTest = NULL;
           }
           
         /*==============================================*/
         /* Unhandled case which should not be possible. */
         /*==============================================*/
         
         else
           {
            SystemError(theEnv,"RULEBLD",1);
            EnvExitRouter(theEnv,EXIT_FAILURE);
           }
        }
      
      /*==============================================*/
      /* Otherwise, there are two preceding patterns. */
      /*==============================================*/

      /*====================================*/
      /* Case #4                            */
      /*    Pattern CE                      */
      /*       Depth Begin: -               */
      /*       Depth End:   N               */
      /*    Pattern CE                      */
      /*       Depth Begin: N               */
      /*       Depth End:   N               */
      /*    Test CE                         */
      /*       Depth Begin: N               */
      /*       Depth End:   M where M < N   */
      /*====================================*/
      
      else if (lastLastNode->endNandDepth == theLHS->beginNandDepth)
        {
         /*==============================================================*/
         /* If the preceding pattern was a NOT or EXISTS CE containing   */
         /* a single pattern, then attached the TEST CE to the secondary */
         /* test, otherwise combine it with the primary network test.    */
         /*==============================================================*/
         
         if (lastNode->negated)
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }
         else
           {
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,theLHS->networkTest);
           }
        }
           
      /*====================================*/
      /* Case #5                            */
      /*    Pattern CE                      */
      /*       Depth Begin: -               */
      /*       Depth End:   R where R < N   */
      /*    Pattern CE                      */
      /*       Depth Begin: N               */
      /*       Depth End:   N               */
      /*    Test CE                         */
      /*       Depth Begin: N               */
      /*       Depth End:   M where M < N   */
      /*====================================*/
            
      else if (lastLastNode->endNandDepth < theLHS->beginNandDepth)
        {
         /*=========================================================*/
         /* The prior pattern is a single pattern within a not/and: */
         /*                                                         */
         /*    (defrule example                                     */
         /*       (a)                                               */
         /*       (not (and (b)                                     */
         /*                 (test (= 1 1))))                        */
         /*       =>)                                               */
         /*                                                         */
         /* The test expression can be directly attached to the     */
         /* network expression for the pattern and the pattern      */
         /* group can be collapsed into a single negated pattern.   */
         /*=========================================================*/

         if ((lastNode->negated == FALSE) &&
             (lastNode->existsNand == FALSE))
           {
            /*====================*/
            /* Use max of R and M */
            /*====================*/
            
            if (lastLastNode->endNandDepth > theLHS->endNandDepth)
              { lastNode->beginNandDepth =  lastLastNode->endNandDepth; }
             else
              { lastNode->beginNandDepth =  theLHS->endNandDepth; }

            lastNode->negated = TRUE;
               
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,lastNode->externalNetworkTest);
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,theLHS->networkTest);
            lastNode->externalNetworkTest = NULL;
           }
          
         /*=================================================================*/
         /* The prior pattern is a single negated pattern within a not/and. */
         /*                                                                 */
         /*    (defrule example                                             */
         /*       (a)                                                       */
         /*       (not (and (not (b))                                       */
         /*                 (test (= 1 1))))                                */
         /*       =>)                                                       */
         /*=================================================================*/
            
         else if ((lastNode->negated == TRUE) &&
                  (lastNode->exists == FALSE) &&
                  (lastNode->existsNand == FALSE))
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }
  
         /*================================================================*/
         /* The prior pattern is a single exists pattern within a not/and. */
         /*                                                                */
         /*    (defrule example                                            */
         /*       (a)                                                      */
         /*       (not (and (exists (b))                                   */
         /*                 (test (= 1 1))))                               */
         /*       =>)                                                      */
         /*================================================================*/
            
         else if ((lastNode->negated == TRUE) &&
                  (lastNode->exists == TRUE) &&
                  (lastNode->existsNand == FALSE))
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }
                 
         /*=============================================================*/
         /* The prior pattern is a single pattern within an exists/and. */
         /*                                                             */
         /*    (defrule example                                         */
         /*       (a)                                                   */
         /*       (exists (and (b)                                      */
         /*                    (test (= 1 1))))                         */
         /*       =>)                                                   */
         /*                                                             */
         /* The test expression can be directly attached to the         */
         /* network expression for the pattern and the pattern          */
         /* group can be collapsed into a single exists pattern.        */
         /*=============================================================*/
            
         else if ((lastNode->negated == FALSE) &&
                  (lastNode->exists == FALSE) &&
                  (lastNode->existsNand == TRUE))
           {
            if (lastLastNode->endNandDepth > theLHS->endNandDepth)
              { lastNode->beginNandDepth =  lastLastNode->endNandDepth; }
             else
              { lastNode->beginNandDepth =  theLHS->endNandDepth; }

            lastNode->existsNand = FALSE;
            lastNode->exists = TRUE;
            lastNode->negated = TRUE;
            
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,lastNode->externalNetworkTest);
            lastNode->networkTest =
               CombineExpressions(theEnv,lastNode->networkTest,theLHS->networkTest);
            lastNode->externalNetworkTest = NULL;
           }
              
         /*=======================================*/
         /* The prior pattern is a single negated */
         /* pattern within an exists/and.         */
         /*                                       */
         /*    (defrule example                   */
         /*       (a)                             */
         /*       (exists (and (not (b))          */
         /*                    (test (= 1 1))))   */
         /*       =>)                             */
         /*                                       */
         /*=======================================*/
            
         else if ((lastNode->negated == TRUE) &&
                  (lastNode->exists == FALSE) &&
                  (lastNode->existsNand == TRUE))
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }

         /*======================================*/
         /* The prior pattern is a single exists */
         /* pattern within an exists/and.        */
         /*                                      */
         /*    (defrule example                  */
         /*       (a)                            */
         /*       (exists (and (exists (b))      */
         /*                    (test (= 1 1))))  */
         /*       =>)                            */
         /*                                      */
         /*======================================*/
         
         else if ((lastNode->negated == TRUE) &&
                  (lastNode->exists == TRUE) &&
                  (lastNode->existsNand == TRUE))
           {
            lastNode->secondaryNetworkTest =
               CombineExpressions(theEnv,lastNode->secondaryNetworkTest,theLHS->networkTest);
           }
           
         /*==============================================*/
         /* Unhandled case which should not be possible. */
         /*==============================================*/
      
         else
           {
            SystemError(theEnv,"RULEBLD",2);
            EnvExitRouter(theEnv,EXIT_FAILURE);
           }
        }
        
      /*==============================================*/
      /* Unhandled case which should not be possible. */
      /*==============================================*/
      
      else
        {
         SystemError(theEnv,"RULEBLD",3);
         EnvExitRouter(theEnv,EXIT_FAILURE);
        }
        
      /*=================================================*/
      /* Remove the TEST CE and continue to the next CE. */
      /*=================================================*/
         
      theLHS->networkTest = NULL;
      tempNode = theLHS->bottom;
      theLHS->bottom = NULL;
      lastNode->bottom = tempNode;
      lastNode->endNandDepth = theLHS->endNandDepth;
      ReturnLHSParseNodes(theEnv,theLHS);
      theLHS = tempNode;
     }
  }
  
/********************************************************************/
/* FindShareableJoin: Determines whether a join exists that can be  */
/*   reused for the join currently being added to the join network. */
/*   Returns a pointer to the join to be shared if one if found,    */
/*   otherwise returns a NULL pointer.                              */
/********************************************************************/
static struct joinNode *FindShareableJoin(
  struct joinLink *theLinks,
  struct joinNode *listOfJoins,
  intBool useLinks,
  void *rhsStruct,
  unsigned int firstJoin,
  unsigned int negatedRHS,
  unsigned int existsRHS,
  unsigned int isLogical,
  struct expr *joinTest,
  struct expr *secondaryJoinTest,
  struct expr *leftHash,
  struct expr *rightHash)
  {   
   /*========================================*/
   /* Loop through all of the joins in the   */
   /* list of potential candiates for reuse. */
   /*========================================*/

   if (useLinks)
     { 
      if (theLinks != NULL)
        { listOfJoins = theLinks->join; }
      else
        { listOfJoins = NULL; }
     }
     
   while (listOfJoins != NULL)
     {
      /*=========================================================*/
      /* If the join being tested for reuse is connected on the  */
      /* RHS to the end node of the pattern node associated with */
      /* the join to be added, then determine if the join can    */
      /* be reused. If so, return the join.                      */
      /*=========================================================*/

      if (listOfJoins->rightSideEntryStructure == rhsStruct)
        {
         if (TestJoinForReuse(listOfJoins,firstJoin,negatedRHS,existsRHS,
                              isLogical,joinTest,secondaryJoinTest,
                              leftHash,rightHash))
           { return(listOfJoins); }
        }

      /*====================================================*/
      /* Move on to the next potential candidate. Note that */
      /* the rightMatchNode link is used for traversing     */
      /* through the candidates for the first join of a     */
      /* rule and that rightDriveNode link is used for      */
      /* traversing through the candidates for subsequent   */
      /* joins of a rule.                                   */
      /*====================================================*/

      if (useLinks)
        {
         theLinks = theLinks->next;
         if (theLinks != NULL) 
           { listOfJoins = theLinks->join; }
         else
           { listOfJoins = NULL; }
        }
      else
        { listOfJoins = listOfJoins->rightMatchNode; }
     }

   /*================================*/
   /* Return a NULL pointer, since a */
   /* reusable join was not found.   */
   /*================================*/

   return(NULL);
  }

/**************************************************************/
/* TestJoinForReuse: Determines if the specified join can be  */
/*   shared with a join being added for a rule being defined. */
/*   Returns TRUE if the join can be shared, otherwise FALSE. */
/**************************************************************/
static int TestJoinForReuse(
  struct joinNode *testJoin,
  unsigned firstJoin,
  unsigned negatedRHS,
  unsigned existsRHS,
  unsigned int isLogical,
  struct expr *joinTest,
  struct expr *secondaryJoinTest,
  struct expr *leftHash,
  struct expr *rightHash)
  {
   /*==================================================*/
   /* The first join of a rule may only be shared with */
   /* a join that has its firstJoin field set to TRUE. */
   /*==================================================*/

   if (testJoin->firstJoin != firstJoin) return(FALSE);

   /*========================================================*/
   /* A join connected to a not CE may only be shared with a */
   /* join that has its patternIsNegated field set to TRUE.  */
   /*========================================================*/

   if ((testJoin->patternIsNegated != negatedRHS) && (! existsRHS)) return(FALSE);

   /*==========================================================*/
   /* A join connected to an exists CE may only be shared with */
   /* a join that has its patternIsExists field set to TRUE.   */
   /*==========================================================*/

   if (testJoin->patternIsExists != existsRHS) return(FALSE);
   
   /*==========================================================*/
   /* If the join added is associated with a logical CE, then  */
   /* either the join to be shared must be associated with a   */
   /* logical CE or the beta memory must be empty (since       */
   /* joins associate an extra field with each partial match). */
   /*==========================================================*/

   if ((isLogical == TRUE) &&
       (testJoin->logicalJoin == FALSE) &&
       BetaMemoryNotEmpty(testJoin))
     { return(FALSE); }

   /*===============================================================*/
   /* The expression associated with the join must be identical to  */
   /* the networkTest expression stored with the join to be shared. */
   /*===============================================================*/

   if (IdenticalExpression(testJoin->networkTest,joinTest) != TRUE)
     { return(FALSE); }

   if (IdenticalExpression(testJoin->secondaryNetworkTest,secondaryJoinTest) != TRUE)
     { return(FALSE); }
     
   /*====================================================================*/
   /* The alpha memory hashing values associated with the join must be   */
   /* identical to the hashing values stored with the join to be shared. */
   /*====================================================================*/

   if (IdenticalExpression(testJoin->leftHash,leftHash) != TRUE)
     { return(FALSE); }

   if (IdenticalExpression(testJoin->rightHash,rightHash) != TRUE)
     { return(FALSE); }
     
   /*=============================================*/
   /* The join can be shared since all conditions */
   /* for sharing have been satisfied.            */
   /*=============================================*/

   return(TRUE);
  }

/*************************************************************************/
/* CreateNewJoin: Creates a new join and links it into the join network. */
/*************************************************************************/
static struct joinNode *CreateNewJoin(
  void *theEnv,
  struct expr *joinTest,
  struct expr *secondaryJoinTest,
  struct joinNode *lhsEntryStruct,
  void *rhsEntryStruct,
  int joinFromTheRight,
  int negatedRHSPattern,
  int existsRHSPattern,
  struct expr *leftHash,
  struct expr *rightHash)
  {
   struct joinNode *newJoin;
   struct joinLink *theLink;
   
   /*===============================================*/
   /* If compilations are being watch, print +j to  */
   /* indicate that a new join has been created for */
   /* this pattern of the rule (i.e. a join could   */
   /* not be shared with another rule.              */
   /*===============================================*/

#if DEBUGGING_FUNCTIONS
   if ((EnvGetWatchItem(theEnv,"compilations") == TRUE) && GetPrintWhileLoading(theEnv))
     { EnvPrintRouter(theEnv,WDIALOG,"+j"); }
#endif

   /*======================*/
   /* Create the new join. */
   /*======================*/

   newJoin = get_struct(theEnv,joinNode);
   
   /*======================================================*/
   /* The first join of a rule does not have a beta memory */
   /* unless the RHS pattern is an exists or not CE.       */
   /*======================================================*/
   
   if ((lhsEntryStruct != NULL) || existsRHSPattern || negatedRHSPattern || joinFromTheRight)
     {
      if (leftHash == NULL)     
        {      
         newJoin->leftMemory = get_struct(theEnv,betaMemory); 
         newJoin->leftMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
         newJoin->leftMemory->beta[0] = NULL;
         newJoin->leftMemory->last = NULL;
         newJoin->leftMemory->size = 1;
         newJoin->leftMemory->count = 0;
         }
      else
        {
         newJoin->leftMemory = get_struct(theEnv,betaMemory); 
         newJoin->leftMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         memset(newJoin->leftMemory->beta,0,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         newJoin->leftMemory->last = NULL;
         newJoin->leftMemory->size = INITIAL_BETA_HASH_SIZE;
         newJoin->leftMemory->count = 0;
        }
      
      /*===========================================================*/
      /* If the first join of a rule connects to an exists or not  */
      /* CE, then we create an empty partial match for the usually */
      /* empty left beta memory so that we can track the current   */
      /* current right memory partial match satisfying the CE.     */
      /*===========================================================*/
         
      if ((lhsEntryStruct == NULL) && (existsRHSPattern || negatedRHSPattern || joinFromTheRight))
        {
         newJoin->leftMemory->beta[0] = CreateEmptyPartialMatch(theEnv); 
         newJoin->leftMemory->beta[0]->owner = newJoin;
         newJoin->leftMemory->count = 1;
        }
     }
   else
     { newJoin->leftMemory = NULL; }
     
   if (joinFromTheRight)
     {
      if (leftHash == NULL)     
        {      
         newJoin->rightMemory = get_struct(theEnv,betaMemory); 
         newJoin->rightMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
         newJoin->rightMemory->last = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
         newJoin->rightMemory->beta[0] = NULL;
         newJoin->rightMemory->last[0] = NULL;
         newJoin->rightMemory->size = 1;
         newJoin->rightMemory->count = 0;
         }
      else
        {
         newJoin->rightMemory = get_struct(theEnv,betaMemory); 
         newJoin->rightMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         newJoin->rightMemory->last = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         memset(newJoin->rightMemory->beta,0,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         memset(newJoin->rightMemory->last,0,sizeof(struct partialMatch *) * INITIAL_BETA_HASH_SIZE);
         newJoin->rightMemory->size = INITIAL_BETA_HASH_SIZE;
         newJoin->rightMemory->count = 0;
        }     
     }
   else if (rhsEntryStruct == NULL)
     {
      newJoin->rightMemory = get_struct(theEnv,betaMemory); 
      newJoin->rightMemory->beta = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
      newJoin->rightMemory->last = (struct partialMatch **) genalloc(theEnv,sizeof(struct partialMatch *));
      newJoin->rightMemory->beta[0] = CreateEmptyPartialMatch(theEnv);
      newJoin->rightMemory->beta[0]->owner = newJoin;
      newJoin->rightMemory->beta[0]->rhsMemory = TRUE;
      newJoin->rightMemory->last[0] = newJoin->rightMemory->beta[0];
      newJoin->rightMemory->size = 1;
      newJoin->rightMemory->count = 1;    
     }
   else
     { newJoin->rightMemory = NULL; }
     
   newJoin->nextLinks = NULL;
   newJoin->joinFromTheRight = joinFromTheRight;
   
   if (existsRHSPattern)
     { newJoin->patternIsNegated = FALSE; }
   else
     { newJoin->patternIsNegated = negatedRHSPattern; }
   newJoin->patternIsExists = existsRHSPattern;

   newJoin->marked = FALSE;
   newJoin->initialize = EnvGetIncrementalReset(theEnv);
   newJoin->logicalJoin = FALSE;
   newJoin->ruleToActivate = NULL;
   newJoin->memoryLeftAdds = 0;
   newJoin->memoryRightAdds = 0;
   newJoin->memoryLeftDeletes = 0;
   newJoin->memoryRightDeletes = 0;
   newJoin->memoryCompares = 0;

   /*==============================================*/
   /* Install the expressions used to determine    */
   /* if a partial match satisfies the constraints */
   /* associated with this join.                   */
   /*==============================================*/

   newJoin->networkTest = AddHashedExpression(theEnv,joinTest);
   newJoin->secondaryNetworkTest = AddHashedExpression(theEnv,secondaryJoinTest);
   
   /*=====================================================*/
   /* Install the expression used to hash the beta memory */
   /* partial match to determine the location to search   */
   /* in the alpha memory.                                */
   /*=====================================================*/
   
   newJoin->leftHash = AddHashedExpression(theEnv,leftHash);
   newJoin->rightHash = AddHashedExpression(theEnv,rightHash);

   /*============================================================*/
   /* Initialize the values associated with the LHS of the join. */
   /*============================================================*/

   newJoin->lastLevel = lhsEntryStruct;

   if (lhsEntryStruct == NULL)
     {
      newJoin->firstJoin = TRUE;
      newJoin->depth = 1;
     }
   else
     {
      newJoin->firstJoin = FALSE;
      newJoin->depth = lhsEntryStruct->depth;
      newJoin->depth++; /* To work around Sparcworks C compiler bug */
      
      theLink = get_struct(theEnv,joinLink);
      theLink->join = newJoin;
      theLink->enterDirection = LHS;
      
      /*==============================================================*/
      /* If this is a join from the right, then there should already  */
      /* be a link from the previous join to the other join in the    */
      /* the bifurcated path through the join network. If so, we want */
      /* add the next link to the join from the right so that it is   */
      /* visited after the other path. Doing this will reduce the     */
      /* number of activations added and then removed if the other    */
      /* path were followed first. The other path generates the       */
      /* partial matches which are negated by this path, so if that   */
      /* path is processed first, the partial matches from that path  */
      /* will prevent partial matches on this path.                   */
      /*==============================================================*/
      
      if ((joinFromTheRight) && (lhsEntryStruct->nextLinks != NULL))
        {
         theLink->next = lhsEntryStruct->nextLinks->next;
         lhsEntryStruct->nextLinks->next = theLink;
        }
      else
        {
         theLink->next = lhsEntryStruct->nextLinks;
         lhsEntryStruct->nextLinks = theLink;
        }
     }

   /*=======================================================*/
   /* Initialize the pointer values associated with the RHS */
   /* of the join (both for the new join and the join or    */
   /* pattern which enters this join from the right.        */
   /*=======================================================*/

   newJoin->rightSideEntryStructure = rhsEntryStruct;
   
   if (rhsEntryStruct == NULL)
     { 
      if (newJoin->firstJoin)
        {
         theLink = get_struct(theEnv,joinLink);
         theLink->join = newJoin;
         theLink->enterDirection = RHS;
         theLink->next = DefruleData(theEnv)->RightPrimeJoins;
         DefruleData(theEnv)->RightPrimeJoins = theLink;
        }
        
      newJoin->rightMatchNode = NULL;
        
      return(newJoin); 
     }
     
   /*===========================================================*/
   /* If the first join of a rule is a not CE, then it needs to */
   /* be "primed" under certain circumstances. This used to be  */
   /* handled by adding the (initial-fact) pattern to a rule    */
   /* with the not CE as its first pattern, but this alternate  */
   /* mechanism is now used so patterns don't have to be added. */
   /*===========================================================*/
     
   if (newJoin->firstJoin && (newJoin->patternIsNegated || newJoin->joinFromTheRight) && (! newJoin->patternIsExists))
     {
      theLink = get_struct(theEnv,joinLink);
      theLink->join = newJoin;
      theLink->enterDirection = LHS;
      theLink->next = DefruleData(theEnv)->LeftPrimeJoins;
      DefruleData(theEnv)->LeftPrimeJoins = theLink;
     }
       
   if (joinFromTheRight)
     {
      theLink = get_struct(theEnv,joinLink);
      theLink->join = newJoin;
      theLink->enterDirection = RHS;
      theLink->next = ((struct joinNode *) rhsEntryStruct)->nextLinks;
      ((struct joinNode *) rhsEntryStruct)->nextLinks = theLink;
      newJoin->rightMatchNode = NULL;
     }
   else
     {
      newJoin->rightMatchNode = ((struct patternNodeHeader *) rhsEntryStruct)->entryJoin;
      ((struct patternNodeHeader *) rhsEntryStruct)->entryJoin = newJoin;
     }

   /*================================*/
   /* Return the newly created join. */
   /*================================*/

   return(newJoin);
  }

#endif



