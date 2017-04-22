   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/16/14          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose: Message-passing support functions                */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*      6.24: Removed IMPERATIVE_MESSAGE_HANDLERS and        */
/*            AUXILIARY_MESSAGE_HANDLERS compilation flags.  */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: The return value of DirectMessage indicates    */
/*            whether an execution error has occurred.       */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Changed garbage collection algorithm.          */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_msgpass
#define _H_msgpass

#define GetActiveInstance(theEnv) ((INSTANCE_TYPE *) GetNthMessageArgument(theEnv,0)->value)

#ifndef _H_object
#include "object.h"
#endif

typedef struct messageHandlerLink
  {
   HANDLER *hnd;
   struct messageHandlerLink *nxt;
   struct messageHandlerLink *nxtInStack;
  } HANDLER_LINK;

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MSGPASS_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE intBool          DirectMessage(void *,SYMBOL_HN *,INSTANCE_TYPE *,
                                         DATA_OBJECT *,EXPRESSION *);
   LOCALE void             EnvSend(void *,DATA_OBJECT *,const char *,const char *,DATA_OBJECT *);
   LOCALE void             DestroyHandlerLinks(void *,HANDLER_LINK *);
   LOCALE void             SendCommand(void *,DATA_OBJECT *);
   LOCALE DATA_OBJECT     *GetNthMessageArgument(void *,int);

   LOCALE int              NextHandlerAvailable(void *);
   LOCALE void             CallNextHandler(void *,DATA_OBJECT *);

   LOCALE void             FindApplicableOfName(void *,DEFCLASS *,HANDLER_LINK *[],
                                                HANDLER_LINK *[],SYMBOL_HN *);
   LOCALE HANDLER_LINK    *JoinHandlerLinks(void *,HANDLER_LINK *[],HANDLER_LINK *[],SYMBOL_HN *);

   LOCALE void             PrintHandlerSlotGetFunction(void *,const char *,void *);
   LOCALE intBool          HandlerSlotGetFunction(void *,void *,DATA_OBJECT *);
   LOCALE void             PrintHandlerSlotPutFunction(void *,const char *,void *);
   LOCALE intBool          HandlerSlotPutFunction(void *,void *,DATA_OBJECT *);
   LOCALE void             DynamicHandlerGetSlot(void *,DATA_OBJECT *);
   LOCALE void             DynamicHandlerPutSlot(void *,DATA_OBJECT *);

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE void             Send(DATA_OBJECT *,const char *,const char *,DATA_OBJECT *);

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_object */







