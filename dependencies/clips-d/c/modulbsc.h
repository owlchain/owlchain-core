   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*         DEFMODULE BASIC COMMANDS HEADER FILE        */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements core commands for the deffacts        */
/*   construct such as clear, reset, save, undeffacts,       */
/*   ppdeffacts, list-deffacts, and get-deffacts-list.       */
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

#ifndef _H_modulbsc
#define _H_modulbsc

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MODULBSC_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           DefmoduleBasicCommands(void *);
   LOCALE void                           EnvGetDefmoduleList(void *,DATA_OBJECT_PTR);
   LOCALE void                           PPDefmoduleCommand(void *);
   LOCALE int                            PPDefmodule(void *,const char *,const char *);
   LOCALE void                           ListDefmodulesCommand(void *);
   LOCALE void                           EnvListDefmodules(void *,const char *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE void                           GetDefmoduleList(DATA_OBJECT_PTR);
#if DEBUGGING_FUNCTIONS
   LOCALE void                           ListDefmodules(const char *);
#endif

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_modulbsc */

