   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*              FILE COMMANDS HEADER FILE              */
   /*******************************************************/

/*************************************************************/
/* Purpose: Contains the code for file commands including    */
/*   batch, dribble-on, dribble-off, save, load, bsave, and  */
/*   bload.                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
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
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added code for capturing errors/warnings.      */
/*                                                           */
/*            Added AwaitingInput flag.                      */
/*                                                           */             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*************************************************************/

#ifndef _H_filecom

#define _H_filecom

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _FILECOM_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           FileCommandDefinitions(void *);
   LOCALE intBool                        EnvDribbleOn(void *,const char *);
   LOCALE intBool                        EnvDribbleActive(void *);
   LOCALE intBool                        EnvDribbleOff(void *);
   LOCALE void                           SetDribbleStatusFunction(void *,int (*)(void *,int));
   LOCALE int                            LLGetcBatch(void *,const char *,int);
   LOCALE int                            Batch(void *,const char *);
   LOCALE int                            OpenBatch(void *,const char *,int);
   LOCALE int                            OpenStringBatch(void *,const char *,const char *,int);
   LOCALE int                            RemoveBatch(void *);
   LOCALE intBool                        BatchActive(void *);
   LOCALE void                           CloseAllBatchSources(void *);
   LOCALE int                            BatchCommand(void *);
   LOCALE int                            BatchStarCommand(void *);
   LOCALE int                            EnvBatchStar(void *,const char *);
   LOCALE int                            LoadCommand(void *);
   LOCALE int                            LoadStarCommand(void *);
   LOCALE int                            SaveCommand(void *);
   LOCALE int                            DribbleOnCommand(void *);
   LOCALE int                            DribbleOffCommand(void *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE intBool                        DribbleActive(void);
   LOCALE intBool                        DribbleOn(const char *);
   LOCALE intBool                        DribbleOff(void);
   LOCALE int                            BatchStar(const char *);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_filecom */






