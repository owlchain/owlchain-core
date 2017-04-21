   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                 DEVELOPER HEADER FILE               */
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
/*      6.24: Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*      6.30: Added support for hashed alpha memories.       */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*            Functions enable-gc-heuristics and             */
/*            disable-gc-heuristics are no longer supported. */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*************************************************************/

#ifndef _H_developr
#define _H_developr

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _DEVELOPR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           DeveloperCommands(void *);
   LOCALE void                           PrimitiveTablesInfo(void *);
   LOCALE void                           PrimitiveTablesUsage(void *);

#if DEFRULE_CONSTRUCT && DEFTEMPLATE_CONSTRUCT
   LOCALE void                           ShowFactPatternNetwork(void *);
   LOCALE intBool                        ValidateFactIntegrity(void *);
#endif
#if DEFRULE_CONSTRUCT && OBJECT_SYSTEM
   LOCALE void                           PrintObjectPatternNetwork(void *);
#endif
#if OBJECT_SYSTEM
   LOCALE void                           InstanceTableUsage(void *);
#endif
#if DEFRULE_CONSTRUCT
   LOCALE void                           ValidateBetaMemories(void *);
#endif

#endif /* _H_developr */


