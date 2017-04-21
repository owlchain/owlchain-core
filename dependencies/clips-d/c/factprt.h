   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*         FACT RETE PRINT FUNCTIONS HEADER FILE       */
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
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Updates to support new struct members.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_factprt

#define _H_factprt

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _FACTPRT_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           PrintFactJNCompVars1(void *,const char *,void *);
   LOCALE void                           PrintFactJNCompVars2(void *,const char *,void *);
   LOCALE void                           PrintFactPNCompVars1(void *,const char *,void *);
   LOCALE void                           PrintFactJNGetVar1(void *,const char *,void *);
   LOCALE void                           PrintFactJNGetVar2(void *,const char *,void *);
   LOCALE void                           PrintFactJNGetVar3(void *,const char *,void *);
   LOCALE void                           PrintFactPNGetVar1(void *,const char *,void *);
   LOCALE void                           PrintFactPNGetVar2(void *,const char *,void *);
   LOCALE void                           PrintFactPNGetVar3(void *,const char *,void *);
   LOCALE void                           PrintFactSlotLength(void *,const char *,void *);
   LOCALE void                           PrintFactPNConstant1(void *,const char *,void *);
   LOCALE void                           PrintFactPNConstant2(void *,const char *,void *);

#endif /* _H_factprt */


