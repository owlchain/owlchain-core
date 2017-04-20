   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*         DEFMODULE BASIC COMMANDS HEADER FILE        */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements core commands for the defmodule       */
/*   construct such as clear, reset, save, ppdefmodule       */
/*   list-defmodules, and get-defmodule-list.                */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#define _MODULBSC_SOURCE_

#include "setup.h"

#include <stdio.h>
#define _STDIO_INCLUDED_
#include <string.h>

#include "constrct.h"
#include "extnfunc.h"
#include "modulbin.h"
#include "prntutil.h"
#include "modulcmp.h"
#include "router.h"
#include "argacces.h"
#include "bload.h"
#include "multifld.h"
#include "envrnmnt.h"

#include "modulbsc.h"

/***************************************/
/* LOCAL INTERNAL FUNCTION DEFINITIONS */
/***************************************/

   static void                    ClearDefmodules(void *);
#if DEFMODULE_CONSTRUCT
   static void                    SaveDefmodules(void *,void *,const char *);
#endif

/*****************************************************************/
/* DefmoduleBasicCommands: Initializes basic defmodule commands. */
/*****************************************************************/
globle void DefmoduleBasicCommands(
  void *theEnv)
  {
   EnvAddClearFunction(theEnv,"defmodule",ClearDefmodules,2000);

#if DEFMODULE_CONSTRUCT
   AddSaveFunction(theEnv,"defmodule",SaveDefmodules,1100);

#if ! RUN_TIME
   EnvDefineFunction2(theEnv,"get-defmodule-list",'m',PTIEF EnvGetDefmoduleList,"EnvGetDefmoduleList","00");

#if DEBUGGING_FUNCTIONS
   EnvDefineFunction2(theEnv,"list-defmodules",'v', PTIEF ListDefmodulesCommand,"ListDefmodulesCommand","00");
   EnvDefineFunction2(theEnv,"ppdefmodule",'v',PTIEF PPDefmoduleCommand,"PPDefmoduleCommand","11w");
#endif
#endif
#endif

#if (BLOAD || BLOAD_ONLY || BLOAD_AND_BSAVE)
   DefmoduleBinarySetup(theEnv);
#endif

#if CONSTRUCT_COMPILER && (! RUN_TIME)
   DefmoduleCompilerSetup(theEnv);
#endif
  }

/*********************************************************/
/* ClearDefmodules: Defmodule clear routine for use with */
/*   the clear command. Creates the MAIN module.         */
/*********************************************************/
static void ClearDefmodules(
  void *theEnv)
  {
#if (BLOAD || BLOAD_AND_BSAVE || BLOAD_ONLY) && (! RUN_TIME)
   if (Bloaded(theEnv) == TRUE) return;
#endif
#if (! RUN_TIME)
   RemoveAllDefmodules(theEnv);

   CreateMainModule(theEnv);
   DefmoduleData(theEnv)->MainModuleRedefinable = TRUE;
#else
#if MAC_XCD
#pragma unused(theEnv)
#endif
#endif
  }

#if DEFMODULE_CONSTRUCT

/******************************************/
/* SaveDefmodules: Defmodule save routine */
/*   for use with the save command.       */
/******************************************/
static void SaveDefmodules(
  void *theEnv,
  void *theModule,
  const char *logicalName)
  {
   const char *ppform;

   ppform = EnvGetDefmodulePPForm(theEnv,theModule);
   if (ppform != NULL)
     {
      PrintInChunks(theEnv,logicalName,ppform);
      EnvPrintRouter(theEnv,logicalName,"\n");
     }
  }

/*************************************************/
/* EnvGetDefmoduleList: H/L and C access routine */
/*   for the get-defmodule-list function.        */
/*************************************************/
globle void EnvGetDefmoduleList(
  void *theEnv,
  DATA_OBJECT_PTR returnValue)
  {
   void *theConstruct;
   unsigned long count = 0;
   struct multifield *theList;

   /*====================================*/
   /* Determine the number of constructs */
   /* of the specified type.             */
   /*====================================*/

   for (theConstruct = EnvGetNextDefmodule(theEnv,NULL);
        theConstruct != NULL;
        theConstruct = EnvGetNextDefmodule(theEnv,theConstruct))
     { count++; }

   /*===========================*/
   /* Create a multifield large */
   /* enough to store the list. */
   /*===========================*/

   SetpType(returnValue,MULTIFIELD);
   SetpDOBegin(returnValue,1);
   SetpDOEnd(returnValue,(long) count);
   theList = (struct multifield *) EnvCreateMultifield(theEnv,count);
   SetpValue(returnValue,(void *) theList);

   /*====================================*/
   /* Store the names in the multifield. */
   /*====================================*/

   for (theConstruct = EnvGetNextDefmodule(theEnv,NULL), count = 1;
        theConstruct != NULL;
        theConstruct = EnvGetNextDefmodule(theEnv,theConstruct), count++)
     {
      if (EvaluationData(theEnv)->HaltExecution == TRUE)
        {
         EnvSetMultifieldErrorValue(theEnv,returnValue);
         return;
        }
      SetMFType(theList,count,SYMBOL);
      SetMFValue(theList,count,EnvAddSymbol(theEnv,EnvGetDefmoduleName(theEnv,theConstruct)));
     }
  }

#if DEBUGGING_FUNCTIONS

/********************************************/
/* PPDefmoduleCommand: H/L access routine   */
/*   for the ppdefmodule command.           */
/********************************************/
globle void PPDefmoduleCommand(
  void *theEnv)
  {
   const char *defmoduleName;

   defmoduleName = GetConstructName(theEnv,"ppdefmodule","defmodule name");
   if (defmoduleName == NULL) return;

   PPDefmodule(theEnv,defmoduleName,WDISPLAY);

   return;
  }

/*************************************/
/* PPDefmodule: C access routine for */
/*   the ppdefmodule command.        */
/*************************************/
globle int PPDefmodule(
  void *theEnv,
  const char *defmoduleName,
  const char *logicalName)
  {
   void *defmodulePtr;

   defmodulePtr = EnvFindDefmodule(theEnv,defmoduleName);
   if (defmodulePtr == NULL)
     {
      CantFindItemErrorMessage(theEnv,"defmodule",defmoduleName);
      return(FALSE);
     }

   if (EnvGetDefmodulePPForm(theEnv,defmodulePtr) == NULL) return(TRUE);
   PrintInChunks(theEnv,logicalName,EnvGetDefmodulePPForm(theEnv,defmodulePtr));
   return(TRUE);
  }

/***********************************************/
/* ListDefmodulesCommand: H/L access routine   */
/*   for the list-defmodules command.          */
/***********************************************/
globle void ListDefmodulesCommand(
  void *theEnv)
  {
   if (EnvArgCountCheck(theEnv,"list-defmodules",EXACTLY,0) == -1) return;

   EnvListDefmodules(theEnv,WDISPLAY);
  }

/***************************************/
/* EnvListDefmodules: C access routine */
/*   for the list-defmodules command.  */
/***************************************/
globle void EnvListDefmodules(
  void *theEnv,
  const char *logicalName)
  {
   void *theModule;
   int count = 0;

   for (theModule = EnvGetNextDefmodule(theEnv,NULL);
        theModule != NULL;
        theModule = EnvGetNextDefmodule(theEnv,theModule))
    {
     EnvPrintRouter(theEnv,logicalName,EnvGetDefmoduleName(theEnv,theModule));
     EnvPrintRouter(theEnv,logicalName,"\n");
     count++;
    }

   PrintTally(theEnv,logicalName,count,"defmodule","defmodules");
  }

#endif /* DEBUGGING_FUNCTIONS */

/*#####################################*/
/* ALLOW_ENVIRONMENT_GLOBALS Functions */
/*#####################################*/

#if ALLOW_ENVIRONMENT_GLOBALS

globle void GetDefmoduleList(
  DATA_OBJECT_PTR returnValue)
  {
   EnvGetDefmoduleList(GetCurrentEnvironment(),returnValue);
  }

#if DEBUGGING_FUNCTIONS

globle void ListDefmodules(
  const char *logicalName)
  {
   EnvListDefmodules(GetCurrentEnvironment(),logicalName);
  }

#endif /* DEBUGGING_FUNCTIONS */

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* DEFMODULE_CONSTRUCT */


