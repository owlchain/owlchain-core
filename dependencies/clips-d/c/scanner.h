   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                 SCANNER HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for scanning lexical tokens from an     */
/*   input source.                                           */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added SetLineCount function.                   */
/*                                                           */
/*            Added UTF-8 support.                           */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_scanner
#define _H_scanner

struct token;

#ifndef _H_pprint
#include "pprint.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _SCANNER_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

struct token
  {
   unsigned short type;
   void *value;
   const char *printForm;
  };

#define SCANNER_DATA 57

struct scannerData
  { 
   char *GlobalString;
   size_t GlobalMax;
   size_t GlobalPos;
   long LineCount;
   int IgnoreCompletionErrors;
  };

#define ScannerData(theEnv) ((struct scannerData *) GetEnvironmentData(theEnv,SCANNER_DATA))

   LOCALE void                           InitializeScannerData(void *);
   LOCALE void                           GetToken(void *,const char *,struct token *);
   LOCALE void                           CopyToken(struct token *,struct token *);
   LOCALE void                           ResetLineCount(void *);
   LOCALE long                           GetLineCount(void *);
   LOCALE long                           SetLineCount(void *,long);
   LOCALE void                           IncrementLineCount(void *);
   LOCALE void                           DecrementLineCount(void *);

#endif /* _H_scanner */




