import std.stdio;
import clips;

int main( string[] argv)
 {
   writefln("CLIPS DEMO");

   void *theEnv = CreateEnvironment();

   RerouteStdin(theEnv,cast(int)argv.length,cast(char **)argv.ptr);

   CommandLoop(theEnv);

   /*==================================================================*/
   /* Control does not normally return from the CommandLoop function.  */
   /* However if you are embedding CLIPS, have replaced CommandLoop    */
   /* with your own embedded calls that will return to this point, and */
   /* are running software that helps detect memory leaks, you need to */
   /* add function calls here to deallocate memory still being used by */
   /* CLIPS. If you have a multi-threaded application, no environments */
   /* can be currently executing. If the ALLOW_ENVIRONMENT_GLOBALS     */
   /* flag in setup.h has been set to TRUE (the default value), you    */
   /* call the DeallocateEnvironmentData function which will call      */
   /* DestroyEnvironment for each existing environment and then        */
   /* deallocate the remaining data used to keep track of allocated    */
   /* environments. Otherwise, you must explicitly call                */
   /* DestroyEnvironment for each environment you create.              */
   /*==================================================================*/
   
   /* DeallocateEnvironmentData(); */
   /* DestroyEnvironment(theEnv); */
   
   return(-1);
  }
