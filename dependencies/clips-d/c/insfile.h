   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  02/04/15          */
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
/*      6.24: Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*            Corrected code to remove compiler warnings.    */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_insfile
#define _H_insfile

#ifndef _H_expressn
#include "expressn.h"
#endif

#define INSTANCE_FILE_DATA 30

#if BLOAD_INSTANCES || BSAVE_INSTANCES
struct instanceFileData
  { 
   const char *InstanceBinaryPrefixID;
   const char *InstanceBinaryVersionID;
   unsigned long BinaryInstanceFileSize;

#if BLOAD_INSTANCES
   unsigned long BinaryInstanceFileOffset;
   char *CurrentReadBuffer;
   unsigned long CurrentReadBufferSize;
   unsigned long CurrentReadBufferOffset;
#endif
  };

#define InstanceFileData(theEnv) ((struct instanceFileData *) GetEnvironmentData(theEnv,INSTANCE_FILE_DATA))

#endif /* BLOAD_INSTANCES || BSAVE_INSTANCES */

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INSFILE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           SetupInstanceFileCommands(void *);
   LOCALE long                           SaveInstancesCommand(void *);
   LOCALE long                           LoadInstancesCommand(void *);
   LOCALE long                           RestoreInstancesCommand(void *);
   LOCALE long                           EnvSaveInstancesDriver(void *,const char *,int,EXPRESSION *,intBool);
   LOCALE long                           EnvSaveInstances(void *,const char *,int);
#if BSAVE_INSTANCES
   LOCALE long                           BinarySaveInstancesCommand(void *);
   LOCALE long                           EnvBinarySaveInstancesDriver(void *,const char *,int,EXPRESSION *,intBool);
   LOCALE long                           EnvBinarySaveInstances(void *,const char *,int);
#endif
#if BLOAD_INSTANCES
   LOCALE long                           BinaryLoadInstancesCommand(void *);
   LOCALE long                           EnvBinaryLoadInstances(void *,const char *);
#endif
   LOCALE long                           EnvLoadInstances(void *,const char *);
   LOCALE long                           EnvLoadInstancesFromString(void *,const char *,int);
   LOCALE long                           EnvRestoreInstances(void *,const char *);
   LOCALE long                           EnvRestoreInstancesFromString(void *,const char *,int);

#if ALLOW_ENVIRONMENT_GLOBALS

#if BLOAD_INSTANCES
   LOCALE long                           BinaryLoadInstances(const char *);
#endif
#if BSAVE_INSTANCES
   LOCALE long                           BinarySaveInstances(const char *,int);
#endif
   LOCALE long                           LoadInstances(const char *);
   LOCALE long                           LoadInstancesFromString(const char *,int);
   LOCALE long                           RestoreInstances(const char *);
   LOCALE long                           RestoreInstancesFromString(const char *,int);
   LOCALE long                           SaveInstances(const char *,int);
   
#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_insfile */



