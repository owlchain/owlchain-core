   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.30  08/22/14          */
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
/* Revision History:                                         */
/*                                                           */
/*      6.23: Changed name of variable log to logName        */
/*            because of Unix compiler warnings of shadowed  */
/*            definitions.                                   */
/*                                                           */
/*      6.24: Removed IMPERATIVE_MESSAGE_HANDLERS            */
/*                    compilation flag.                      */
/*                                                           */
/*            Corrected code to remove run-time program      */
/*            compiler warnings.                             */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*            Added DeallocateMessageHandlerData to          */
/*            deallocate message handler environment data.   */
/*                                                           */
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*            Converted API macros to function calls.        */
/*                                                           */
/*************************************************************/

#ifndef _H_msgcom
#define _H_msgcom

#ifndef _H_object
#include "object.h"
#endif

#ifndef _H_msgpass
#include "msgpass.h"
#endif

#define MESSAGE_HANDLER_DATA 32

struct messageHandlerData
  { 
   ENTITY_RECORD HandlerGetInfo;
   ENTITY_RECORD HandlerPutInfo;
   SYMBOL_HN *INIT_SYMBOL;
   SYMBOL_HN *DELETE_SYMBOL;
   SYMBOL_HN *CREATE_SYMBOL;
#if DEBUGGING_FUNCTIONS
   unsigned WatchHandlers;
   unsigned WatchMessages;
#endif
   const char *hndquals[4];
   SYMBOL_HN *SELF_SYMBOL;
   SYMBOL_HN *CurrentMessageName;
   HANDLER_LINK *CurrentCore;
   HANDLER_LINK *TopOfCore;
   HANDLER_LINK *NextInCore;
   HANDLER_LINK *OldCore;
  };

#define MessageHandlerData(theEnv) ((struct messageHandlerData *) GetEnvironmentData(theEnv,MESSAGE_HANDLER_DATA))


#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MSGCOM_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#define INIT_STRING   "init"
#define DELETE_STRING "delete"
#define PRINT_STRING  "print"
#define CREATE_STRING "create"

   LOCALE void             SetupMessageHandlers(void *);
   LOCALE const char      *EnvGetDefmessageHandlerName(void *,void *,int);
   LOCALE const char      *EnvGetDefmessageHandlerType(void *,void *,int);
   LOCALE int              EnvGetNextDefmessageHandler(void *,void *,int);
   LOCALE HANDLER         *GetDefmessageHandlerPointer(void *,int);
#if DEBUGGING_FUNCTIONS
   LOCALE unsigned         EnvGetDefmessageHandlerWatch(void *,void *,int);
   LOCALE void             EnvSetDefmessageHandlerWatch(void *,int,void *,int);
#endif
   LOCALE unsigned         EnvFindDefmessageHandler(void *,void *,const char *,const char *);
   LOCALE int              EnvIsDefmessageHandlerDeletable(void *,void *,int);
   LOCALE void             UndefmessageHandlerCommand(void *);
   LOCALE int              EnvUndefmessageHandler(void *,void *,int);
#if DEBUGGING_FUNCTIONS
   LOCALE void             PPDefmessageHandlerCommand(void *);
   LOCALE void             ListDefmessageHandlersCommand(void *);
   LOCALE void             PreviewSendCommand(void *); 
   LOCALE const char      *EnvGetDefmessageHandlerPPForm(void *,void *,int);
   LOCALE void             EnvListDefmessageHandlers(void *,const char *,void *,int);
   LOCALE void             EnvPreviewSend(void *,const char *,void *,const char *);
   LOCALE long             DisplayHandlersInLinks(void *,const char *,PACKED_CLASS_LINKS *,int);
#endif

#if ALLOW_ENVIRONMENT_GLOBALS

   LOCALE unsigned         FindDefmessageHandler(void *,const char *,const char *);
   LOCALE const char      *GetDefmessageHandlerName(void *,int);
   LOCALE const char      *GetDefmessageHandlerType(void *,int);
   LOCALE int              GetNextDefmessageHandler(void *,int);
   LOCALE int              IsDefmessageHandlerDeletable(void *,int);
   LOCALE int              UndefmessageHandler(void *,int);
#if DEBUGGING_FUNCTIONS
   LOCALE const char      *GetDefmessageHandlerPPForm(void *,int);
   LOCALE unsigned         GetDefmessageHandlerWatch(void *,int);
   LOCALE void             ListDefmessageHandlers(const char *,void *,int);
   LOCALE void             PreviewSend(const char *,void *,const char *);
   LOCALE void             SetDefmessageHandlerWatch(int,void *,int);
#endif /* DEBUGGING_FUNCTIONS */

#endif /* ALLOW_ENVIRONMENT_GLOBALS */

#endif /* _H_msgcom */





