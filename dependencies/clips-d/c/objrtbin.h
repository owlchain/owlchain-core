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
/*      6.24: Converted INSTANCE_PATTERN_MATCHING to         */
/*            DEFRULE_CONSTRUCT.                             */
/*                                                           */
/*            ResetObjectMatchTimeTags did not pass in the   */
/*            environment argument when BLOAD_ONLY was set.  */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Added support for hashed comparisons to        */
/*            constants.                                     */
/*                                                           */
/*            Added support for hashed alpha memories.       */
/*                                                           */
/*************************************************************/

#ifndef _H_objrtbin
#define _H_objrtbin

#if DEFRULE_CONSTRUCT && OBJECT_SYSTEM

#define OBJECTRETEBIN_DATA 34

struct objectReteBinaryData
  { 
   long AlphaNodeCount;
   long PatternNodeCount;
   OBJECT_ALPHA_NODE *AlphaArray;
   OBJECT_PATTERN_NODE *PatternArray;
  };

#define ObjectReteBinaryData(theEnv) ((struct objectReteBinaryData *) GetEnvironmentData(theEnv,OBJECTRETEBIN_DATA))


#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _OBJRTBIN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                    SetupObjectPatternsBload(void *);

#endif /* DEFRULE_CONSTRUCT && OBJECT_SYSTEM */

#endif /* _H_objrtbin */



