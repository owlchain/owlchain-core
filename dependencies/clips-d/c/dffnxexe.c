   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose: Deffunction Execution Routines                   */
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
/*      6.30: Changed garbage collection algorithm.          */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

/* =========================================
   *****************************************
               EXTERNAL DEFINITIONS
   =========================================
   ***************************************** */
#include "setup.h"

#if DEFFUNCTION_CONSTRUCT

#ifndef _STDIO_INCLUDED_
#define _STDIO_INCLUDED_
#include <stdio.h>
#endif

#include <string.h>

#include "constrct.h"
#include "envrnmnt.h"
#include "prcdrfun.h"
#include "prccode.h"
#include "proflfun.h"
#include "router.h"
#include "utility.h"
#include "watch.h"

#define _DFFNXEXE_SOURCE_
#include "dffnxexe.h"

/* =========================================
   *****************************************
                   CONSTANTS
   =========================================
   ***************************************** */
#define BEGIN_TRACE ">> "
#define END_TRACE   "<< "

/* =========================================
   *****************************************
      INTERNALLY VISIBLE FUNCTION HEADERS
   =========================================
   ***************************************** */

static void UnboundDeffunctionErr(void *);

#if DEBUGGING_FUNCTIONS
static void WatchDeffunction(void *,const char *);
#endif

/* =========================================
   *****************************************
          EXTERNALLY VISIBLE FUNCTIONS
   =========================================
   ***************************************** */

/****************************************************
  NAME         : CallDeffunction
  DESCRIPTION  : Executes the body of a deffunction
  INPUTS       : 1) The deffunction
                 2) Argument expressions
                 3) Data object buffer to hold result
  RETURNS      : Nothing useful
  SIDE EFFECTS : Deffunction executed and result
                 stored in data object buffer
  NOTES        : Used in EvaluateExpression(theEnv,)
 ****************************************************/
globle void CallDeffunction(
  void *theEnv,
  DEFFUNCTION *dptr,
  EXPRESSION *args,
  DATA_OBJECT *result)
  {
   int oldce;
   DEFFUNCTION *previouslyExecutingDeffunction;
   struct garbageFrame newGarbageFrame;
   struct garbageFrame *oldGarbageFrame;
#if PROFILING_FUNCTIONS
   struct profileFrameInfo profileFrame;
#endif

   result->type = SYMBOL;
   result->value = EnvFalseSymbol(theEnv);
   EvaluationData(theEnv)->EvaluationError = FALSE;
   if (EvaluationData(theEnv)->HaltExecution)
     return;
     
   oldGarbageFrame = UtilityData(theEnv)->CurrentGarbageFrame;
   memset(&newGarbageFrame,0,sizeof(struct garbageFrame));
   newGarbageFrame.priorFrame = oldGarbageFrame;
   UtilityData(theEnv)->CurrentGarbageFrame = &newGarbageFrame;

   oldce = ExecutingConstruct(theEnv);
   SetExecutingConstruct(theEnv,TRUE);
   previouslyExecutingDeffunction = DeffunctionData(theEnv)->ExecutingDeffunction;
   DeffunctionData(theEnv)->ExecutingDeffunction = dptr;
   EvaluationData(theEnv)->CurrentEvaluationDepth++;
   dptr->executing++;
   PushProcParameters(theEnv,args,CountArguments(args),EnvGetDeffunctionName(theEnv,(void *) dptr),
                      "deffunction",UnboundDeffunctionErr);
   if (EvaluationData(theEnv)->EvaluationError)
     {
      dptr->executing--;
      DeffunctionData(theEnv)->ExecutingDeffunction = previouslyExecutingDeffunction;
      EvaluationData(theEnv)->CurrentEvaluationDepth--;
      
      RestorePriorGarbageFrame(theEnv,&newGarbageFrame,oldGarbageFrame,result);
      CallPeriodicTasks(theEnv);

      SetExecutingConstruct(theEnv,oldce);
      return;
     }

#if DEBUGGING_FUNCTIONS
   if (dptr->trace)
     WatchDeffunction(theEnv,BEGIN_TRACE);
#endif

#if PROFILING_FUNCTIONS
   StartProfile(theEnv,&profileFrame,
                &dptr->header.usrData,
                ProfileFunctionData(theEnv)->ProfileConstructs);
#endif

   EvaluateProcActions(theEnv,dptr->header.whichModule->theModule,
                       dptr->code,dptr->numberOfLocalVars,
                       result,UnboundDeffunctionErr);

#if PROFILING_FUNCTIONS
    EndProfile(theEnv,&profileFrame);
#endif

#if DEBUGGING_FUNCTIONS
   if (dptr->trace)
     WatchDeffunction(theEnv,END_TRACE);
#endif
   ProcedureFunctionData(theEnv)->ReturnFlag = FALSE;

   dptr->executing--;
   PopProcParameters(theEnv);
   DeffunctionData(theEnv)->ExecutingDeffunction = previouslyExecutingDeffunction;
   EvaluationData(theEnv)->CurrentEvaluationDepth--;
   
   RestorePriorGarbageFrame(theEnv,&newGarbageFrame,oldGarbageFrame,result);
   CallPeriodicTasks(theEnv);
   
   SetExecutingConstruct(theEnv,oldce);
  }

/* =========================================
   *****************************************
          INTERNALLY VISIBLE FUNCTIONS
   =========================================
   ***************************************** */

/*******************************************************
  NAME         : UnboundDeffunctionErr
  DESCRIPTION  : Print out a synopis of the currently
                   executing deffunction for unbound
                   variable errors
  INPUTS       : None
  RETURNS      : Nothing useful
  SIDE EFFECTS : Error synopsis printed to WERROR
  NOTES        : None
 *******************************************************/
static void UnboundDeffunctionErr(
  void *theEnv)
  {
   EnvPrintRouter(theEnv,WERROR,"deffunction ");
   EnvPrintRouter(theEnv,WERROR,EnvGetDeffunctionName(theEnv,(void *) DeffunctionData(theEnv)->ExecutingDeffunction));
   EnvPrintRouter(theEnv,WERROR,".\n");
  }

#if DEBUGGING_FUNCTIONS

/***************************************************
  NAME         : WatchDeffunction
  DESCRIPTION  : Displays a message indicating when
                 a deffunction began and ended
                 execution
  INPUTS       : The beginning or end trace string
                 to print when deffunction starts
                 or finishes respectively
  RETURNS      : Nothing useful
  SIDE EFFECTS : Watch message printed
  NOTES        : None
 ***************************************************/
static void WatchDeffunction(
  void *theEnv,
  const char *tstring)
  {
   EnvPrintRouter(theEnv,WTRACE,"DFN ");
   EnvPrintRouter(theEnv,WTRACE,tstring);
   if (DeffunctionData(theEnv)->ExecutingDeffunction->header.whichModule->theModule != ((struct defmodule *) EnvGetCurrentModule(theEnv)))
     {
      EnvPrintRouter(theEnv,WTRACE,EnvGetDefmoduleName(theEnv,(void *)
                        DeffunctionData(theEnv)->ExecutingDeffunction->header.whichModule->theModule));
      EnvPrintRouter(theEnv,WTRACE,"::");
     }
   EnvPrintRouter(theEnv,WTRACE,ValueToString(DeffunctionData(theEnv)->ExecutingDeffunction->header.name));
   EnvPrintRouter(theEnv,WTRACE," ED:");
   PrintLongInteger(theEnv,WTRACE,(long long) EvaluationData(theEnv)->CurrentEvaluationDepth);
   PrintProcParamArray(theEnv,WTRACE);
  }

#endif
#endif
