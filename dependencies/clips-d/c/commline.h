   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*              COMMAND LINE HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a set of routines for processing        */
/*   commands entered at the top level prompt.               */
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
/*            Refactored several functions and added         */
/*            additional functions for use by an interface   */
/*            layered on top of CLIPS.                       */
/*                                                           */
/*      6.30: Local variables set with the bind function     */
/*            persist until a reset/clear command is issued. */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Metrowerks CodeWarrior (MAC_MCW, IBM_MCW) is   */
/*            no longer supported.                           */
/*                                                           */
/*            UTF-8 support.                                 */
/*                                                           */
/*            Command history and editing support            */
/*                                                           */
/*            Used genstrcpy instead of strcpy.              */
/*                                                           */             
/*            Added before command execution callback        */
/*            function.                                      */
/*                                                           */  
/*            Fixed RouteCommand return value.               */           
/*                                                           */             
/*            Added AwaitingInput flag.                      */
/*                                                           */             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_commline

#define _H_commline

#define COMMANDLINE_DATA 40

struct commandLineData
  { 
   int EvaluatingTopLevelCommand;
   int HaltCommandLoopBatch;
#if ! RUN_TIME
   struct expr *CurrentCommand;
   char *CommandString;
   size_t MaximumCharacters;
   int ParsingTopLevelCommand;
   const char *BannerString;
   int (*EventFunction)(void *);
   int (*AfterPromptFunction)(void *);
   int (*BeforeCommandExecutionFunction)(void *);
#endif
  };

#define CommandLineData(theEnv) ((struct commandLineData *) GetEnvironmentData(theEnv,COMMANDLINE_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _COMMLINE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InitializeCommandLineData(void *);
   LOCALE int                            ExpandCommandString(void *,int);
   LOCALE void                           FlushCommandString(void *);
   LOCALE void                           SetCommandString(void *,const char *);
   LOCALE void                           AppendCommandString(void *,const char *);
   LOCALE void                           InsertCommandString(void *,const char *,unsigned);
   LOCALE char                          *GetCommandString(void *);
   LOCALE int                            CompleteCommand(const char *);
   LOCALE void                           CommandLoop(void *);
   LOCALE void                           CommandLoopBatch(void *);
   LOCALE void                           CommandLoopBatchDriver(void *);
   LOCALE void                           PrintPrompt(void *);
   LOCALE void                           PrintBanner(void *);
   LOCALE void                           SetAfterPromptFunction(void *,int (*)(void *));
   LOCALE void                           SetBeforeCommandExecutionFunction(void *,int (*)(void *));
   LOCALE intBool                        RouteCommand(void *,const char *,int);
   LOCALE int                          (*SetEventFunction(void *,int (*)(void *)))(void *);
   LOCALE intBool                        TopLevelCommand(void *);
   LOCALE void                           AppendNCommandString(void *,const char *,unsigned);
   LOCALE void                           SetNCommandString(void *,const char *,unsigned);
   LOCALE const char                    *GetCommandCompletionString(void *,const char *,size_t);
   LOCALE intBool                        ExecuteIfCommandComplete(void *);
   LOCALE void                           CommandLoopOnceThenBatch(void *);
   LOCALE intBool                        CommandCompleteAndNotEmpty(void *);
   LOCALE void                           SetHaltCommandLoopBatch(void *,int);
   LOCALE int                            GetHaltCommandLoopBatch(void *);

#endif





