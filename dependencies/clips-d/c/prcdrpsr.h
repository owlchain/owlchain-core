   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*       PROCEDURAL FUNCTIONS PARSER HEADER FILE       */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Local variables set with the bind function     */
/*            persist until a reset/clear command is issued. */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Fixed linkage issue when BLOAD_ONLY compiler   */
/*            flag is set to 1.                              */
/*                                                           */
/*************************************************************/

#ifndef _H_prcdrpsr

#define _H_prcdrpsr

#ifndef _H_constrnt
#include "constrnt.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _PRCDRPSR_SOURCE
#define LOCALE
#else
#define LOCALE extern
#endif

struct BindInfo
  {
   struct symbolHashNode *name;
   CONSTRAINT_RECORD *constraints;
   struct BindInfo *next;
  };

#if (! RUN_TIME)
   LOCALE void                           ProceduralFunctionParsers(void *);
   LOCALE struct BindInfo               *GetParsedBindNames(void *);
   LOCALE void                           SetParsedBindNames(void *,struct BindInfo *);
   LOCALE void                           ClearParsedBindNames(void *);
   LOCALE intBool                        ParsedBindNamesEmpty(void *);
#endif
#if (! BLOAD_ONLY) && (! RUN_TIME)
   LOCALE int                            SearchParsedBindNames(void *,struct symbolHashNode *);
   LOCALE int                            CountParsedBindNames(void *);
   LOCALE void                           RemoveParsedBindName(void *,struct symbolHashNode *);
   LOCALE struct constraintRecord       *FindBindConstraints(void *,struct symbolHashNode *);
#endif

#endif /* _H_prcdrpsr */




