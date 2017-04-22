   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*                 UTILITY HEADER FILE                 */
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

#ifndef _H_utility
#define _H_utility

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

struct callFunctionItem
  {
   const char *name;
   void (*func)(void *);
   int priority;
   struct callFunctionItem *next;
   short int environmentAware;
   void *context;
  };

struct callFunctionItemWithArg
  {
   const char *name;
   void (*func)(void *,void *);
   int priority;
   struct callFunctionItemWithArg *next;
   short int environmentAware;
   void *context;
  };
  
struct trackedMemory
  {
   void *theMemory;
   struct trackedMemory *next;
   struct trackedMemory *prev;
   size_t memSize;
  };

struct garbageFrame
  {
   short dirty;
   short topLevel;
   struct garbageFrame *priorFrame;
   struct ephemeron *ephemeralSymbolList;
   struct ephemeron *ephemeralFloatList;
   struct ephemeron *ephemeralIntegerList;
   struct ephemeron *ephemeralBitMapList;
   struct ephemeron *ephemeralExternalAddressList;
   struct multifield *ListOfMultifields;
   struct multifield *LastMultifield;
  };

#define UTILITY_DATA 55

struct utilityData
  { 
   struct callFunctionItem *ListOfCleanupFunctions;
   struct callFunctionItem *ListOfPeriodicFunctions;
   short GarbageCollectionLocks;
   short PeriodicFunctionsEnabled;
   short YieldFunctionEnabled;
   void (*YieldTimeFunction)(void);
   struct trackedMemory *trackList;
   struct garbageFrame MasterGarbageFrame;
   struct garbageFrame *CurrentGarbageFrame;
  };

#define UtilityData(theEnv) ((struct utilityData *) GetEnvironmentData(theEnv,UTILITY_DATA))

  /* Is c the start of a utf8 sequence? */
#define IsUTF8Start(ch) (((ch) & 0xC0) != 0x80)
#define IsUTF8MultiByteStart(ch) ((((unsigned char) ch) >= 0xC0) && (((unsigned char) ch) <= 0xF7))
#define IsUTF8MultiByteContinuation(ch) ((((unsigned char) ch) >= 0x80) && (((unsigned char) ch) <= 0xBF))

#ifdef _UTILITY_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InitializeUtilityData(void *);
   LOCALE intBool                        AddCleanupFunction(void *,const char *,void (*)(void *),int);
   LOCALE intBool                        EnvAddPeriodicFunction(void *,const char *,void (*)(void *),int);
   LOCALE intBool                        AddPeriodicFunction(const char *,void (*)(void),int);
   LOCALE intBool                        RemoveCleanupFunction(void *,const char *);
   LOCALE intBool                        EnvRemovePeriodicFunction(void *,const char *);
   LOCALE char                          *CopyString(void *,const char *);
   LOCALE void                           DeleteString(void *,char *);
   LOCALE const char                    *AppendStrings(void *,const char *,const char *);
   LOCALE const char                    *StringPrintForm(void *,const char *);
   LOCALE char                          *AppendToString(void *,const char *,char *,size_t *,size_t *);
   LOCALE char                          *InsertInString(void *,const char *,size_t,char *,size_t *,size_t *);
   LOCALE char                          *AppendNToString(void *,const char *,char *,size_t,size_t *,size_t *);
   LOCALE char                          *EnlargeString(void *,size_t,char *,size_t *,size_t *);
   LOCALE char                          *ExpandStringWithChar(void *,int,char *,size_t *,size_t *,size_t);
   LOCALE struct callFunctionItem       *AddFunctionToCallList(void *,const char *,int,void (*)(void *),
                                                               struct callFunctionItem *,intBool);
   LOCALE struct callFunctionItem       *AddFunctionToCallListWithContext(void *,const char *,int,void (*)(void *),
                                                                          struct callFunctionItem *,intBool,void *);
   LOCALE struct callFunctionItem       *RemoveFunctionFromCallList(void *,const char *,
                                                             struct callFunctionItem *,
                                                             int *);
   LOCALE void                           DeallocateCallList(void *,struct callFunctionItem *);
   LOCALE struct callFunctionItemWithArg *AddFunctionToCallListWithArg(void *,const char *,int,void (*)(void *, void *),
                                                                       struct callFunctionItemWithArg *,intBool);
   LOCALE struct callFunctionItemWithArg *AddFunctionToCallListWithArgWithContext(void *,const char *,int,void (*)(void *, void *),
                                                                                  struct callFunctionItemWithArg *,intBool,void *);
   LOCALE struct callFunctionItemWithArg *RemoveFunctionFromCallListWithArg(void *,const char *,
                                                                            struct callFunctionItemWithArg *,
                                                                            int *);
   LOCALE void                           DeallocateCallListWithArg(void *,struct callFunctionItemWithArg *);
   LOCALE unsigned long                  ItemHashValue(void *,unsigned short,void *,unsigned long);
   LOCALE void                           YieldTime(void *);
   LOCALE void                           EnvIncrementGCLocks(void *);
   LOCALE void                           EnvDecrementGCLocks(void *);
   LOCALE short                          EnablePeriodicFunctions(void *,short);
   LOCALE short                          EnableYieldFunction(void *,short);
   LOCALE struct trackedMemory          *AddTrackedMemory(void *,void *,size_t);
   LOCALE void                           RemoveTrackedMemory(void *,struct trackedMemory *);
   LOCALE void                           UTF8Increment(const char *,size_t *);
   LOCALE size_t                         UTF8Offset(const char *,size_t);
   LOCALE size_t                         UTF8Length(const char *);
   LOCALE size_t                         UTF8CharNum(const char *,size_t);
   LOCALE void                           RestorePriorGarbageFrame(void *,struct garbageFrame *,struct garbageFrame *,struct dataObject *);
   LOCALE void                           CallCleanupFunctions(void *);
   LOCALE void                           CallPeriodicTasks(void *);
   LOCALE void                           CleanCurrentGarbageFrame(void *,struct dataObject *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE void                           IncrementGCLocks(void);
   LOCALE void                           DecrementGCLocks(void);
   LOCALE intBool                        RemovePeriodicFunction(const char *);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_utility */




