import std.stdio;
import clips;
import std.conv:to;

int main( string[] argv)
{
  //writefln("CLIPS DEMO");
  auto env = new Environment;
  env.reset();
  env.clear();

  string PROMPT="CLIPS DEMO>";
  char[] buf;
  while (readln(buf)){
    auto vs = env.evaluate(to!string(buf));
    writeValues(vs);
    write(PROMPT ~ to!string(buf));
  }

  //void *theEnv = CreateEnvironment();
  //RerouteStdin(theEnv,cast(int)argv.length,cast(char **)argv.ptr);
  //CommandLoop(theEnv);
  //DeallocateEnvironmentData(); 
  //DestroyEnvironment(theEnv); 

  return(-1);
}


void writeValues(Values vs) {
  foreach(Value v; vs) {
    writefln(v.data.type.toString());
  }
}