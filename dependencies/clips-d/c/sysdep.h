   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  02/04/15            */
   /*                                                     */
   /*            SYSTEM DEPENDENT HEADER FILE             */
   /*******************************************************/

/*************************************************************/
/* Purpose: Isolation of system dependent routines.          */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Modified GenOpen to check the file length      */
/*            against the system constant FILENAME_MAX.      */
/*                                                           */
/*      6.24: Support for run-time programs directly passing */
/*            the hash tables for initialization.            */
/*                                                           */
/*            Made gensystem functional for Xcode.           */ 
/*                                                           */
/*            Added BeforeOpenFunction and AfterOpenFunction */
/*            hooks.                                         */
/*                                                           */
/*            Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*            Updated UNIX_V gentime functionality.          */
/*                                                           */
/*            Removed GenOpen check against FILENAME_MAX.    */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, IBM_ICB, IBM_TBC, IBM_ZTC, and        */
/*            IBM_SC).                                       */
/*                                                           */
/*            Renamed IBM_MSC and WIN_MVC compiler flags     */
/*            and IBM_GCC to WIN_GCC.                        */
/*                                                           */
/*            Added LINUX and DARWIN compiler flags.         */
/*                                                           */
/*            Removed HELP_FUNCTIONS compilation flag and    */
/*            associated functionality.                      */
/*                                                           */
/*            Removed EMACS_EDITOR compilation flag and      */
/*            associated functionality.                      */
/*                                                           */
/*            Combined BASIC_IO and EXT_IO compilation       */
/*            flags into the single IO_FUNCTIONS flag.       */
/*                                                           */
/*            Changed the EX_MATH compilation flag to        */
/*            EXTENDED_MATH_FUNCTIONS.                       */
/*                                                           */
/*            Support for typed EXTERNAL_ADDRESS.            */
/*                                                           */
/*            GenOpen function checks for UTF-8 Byte Order   */
/*            Marker.                                        */
/*                                                           */
/*            Added gengetchar, genungetchar, genprintfile,  */
/*            genstrcpy, genstrncpy, genstrcat, genstrncat,  */
/*            and gensprintf functions.                      */
/*                                                           */
/*            Added SetJmpBuffer function.                   */
/*                                                           */
/*            Added environment argument to genexit.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_sysdep
#define _H_sysdep

#ifndef _H_symbol
#include "symbol.h"
#endif

#ifndef _STDIO_INCLUDED_
#define _STDIO_INCLUDED_
#include <stdio.h>
#endif

#include <setjmp.h>

#if WIN_MVC
#include <dos.h>
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _SYSDEP_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ALLOW_ENVIRONMENT_GLOBALS
   LOCALE void                        InitializeEnvironment(void);
#endif
   LOCALE void                        EnvInitializeEnvironment(void *,struct symbolHashNode **,struct floatHashNode **,
															   struct integerHashNode **,struct bitMapHashNode **,
															   struct externalAddressHashNode **);
   LOCALE void                        SetRedrawFunction(void *,void (*)(void *));
   LOCALE void                        SetPauseEnvFunction(void *,void (*)(void *));
   LOCALE void                        SetContinueEnvFunction(void *,void (*)(void *,int));
   LOCALE void                        (*GetRedrawFunction(void *))(void *);
   LOCALE void                        (*GetPauseEnvFunction(void *))(void *);
   LOCALE void                        (*GetContinueEnvFunction(void *))(void *,int);
   LOCALE void                        RerouteStdin(void *,int,char *[]);
   LOCALE double                      gentime(void);
   LOCALE void                        gensystem(void *theEnv);
   LOCALE void                        VMSSystem(char *);
   LOCALE int                         GenOpenReadBinary(void *,const char *,const char *);
   LOCALE void                        GetSeekCurBinary(void *,long);
   LOCALE void                        GetSeekSetBinary(void *,long);
   LOCALE void                        GenTellBinary(void *,long *);
   LOCALE void                        GenCloseBinary(void *);
   LOCALE void                        GenReadBinary(void *,void *,size_t);
   LOCALE FILE                       *GenOpen(void *,const char *,const char *);
   LOCALE int                         GenClose(void *,FILE *);
   LOCALE void                        genexit(void *,int);
   LOCALE int                         genrand(void);
   LOCALE void                        genseed(int);
   LOCALE int                         genremove(const char *);
   LOCALE int                         genrename(const char *,const char *);
   LOCALE char                       *gengetcwd(char *,int);
   LOCALE void                        GenWrite(void *,size_t,FILE *);
   LOCALE int                       (*EnvSetBeforeOpenFunction(void *,int (*)(void *)))(void *);
   LOCALE int                       (*EnvSetAfterOpenFunction(void *,int (*)(void *)))(void *);
   LOCALE int                         gensprintf(char *,const char *,...);
   LOCALE char                       *genstrcpy(char *,const char *);
   LOCALE char                       *genstrncpy(char *,const char *,size_t);
   LOCALE char                       *genstrcat(char *,const char *);
   LOCALE char                       *genstrncat(char *,const char *,size_t);
   LOCALE void                        SetJmpBuffer(void *,jmp_buf *);
   LOCALE void                        genprintfile(void *,FILE *,const char *);
   LOCALE int                         gengetchar(void *);
   LOCALE int                         genungetchar(void *,int);
   
#endif /* _H_sysdep */





