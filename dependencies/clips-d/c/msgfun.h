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
/*      6.23: Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Removed IMPERATIVE_MESSAGE_HANDLERS and        */
/*            AUXILIARY_MESSAGE_HANDLERS compilation flags.  */
/*                                                           */
/*            Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*      6.30: Support for long long integers.                */
/*                                                           */
/*            Changed integer type/precision.                */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_msgfun
#define _H_msgfun

typedef struct handlerSlotReference
  {
   long classID;
   long slotID;
  } HANDLER_SLOT_REFERENCE;

#ifndef _H_object
#include "object.h"
#endif
#include "msgpass.h"

#define BEGIN_TRACE ">>"
#define END_TRACE   "<<"

/* =================================================================================
   Message-handler types - don't change these values: a string array depends on them
   ================================================================================= */
#define MAROUND        0
#define MBEFORE        1
#define MPRIMARY       2
#define MAFTER         3
#define MERROR         4

#define LOOKUP_HANDLER_INDEX   0
#define LOOKUP_HANDLER_ADDRESS 1

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MSGFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void             UnboundHandlerErr(void *);
   LOCALE void             PrintNoHandlerError(void *,const char *);
   LOCALE int              CheckHandlerArgCount(void *);
   LOCALE void             SlotAccessViolationError(void *,const char *,intBool,void *);
   LOCALE void             SlotVisibilityViolationError(void *,SLOT_DESC *,DEFCLASS *);

#if ! RUN_TIME
   LOCALE void             NewSystemHandler(void *,const char *,const char *,const char *,int);
   LOCALE HANDLER         *InsertHandlerHeader(void *,DEFCLASS *,SYMBOL_HN *,int);
#endif

#if (! BLOAD_ONLY) && (! RUN_TIME)
   LOCALE HANDLER         *NewHandler(void);
   LOCALE int              HandlersExecuting(DEFCLASS *);
   LOCALE int              DeleteHandler(void *,DEFCLASS *,SYMBOL_HN *,int,int);
   LOCALE void             DeallocateMarkedHandlers(void *,DEFCLASS *);
#endif
   LOCALE unsigned         HandlerType(void *,const char *,const char *);
   LOCALE int              CheckCurrentMessage(void *,const char *,int);
   LOCALE void             PrintHandler(void *,const char *,HANDLER *,int);
   LOCALE HANDLER         *FindHandlerByAddress(DEFCLASS *,SYMBOL_HN *,unsigned);
   LOCALE int              FindHandlerByIndex(DEFCLASS *,SYMBOL_HN *,unsigned);
   LOCALE int              FindHandlerNameGroup(DEFCLASS *,SYMBOL_HN *);
   LOCALE void             HandlerDeleteError(void *,const char *);

#if DEBUGGING_FUNCTIONS
   LOCALE void             DisplayCore(void *,const char *,HANDLER_LINK *,int);
   LOCALE HANDLER_LINK    *FindPreviewApplicableHandlers(void *,DEFCLASS *,SYMBOL_HN *);
   LOCALE void             WatchMessage(void *,const char *,const char *);
   LOCALE void             WatchHandler(void *,const char *,HANDLER_LINK *,const char *);
#endif

#endif /* _H_msgfun */







