   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*          LOGICAL DEPENDENCIES HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provide support routines for managing truth      */
/*   maintenance using the logical conditional element.      */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Rule with exists CE has incorrect activation.  */
/*            DR0867                                         */
/*                                                           */
/*      6.30: Added support for hashed memories.             */
/*                                                           */
/*************************************************************/

#ifndef _H_lgcldpnd

#define _H_lgcldpnd

struct dependency
  {
   void *dPtr;
   struct dependency *next;
  };

#ifndef _H_match
#include "match.h"
#endif
#ifndef _H_pattern
#include "pattern.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif
#ifdef _LGCLDPND_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE intBool                        AddLogicalDependencies(void *,struct patternEntity *,int);
   LOCALE void                           RemoveEntityDependencies(void *,struct patternEntity *);
   LOCALE void                           RemovePMDependencies(void *,struct partialMatch *);
   LOCALE void                           DestroyPMDependencies(void *,struct partialMatch *);
   LOCALE void                           RemoveLogicalSupport(void *,struct partialMatch *);
   LOCALE void                           ForceLogicalRetractions(void *);
   LOCALE void                           Dependencies(void *,struct patternEntity *);
   LOCALE void                           Dependents(void *,struct patternEntity *);
   LOCALE void                           DependenciesCommand(void *);
   LOCALE void                           DependentsCommand(void *);
   LOCALE void                           ReturnEntityDependencies(void *,struct patternEntity *);
   LOCALE struct partialMatch           *FindLogicalBind(struct joinNode *,struct partialMatch *);

#endif /* _H_lgcldpnd */





