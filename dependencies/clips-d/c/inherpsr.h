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
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_inherpsr
#define _H_inherpsr

#if OBJECT_SYSTEM && (! BLOAD_ONLY) && (! RUN_TIME)

#ifndef _H_object
#include "object.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INHERPSR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE PACKED_CLASS_LINKS            *ParseSuperclasses(void *,const char *,SYMBOL_HN *);
   LOCALE PACKED_CLASS_LINKS            *FindPrecedenceList(void *,DEFCLASS *,PACKED_CLASS_LINKS *);
   LOCALE void                           PackClassLinks(void *,PACKED_CLASS_LINKS *,CLASS_LINK *);

#endif /* OBJECT_SYSTEM && (! BLOAD_ONLY) && (! RUN_TIME) */

#endif /* _H_inherpsr */



