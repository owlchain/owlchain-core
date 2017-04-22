   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*              RETE UTILITY HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a set of utility functions useful to    */
/*   other modules.                                          */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed INCREMENTAL_RESET compilation flag.    */
/*                                                           */
/*            Rule with exists CE has incorrect activation.  */
/*            DR0867                                         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Support for join network changes.              */
/*                                                           */
/*            Support for using an asterick (*) to indicate  */
/*            that existential patterns are matched.         */
/*                                                           */
/*            Support for partial match changes.             */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added support for hashed memories.             */
/*                                                           */
/*            Removed pseudo-facts used in not CEs.          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_reteutil
#define _H_reteutil

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_match
#include "match.h"
#endif
#ifndef _H_network
#include "network.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _RETEUTIL_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#define NETWORK_ASSERT  0
#define NETWORK_RETRACT 1

   LOCALE void                           PrintPartialMatch(void *,const char *,struct partialMatch *);
   LOCALE struct partialMatch           *CopyPartialMatch(void *,struct partialMatch *);
   LOCALE struct partialMatch           *MergePartialMatches(void *,struct partialMatch *,struct partialMatch *);
   LOCALE long int                       IncrementPseudoFactIndex(void);
   LOCALE struct partialMatch           *GetAlphaMemory(void *,struct patternNodeHeader *,unsigned long);
   LOCALE struct partialMatch           *GetLeftBetaMemory(struct joinNode *,unsigned long);
   LOCALE struct partialMatch           *GetRightBetaMemory(struct joinNode *,unsigned long);
   LOCALE void                           ReturnLeftMemory(void *,struct joinNode *);
   LOCALE void                           ReturnRightMemory(void *,struct joinNode *);
   LOCALE void                           DestroyBetaMemory(void *,struct joinNode *,int);
   LOCALE void                           FlushBetaMemory(void *,struct joinNode *,int);
   LOCALE intBool                        BetaMemoryNotEmpty(struct joinNode *);
   LOCALE void                           RemoveAlphaMemoryMatches(void *,struct patternNodeHeader *,struct partialMatch *,
                                                                  struct alphaMatch *); 
   LOCALE void                           DestroyAlphaMemory(void *,struct patternNodeHeader *,int);
   LOCALE void                           FlushAlphaMemory(void *,struct patternNodeHeader *);
   LOCALE void                           FlushAlphaBetaMemory(void *,struct partialMatch *);
   LOCALE void                           DestroyAlphaBetaMemory(void *,struct partialMatch *);
   LOCALE int                            GetPatternNumberFromJoin(struct joinNode *);
   LOCALE struct multifieldMarker       *CopyMultifieldMarkers(void *,struct multifieldMarker *);
   LOCALE struct partialMatch           *CreateAlphaMatch(void *,void *,struct multifieldMarker *,
                                                          struct patternNodeHeader *,unsigned long);
   LOCALE void                           TraceErrorToRule(void *,struct joinNode *,const char *);
   LOCALE void                           InitializePatternHeader(void *,struct patternNodeHeader *);
   LOCALE void                           MarkRuleNetwork(void *,int);
   LOCALE void                           TagRuleNetwork(void *,long *,long *,long *,long *);
   LOCALE int                            FindEntityInPartialMatch(struct patternEntity *,struct partialMatch *);
   LOCALE unsigned long                  ComputeRightHashValue(void *,struct patternNodeHeader *);
   LOCALE void                           UpdateBetaPMLinks(void *,struct partialMatch *,struct partialMatch *,struct partialMatch *,
                                                       struct joinNode *,unsigned long,int);
   LOCALE void                           UnlinkBetaPMFromNodeAndLineage(void *,struct joinNode *,struct partialMatch *,int);
   LOCALE void                           UnlinkNonLeftLineage(void *,struct joinNode *,struct partialMatch *,int);
   LOCALE struct partialMatch           *CreateEmptyPartialMatch(void *);
   LOCALE void                           MarkRuleJoins(struct joinNode *,int);
   LOCALE void                           AddBlockedLink(struct partialMatch *,struct partialMatch *);
   LOCALE void                           RemoveBlockedLink(struct partialMatch *);
   LOCALE unsigned long                  PrintBetaMemory(void *,const char *,struct betaMemory *,int,const char *,int);

#endif /* _H_reteutil */



