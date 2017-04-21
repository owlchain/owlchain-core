   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                 BLOAD HEADER FILE                   */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Borland C (IBM_TBC) and Metrowerks CodeWarrior */
/*            (MAC_MCW, IBM_MCW) are no longer supported.    */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_bload
#define _H_bload

#ifndef _H_utility
#include "utility.h"
#endif
#ifndef _H_extnfunc
#include "extnfunc.h"
#endif
#ifndef _H_exprnbin
#include "exprnbin.h"
#endif
#ifndef _H_symbol
#include "symbol.h"
#endif
#ifndef _H_sysdep
#include "sysdep.h"
#endif
#ifndef _H_symblbin
#include "symblbin.h"
#endif

#define BLOAD_DATA 38

struct bloadData
  { 
   const char *BinaryPrefixID;
   const char *BinaryVersionID;
   struct FunctionDefinition **FunctionArray;
   int BloadActive;
   struct callFunctionItem *BeforeBloadFunctions;
   struct callFunctionItem *AfterBloadFunctions;
   struct callFunctionItem *ClearBloadReadyFunctions;
   struct callFunctionItem *AbortBloadFunctions;
  };

#define BloadData(theEnv) ((struct bloadData *) GetEnvironmentData(theEnv,BLOAD_DATA))

#ifdef LOCALE
#undef LOCALE
#endif
#ifdef _BLOAD_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#define FunctionPointer(i) ((struct FunctionDefinition *) (((i) == -1L) ? NULL : BloadData(theEnv)->FunctionArray[i]))

   LOCALE void                    InitializeBloadData(void *);
   LOCALE int                     BloadCommand(void *);
   LOCALE intBool                 EnvBload(void *,const char *);
   LOCALE void                    BloadandRefresh(void *,long,size_t,void (*)(void *,void *,long));
   LOCALE intBool                 Bloaded(void *);
   LOCALE void                    AddBeforeBloadFunction(void *,const char *,void (*)(void *),int);
   LOCALE void                    AddAfterBloadFunction(void *,const char *,void (*)(void *),int);
   LOCALE void                    AddClearBloadReadyFunction(void *,const char *,int (*)(void *),int);
   LOCALE void                    AddAbortBloadFunction(void *,const char *,void (*)(void *),int);
   LOCALE void                    CannotLoadWithBloadMessage(void *,const char *);

#if ALLOW_ENVIRONMENT_GLOBALS
   LOCALE int                     Bload(const char *);
#endif

#endif

