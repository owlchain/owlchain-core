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
/* Revision History:                                         */
/*                                                           */
/*      6.24: Removed IMPERATIVE_MESSAGE_HANDLERS and        */
/*            AUXILIARY_MESSAGE_HANDLERS compilation flags.  */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW,          */
/*            MAC_MCW, and IBM_TBC).                         */
/*                                                           */
/*************************************************************/

#ifndef _H_objbin
#define _H_objbin

#ifndef _H_object
#include "object.h"
#endif

#define OBJECTBIN_DATA 33

struct objectBinaryData
  { 
   DEFCLASS *DefclassArray;
   long ModuleCount;
   long ClassCount;
   long LinkCount;
   long SlotCount;
   long SlotNameCount;
   long TemplateSlotCount;
   long SlotNameMapCount;
   long HandlerCount;
   DEFCLASS_MODULE *ModuleArray;
   DEFCLASS **LinkArray;
   SLOT_DESC *SlotArray;
   SLOT_DESC **TmpslotArray;
   SLOT_NAME *SlotNameArray;
   unsigned *MapslotArray;
   HANDLER *HandlerArray;
   unsigned *MaphandlerArray;
  };

#define ObjectBinaryData(theEnv) ((struct objectBinaryData *) GetEnvironmentData(theEnv,OBJECTBIN_DATA))

#define DefclassPointer(i) (((i) == -1L) ? NULL : (DEFCLASS *) &ObjectBinaryData(theEnv)->DefclassArray[i])
#define DefclassIndex(cls) (((cls) == NULL) ? -1 : ((struct constructHeader *) cls)->bsaveID)

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _OBJBIN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                    SetupObjectsBload(void *);
   LOCALE void                   *BloadDefclassModuleReference(void *,int);

#endif /* _H_objbin */



