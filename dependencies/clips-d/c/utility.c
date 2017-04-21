   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/03/15            */
   /*                                                     */
   /*                   UTILITY MODULE                    */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a set of utility functions useful to    */
/*   other modules. Primarily these are the functions for    */
/*   handling periodic garbage collection and appending      */
/*   string data.                                            */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian Dantes                                         */
/*      Jeff Bezanson                                        */
/*         www.cprogramming.com/tutorial/unicode.html        */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added CopyString, DeleteString,                */
/*            InsertInString,and EnlargeString functions.    */
/*                                                           */
/*            Used genstrncpy function instead of strncpy    */
/*            function.                                      */
/*                                                           */
/*            Support for typed EXTERNAL_ADDRESS.            */
/*                                                           */
/*            Support for tracked memory (allows memory to   */
/*            be freed if CLIPS is exited while executing).  */
/*                                                           */
/*            Added UTF-8 routines.                          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#define _UTILITY_SOURCE_

#include "setup.h"

#include <ctype.h>
#include <stdlib.h>

#include <stdio.h>
#define _STDIO_INCLUDED_
#include <string.h>

#include "commline.h"
#include "envrnmnt.h"
#include "evaluatn.h"
#include "facthsh.h"
#include "memalloc.h"
#include "multifld.h"
#include "prntutil.h"
#include "sysdep.h"

#include "utility.h"

#define MAX_EPHEMERAL_COUNT 1000L
#define MAX_EPHEMERAL_SIZE 10240L
#define COUNT_INCREMENT 1000L
#define SIZE_INCREMENT 10240L

/***************************************/
/* LOCAL INTERNAL FUNCTION DEFINITIONS */
/***************************************/

   static void                    DeallocateUtilityData(void *);

/************************************************/
/* InitializeUtilityData: Allocates environment */
/*    data for utility routines.                */
/************************************************/
globle void InitializeUtilityData(
  void *theEnv)
  {
   AllocateEnvironmentData(theEnv,UTILITY_DATA,sizeof(struct utilityData),DeallocateUtilityData);

   UtilityData(theEnv)->CurrentGarbageFrame = &UtilityData(theEnv)->MasterGarbageFrame;
   UtilityData(theEnv)->CurrentGarbageFrame->topLevel = TRUE;
   
   UtilityData(theEnv)->GarbageCollectionLocks = 0;
   UtilityData(theEnv)->PeriodicFunctionsEnabled = TRUE;
   UtilityData(theEnv)->YieldFunctionEnabled = TRUE;
  }
  
/**************************************************/
/* DeallocateUtilityData: Deallocates environment */
/*    data for utility routines.                  */
/**************************************************/
static void DeallocateUtilityData(
  void *theEnv)
  {
   struct callFunctionItem *tmpPtr, *nextPtr;
   struct trackedMemory *tmpTM, *nextTM;
   struct garbageFrame *theGarbageFrame;
   struct ephemeron *edPtr, *nextEDPtr;
   struct multifield *tmpMFPtr, *nextMFPtr;
   
   /*======================*/
   /* Free tracked memory. */
   /*======================*/
   
   tmpTM = UtilityData(theEnv)->trackList;
   while (tmpTM != NULL)
     {
      nextTM = tmpTM->next;
      genfree(theEnv,tmpTM->theMemory,tmpTM->memSize);
      rtn_struct(theEnv,trackedMemory,tmpTM);
      tmpTM = nextTM;
     }
   
   /*==========================*/
   /* Free callback functions. */
   /*==========================*/
   
   tmpPtr = UtilityData(theEnv)->ListOfPeriodicFunctions;
   while (tmpPtr != NULL)
     {
      nextPtr = tmpPtr->next;
      rtn_struct(theEnv,callFunctionItem,tmpPtr);
      tmpPtr = nextPtr;
     }

   tmpPtr = UtilityData(theEnv)->ListOfCleanupFunctions;
   while (tmpPtr != NULL)
     {
      nextPtr = tmpPtr->next;
      rtn_struct(theEnv,callFunctionItem,tmpPtr);
      tmpPtr = nextPtr;
     }
     
   /*=========================================*/
   /* Free the ephemerons tracking data which */
   /* needs to be garbage collected.          */
   /*=========================================*/
   
   while (UtilityData(theEnv)->CurrentGarbageFrame != NULL)
     {
      theGarbageFrame = UtilityData(theEnv)->CurrentGarbageFrame;
   
      edPtr = theGarbageFrame->ephemeralSymbolList;

      while (edPtr != NULL)
        {
         nextEDPtr = edPtr->next;
         rtn_struct(theEnv,ephemeron,edPtr);
         edPtr = nextEDPtr;
        }

      edPtr = theGarbageFrame->ephemeralFloatList;

      while (edPtr != NULL)
        {
         nextEDPtr = edPtr->next;
         rtn_struct(theEnv,ephemeron,edPtr);
         edPtr = nextEDPtr;
        }

      edPtr = theGarbageFrame->ephemeralIntegerList;

      while (edPtr != NULL)
        {
         nextEDPtr = edPtr->next;
         rtn_struct(theEnv,ephemeron,edPtr);
         edPtr = nextEDPtr;
        }

      edPtr = theGarbageFrame->ephemeralBitMapList;

      while (edPtr != NULL)
        {
         nextEDPtr = edPtr->next;
         rtn_struct(theEnv,ephemeron,edPtr);
         edPtr = nextEDPtr;
        }

      edPtr = theGarbageFrame->ephemeralExternalAddressList;

      while (edPtr != NULL)
        {
         nextEDPtr = edPtr->next;
         rtn_struct(theEnv,ephemeron,edPtr);
         edPtr = nextEDPtr;
        }

      /*==========================*/
      /* Free up multifield data. */
      /*==========================*/
      
      tmpMFPtr = theGarbageFrame->ListOfMultifields;
      while (tmpMFPtr != NULL)
        {
         nextMFPtr = tmpMFPtr->next;
         ReturnMultifield(theEnv,tmpMFPtr);
         tmpMFPtr = nextMFPtr;
        }
      
      UtilityData(theEnv)->CurrentGarbageFrame = UtilityData(theEnv)->CurrentGarbageFrame->priorFrame;
     }
  }

/*****************************/
/* CleanCurrentGarbageFrame: */
/*****************************/
globle void CleanCurrentGarbageFrame(
  void *theEnv,
  DATA_OBJECT *returnValue)
  {
   struct garbageFrame *currentGarbageFrame;
   
   currentGarbageFrame = UtilityData(theEnv)->CurrentGarbageFrame;

   if (! currentGarbageFrame->dirty) return;
 
   if (returnValue != NULL)
     { ValueInstall(theEnv,returnValue); }
   
   CallCleanupFunctions(theEnv);
   RemoveEphemeralAtoms(theEnv);
   FlushMultifields(theEnv);
   
   if (returnValue != NULL)
     { ValueDeinstall(theEnv,returnValue); }
    
   if ((currentGarbageFrame->ephemeralFloatList == NULL) &&
       (currentGarbageFrame->ephemeralIntegerList == NULL) &&
       (currentGarbageFrame->ephemeralSymbolList == NULL) &&
       (currentGarbageFrame->ephemeralBitMapList == NULL) &&
       (currentGarbageFrame->ephemeralExternalAddressList == NULL) &&
       (currentGarbageFrame->LastMultifield == NULL))
     { currentGarbageFrame->dirty = FALSE; }
  }

/*****************************/
/* RestorePriorGarbageFrame: */
/*****************************/
globle void RestorePriorGarbageFrame(
  void *theEnv,
  struct garbageFrame *newGarbageFrame,
  struct garbageFrame *oldGarbageFrame,
  DATA_OBJECT *returnValue)
  {
   if (newGarbageFrame->dirty)
     {
      if (returnValue != NULL) ValueInstall(theEnv,returnValue);
      CallCleanupFunctions(theEnv);
      RemoveEphemeralAtoms(theEnv);
      FlushMultifields(theEnv);
     }

   UtilityData(theEnv)->CurrentGarbageFrame = oldGarbageFrame;
   
   if (newGarbageFrame->dirty)
     {
      if (newGarbageFrame->ListOfMultifields != NULL)
        {
         if (oldGarbageFrame->ListOfMultifields == NULL)
           { oldGarbageFrame->ListOfMultifields = newGarbageFrame->ListOfMultifields; }
         else
           { oldGarbageFrame->LastMultifield->next = newGarbageFrame->ListOfMultifields; }
           
         oldGarbageFrame->LastMultifield = newGarbageFrame->LastMultifield;
         oldGarbageFrame->dirty = TRUE;
        }
        
      if (returnValue != NULL) ValueDeinstall(theEnv,returnValue);
     }
     
   if (returnValue != NULL)
     { EphemerateValue(theEnv,returnValue->type,returnValue->value); }
  }

/*************************/
/* CallCleanupFunctions: */
/*************************/
globle void CallCleanupFunctions(
  void *theEnv)
  {
   struct callFunctionItem *cleanupPtr;

   for (cleanupPtr = UtilityData(theEnv)->ListOfCleanupFunctions;
        cleanupPtr != NULL;
        cleanupPtr = cleanupPtr->next)
     {
      if (cleanupPtr->environmentAware)
        { (*cleanupPtr->func)(theEnv); }
      else            
        { (* (void (*)(void)) cleanupPtr->func)(); }
     }
  }

/**************************************************/
/* CallPeriodicTasks: Calls the list of functions */
/*   for handling periodic tasks.                 */
/**************************************************/
globle void CallPeriodicTasks(
  void *theEnv)
  {
   struct callFunctionItem *periodPtr;

   if (UtilityData(theEnv)->PeriodicFunctionsEnabled)
     {
      for (periodPtr = UtilityData(theEnv)->ListOfPeriodicFunctions;
           periodPtr != NULL;
           periodPtr = periodPtr->next)
        { 
         if (periodPtr->environmentAware)
           { (*periodPtr->func)(theEnv); }
         else            
           { (* (void (*)(void)) periodPtr->func)(); }
        }
     }
  }

/***************************************************/
/* AddCleanupFunction: Adds a function to the list */
/*   of functions called to perform cleanup such   */
/*   as returning free memory to the memory pool.  */
/***************************************************/
globle intBool AddCleanupFunction(
  void *theEnv,
  const char *name,
  void (*theFunction)(void *),
  int priority)
  {
   UtilityData(theEnv)->ListOfCleanupFunctions =
     AddFunctionToCallList(theEnv,name,priority,
                           (void (*)(void *)) theFunction,
                           UtilityData(theEnv)->ListOfCleanupFunctions,TRUE);
   return(1);
  }

#if ALLOW_ENVIRONMENT_GLOBALS
/****************************************************/
/* AddPeriodicFunction: Adds a function to the list */
/*   of functions called to handle periodic tasks.  */
/****************************************************/
globle intBool AddPeriodicFunction(
  const char *name,
  void (*theFunction)(void),
  int priority)
  {
   void *theEnv;
   
   theEnv = GetCurrentEnvironment();
   
   UtilityData(theEnv)->ListOfPeriodicFunctions =
     AddFunctionToCallList(theEnv,name,priority,
                           (void (*)(void *)) theFunction,
                           UtilityData(theEnv)->ListOfPeriodicFunctions,FALSE);

   return(1);
  }
#endif

/*******************************************************/
/* EnvAddPeriodicFunction: Adds a function to the list */
/*   of functions called to handle periodic tasks.     */
/*******************************************************/
globle intBool EnvAddPeriodicFunction(
  void *theEnv,
  const char *name,
  void (*theFunction)(void *),
  int priority)
  {
   UtilityData(theEnv)->ListOfPeriodicFunctions =
     AddFunctionToCallList(theEnv,name,priority,
                           (void (*)(void *)) theFunction,
                           UtilityData(theEnv)->ListOfPeriodicFunctions,TRUE);
   return(1);
  }

/*******************************************************/
/* RemoveCleanupFunction: Removes a function from the  */
/*   list of functions called to perform cleanup such  */
/*   as returning free memory to the memory pool.      */
/*******************************************************/
globle intBool RemoveCleanupFunction(
  void *theEnv,
  const char *name)
  {
   intBool found;
   
   UtilityData(theEnv)->ListOfCleanupFunctions =
      RemoveFunctionFromCallList(theEnv,name,UtilityData(theEnv)->ListOfCleanupFunctions,&found);
  
   return found;
  }

/**********************************************************/
/* EnvRemovePeriodicFunction: Removes a function from the */
/*   list of functions called to handle periodic tasks.   */
/**********************************************************/
globle intBool EnvRemovePeriodicFunction(
  void *theEnv,
  const char *name)
  {
   intBool found;
   
   UtilityData(theEnv)->ListOfPeriodicFunctions =
      RemoveFunctionFromCallList(theEnv,name,UtilityData(theEnv)->ListOfPeriodicFunctions,&found);
  
   return found;
  }

/*****************************************************/
/* StringPrintForm: Generates printed representation */
/*   of a string. Replaces / with // and " with /".  */
/*****************************************************/
globle const char *StringPrintForm(
  void *theEnv,
  const char *str)
  {
   int i = 0;
   size_t pos = 0;
   size_t max = 0;
   char *theString = NULL;
   void *thePtr;

   theString = ExpandStringWithChar(theEnv,'"',theString,&pos,&max,max+80);
   while (str[i] != EOS)
     {
      if ((str[i] == '"') || (str[i] == '\\'))
        {
         theString = ExpandStringWithChar(theEnv,'\\',theString,&pos,&max,max+80);
         theString = ExpandStringWithChar(theEnv,str[i],theString,&pos,&max,max+80);
        }
      else
        { theString = ExpandStringWithChar(theEnv,str[i],theString,&pos,&max,max+80); }
      i++;
     }

   theString = ExpandStringWithChar(theEnv,'"',theString,&pos,&max,max+80);

   thePtr = EnvAddSymbol(theEnv,theString);
   rm(theEnv,theString,max);
   return(ValueToString(thePtr));
  }

/**************************************************************/
/* CopyString: Copies a string using CLIPS memory management. */
/**************************************************************/
globle char *CopyString(
  void *theEnv,
  const char *theString)
  {
   char *stringCopy = NULL;
   
   if (theString != NULL)
     {
      stringCopy = (char *) genalloc(theEnv,strlen(theString) + 1);
      genstrcpy(stringCopy,theString);
     }
     
   return stringCopy;
  }

/*****************************************************************/
/* DeleteString: Deletes a string using CLIPS memory management. */
/*****************************************************************/
globle void DeleteString(
  void *theEnv,
  char *theString)
  {
   if (theString != NULL)
     { genfree(theEnv,theString,strlen(theString) + 1); }
  }

/***********************************************************/
/* AppendStrings: Appends two strings together. The string */
/*   created is added to the SymbolTable, so it is not     */
/*   necessary to deallocate the string returned.          */
/***********************************************************/
globle const char *AppendStrings(
  void *theEnv,
  const char *str1,
  const char *str2)
  {
   size_t pos = 0;
   size_t max = 0;
   char *theString = NULL;
   void *thePtr;

   theString = AppendToString(theEnv,str1,theString,&pos,&max);
   theString = AppendToString(theEnv,str2,theString,&pos,&max);

   thePtr = EnvAddSymbol(theEnv,theString);
   rm(theEnv,theString,max);
   return(ValueToString(thePtr));
  }

/******************************************************/
/* AppendToString: Appends a string to another string */
/*   (expanding the other string if necessary).       */
/******************************************************/
globle char *AppendToString(
  void *theEnv,
  const char *appendStr,
  char *oldStr,
  size_t *oldPos,
  size_t *oldMax)
  {
   size_t length;

   /*=========================================*/
   /* Expand the old string so it can contain */
   /* the new string (if necessary).          */
   /*=========================================*/

   length = strlen(appendStr);

   /*==============================================================*/
   /* Return NULL if the old string was not successfully expanded. */
   /*==============================================================*/

   if ((oldStr = EnlargeString(theEnv,length,oldStr,oldPos,oldMax)) == NULL) { return(NULL); }

   /*===============================================*/
   /* Append the new string to the expanded string. */
   /*===============================================*/

   genstrcpy(&oldStr[*oldPos],appendStr);
   *oldPos += (int) length;

   /*============================================================*/
   /* Return the expanded string containing the appended string. */
   /*============================================================*/

   return(oldStr);
  }

/**********************************************************/
/* InsertInString: Inserts a string within another string */
/*   (expanding the other string if necessary).           */
/**********************************************************/
globle char *InsertInString(
  void *theEnv,
  const char *insertStr,
  size_t position,
  char *oldStr,
  size_t *oldPos,
  size_t *oldMax)
  {
   size_t length;

   /*=========================================*/
   /* Expand the old string so it can contain */
   /* the new string (if necessary).          */
   /*=========================================*/

   length = strlen(insertStr);

   /*==============================================================*/
   /* Return NULL if the old string was not successfully expanded. */
   /*==============================================================*/

   if ((oldStr = EnlargeString(theEnv,length,oldStr,oldPos,oldMax)) == NULL) { return(NULL); }

   /*================================================================*/
   /* Shift the contents to the right of insertion point so that the */
   /* new text does not overwrite what is currently in the string.   */
   /*================================================================*/
   
   memmove(&oldStr[position],&oldStr[position+length],*oldPos - position);

   /*===============================================*/
   /* Insert the new string in the expanded string. */
   /*===============================================*/

   genstrncpy(&oldStr[*oldPos],insertStr,length);
   *oldPos += (int) length;

   /*============================================================*/
   /* Return the expanded string containing the appended string. */
   /*============================================================*/

   return(oldStr);
  }
  
/*******************************************************************/
/* EnlargeString: Enlarges a string by the specified amount.       */
/*******************************************************************/
globle char *EnlargeString(
  void *theEnv,
  size_t length,
  char *oldStr,
  size_t *oldPos,
  size_t *oldMax)
  {
   /*=========================================*/
   /* Expand the old string so it can contain */
   /* the new string (if necessary).          */
   /*=========================================*/

   if (length + *oldPos + 1 > *oldMax)
     {
      oldStr = (char *) genrealloc(theEnv,oldStr,*oldMax,length + *oldPos + 1);
      *oldMax = length + *oldPos + 1;
     }

   /*==============================================================*/
   /* Return NULL if the old string was not successfully expanded. */
   /*==============================================================*/

   if (oldStr == NULL) { return(NULL); }

   return(oldStr);
  }

/*******************************************************/
/* AppendNToString: Appends a string to another string */
/*   (expanding the other string if necessary). Only a */
/*   specified number of characters are appended from  */
/*   the string.                                       */
/*******************************************************/
globle char *AppendNToString(
  void *theEnv,
  const char *appendStr,
  char *oldStr,
  size_t length,
  size_t *oldPos,
  size_t *oldMax)
  {
   size_t lengthWithEOS;

   /*====================================*/
   /* Determine the number of characters */
   /* to be appended from the string.    */
   /*====================================*/

   if (appendStr[length-1] != '\0') lengthWithEOS = length + 1;
   else lengthWithEOS = length;

   /*=========================================*/
   /* Expand the old string so it can contain */
   /* the new string (if necessary).          */
   /*=========================================*/

   if (lengthWithEOS + *oldPos > *oldMax)
     {
      oldStr = (char *) genrealloc(theEnv,oldStr,*oldMax,*oldPos + lengthWithEOS);
      *oldMax = *oldPos + lengthWithEOS;
     }

   /*==============================================================*/
   /* Return NULL if the old string was not successfully expanded. */
   /*==============================================================*/

   if (oldStr == NULL) { return(NULL); }

   /*==================================*/
   /* Append N characters from the new */
   /* string to the expanded string.   */
   /*==================================*/

   genstrncpy(&oldStr[*oldPos],appendStr,length);
   *oldPos += (lengthWithEOS - 1);
   oldStr[*oldPos] = '\0';

   /*============================================================*/
   /* Return the expanded string containing the appended string. */
   /*============================================================*/

   return(oldStr);
  }

/*******************************************************/
/* ExpandStringWithChar: Adds a character to a string, */
/*   reallocating space for the string if it needs to  */
/*   be enlarged. The backspace character causes the   */
/*   size of the string to reduced if it is "added" to */
/*   the string.                                       */
/*******************************************************/
globle char *ExpandStringWithChar(
  void *theEnv,
  int inchar,
  char *str,
  size_t *pos,
  size_t *max,
  size_t newSize)
  {
   if ((*pos + 1) >= *max)
     {
      str = (char *) genrealloc(theEnv,str,*max,newSize);
      *max = newSize;
     }

  if (inchar != '\b')
    {
     str[*pos] = (char) inchar;
     (*pos)++;
     str[*pos] = '\0';
    }
  else
    {
     /*===========================================================*/
     /* First delete any UTF-8 multibyte continuation characters. */
     /*===========================================================*/

     while ((*pos > 1) && IsUTF8MultiByteContinuation(str[*pos - 1]))
       { (*pos)--; }
     
     /*===================================================*/
     /* Now delete the first byte of the UTF-8 character. */
     /*===================================================*/
     
     if (*pos > 0) (*pos)--;
     str[*pos] = '\0';
    }

   return(str);
  }

/*****************************************************************/
/* AddFunctionToCallList: Adds a function to a list of functions */
/*   which are called to perform certain operations (e.g. clear, */
/*   reset, and bload functions).                                */
/*****************************************************************/
globle struct callFunctionItem *AddFunctionToCallList(
  void *theEnv,
  const char *name,
  int priority,
  void (*func)(void *),
  struct callFunctionItem *head,
  intBool environmentAware)
  {
   return AddFunctionToCallListWithContext(theEnv,name,priority,func,head,environmentAware,NULL);
  }
  
/***********************************************************/
/* AddFunctionToCallListWithContext: Adds a function to a  */
/*   list of functions which are called to perform certain */
/*   operations (e.g. clear, reset, and bload functions).  */
/***********************************************************/
globle struct callFunctionItem *AddFunctionToCallListWithContext(
  void *theEnv,
  const char *name,
  int priority,
  void (*func)(void *),
  struct callFunctionItem *head,
  intBool environmentAware,
  void *context)
  {
   struct callFunctionItem *newPtr, *currentPtr, *lastPtr = NULL;

   newPtr = get_struct(theEnv,callFunctionItem);

   newPtr->name = name;
   newPtr->func = func;
   newPtr->priority = priority;
   newPtr->environmentAware = (short) environmentAware;
   newPtr->context = context;

   if (head == NULL)
     {
      newPtr->next = NULL;
      return(newPtr);
     }

   currentPtr = head;
   while ((currentPtr != NULL) ? (priority < currentPtr->priority) : FALSE)
     {
      lastPtr = currentPtr;
      currentPtr = currentPtr->next;
     }

   if (lastPtr == NULL)
     {
      newPtr->next = head;
      head = newPtr;
     }
   else
     {
      newPtr->next = currentPtr;
      lastPtr->next = newPtr;
     }

   return(head);
  }

/*****************************************************************/
/* RemoveFunctionFromCallList: Removes a function from a list of */
/*   functions which are called to perform certain operations    */
/*   (e.g. clear, reset, and bload functions).                   */
/*****************************************************************/
globle struct callFunctionItem *RemoveFunctionFromCallList(
  void *theEnv,
  const char *name,
  struct callFunctionItem *head,
  int *found)
  {
   struct callFunctionItem *currentPtr, *lastPtr;

   *found = FALSE;
   lastPtr = NULL;
   currentPtr = head;

   while (currentPtr != NULL)
     {
      if (strcmp(name,currentPtr->name) == 0)
        {
         *found = TRUE;
         if (lastPtr == NULL)
           { head = currentPtr->next; }
         else
           { lastPtr->next = currentPtr->next; }

         rtn_struct(theEnv,callFunctionItem,currentPtr);
         return(head);
        }

      lastPtr = currentPtr;
      currentPtr = currentPtr->next;
     }

   return(head);
  }

/**************************************************************/
/* DeallocateCallList: Removes all functions from a list of   */
/*   functions which are called to perform certain operations */
/*   (e.g. clear, reset, and bload functions).                */
/**************************************************************/
globle void DeallocateCallList(
  void *theEnv,
  struct callFunctionItem *theList)
  {
   struct callFunctionItem *tmpPtr, *nextPtr;
   
   tmpPtr = theList;
   while (tmpPtr != NULL)
     {
      nextPtr = tmpPtr->next;
      rtn_struct(theEnv,callFunctionItem,tmpPtr);
      tmpPtr = nextPtr;
     }
  }
  
/***************************************************************/
/* AddFunctionToCallListWithArg: Adds a function to a list of  */
/*   functions which are called to perform certain operations  */
/*   (e.g. clear,reset, and bload functions).                  */
/***************************************************************/
globle struct callFunctionItemWithArg *AddFunctionToCallListWithArg(
  void *theEnv,
  const char *name,
  int priority,
  void (*func)(void *, void *),
  struct callFunctionItemWithArg *head,
  intBool environmentAware)
  {
   return AddFunctionToCallListWithArgWithContext(theEnv,name,priority,func,head,environmentAware,NULL);
  }
  
/***************************************************************/
/* AddFunctionToCallListWithArgWithContext: Adds a function to */
/*   a list of functions which are called to perform certain   */
/*   operations (e.g. clear, reset, and bload functions).      */
/***************************************************************/
globle struct callFunctionItemWithArg *AddFunctionToCallListWithArgWithContext(
  void *theEnv,
  const char *name,
  int priority,
  void (*func)(void *, void *),
  struct callFunctionItemWithArg *head,
  intBool environmentAware,
  void *context)
  {
   struct callFunctionItemWithArg *newPtr, *currentPtr, *lastPtr = NULL;

   newPtr = get_struct(theEnv,callFunctionItemWithArg);

   newPtr->name = name;
   newPtr->func = func;
   newPtr->priority = priority;
   newPtr->environmentAware = (short) environmentAware;
   newPtr->context = context;

   if (head == NULL)
     {
      newPtr->next = NULL;
      return(newPtr);
     }

   currentPtr = head;
   while ((currentPtr != NULL) ? (priority < currentPtr->priority) : FALSE)
     {
      lastPtr = currentPtr;
      currentPtr = currentPtr->next;
     }

   if (lastPtr == NULL)
     {
      newPtr->next = head;
      head = newPtr;
     }
   else
     {
      newPtr->next = currentPtr;
      lastPtr->next = newPtr;
     }

   return(head);
  }

/**************************************************************/
/* RemoveFunctionFromCallListWithArg: Removes a function from */
/*   a list of functions which are called to perform certain  */
/*   operations (e.g. clear, reset, and bload functions).     */
/**************************************************************/
globle struct callFunctionItemWithArg *RemoveFunctionFromCallListWithArg(
  void *theEnv,
  const char *name,
  struct callFunctionItemWithArg *head,
  int *found)
  {
   struct callFunctionItemWithArg *currentPtr, *lastPtr;

   *found = FALSE;
   lastPtr = NULL;
   currentPtr = head;

   while (currentPtr != NULL)
     {
      if (strcmp(name,currentPtr->name) == 0)
        {
         *found = TRUE;
         if (lastPtr == NULL)
           { head = currentPtr->next; }
         else
           { lastPtr->next = currentPtr->next; }

         rtn_struct(theEnv,callFunctionItemWithArg,currentPtr);
         return(head);
        }

      lastPtr = currentPtr;
      currentPtr = currentPtr->next;
     }

   return(head);
  }

/**************************************************************/
/* DeallocateCallListWithArg: Removes all functions from a list of   */
/*   functions which are called to perform certain operations */
/*   (e.g. clear, reset, and bload functions).                */
/**************************************************************/
globle void DeallocateCallListWithArg(
  void *theEnv,
  struct callFunctionItemWithArg *theList)
  {
   struct callFunctionItemWithArg *tmpPtr, *nextPtr;
   
   tmpPtr = theList;
   while (tmpPtr != NULL)
     {
      nextPtr = tmpPtr->next;
      rtn_struct(theEnv,callFunctionItemWithArg,tmpPtr);
      tmpPtr = nextPtr;
     }
  }

/*****************************************/
/* ItemHashValue: Returns the hash value */
/*   for the specified value.            */
/*****************************************/
globle unsigned long ItemHashValue(
  void *theEnv,
  unsigned short theType,
  void *theValue,
  unsigned long theRange)
  {
   union
     {
      void *vv;
      unsigned uv;
     } fis;
     
   switch(theType)
     {
      case FLOAT:
        return(HashFloat(ValueToDouble(theValue),theRange));

      case INTEGER:
        return(HashInteger(ValueToLong(theValue),theRange));

      case SYMBOL:
      case STRING:
#if OBJECT_SYSTEM
      case INSTANCE_NAME:
#endif
        return(HashSymbol(ValueToString(theValue),theRange));

      case MULTIFIELD:
        return(HashMultifield((struct multifield *) theValue,theRange));

#if DEFTEMPLATE_CONSTRUCT
      case FACT_ADDRESS:
        return(((struct fact *) theValue)->hashValue % theRange);
#endif

      case EXTERNAL_ADDRESS:
        return(HashExternalAddress(ValueToExternalAddress(theValue),theRange));
        
#if OBJECT_SYSTEM
      case INSTANCE_ADDRESS:
#endif
        fis.uv = 0;
        fis.vv = theValue;
        return(fis.uv % theRange);
     }

   SystemError(theEnv,"UTILITY",1);
   return(0);
  }

/********************************************/
/* YieldTime: Yields time to a user-defined */
/*   function. Intended to allow foreground */
/*   application responsiveness when CLIPS  */
/*   is running in the background.          */
/********************************************/
globle void YieldTime(
  void *theEnv)
  {
   if ((UtilityData(theEnv)->YieldTimeFunction != NULL) && UtilityData(theEnv)->YieldFunctionEnabled)
     { (*UtilityData(theEnv)->YieldTimeFunction)(); }
  }
   
/**********************************************/
/* EnvIncrementGCLocks: Increments the number */
/*   of garbage collection locks.             */
/**********************************************/
globle void EnvIncrementGCLocks(
  void *theEnv)
  {
   UtilityData(theEnv)->GarbageCollectionLocks++;
  }

/**********************************************/
/* EnvDecrementGCLocks: Decrements the number */
/*   of garbage collection locks.             */
/**********************************************/
globle void EnvDecrementGCLocks(
  void *theEnv)
  {
   if (UtilityData(theEnv)->GarbageCollectionLocks > 0)
     { UtilityData(theEnv)->GarbageCollectionLocks--; }
     
   if ((UtilityData(theEnv)->CurrentGarbageFrame->topLevel) && (! CommandLineData(theEnv)->EvaluatingTopLevelCommand) &&
       (EvaluationData(theEnv)->CurrentExpression == NULL) && (UtilityData(theEnv)->GarbageCollectionLocks == 0))
     { 
      CleanCurrentGarbageFrame(theEnv,NULL);
      CallPeriodicTasks(theEnv);
     }
  }
 
/********************************************/
/* EnablePeriodicFunctions:         */
/********************************************/
globle short EnablePeriodicFunctions(
  void *theEnv,
  short value)
  {
   short oldValue;
   
   oldValue = UtilityData(theEnv)->PeriodicFunctionsEnabled;
   
   UtilityData(theEnv)->PeriodicFunctionsEnabled = value;
   
   return(oldValue);
  }
  
/************************/
/* EnableYieldFunction: */
/************************/
globle short EnableYieldFunction(
  void *theEnv,
  short value)
  {
   short oldValue;
   
   oldValue = UtilityData(theEnv)->YieldFunctionEnabled;
   
   UtilityData(theEnv)->YieldFunctionEnabled = value;
   
   return(oldValue);
  }

/*************************************************************************/
/* AddTrackedMemory: Tracked memory is memory allocated by CLIPS that's  */
/*   referenced by a variable on the stack, but not by any environment   */
/*   data structure. An example would be the storage for local variables */
/*   allocated when a deffunction is executed. Tracking this memory      */
/*   allows it to be removed later when using longjmp as the code that   */
/*   would normally deallocate the memory would be bypassed.             */
/*************************************************************************/
globle struct trackedMemory *AddTrackedMemory(
  void *theEnv,
  void *theMemory,
  size_t theSize)
  {
   struct trackedMemory *newPtr;
   
   newPtr = get_struct(theEnv,trackedMemory);
   
   newPtr->prev = NULL;
   newPtr->theMemory = theMemory;
   newPtr->memSize = theSize;
   newPtr->next = UtilityData(theEnv)->trackList;
   UtilityData(theEnv)->trackList = newPtr;
   
   return newPtr;
  }

/************************/
/* RemoveTrackedMemory: */
/************************/
globle void RemoveTrackedMemory(
  void *theEnv,
  struct trackedMemory *theTracker)
  {   
   if (theTracker->prev == NULL)
     { UtilityData(theEnv)->trackList = theTracker->next; }
   else
     { theTracker->prev->next = theTracker->next; }
     
   if (theTracker->next != NULL)
     { theTracker->next->prev = theTracker->prev; }
     
   rtn_struct(theEnv,trackedMemory,theTracker);
  }

/******************************************/
/* UTF8Length: Returns the logical number */
/*   of characters in a UTF8 string.      */
/******************************************/
globle size_t UTF8Length(
  const char *s)
  {
   size_t i = 0, length = 0;
   
   while (s[i] != '\0')
     { 
      UTF8Increment(s,&i); 
      length++;
     }
   
   return(length);
  }
  
/*********************************************/
/* UTF8Increment: Finds the beginning of the */
/*   next character in a UTF8 string.        */
/*********************************************/
globle void UTF8Increment(
  const char *s,
  size_t *i)
  {
   (void) (IsUTF8Start(s[++(*i)]) || 
           IsUTF8Start(s[++(*i)]) ||
           IsUTF8Start(s[++(*i)]) || 
           ++(*i));
  }

/****************************************************/
/* UTF8Offset: Converts the logical character index */
/*   in a UTF8 string to the actual byte offset.    */
/****************************************************/
globle size_t UTF8Offset(
  const char *str,
  size_t charnum)
  {
   size_t offs = 0;

   while ((charnum > 0) && (str[offs])) 
     {
      (void) (IsUTF8Start(str[++offs]) || 
              IsUTF8Start(str[++offs]) ||
              IsUTF8Start(str[++offs]) || 
              ++offs);
              
      charnum--;
     }
     
   return offs;
  }

/*************************************************/
/* UTF8CharNum: Converts the UTF8 character byte */ 
/*   offset to the logical character index.      */
/*************************************************/
globle size_t UTF8CharNum(
  const char *s,
  size_t offset)
  {
   size_t charnum = 0, offs=0;

   while ((offs < offset) && (s[offs])) 
     {
      (void) (IsUTF8Start(s[++offs]) ||
              IsUTF8Start(s[++offs]) ||
              IsUTF8Start(s[++offs]) || 
              ++offs);
              
      charnum++;
     }
     
   return charnum;
  }

/*#####################################*/
/* ALLOW_ENVIRONMENT_GLOBALS Functions */
/*#####################################*/

#if ALLOW_ENVIRONMENT_GLOBALS

globle void IncrementGCLocks()
  {
   EnvIncrementGCLocks(GetCurrentEnvironment());
  }

globle void DecrementGCLocks()
  {
   EnvDecrementGCLocks(GetCurrentEnvironment());
  }

globle intBool RemovePeriodicFunction(
  const char *name)
  {
   return EnvRemovePeriodicFunction(GetCurrentEnvironment(),name);
  }

#endif /* ALLOW_ENVIRONMENT_GLOBALS */
