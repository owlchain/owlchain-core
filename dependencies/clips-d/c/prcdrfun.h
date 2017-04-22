   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*          PROCEDURAL FUNCTIONS HEADER FILE           */
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
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*            Changed name of variable exp to theExp         */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Local variables set with the bind function     */
/*            persist until a reset/clear command is issued. */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*************************************************************/

#ifndef _H_prcdrfun

#define _H_prcdrfun

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _PRCDRFUN_SOURCE
#define LOCALE
#else
#define LOCALE extern
#endif

typedef struct loopCounterStack
  {
   long long loopCounter;
   struct loopCounterStack *nxt;
  } LOOP_COUNTER_STACK;

#define PRCDRFUN_DATA 13

struct procedureFunctionData
  { 
   int ReturnFlag;
   int BreakFlag;
   LOOP_COUNTER_STACK *LoopCounterStack;
   struct dataObject *BindList;
  };

#define ProcedureFunctionData(theEnv) ((struct procedureFunctionData *) GetEnvironmentData(theEnv,PRCDRFUN_DATA))

   LOCALE void                           ProceduralFunctionDefinitions(void *);
   LOCALE void                           WhileFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           LoopForCountFunction(void *,DATA_OBJECT_PTR);
   LOCALE long long                      GetLoopCount(void *);
   LOCALE void                           IfFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           BindFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           PrognFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           ReturnFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           BreakFunction(void *);
   LOCALE void                           SwitchFunction(void *,DATA_OBJECT_PTR);
   LOCALE intBool                        GetBoundVariable(void *,struct dataObject *,struct symbolHashNode *);
   LOCALE void                           FlushBindList(void *);

#endif /* _H_prcdrfun */






