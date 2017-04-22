   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  12/04/07            */
   /*                                                     */
   /*                  DRIVE HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Handles join network activity associated with    */
/*   with the addition of a data entity such as a fact or    */
/*   instance.                                               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Added support for hashed memories.             */
/*                                                           */
/*            Added additional developer statistics to help  */
/*            analyze join network performance.              */
/*                                                           */
/*            Removed pseudo-facts used in not CE.           */
/*                                                           */
/*************************************************************/

#ifndef _H_drive

#define _H_drive

#ifndef _H_expressn
#include "expressn.h"
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

#ifdef _DRIVE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   void                           NetworkAssert(void *,struct partialMatch *,struct joinNode *);
   intBool                        EvaluateJoinExpression(void *,struct expr *,struct joinNode *);
   void                           NetworkAssertLeft(void *,struct partialMatch *,struct joinNode *,int);
   void                           NetworkAssertRight(void *,struct partialMatch *,struct joinNode *,int);
   void                           PPDrive(void *,struct partialMatch *,struct partialMatch *,struct joinNode *,int);
   unsigned long                  BetaMemoryHashValue(void *,struct expr *,struct partialMatch *,struct partialMatch *,struct joinNode *);
   intBool                        EvaluateSecondaryNetworkTest(void *,struct partialMatch *,struct joinNode *);
   void                           EPMDrive(void *,struct partialMatch *,struct joinNode *,int);
   
#endif /* _H_drive */





