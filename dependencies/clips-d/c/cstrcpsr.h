   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*              CONSTRUCT PARSER MODULE                */
   /*******************************************************/

/*************************************************************/
/* Purpose: Parsing routines and utilities for parsing       */
/*   constructs.                                             */
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
/*            Made the construct redefinition message more   */
/*            prominent.                                     */
/*                                                           */
/*            Added pragmas to remove compilation warnings.  */
/*                                                           */
/*      6.30: Added code for capturing errors/warnings.      */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW, MAC_MCW, */
/*            and IBM_TBC).                                  */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            GetConstructNameAndComment API change.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*************************************************************/

#ifndef _H_cstrcpsr

#define _H_cstrcpsr

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_scanner
#include "scanner.h"
#endif
#ifndef _H_constrct
#include "constrct.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _CSTRCPSR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ALLOW_ENVIRONMENT_GLOBALS
   LOCALE int                            Load(const char *);
#endif

   LOCALE int                            EnvLoad(void *,const char *);
   LOCALE int                            LoadConstructsFromLogicalName(void *,const char *);
   LOCALE int                            ParseConstruct(void *,const char *,const char *);
   LOCALE void                           RemoveConstructFromModule(void *,struct constructHeader *);
   LOCALE struct symbolHashNode         *GetConstructNameAndComment(void *,const char *,
                                                                    struct token *,const char *,
                                                                    void *(*)(void *,const char *),
                                                                    int (*)(void *,void *),
                                                                    const char *,int,int,int,int);
   LOCALE void                           ImportExportConflictMessage(void *,const char *,const char *,const char *,const char *);
#if (! RUN_TIME) && (! BLOAD_ONLY)
   LOCALE void                           FlushParsingMessages(void *);
   LOCALE char                          *EnvGetParsingFileName(void *);
   LOCALE void                           EnvSetParsingFileName(void *,const char *);
   LOCALE char                          *EnvGetErrorFileName(void *);
   LOCALE void                           EnvSetErrorFileName(void *,const char *);
   LOCALE char                          *EnvGetWarningFileName(void *);
   LOCALE void                           EnvSetWarningFileName(void *,const char *);
   LOCALE void                           CreateErrorCaptureRouter(void *);
   LOCALE void                           DeleteErrorCaptureRouter(void *);
#endif

#endif







