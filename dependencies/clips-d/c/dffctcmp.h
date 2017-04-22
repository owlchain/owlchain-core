   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*        DEFFACTS CONSTRUCT COMPILER HEADER FILE      */
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
/*      6.30: Added support for path name argument to        */
/*            constructs-to-c.                               */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*************************************************************/

#ifndef _H_dffctcmp

#define _H_dffctcmp

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _DFFCTCMP_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           DeffactsCompilerSetup(void *);
   LOCALE void                           DeffactsCModuleReference(void *,FILE *,int,int,int);

#endif /* _H_dffctcmp */
