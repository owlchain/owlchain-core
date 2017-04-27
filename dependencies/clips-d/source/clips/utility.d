module clips.utility;

import clips.value;
import clips.c.clips;
import clips.environment;
import std.string:toStringz;
import std.conv:to;

  Values data_object_to_values( dataObject* clipsdo ) {
    return data_object_to_values( *clipsdo );
  }

  Values data_object_to_values( dataObject clipsdo ) {
    Values values;

    char* s;
    double d;
    long  i;
    void* p;

    void* mfptr;
    long end;
  
    switch ( clipsdo.type ) {
    case RVOID:
      return values;
    case STRING:
      s = DOToString( clipsdo );
      values ~= Value( to!string(s) );
      return values;
    case INSTANCE_NAME:
      s = DOToString( clipsdo );
      values ~= Value( to!string(s), Type.TYPE_INSTANCE_NAME );
      return values;
    case SYMBOL:
      s = DOToString( clipsdo );
      values ~= Value( to!string(s), Type.TYPE_INSTANCE_NAME );
      return values;
    case FLOAT:
      d = DOToDouble( clipsdo );
      values ~= Value( d );
      return values;
    case INTEGER:
      i = DOToLong( clipsdo );
      values ~= Value( i );
      return values;
    case INSTANCE_ADDRESS:
      p = DOToPointer( clipsdo );
      values ~= Value( p, Type.TYPE_INSTANCE_ADDRESS );
      return values;
    case EXTERNAL_ADDRESS:
      p = ((cast(externalAddressHashNode *)(clipsdo.value)).externalAddress);
      values ~= Value( p, Type.TYPE_EXTERNAL_ADDRESS ) ;
      return values;
    case MULTIFIELD:
      end = GetDOEnd( clipsdo );
      mfptr = GetValue( clipsdo );
      for ( int iter = GetDOBegin( clipsdo ); iter <= end; iter++ ) {
	      switch ( GetMFType( mfptr, iter ) ) {
	        case STRING:
	          s = ValueToString( GetMFValue( mfptr, iter ) );
	          values ~= Value( s, Type.TYPE_STRING );
	          break;
          case SYMBOL:
            s = ValueToString( GetMFValue( mfptr, iter ) );
            values ~= Value( s, Type.TYPE_SYMBOL ) ;
            break;
          case FLOAT:
            d = ValueToDouble( GetMFValue( mfptr, iter ) );
            values ~= Value( d );
            break;
          case INTEGER:
            i = ValueToLong( GetMFValue( mfptr, iter ) );
            values ~= Value( i ) ;
            break;
          case EXTERNAL_ADDRESS:
            p = ValueToExternalAddress( GetMFValue( mfptr, iter ) );
            values ~= Value( p, Type.TYPE_EXTERNAL_ADDRESS );
            break;
          default:
            throw new ClipsValueException( "clips.data_object_to_values: Unhandled multifield type" );
          }
      }
      return values;
    default:
      //std::cout << std::endl << "Type: " << GetType(clipsdo) << std::endl;
      throw new ClipsValueException( "clips.data_object_to_values: Unhandled data object type" );
    }
  }

  dataObject * value_to_data_object(Environment env, Value value, dataObject *obj)
  {
    return value_to_data_object_rawenv(env.cobj(), value, obj);
  }


  dataObject * value_to_data_object_rawenv(void *env, Value value, dataObject *obj)
  {
    void *p;

    dataObject* clipsdo = obj;
    if (! clipsdo) {
      clipsdo = new dataObject;
    }

    SetpType(clipsdo, cast(ushort)value.type() );

    switch ( value.type() ) {
      case Type.TYPE_SYMBOL,Type.TYPE_STRING, Type.TYPE_INSTANCE_NAME:
        p = EnvAddSymbol( env,
                          cast(char*)( toStringz(*value.data.peek!string) )
                        );
        SetpValue(clipsdo, p);
        return clipsdo;
      case Type.TYPE_INTEGER:
        p = EnvAddLong( env, * value.data.peek!long );
        SetpValue(clipsdo, p);
        return clipsdo;
      case Type.TYPE_FLOAT:
        p = EnvAddDouble( env, * value.data.peek!double );
        SetpValue(clipsdo, p);
        return clipsdo;
      case Type.TYPE_EXTERNAL_ADDRESS:
        p = EnvAddExternalAddress( env, value.data.peek!(void*), EXTERNAL_ADDRESS );
        SetpValue(clipsdo, p);
        return clipsdo;
      default:
        throw new ClipsValueException( "clips.value_to_data_object: Unhandled data object type" );
    }

    //return null;
  }

  dataObject *value_to_data_object(Environment env, Values values, dataObject *obj)
  {
    return value_to_data_object_rawenv(env.cobj(), values, obj);
  }

  dataObject *value_to_data_object_rawenv(void *env, Values values, dataObject *obj)
  {
    void *p;
    void *p2;

    dataObject* clipsdo = obj;
    if (! clipsdo) {
      clipsdo = new dataObject;
    }

    p = EnvCreateMultifield( env, cast(int)values.length );
    for (uint iter = 0; iter < values.length; iter++) {
      uint mfi = iter + 1; // mfptr indices start at 1
      SetMFType(p, mfi, cast(ushort)values[iter].type());
      switch ( values[iter].type() ) {
        case Type.TYPE_SYMBOL,Type.TYPE_STRING,Type.TYPE_INSTANCE_NAME:
          p2 = EnvAddSymbol( env,
                             cast(char*)(toStringz(* values[iter].data.peek!string))
                           );
          SetMFValue(p, mfi, p2);
          break;
        case Type.TYPE_INTEGER:
          p2 = EnvAddLong( env, *values[iter].data.peek!int );
          SetMFValue(p, mfi, p2);
          break;
        case Type.TYPE_FLOAT:
          p2 = EnvAddDouble( env, *values[iter].data.peek!double );
          SetMFValue(p, mfi, p2);
          break;
        case Type.TYPE_EXTERNAL_ADDRESS:
          p2 = EnvAddExternalAddress( env, values[iter].data.peek!(void*), EXTERNAL_ADDRESS );
	        SetMFValue(p, mfi, p2);
	        break;
        default:
          throw new ClipsValueException( "clips.value_to_data_object: Unhandled data object type" );
      }
    }
    SetpType(clipsdo, cast(ushort)MULTIFIELD);
    SetpValue(clipsdo, p);
    SetpDOBegin(clipsdo, 1);
    SetpDOEnd(clipsdo, cast(ushort)values.length);
    return clipsdo;
  }
