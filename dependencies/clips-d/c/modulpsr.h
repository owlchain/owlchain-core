   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*             DEFMODULE PARSER HEADER FILE            */
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
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: GetConstructNameAndComment API change.         */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Fixed linkage issue when DEFMODULE_CONSTRUCT   */
/*            compiler flag is set to 0.                     */
/*                                                           */
/*************************************************************/

#ifndef _H_modulpsr
#define _H_modulpsr

struct portConstructItem
  {
   const char *constructName;
   int typeExpected;
   struct portConstructItem *next;
  };

#ifndef _H_symbol
#include "symbol.h"
#endif
#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_moduldef
#include "moduldef.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MODULPSR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE long                           GetNumberOfDefmodules(void *);
   LOCALE void                           SetNumberOfDefmodules(void *,long);
   LOCALE void                           AddAfterModuleDefinedFunction(void *,const char *,void (*)(void *),int);
   LOCALE int                            ParseDefmodule(void *,const char *);
   LOCALE void                           AddPortConstructItem(void *,const char *,int);
   LOCALE struct portConstructItem      *ValidPortConstructItem(void *,const char *);
   LOCALE int                            FindImportExportConflict(void *,const char *,struct defmodule *,const char *);

#endif /* _H_modulpsr */


