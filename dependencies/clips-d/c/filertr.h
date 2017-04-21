   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             FILE I/O ROUTER HEADER FILE             */
   /*******************************************************/

/*************************************************************/
/* Purpose: I/O Router routines which allow files to be used */
/*   as input and output sources.                            */
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
/*            Added pragmas to remove compilation warnings.  */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Used gengetc and genungetchar rather than      */
/*            getc and ungetc.                               */
/*                                                           */
/*            Replaced BASIC_IO and ADVANCED_IO compiler     */
/*            flags with the single IO_FUNCTIONS compiler    */
/*            flag.                                          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_filertr
#define _H_filertr

#ifndef _STDIO_INCLUDED_
#define _STDIO_INCLUDED_
#include <stdio.h>
#endif

#define FILE_ROUTER_DATA 47
   
struct fileRouter
  {
   const char *logicalName;
   FILE *stream;
   struct fileRouter *next;
  };

struct fileRouterData
  { 
   struct fileRouter *ListOfFileRouters;
  };

#define FileRouterData(theEnv) ((struct fileRouterData *) GetEnvironmentData(theEnv,FILE_ROUTER_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _FILERTR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InitializeFileRouter(void *);
   LOCALE FILE                          *FindFptr(void *,const char *);
   LOCALE int                            OpenAFile(void *,const char *,const char *,const char *);
   LOCALE int                            CloseAllFiles(void *);
   LOCALE int                            CloseFile(void *,const char *);
   LOCALE int                            FindFile(void *,const char *);

#endif /* _H_filertr */






