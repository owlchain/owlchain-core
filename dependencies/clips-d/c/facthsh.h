   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                 FACT HASHING MODULE                 */
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
/*      6.24: Removed LOGICAL_DEPENDENCIES compilation flag. */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Fact hash table is resizable.                  */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added FactWillBeAsserted.                      */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_facthsh

#define _H_facthsh

struct factHashEntry;

#ifndef _H_factmngr
#include "factmngr.h"
#endif

struct factHashEntry
  {
   struct fact *theFact;
   struct factHashEntry *next;
  };

#define SIZE_FACT_HASH 16231

#ifdef LOCALE
#undef LOCALE
#endif
#ifdef _FACTHSH_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           AddHashedFact(void *,struct fact *,unsigned long);
   LOCALE intBool                        RemoveHashedFact(void *,struct fact *);
   LOCALE unsigned long                  HandleFactDuplication(void *,void *,intBool *);
   LOCALE intBool                        EnvGetFactDuplication(void *);
   LOCALE intBool                        EnvSetFactDuplication(void *,int);
   LOCALE void                           InitializeFactHashTable(void *);
   LOCALE void                           ShowFactHashTable(void *);
   LOCALE unsigned long                  HashFact(struct fact *);
   LOCALE intBool                        FactWillBeAsserted(void *,void *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE intBool                        GetFactDuplication(void);
   LOCALE intBool                        SetFactDuplication(int);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_facthsh */


