   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            STRING I/O ROUTER HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: I/O Router routines which allow strings to be    */
/*   used as input and output sources.                       */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Used genstrcpy instead of strcpy.              */
/*                                                           */             
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_strngrtr
#define _H_strngrtr

#ifndef _STDIO_INCLUDED_
#define _STDIO_INCLUDED_
#include <stdio.h>
#endif

#define STRING_ROUTER_DATA 48

struct stringRouter
  {
   const char *name;
   const char *readString;
   char *writeString;
   //char *str;
   size_t currentPosition;
   size_t maximumPosition;
   int readWriteType;
   struct stringRouter *next;
  };

struct stringRouterData
  { 
   struct stringRouter *ListOfStringRouters;
  };

#define StringRouterData(theEnv) ((struct stringRouterData *) GetEnvironmentData(theEnv,STRING_ROUTER_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _STRNGRTR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

/**************************/
/* I/O ROUTER DEFINITIONS */
/**************************/

   LOCALE void                           InitializeStringRouter(void *);
   LOCALE int                            OpenStringSource(void *,const char *,const char *,size_t);
   LOCALE int                            OpenTextSource(void *,const char *,const char *,size_t,size_t);
   LOCALE int                            CloseStringSource(void *,const char *);
   LOCALE int                            OpenStringDestination(void *,const char *,char *,size_t);
   LOCALE int                            CloseStringDestination(void *,const char *);

#endif /* _H_strngrtr */


