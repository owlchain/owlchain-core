   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/25/15            */
   /*                                                     */
   /*                  CONSTRUCT MODULE                   */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Changed garbage collection algorithm.          */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added code for capturing errors/warnings       */
/*            (EnvSetParserErrorCallback).                   */
/*                                                           */
/*            Fixed issue with save function when multiple   */
/*            defmodules exist.                              */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*            Added code to prevent a clear command from     */
/*            being executed during fact assertions via      */
/*            Increment/DecrementClearReadyLocks API.        */
/*                                                           */
/*            Added code to keep track of pointers to        */
/*            constructs that are contained externally to    */
/*            to constructs, DanglingConstructs.             */
/*                                                           */
/*************************************************************/

#ifndef _H_constrct

#define _H_constrct

struct constructHeader;
struct construct;

#ifndef _H_moduldef
#include "moduldef.h"
#endif
#ifndef _H_symbol
#include "symbol.h"
#endif

#include "userdata.h"

struct constructHeader
  {
   struct symbolHashNode *name;
   const char *ppForm;
   struct defmoduleItemHeader *whichModule;
   long bsaveID;
   struct constructHeader *next;
   struct userData *usrData;
  };

#define CHS (struct constructHeader *)

struct construct
  {
   const char *constructName;
   const char *pluralName;
   int (*parseFunction)(void *,const char *);
   void *(*findFunction)(void *,const char *);
   struct symbolHashNode *(*getConstructNameFunction)(struct constructHeader *);
   const char *(*getPPFormFunction)(void *,struct constructHeader *);
   struct defmoduleItemHeader *(*getModuleItemFunction)(struct constructHeader *);
   void *(*getNextItemFunction)(void *,void *);
   void (*setNextItemFunction)(struct constructHeader *,struct constructHeader *);
   intBool (*isConstructDeletableFunction)(void *,void *);
   int (*deleteFunction)(void *,void *);
   void (*freeFunction)(void *,void *);
   struct construct *next;
  };

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_scanner
#include "scanner.h"
#endif

#define CONSTRUCT_DATA 42

struct constructData
  { 
   int ClearReadyInProgress;
   int ClearInProgress;
   int ResetReadyInProgress;
   int ResetInProgress;
   short ClearReadyLocks;
   int DanglingConstructs;
#if (! RUN_TIME) && (! BLOAD_ONLY)
   struct callFunctionItem *ListOfSaveFunctions;
   intBool PrintWhileLoading;
   unsigned WatchCompilations;
   int CheckSyntaxMode;
   int ParsingConstruct;
   char *ErrorString;
   char *WarningString;
   char *ParsingFileName;
   char *ErrorFileName;
   char *WarningFileName;
   long ErrLineNumber;
   long WrnLineNumber;
   int errorCaptureRouterCount;
   size_t MaxErrChars;
   size_t CurErrPos;
   size_t MaxWrnChars;
   size_t CurWrnPos;
   void (*ParserErrorCallback)(void *,const char *,const char *,const char *,long);
#endif
   struct construct *ListOfConstructs;
   struct callFunctionItem *ListOfResetFunctions;
   struct callFunctionItem *ListOfClearFunctions;
   struct callFunctionItem *ListOfClearReadyFunctions;
   int Executing;
   int (*BeforeResetFunction)(void *);
  };

#define ConstructData(theEnv) ((struct constructData *) GetEnvironmentData(theEnv,CONSTRUCT_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _CONSTRCT_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           EnvClear(void *);
   LOCALE void                           EnvReset(void *);
   LOCALE int                            EnvSave(void *,const char *);

   LOCALE void                           InitializeConstructData(void *);
   LOCALE intBool                        AddSaveFunction(void *,const char *,void (*)(void *,void *,const char *),int);
   LOCALE intBool                        RemoveSaveFunction(void *,const char *);
   LOCALE intBool                        EnvAddResetFunction(void *,const char *,void (*)(void *),int);
   LOCALE intBool                        EnvRemoveResetFunction(void *,const char *);
   LOCALE intBool                        AddClearReadyFunction(void *,const char *,int (*)(void *),int);
   LOCALE intBool                        RemoveClearReadyFunction(void *,const char *);
   LOCALE intBool                        EnvAddClearFunction(void *,const char *,void (*)(void *),int);
   LOCALE intBool                        EnvRemoveClearFunction(void *,const char *);
   LOCALE void                           EnvIncrementClearReadyLocks(void *);
   LOCALE void                           EnvDecrementClearReadyLocks(void *);
   LOCALE struct construct              *AddConstruct(void *,const char *,const char *,
                                                      int (*)(void *,const char *),
                                                      void *(*)(void *,const char *),
                                                      SYMBOL_HN *(*)(struct constructHeader *),
                                                      const char *(*)(void *,struct constructHeader *),
                                                      struct defmoduleItemHeader *(*)(struct constructHeader *),
                                                      void *(*)(void *,void *),
                                                      void (*)(struct constructHeader *,struct constructHeader *),
                                                      intBool (*)(void *,void *),
                                                      int (*)(void *,void *),
                                                      void (*)(void *,void *));
   LOCALE int                            RemoveConstruct(void *,const char *);
   LOCALE void                           SetCompilationsWatch(void *,unsigned);
   LOCALE unsigned                       GetCompilationsWatch(void *);
   LOCALE void                           SetPrintWhileLoading(void *,intBool);
   LOCALE intBool                        GetPrintWhileLoading(void *);
   LOCALE int                            ExecutingConstruct(void *);
   LOCALE void                           SetExecutingConstruct(void *,int);
   LOCALE void                           InitializeConstructs(void *);
   LOCALE int                          (*SetBeforeResetFunction(void *,int (*)(void *)))(void *);
   LOCALE void                           ResetCommand(void *);
   LOCALE void                           ClearCommand(void *);
   LOCALE intBool                        ClearReady(void *);
   LOCALE struct construct              *FindConstruct(void *,const char *);
   LOCALE void                           DeinstallConstructHeader(void *,struct constructHeader *);
   LOCALE void                           DestroyConstructHeader(void *,struct constructHeader *);
   LOCALE void                         (*EnvSetParserErrorCallback(void *theEnv,
                                                                   void (*functionPtr)(void *,const char *,const char *,
                                                                                       const char *,long)))
                                            (void *,const char *,const char *,const char*,long);


#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE intBool                        AddClearFunction(const char *,void (*)(void),int);
   LOCALE intBool                        AddResetFunction(const char *,void (*)(void),int);
   LOCALE void                           Clear(void);
   LOCALE void                           Reset(void);
   LOCALE intBool                        RemoveClearFunction(const char *);
   LOCALE intBool                        RemoveResetFunction(const char *);
#if (! RUN_TIME) && (! BLOAD_ONLY)
   LOCALE int                            Save(const char *);
#endif

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_constrct */




