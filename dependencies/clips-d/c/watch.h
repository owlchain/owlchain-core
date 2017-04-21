   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                  WATCH HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Support functions for the watch and unwatch      */
/*   commands.                                               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added EnvSetWatchItem function.                */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_watch
#define _H_watch

#ifndef _H_expressn
#include "expressn.h"
#endif

#define WATCH_DATA 54

struct watchItem
  {
   const char *name;
   unsigned *flag;
   int code,priority;
   unsigned (*accessFunc)(void *,int,unsigned,struct expr *);
   unsigned (*printFunc)(void *,const char *,int,struct expr *);
   struct watchItem *next;
  };

struct watchData
  { 
   struct watchItem *ListOfWatchItems;
  };

#define WatchData(theEnv) ((struct watchData *) GetEnvironmentData(theEnv,WATCH_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _WATCH_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE intBool                        EnvWatch(void *,const char *);
   LOCALE intBool                        EnvUnwatch(void *,const char *);
   LOCALE void                           InitializeWatchData(void *);   
   LOCALE int                            EnvSetWatchItem(void *,const char *,unsigned,struct expr *);
   LOCALE int                            EnvGetWatchItem(void *,const char *);
   LOCALE intBool                        AddWatchItem(void *,const char *,int,unsigned *,int,
                                                      unsigned (*)(void *,int,unsigned,struct expr *),
                                                      unsigned (*)(void *,const char *,int,struct expr *));
   LOCALE const char                    *GetNthWatchName(void *,int);
   LOCALE int                            GetNthWatchValue(void *,int);
   LOCALE void                           WatchCommand(void *);
   LOCALE void                           UnwatchCommand(void *);
   LOCALE void                           ListWatchItemsCommand(void *);
   LOCALE void                           WatchFunctionDefinitions(void *);
   LOCALE int                            GetWatchItemCommand(void *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE intBool                        Watch(const char *);
   LOCALE intBool                        Unwatch(const char *);
   LOCALE int                            GetWatchItem(const char *);
   LOCALE int                            SetWatchItem(const char *,unsigned,struct expr *);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_watch */



