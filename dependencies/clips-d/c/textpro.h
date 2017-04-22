   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             TEXT PROCESSING HEADER FILE             */
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
/*      6.23: Modified error messages so that they were      */
/*            directly printed rather than storing them in   */
/*            a string buffer which might not be large       */
/*            enough to contain the entire message. DR0855   */
/*            Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Added get-region function.                     */
/*                                                           */
/*            Added environment parameter to GenClose.       */
/*            Added environment parameter to GenOpen.        */
/*                                                           */
/*      6.30: Removed HELP_FUNCTIONS compilation flag and    */
/*            associated functionality.                      */
/*                                                           */
/*            Used genstrcpy and genstrncpy instead of       */
/*            strcpy and strncpy.                            */
/*                                                           */             
/*            Support for long long integers.                */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_TBC).         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_textpro

#define _H_textpro

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _TEXTPRO_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if TEXTPRO_FUNCTIONS
   LOCALE void                           FetchCommand(void *,DATA_OBJECT *);
   LOCALE int                            PrintRegionCommand(void *);
   LOCALE void                          *GetRegionCommand(void *);
   int                                   TossCommand(void *);
#endif

   LOCALE void                           HelpFunctionDefinitions(void *);

#endif /* _H_textpro */





