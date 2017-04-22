   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/04/15            */
   /*                                                     */
   /*               FACT COMMANDS HEADER FILE             */
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
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added code to prevent a clear command from     */
/*            being executed during fact assertions via      */
/*            Increment/DecrementClearReadyLocks API.        */
/*                                                           */
/*************************************************************/

#ifndef _H_factcom
#define _H_factcom

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _FACTCOM_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           FactCommandDefinitions(void *);
   LOCALE void                           AssertCommand(void *,DATA_OBJECT_PTR);
   LOCALE void                           RetractCommand(void *);
   LOCALE void                           AssertStringFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           FactsCommand(void *);
   LOCALE void                           EnvFacts(void *,const char *,void *,long long,long long,long long);
   LOCALE int                            SetFactDuplicationCommand(void *);
   LOCALE int                            GetFactDuplicationCommand(void *);
   LOCALE int                            SaveFactsCommand(void *);
   LOCALE int                            LoadFactsCommand(void *);
   LOCALE int                            EnvSaveFacts(void *,const char *,int);
   LOCALE int                            EnvSaveFactsDriver(void *,const char *,int,struct expr *);
   LOCALE int                            EnvLoadFacts(void *,const char *);
   LOCALE int                            EnvLoadFactsFromString(void *,const char *,long);
   LOCALE long long                      FactIndexFunction(void *);

#if ALLOW_ENVIRONMENT_GLOBALS

#if DEBUGGING_FUNCTIONS
   LOCALE void                           Facts(const char *,void *,long long,long long,long long);
#endif
   LOCALE intBool                        LoadFacts(const char *);
   LOCALE intBool                        SaveFacts(const char *,int);
   LOCALE intBool                        LoadFactsFromString(const char *,int);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_factcom */


