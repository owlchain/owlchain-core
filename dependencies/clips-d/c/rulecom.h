   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             DEFRULE COMMANDS HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides the matches command. Also provides the  */
/*   the developer commands show-joins and rule-complexity.  */
/*   Also provides the initialization routine which          */
/*   registers rule commands found in other modules.         */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed CONFLICT_RESOLUTION_STRATEGIES         */
/*            INCREMENTAL_RESET, and LOGICAL_DEPENDENCIES    */
/*            compilation flags.                             */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added support for hashed memories.             */
/*                                                           */
/*            Improvements to matches command.               */
/*                                                           */
/*            Add join-activity and join-activity-reset      */
/*            commands.                                      */
/*                                                           */
/*            Added get-beta-memory-resizing and             */
/*            set-beta-memory-resizing functions.            */
/*                                                           */
/*            Added timetag function.                        */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_rulecom
#define _H_rulecom

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _RULECOM_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

struct joinInformation
  {
   int whichCE;
   struct joinNode *theJoin;
   int patternBegin;
   int patternEnd;
   int marked;
   struct betaMemory *theMemory;
   struct joinNode *nextJoin;
  };

#define VERBOSE  0
#define SUCCINCT 1
#define TERSE    2

   LOCALE intBool                        EnvGetBetaMemoryResizing(void *);
   LOCALE intBool                        EnvSetBetaMemoryResizing(void *,intBool);
   LOCALE int                            GetBetaMemoryResizingCommand(void *);
   LOCALE int                            SetBetaMemoryResizingCommand(void *);

   LOCALE void                           EnvMatches(void *,void *,int,DATA_OBJECT *);
   LOCALE void                           EnvJoinActivity(void *,void *,int,DATA_OBJECT *);
   LOCALE void                           DefruleCommands(void *);
   LOCALE void                           MatchesCommand(void *,DATA_OBJECT *);
   LOCALE void                           JoinActivityCommand(void *,DATA_OBJECT *);
   LOCALE long long                      TimetagFunction(void *);
   LOCALE long                           EnvAlphaJoinCount(void *,void *);
   LOCALE long                           EnvBetaJoinCount(void *,void *);
   LOCALE struct joinInformation        *EnvCreateJoinArray(void *,long);
   LOCALE void                           EnvFreeJoinArray(void *,struct joinInformation *,long);
   LOCALE void                           EnvAlphaJoins(void *,void *,long,struct joinInformation *);
   LOCALE void                           EnvBetaJoins(void *,void *,long,struct joinInformation *);
   LOCALE void                           JoinActivityResetCommand(void *);
#if DEVELOPER
   LOCALE void                           ShowJoinsCommand(void *);
   LOCALE long                           RuleComplexityCommand(void *);
   LOCALE void                           ShowAlphaHashTable(void *);
#endif

#if ALLOW_ENVIRONMENT_GLOBALS

#if DEBUGGING_FUNCTIONS
   LOCALE void                           Matches(void *,int,DATA_OBJECT *);
   LOCALE void                           JoinActivity(void *,int,DATA_OBJECT *);
#endif
   LOCALE intBool                        GetBetaMemoryResizing(void);
   LOCALE intBool                        SetBetaMemoryResizing(int);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_rulecom */
