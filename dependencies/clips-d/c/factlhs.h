   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*                FACT BUILD HEADER FILE               */
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
/*      6.30: Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Initialize the exists member.                  */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_factlhs

#define _H_factlhs

#ifndef _H_symbol
#include "symbol.h"
#endif
#ifndef _H_scanner
#include "scanner.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _FACTLHS_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE int                            FactPatternParserFind(SYMBOL_HN *);
   LOCALE struct lhsParseNode           *FactPatternParse(void *,const char *,struct token *);
   LOCALE struct lhsParseNode           *SequenceRestrictionParse(void *,const char *,struct token *);
   LOCALE struct lhsParseNode           *CreateInitialFactPattern(void *);

#endif /* _H_factlhs */
