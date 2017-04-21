   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                          */
/*                                                            */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859   */
/*                                                            */
/*            Changed name of variable log to logName         */
/*            because of Unix compiler warnings of shadowed   */
/*            definitions.                                    */
/*                                                            */
/*      6.24: Renamed BOOLEAN macro type to intBool.          */
/*                                                            */
/*            Added pragmas to remove compilation warnings.   */
/*                                                            */
/*      6.30: Updated ENTITY_RECORD definitions to include    */
/*            additional NULL initializers.                   */
/*                                                            */
/*            Added ReleaseProcParameters call.               */
/*                                                            */
/*            Added tracked memory calls.                     */
/*                                                            */
/*            Removed conditional code for unsupported        */
/*            compilers/operating systems (IBM_MCW,           */
/*            MAC_MCW, and IBM_TBC).                          */
/*                                                            */
/*            Added const qualifiers to remove C++            */
/*            deprecation warnings.                           */
/*                                                            */
/*************************************************************/

#ifndef _H_prccode
#define _H_prccode

#ifndef _H_expressn
#include "expressn.h"
#endif
#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_moduldef
#include "moduldef.h"
#endif
#ifndef _H_scanner
#include "scanner.h"
#endif
#ifndef _H_symbol
#include "symbol.h"
#endif

typedef struct ProcParamStack
  {
   DATA_OBJECT *ParamArray;

#if DEFGENERIC_CONSTRUCT
   EXPRESSION *ParamExpressions;
#endif

   int ParamArraySize;
   DATA_OBJECT *WildcardValue;
   void (*UnboundErrFunc)(void *);
   struct ProcParamStack *nxt;
  } PROC_PARAM_STACK;

#define PROCEDURAL_PRIMITIVE_DATA 37

struct proceduralPrimitiveData
  { 
   void *NoParamValue;
   DATA_OBJECT *ProcParamArray;
   int ProcParamArraySize;
   EXPRESSION *CurrentProcActions;
#if DEFGENERIC_CONSTRUCT
   EXPRESSION *ProcParamExpressions;
#endif
   PROC_PARAM_STACK *pstack;
   DATA_OBJECT *WildcardValue;
   DATA_OBJECT *LocalVarArray;
   void (*ProcUnboundErrFunc)(void *);
   ENTITY_RECORD ProcParameterInfo; 
   ENTITY_RECORD ProcWildInfo;
   ENTITY_RECORD ProcGetInfo;     
   ENTITY_RECORD ProcBindInfo;      
#if ! DEFFUNCTION_CONSTRUCT
   ENTITY_RECORD DeffunctionEntityRecord;
#endif
#if ! DEFGENERIC_CONSTRUCT
   ENTITY_RECORD GenericEntityRecord;
#endif
   int Oldindex;
  };

#define ProceduralPrimitiveData(theEnv) ((struct proceduralPrimitiveData *) GetEnvironmentData(theEnv,PROCEDURAL_PRIMITIVE_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _PRCCODE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InstallProcedurePrimitives(void *);

#if (! BLOAD_ONLY) && (! RUN_TIME)

#if DEFFUNCTION_CONSTRUCT || OBJECT_SYSTEM
   LOCALE EXPRESSION                    *ParseProcParameters(void *,const char *,struct token *,EXPRESSION *,
                                                             SYMBOL_HN **,int *,int *,int *,
                                                             int (*)(void *,const char *));
#endif
   LOCALE EXPRESSION                    *ParseProcActions(void *,const char *,const char *,struct token *,EXPRESSION *,SYMBOL_HN *,
                                                          int (*)(void *,EXPRESSION *,void *),
                                                          int (*)(void *,EXPRESSION *,void *),
                                                          int *,void *);
   LOCALE intBool                        ReplaceProcVars(void *,const char *,EXPRESSION *,EXPRESSION *,SYMBOL_HN *,
                                                         int (*)(void *,EXPRESSION *,void *),void *);
#if DEFGENERIC_CONSTRUCT
   LOCALE EXPRESSION                    *GenProcWildcardReference(void *,int);
#endif
#endif

   LOCALE void                           PushProcParameters(void *,EXPRESSION *,int,const char *,const char *,void (*)(void *));
   LOCALE void                           PopProcParameters(void *);

#if DEFGENERIC_CONSTRUCT
   LOCALE EXPRESSION                    *GetProcParamExpressions(void *);
#endif

   LOCALE void                           EvaluateProcActions(void *,struct defmodule *,EXPRESSION *,int,
                                                             DATA_OBJECT *,void (*)(void *));
   LOCALE void                           PrintProcParamArray(void *,const char *);
   LOCALE void                           GrabProcWildargs(void *,DATA_OBJECT *,int);

#endif /* _H_prccode */

