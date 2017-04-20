   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            DEFMODULE UTILITY HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides routines for parsing module/construct   */
/*   names and searching through modules for specific        */
/*   constructs.                                             */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.30: Used genstrncpy instead of strncpy.            */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_modulutl
#define _H_modulutl

#ifndef _H_symbol
#include "symbol.h"
#endif
#ifndef _H_moduldef
#include "moduldef.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MODULUTL_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE unsigned                       FindModuleSeparator(const char *);
   LOCALE SYMBOL_HN                     *ExtractModuleName(void *,unsigned,const char *);
   LOCALE SYMBOL_HN                     *ExtractConstructName(void *,unsigned,const char *);
   LOCALE const char                    *ExtractModuleAndConstructName(void *,const char *);
   LOCALE void                          *FindImportedConstruct(void *,const char *,struct defmodule *,
                                                               const char *,int *,int,struct defmodule *);
   LOCALE void                           AmbiguousReferenceErrorMessage(void *,const char *,const char *);
   LOCALE void                           MarkModulesAsUnvisited(void *);
   LOCALE intBool                        AllImportedModulesVisited(void *,struct defmodule *);
   LOCALE void                           ListItemsDriver(void *,
                                                         const char *,struct defmodule *,
                                                         const char *,const char *,
                                                         void *(*)(void *,void *),
                                                         const char *(*)(void *),
                                                         void (*)(void *,const char *,void *),
                                                         int (*)(void *,void *));
   LOCALE long                           DoForAllModules(void *,
                                                         void (*)(struct defmodule *,void *),
                                                         int,void *);
   LOCALE intBool                        ConstructExported(void *,const char *,struct symbolHashNode *,struct symbolHashNode *);
   
#endif /* _H_modulutl */



