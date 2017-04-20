   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  01/26/15            */
   /*                                                     */
   /*                 ROUTER HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a centralized mechanism for handling    */
/*   input and output requests.                              */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed conversion of '\r' to '\n' from the    */
/*            EnvGetcRouter function.                        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added support for passing context information  */ 
/*            to the router functions.                       */
/*                                                           */
/*      6.30: Fixed issues with passing context to routers.  */
/*                                                           */
/*            Added AwaitingInput flag.                      */
/*                                                           */             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added STDOUT and STDIN logical name            */
/*            definitions.                                   */
/*                                                           */
/*************************************************************/

#ifndef _H_router
#define _H_router

#ifndef _H_prntutil
#include "prntutil.h"
#endif

#ifndef _STDIO_INCLUDED_
#define _STDIO_INCLUDED_
#include <stdio.h>
#endif

#define WWARNING "wwarning"
#define WERROR "werror"
#define WTRACE "wtrace"
#define WDIALOG "wdialog"
#define WPROMPT  WPROMPT_STRING
#define WDISPLAY "wdisplay"
#define STDOUT "stdout"
#define STDIN "stdin"

#define ROUTER_DATA 46

struct router
  {
   const char *name;
   int active;
   int priority;
   short int environmentAware;
   void *context;
   int (*query)(void *,const char *);
   int (*printer)(void *,const char *,const char *);
   int (*exiter)(void *,int);
   int (*charget)(void *,const char *);
   int (*charunget)(void *,int,const char *);
   struct router *next;
  };

struct routerData
  { 
   size_t CommandBufferInputCount;
   int AwaitingInput;
   const char *LineCountRouter;
   const char *FastCharGetRouter;
   char *FastCharGetString;
   long FastCharGetIndex;
   struct router *ListOfRouters;
   FILE *FastLoadFilePtr;
   FILE *FastSaveFilePtr;
   int Abort;
  };

#define RouterData(theEnv) ((struct routerData *) GetEnvironmentData(theEnv,ROUTER_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _ROUTER_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InitializeDefaultRouters(void *);
   LOCALE int                            EnvPrintRouter(void *,const char *,const char *);
   LOCALE int                            EnvGetcRouter(void *,const char *);
   LOCALE int                            EnvUngetcRouter(void *,int,const char *);
   LOCALE void                           EnvExitRouter(void *,int);
   LOCALE void                           AbortExit(void *);
   LOCALE intBool                        EnvAddRouterWithContext(void *,
                                                   const char *,int,
                                                   int (*)(void *,const char *),
                                                   int (*)(void *,const char *,const char *),
                                                   int (*)(void *,const char *),
                                                   int (*)(void *,int,const char *),
                                                   int (*)(void *,int),
                                                   void *);
   LOCALE intBool                        EnvAddRouter(void *,
                                                   const char *,int,
                                                   int (*)(void *,const char *),
                                                   int (*)(void *,const char *,const char *),
                                                   int (*)(void *,const char *),
                                                   int (*)(void *,int,const char *),
                                                   int (*)(void *,int));
   LOCALE int                            EnvDeleteRouter(void *,const char *);
   LOCALE int                            QueryRouters(void *,const char *);
   LOCALE int                            EnvDeactivateRouter(void *,const char *);
   LOCALE int                            EnvActivateRouter(void *,const char *);
   LOCALE void                           SetFastLoad(void *,FILE *);
   LOCALE void                           SetFastSave(void *,FILE *);
   LOCALE FILE                          *GetFastLoad(void *);
   LOCALE FILE                          *GetFastSave(void *);
   LOCALE void                           UnrecognizedRouterMessage(void *,const char *);
   LOCALE void                           ExitCommand(void *);
   LOCALE int                            PrintNRouter(void *,const char *,const char *,unsigned long);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE int                            ActivateRouter(const char *);
   LOCALE intBool                        AddRouter(const char *,int,
                                                   int (*)(const char *),
                                                   int (*)(const char *,const char *),
                                                   int (*)(const char *),
                                                   int (*)(int,const char *),
                                                   int (*)(int));
   LOCALE int                            DeactivateRouter(const char *);
   LOCALE int                            DeleteRouter(const char *);
   LOCALE void                           ExitRouter(int);
   LOCALE int                            GetcRouter(const char *);
   LOCALE int                            PrintRouter(const char *,const char *);
   LOCALE int                            UngetcRouter(int,const char *);
   
#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_router */


