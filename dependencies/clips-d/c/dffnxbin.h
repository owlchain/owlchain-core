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
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*************************************************************/

#ifndef _H_dffnxbin
#define _H_dffnxbin

#if DEFFUNCTION_CONSTRUCT && (BLOAD || BLOAD_ONLY || BLOAD_AND_BSAVE)

#include "dffnxfun.h"

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _DFFNXBIN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           SetupDeffunctionsBload(void *);
   LOCALE void                          *BloadDeffunctionModuleReference(void *,int);

#define DFFNXBIN_DATA 24

struct deffunctionBinaryData
  { 
   DEFFUNCTION *DeffunctionArray;
   long DeffunctionCount;
   long ModuleCount;
   DEFFUNCTION_MODULE *ModuleArray;
  };
  
#define DeffunctionBinaryData(theEnv) ((struct deffunctionBinaryData *) GetEnvironmentData(theEnv,DFFNXBIN_DATA))

#define DeffunctionPointer(i) (((i) == -1L) ? NULL : (DEFFUNCTION *) &DeffunctionBinaryData(theEnv)->DeffunctionArray[i])

#endif /* DEFFUNCTION_CONSTRUCT && (BLOAD || BLOAD_ONLY || BLOAD_AND_BSAVE) */

#endif /* _H_dffnxbin */




