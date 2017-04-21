   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.30  08/16/14            */
   /*                                                     */
   /*               I/O FUNCTIONS HEADER FILE             */
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
/*      6.24: Added the get-char, set-locale, and            */
/*            read-number functions.                         */
/*                                                           */
/*            Modified printing of floats in the format      */
/*            function to use the locale from the set-locale */
/*            function.                                      */
/*                                                           */
/*            Moved IllegalLogicalNameMessage function to    */
/*            argacces.c.                                    */
/*                                                           */
/*      6.30: Changed integer type/precision.                */
/*                                                           */
/*            Support for long long integers.                */
/*                                                           */
/*            Removed the undocumented use of t in the       */
/*            printout command to perform the same function  */
/*            as crlf.                                       */
/*                                                           */
/*            Replaced EXT_IO and BASIC_IO compiler flags    */
/*            with IO_FUNCTIONS compiler flag.               */
/*                                                           */
/*            Added a+, w+, rb, ab, r+b, w+b, and a+b modes  */
/*            for the open function.                         */
/*                                                           */
/*            Removed conditional code for unsupported       */
/*            compilers/operating systems (IBM_MCW and       */
/*            MAC_MCW).                                      */
/*                                                           */
/*            Used gensprintf instead of sprintf.            */
/*                                                           */
/*            Added put-char function.                       */
/*                                                           */
/*            Added SetFullCRLF which allows option to       */
/*            specify crlf as \n or \r\n.                    */
/*                                                           */
/*            Added AwaitingInput flag.                      */
/*                                                           */             
/*            Added const qualifiers to remove C++           */
/*            deprecation warnings.                          */
/*                                                           */
/*************************************************************/

#ifndef _H_iofun

#define _H_iofun

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _IOFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           IOFunctionDefinitions(void *);
#if IO_FUNCTIONS
   LOCALE intBool                        SetFullCRLF(void *,intBool);
   LOCALE void                           PrintoutFunction(void *);
   LOCALE void                           ReadFunction(void *,DATA_OBJECT_PTR);
   LOCALE int                            OpenFunction(void *);
   LOCALE int                            CloseFunction(void *);
   LOCALE int                            GetCharFunction(void *);
   LOCALE void                           PutCharFunction(void *);
   LOCALE void                           ReadlineFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                          *FormatFunction(void *);
   LOCALE int                            RemoveFunction(void *);
   LOCALE int                            RenameFunction(void *);
   LOCALE void                           SetLocaleFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                           ReadNumberFunction(void *,DATA_OBJECT_PTR);
#endif

#endif /* _H_iofun */






