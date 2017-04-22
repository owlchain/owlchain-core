   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/20/14            */
   /*                                                     */
   /*          DEFTEMPLATE FUNCTION HEADER FILE           */
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
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Added deftemplate-slot-names,                  */
/*            deftemplate-slot-default-value,                */
/*            deftemplate-slot-cardinality,                  */
/*            deftemplate-slot-allowed-values,               */
/*            deftemplate-slot-range,                        */
/*            deftemplate-slot-types,                        */
/*            deftemplate-slot-multip,                       */
/*            deftemplate-slot-singlep,                      */
/*            deftemplate-slot-existp, and                   */
/*            deftemplate-slot-defaultp functions.           */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Support for deftemplate slot facets.           */
/*                                                           */
/*            Added deftemplate-slot-facet-existp and        */
/*            deftemplate-slot-facet-value functions.        */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Support for modify callback function.          */
/*                                                           */
/*            Added additional argument to function          */
/*            CheckDeftemplateAndSlotArguments to specify    */
/*            the expected number of arguments.              */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*            Added code to prevent a clear command from     */
/*            being executed during fact assertions via      */
/*            Increment/DecrementClearReadyLocks API.        */
/*                                                           */
/*************************************************************/

#ifndef _H_tmpltfun

#define _H_tmpltfun

#ifndef _H_symbol
#include "symbol.h"
#endif
#ifndef _H_scanner
#include "scanner.h"
#endif
#ifndef _H_expressn
#include "expressn.h"
#endif
#ifndef _H_factmngr
#include "factmngr.h"
#endif
#ifndef _H_tmpltdef
#include "tmpltdef.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _TMPLTFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE intBool                        UpdateModifyDuplicate(void *,struct expr *,const char *,void *);
   LOCALE struct expr                   *ModifyParse(void *,struct expr *,const char *);
   LOCALE struct expr                   *DuplicateParse(void *,struct expr *,const char *);
   LOCALE void                           DeftemplateFunctions( void *);
   LOCALE void                           ModifyCommand(void *,DATA_OBJECT_PTR);
   LOCALE void                           DuplicateCommand(void *,DATA_OBJECT_PTR);
   LOCALE void                           DeftemplateSlotNamesFunction(void *,DATA_OBJECT *);
   LOCALE void                           EnvDeftemplateSlotNames(void *,void *,DATA_OBJECT *);
   LOCALE void                           DeftemplateSlotDefaultValueFunction(void *,DATA_OBJECT *);
   LOCALE intBool                        EnvDeftemplateSlotDefaultValue(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           DeftemplateSlotCardinalityFunction(void *,DATA_OBJECT *);
   LOCALE void                           EnvDeftemplateSlotCardinality(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           DeftemplateSlotAllowedValuesFunction(void *,DATA_OBJECT *);
   LOCALE void                           EnvDeftemplateSlotAllowedValues(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           DeftemplateSlotRangeFunction(void *,DATA_OBJECT *);
   LOCALE void                           EnvDeftemplateSlotRange(void *,void *,const char *,DATA_OBJECT *);
   LOCALE void                           DeftemplateSlotTypesFunction(void *,DATA_OBJECT *);
   LOCALE void                           EnvDeftemplateSlotTypes(void *,void *,const char *,DATA_OBJECT *);
   LOCALE int                            DeftemplateSlotMultiPFunction(void *);
   LOCALE int                            EnvDeftemplateSlotMultiP(void *,void *,const char *);
   LOCALE int                            DeftemplateSlotSinglePFunction(void *);
   LOCALE int                            EnvDeftemplateSlotSingleP(void *,void *,const char *);
   LOCALE int                            DeftemplateSlotExistPFunction(void *);
   LOCALE int                            EnvDeftemplateSlotExistP(void *,void *,const char *);
   LOCALE void                          *DeftemplateSlotDefaultPFunction(void *);
   LOCALE int                            EnvDeftemplateSlotDefaultP(void *,void *,const char *);
   LOCALE int                            DeftemplateSlotFacetExistPFunction(void *);
   LOCALE int                            EnvDeftemplateSlotFacetExistP(void *,void *,const char *,const char *);
   LOCALE void                           DeftemplateSlotFacetValueFunction(void *,DATA_OBJECT *);
   LOCALE int                            EnvDeftemplateSlotFacetValue(void *,void *,const char *,const char *,DATA_OBJECT *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE void                           DeftemplateSlotNames(void *,DATA_OBJECT *);
   LOCALE intBool                        DeftemplateSlotDefaultValue(void *,const char *,DATA_OBJECT_PTR);
   LOCALE void                           DeftemplateSlotCardinality(void *,const char *,DATA_OBJECT *);
   LOCALE void                           DeftemplateSlotAllowedValues(void *,const char *,DATA_OBJECT *);
   LOCALE void                           DeftemplateSlotRange(void *,const char *,DATA_OBJECT *);
   LOCALE void                           DeftemplateSlotTypes(void *,const char *,DATA_OBJECT *);
   LOCALE int                            DeftemplateSlotMultiP(void *,const char *);
   LOCALE int                            DeftemplateSlotSingleP(void *,const char *);
   LOCALE int                            DeftemplateSlotExistP(void *,const char *);
   LOCALE int                            DeftemplateSlotDefaultP(void *,const char *);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_tmpltfun */




