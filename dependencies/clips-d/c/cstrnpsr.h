   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             CONSTRAINT PARSER HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides functions for parsing constraint        */
/*   declarations.                                           */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Added allowed-classes slot facet.              */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_cstrnpsr
#define _H_cstrnpsr

#ifndef _H_constrnt
#include "constrnt.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _CSTRNPSR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

struct constraintParseRecord
  {
   unsigned int type : 1;
   unsigned int range : 1;
   unsigned int allowedSymbols : 1;
   unsigned int allowedStrings : 1;
   unsigned int allowedLexemes : 1;
   unsigned int allowedFloats : 1;
   unsigned int allowedIntegers : 1;
   unsigned int allowedNumbers : 1;
   unsigned int allowedValues : 1;
   unsigned int allowedClasses : 1;
   unsigned int allowedInstanceNames : 1;
   unsigned int cardinality : 1;
  };

typedef struct constraintParseRecord CONSTRAINT_PARSE_RECORD;

   LOCALE intBool                        CheckConstraintParseConflicts(void *,CONSTRAINT_RECORD *);
   LOCALE void                           AttributeConflictErrorMessage(void *,const char *,const char *);
#if (! RUN_TIME) && (! BLOAD_ONLY)
   LOCALE void                           InitializeConstraintParseRecord(CONSTRAINT_PARSE_RECORD *);
   LOCALE intBool                        StandardConstraint(const char *);
   LOCALE intBool                        ParseStandardConstraint(void *,const char *,const char *,
                                                                 CONSTRAINT_RECORD *,
                                                                 CONSTRAINT_PARSE_RECORD *,
                                                                 int);
   LOCALE void                           OverlayConstraint(void *,CONSTRAINT_PARSE_RECORD *,
                                                           CONSTRAINT_RECORD *,CONSTRAINT_RECORD *);
   LOCALE void                           OverlayConstraintParseRecord(CONSTRAINT_PARSE_RECORD *,
                                                                      CONSTRAINT_PARSE_RECORD *);
#endif /* (! RUN_TIME) && (! BLOAD_ONLY) */

#endif /* _H_cstrnpsr */



