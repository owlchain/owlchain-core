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
/*      6.30: Added support for hashed memories and other    */
/*            join network changes.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_objrtgen
#define _H_objrtgen

#if DEFRULE_CONSTRUCT && OBJECT_SYSTEM && (! RUN_TIME) && (! BLOAD_ONLY)

#ifndef _H_expressn
#include "expressn.h"
#endif
#ifndef _H_reorder
#include "reorder.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _OBJRTGEN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void             ReplaceGetJNObjectValue(void *,EXPRESSION *,struct lhsParseNode *,int);
   LOCALE EXPRESSION      *GenGetJNObjectValue(void *,struct lhsParseNode *,int);
   LOCALE EXPRESSION      *ObjectJNVariableComparison(void *,struct lhsParseNode *,struct lhsParseNode *,int);
   LOCALE EXPRESSION      *GenObjectPNConstantCompare(void *,struct lhsParseNode *);
   LOCALE void             ReplaceGetPNObjectValue(void *,EXPRESSION *,struct lhsParseNode *);
   LOCALE EXPRESSION      *GenGetPNObjectValue(void *,struct lhsParseNode *); 
   LOCALE EXPRESSION      *ObjectPNVariableComparison(void *,struct lhsParseNode *,struct lhsParseNode *);
   LOCALE void             GenObjectLengthTest(void *,struct lhsParseNode *);
   LOCALE void             GenObjectZeroLengthTest(void *,struct lhsParseNode *);

#endif /* DEFRULE_CONSTRUCT && OBJECT_SYSTEM && (! RUN_TIME) && (! BLOAD_ONLY) */

#endif /* _H_objrtgen */




