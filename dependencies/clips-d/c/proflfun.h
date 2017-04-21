   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*      CONSTRUCT PROFILING FUNCTIONS HEADER FILE      */
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
/*      6.23: Modified OutputProfileInfo to allow a before   */
/*            and after prefix so that a string buffer does  */
/*            not need to be created to contain the entire   */
/*            prefix. This allows a buffer overflow problem  */
/*            to be corrected. DR0857.                       */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Added pragmas to remove compilation warnings.  */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warnings.                             */
/*                                                           */
/*      6.30: Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_TBC).         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_proflfun

#define _H_proflfun

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _PROFLFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#include "userdata.h"

struct constructProfileInfo
  {
   struct userData usrData;
   long numberOfEntries;
   unsigned int childCall : 1;
   double startTime;
   double totalSelfTime;
   double totalWithChildrenTime;
  };

struct profileFrameInfo
  {
   unsigned int parentCall : 1;
   unsigned int profileOnExit : 1;
   double parentStartTime;
   struct constructProfileInfo *oldProfileFrame;
  };
  
#define PROFLFUN_DATA 15

struct profileFunctionData
  { 
   double ProfileStartTime;
   double ProfileEndTime;
   double ProfileTotalTime;
   int LastProfileInfo;
   double PercentThreshold;
   struct userDataRecord ProfileDataInfo;
   unsigned char ProfileDataID;
   int ProfileUserFunctions;
   int ProfileConstructs;
   struct constructProfileInfo *ActiveProfileFrame;
   const char *OutputString;
  };

#define ProfileFunctionData(theEnv) ((struct profileFunctionData *) GetEnvironmentData(theEnv,PROFLFUN_DATA))

   LOCALE void                           ConstructProfilingFunctionDefinitions(void *);
   LOCALE void                           ProfileCommand(void *);
   LOCALE void                           ProfileInfoCommand(void *);
   LOCALE void                           StartProfile(void *,
                                                      struct profileFrameInfo *,
                                                      struct userData **,
                                                      intBool);
   LOCALE void                           EndProfile(void *,struct profileFrameInfo *);
   LOCALE void                           ProfileResetCommand(void *);
   LOCALE void                           ResetProfileInfo(struct constructProfileInfo *);

   LOCALE double                         SetProfilePercentThresholdCommand(void *);
   LOCALE double                         SetProfilePercentThreshold(void *,double);
   LOCALE double                         GetProfilePercentThresholdCommand(void *);
   LOCALE double                         GetProfilePercentThreshold(void *);
   LOCALE intBool                        Profile(void *,const char *);
   LOCALE void                           DeleteProfileData(void *,void *);
   LOCALE void                          *CreateProfileData(void *);
   LOCALE const char                    *SetProfileOutputString(void *,const char *);

#endif /* _H_proflfun */


