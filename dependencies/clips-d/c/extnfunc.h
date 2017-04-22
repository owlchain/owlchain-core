   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*            EXTERNAL FUNCTIONS HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for adding new user or system defined   */
/*   functions.                                              */
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
/*      6.30: Added support for passing context information  */ 
/*            to user defined functions.                     */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Replaced ALLOW_ENVIRONMENT_GLOBALS macros      */
/*            with functions.                                */
/*                                                           */
/*************************************************************/

#ifndef _H_extnfunc

#define _H_extnfunc

#ifndef _H_symbol
#include "symbol.h"
#endif
#ifndef _H_expressn
#include "expressn.h"
#endif

#include "userdata.h"

struct FunctionDefinition
  {
   struct symbolHashNode *callFunctionName;
   const char *actualFunctionName;
   char returnValueType;
   int (*functionPointer)(void);
   struct expr *(*parser)(void *,struct expr *,const char *);
   const char *restrictions;
   short int overloadable;
   short int sequenceuseok;
   short int environmentAware;
   short int bsaveIndex;
   struct FunctionDefinition *next;
   struct userData *usrData;
   void *context;
  };

#define ValueFunctionType(target) (((struct FunctionDefinition *) target)->returnValueType)
#define ExpressionFunctionType(target) (((struct FunctionDefinition *) ((target)->value))->returnValueType)
#define ExpressionFunctionPointer(target) (((struct FunctionDefinition *) ((target)->value))->functionPointer)
#define ExpressionFunctionCallName(target) (((struct FunctionDefinition *) ((target)->value))->callFunctionName)
#define ExpressionFunctionRealName(target) (((struct FunctionDefinition *) ((target)->value))->actualFunctionName)

#define PTIF (int (*)(void))
#define PTIEF (int (*)(void *))

/*==================*/
/* ENVIRONMENT DATA */
/*==================*/

#define EXTERNAL_FUNCTION_DATA 50

struct externalFunctionData
  { 
   struct FunctionDefinition *ListOfFunctions;
   struct FunctionHash **FunctionHashtable;
  };

#define ExternalFunctionData(theEnv) ((struct externalFunctionData *) GetEnvironmentData(theEnv,EXTERNAL_FUNCTION_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _EXTNFUNC_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#ifdef LOCALE
struct FunctionHash
  {
   struct FunctionDefinition *fdPtr;
   struct FunctionHash *next;
  };

#define SIZE_FUNCTION_HASH 517
#endif

   LOCALE void                           InitializeExternalFunctionData(void *);
   LOCALE int                            EnvDefineFunction(void *,const char *,int,
                                                           int (*)(void *),const char *);
   LOCALE int                            EnvDefineFunction2(void *,const char *,int,
                                                            int (*)(void *),const char *,const char *);
   LOCALE int                            EnvDefineFunctionWithContext(void *,const char *,int,
                                                           int (*)(void *),const char *,void *);
   LOCALE int                            EnvDefineFunction2WithContext(void *,const char *,int,
                                                            int (*)(void *),const char *,const char *,void *);
   LOCALE int                            DefineFunction3(void *,const char *,int,
                                                         int (*)(void *),const char *,const char *,intBool,void *);
   LOCALE int                            AddFunctionParser(void *,const char *,
                                                           struct expr *(*)( void *,struct expr *,const char *));
   LOCALE int                            RemoveFunctionParser(void *,const char *);
   LOCALE int                            FuncSeqOvlFlags(void *,const char *,int,int);
   LOCALE struct FunctionDefinition     *GetFunctionList(void *);
   LOCALE void                           InstallFunctionList(void *,struct FunctionDefinition *);
   LOCALE struct FunctionDefinition     *FindFunction(void *,const char *);
   LOCALE int                            GetNthRestriction(struct FunctionDefinition *,int);
   LOCALE const char                    *GetArgumentTypeName(int);
   LOCALE int                            UndefineFunction(void *,const char *);
   LOCALE int                            GetMinimumArgs(struct FunctionDefinition *);
   LOCALE int                            GetMaximumArgs(struct FunctionDefinition *);

#if ALLOW_ENVIRONMENT_GLOBALS

#if (! RUN_TIME)
   LOCALE int                            DefineFunction(const char *,int,int (*)(void),const char *);
   LOCALE int                            DefineFunction2(const char *,int,int (*)(void),const char *,const char *);
#endif /* (! RUN_TIME) */

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_extnfunc */



