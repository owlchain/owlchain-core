module clips.value;

import std.signals;
import std.variant;
import std.algorithm.searching:canFind;
//import std.exception;

enum Type {
  TYPE_UNKNOWN = -1,
  TYPE_FLOAT = 0,
  TYPE_INTEGER = 1,
  TYPE_SYMBOL = 2,
  TYPE_STRING = 3,
  TYPE_EXTERNAL_ADDRESS = 5,
  TYPE_INSTANCE_ADDRESS = 7,
  TYPE_INSTANCE_NAME = 8,
}

struct Value {

    // this() {
    //     _type = TYPE_UNKNOWN;
    // }

    this(T)(T v, Type type) {
        set(v,type);
    }

    this(T)(T v) {
        set(v);
    }

    void set(T)(T v) {
        _variant = v;
        _type = guessType(_variant);
    }

    void set(T)(T v, Type type) {
        _variant = v;
        _type = type;
    }

    Type guessType(Variant v){
        if([ typeid(short), typeid(ushort), typeid(int), typeid(uint), typeid(long), typeid(ulong) ].canFind(v.type))
            return type.TYPE_INTEGER;

        else if([typeid(float), typeid(double)].canFind(v.type))
            return type.TYPE_FLOAT;

        else if( typeid(string) == v.type)
                return type.TYPE_STRING;

        else return type.TYPE_UNKNOWN;

    }
    Type type() { return _type; }
    Variant data() { return _variant; }
    Variant _variant;
    Type _type;
}

  
class ClipsValueException: Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

alias Values = Value[];

Values values() { 
    Values vs;
    return vs.dup;
}
