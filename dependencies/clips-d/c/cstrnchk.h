   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/22/14            */
   /*                                                     */
   /*            CONSTRAINT CHECKING HEADER FILE          */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides functions for constraint checking of    */
/*   data types.                                             */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Added allowed-classes slot facet.              */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Dynamic constraint checking for the            */
/*            allowed-classes constraint now searches        */
/*            imported modules.                              */
/*                                                           */
/*************************************************************/

#ifndef _H_cstrnchk
#define _H_cstrnchk

#ifndef _H_constrnt
#include "constrnt.h"
#endif
#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _CSTRNCHK_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#define NO_VIOLATION                    0
#define TYPE_VIOLATION                  1
#define RANGE_VIOLATION                 2
#define ALLOWED_VALUES_VIOLATION        3
#define FUNCTION_RETURN_TYPE_VIOLATION  4
#define CARDINALITY_VIOLATION           5
#define ALLOWED_CLASSES_VIOLATION       6

   LOCALE intBool                        CheckCardinalityConstraint(void *,long,CONSTRAINT_RECORD *);
   LOCALE intBool                        CheckAllowedValuesConstraint(int,void *,CONSTRAINT_RECORD *);
   LOCALE intBool                        CheckAllowedClassesConstraint(void *,int,void *,CONSTRAINT_RECORD *);
   LOCALE int                            ConstraintCheckExpressionChain(void *,struct expr *,
                                                                     CONSTRAINT_RECORD *);
   LOCALE void                           ConstraintViolationErrorMessage(void *,const char *,const char *,int,int,
                                                                      struct symbolHashNode *,
                                                                      int,int,CONSTRAINT_RECORD *,
                                                                      int);
   LOCALE int                            ConstraintCheckValue(void *,int,void *,CONSTRAINT_RECORD *);
   LOCALE int                            ConstraintCheckDataObject(void *,DATA_OBJECT *,CONSTRAINT_RECORD *);
#if (! BLOAD_ONLY) && (! RUN_TIME)
   LOCALE int                            ConstraintCheckExpression(void *,struct expr *,
                                                                CONSTRAINT_RECORD *);
#endif
#if (! RUN_TIME)
   LOCALE intBool                        UnmatchableConstraint(struct constraintRecord *);
#endif

#endif /* _H_cstrnchk */



