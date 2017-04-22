   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            DEFGLOBAL COMMANDS HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_globlcom
#define _H_globlcom

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _GLOBLCOM_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           DefglobalCommandDefinitions(void *);
   LOCALE int                            SetResetGlobalsCommand(void *);
   LOCALE intBool                        EnvSetResetGlobals(void *,int);
   LOCALE int                            GetResetGlobalsCommand(void *);
   LOCALE intBool                        EnvGetResetGlobals(void *);
   LOCALE void                           ShowDefglobalsCommand(void *);
   LOCALE void                           EnvShowDefglobals(void *,const char *,void *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE intBool                        GetResetGlobals(void);
   LOCALE intBool                        SetResetGlobals(int);
#if DEBUGGING_FUNCTIONS
   LOCALE void                           ShowDefglobals(const char *,void *);
#endif

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_globlcom */

