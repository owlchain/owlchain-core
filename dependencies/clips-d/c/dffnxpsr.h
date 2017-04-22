   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            GetConstructNameAndComment API change.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_dffnxpsr
#define _H_dffnxpsr

#if DEFFUNCTION_CONSTRUCT && (! BLOAD_ONLY) && (! RUN_TIME)

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _DFFNXPSR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE intBool                        ParseDeffunction(void *,const char *);

#endif /* DEFFUNCTION_CONSTRUCT && (! BLOAD_ONLY) && (! RUN_TIME) */

#endif /* _H_dffnxpsr */




