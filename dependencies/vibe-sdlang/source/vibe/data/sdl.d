/** SDLang data format serialization support for vibe.data.serialization.
*/
module vibe.data.sdl;

import vibe.data.serialization;
import sdlang;
import std.datetime : Date, DateTime, SysTime, TimeOfDay, UTC;
import std.meta : allSatisfy, staticIndexOf;
import std.traits : Unqual, ValueType, hasUDA, isNumeric, isBoolean, isArray, isAssociativeArray;
import core.time : Duration, days, hours, seconds;

///
unittest {
	import std.conv : to;

	static struct S {
		bool b;
		int i;
		float f;
		double d;
		string str;
		ubyte[] data;
		SysTime sysTime;
		DateTimeFrac dateTime;
		Date date;
		Duration dur;
	}

	S s = {
		b : true,
		i: 12,
		f: 0.5f,
		d: 0.5,
		str: "foo",
		data: [1, 2, 3],
		sysTime: SysTime(DateTime(Date(2016, 12, 10), TimeOfDay(9, 30, 23)), UTC()),
		dateTime: DateTimeFrac(DateTime(Date(2016, 12, 10), TimeOfDay(9, 30, 23))),
		date: Date(2016, 12, 10),
		dur: 2.days + 2.hours + 2.seconds
	};

	auto res = serializeSDLang(s);
	assert(res.toSDLDocument() == "b true\ni 12\nf 0.5F\nd 0.5D\nstr \"foo\"\ndata [AQID]\n"
		~ "sysTime 2016/12/10 09:30:23-UTC\ndateTime 2016/12/10 09:30:23\ndate 2016/12/10\n"
		~ "dur 2d:02:00:02\n", [res.toSDLDocument()].to!string);

	auto t = deserializeSDLang!S(res);
	assert(s == t);
}


///
unittest {
	static struct U {
		@sdlAttribute int att1;
		string content1;
	}

	static struct T {
		@sdlAttribute int att1;
		@sdlAttribute string att2;
		@sdlValue string content;
	}

	static struct S {
		string[string] dict;
		U[] arr;
		T[] arr1;
		@sdlSingle T[] arr2;
		int[] iarr;
	}

	S s = {
		dict : ["a": "foo", "b": "bar"],
		arr : [U(1, "x"), U(2, "y")],
		arr1 : [T(1, "a", "x"), T(2, "b", "y")],
		arr2 : [T(1, "a", "x"), T(2, "b", "y")],
		iarr : [1, 2, 3]
	};

	auto res = serializeSDLang(s);
	assert(res.toSDLDocument() ==
`dict {
	"b" "bar"
	"a" "foo"
}
arr {
	entry att1=1 {
		content1 "x"
	}
	entry att1=2 {
		content1 "y"
	}
}
arr1 {
	entry "x" att1=1 att2="a"
	entry "y" att1=2 att2="b"
}
arr2 "x" att1=1 att2="a"
arr2 "y" att1=2 att2="b"
iarr 1 2 3
`, res.toSDLDocument());

	S t = deserialize!(SDLangSerializer, S)(res);
	import std.conv : to;
	assert(s == t, t.to!string);
}

/** Serializes a value as an SDLang document.
*/
Tag serializeSDLang(T, alias Policy = DefaultPolicy)(T value)
{
	return serializeWithPolicy!(SDLangSerializer, Policy)(value, new Tag(null, null));
}

/** Deseriailzes a value from an SDLang document.
*/
T deserializeSDLang(T, alias Policy = DefaultPolicy)(Tag sdl)
{
	return deserializeWithPolicy!(SDLangSerializer, Policy, T)(sdl);
}


///
struct SDLangSerializer {
	enum isSDLBasicType(T) =
		isNumeric!T ||
		isBoolean!T ||
		is(T == string) ||
		is(T == ubyte[]) ||
		is(T == SysTime) ||
		is(T == DateTime) ||
		is(T == DateTimeFrac) ||
		is(T == Date) ||
		is(T == Duration) ||
		is(T == typeof(null)) ||
		isSDLSerializable!T;

	enum isSupportedValueType(T) = isSDLBasicType!T || is(T == Tag);

	private enum Loc { subNodes, attribute, values }

	private static struct StackEntry {
		Tag tag;
		Attribute attribute;
		Loc loc;
		size_t valIdx;
		bool hasIdentKeys, isArrayEntry;
		string singleArrayName;
	}

	private {
		StackEntry[] m_stack;
	}

	this(Tag data) { pushTag(data); }

	@disable this(this);

	//
	// serialization
	//
	Tag getSerializedResult() { return m_stack[0].tag; }

	void beginWriteDictionary(Traits)()
	{
		current.hasIdentKeys = !isAssociativeArray!(Traits.Type);
	}
	void endWriteDictionary(Traits)() {}
	void beginWriteDictionaryEntry(ElementTraits)(string name) {
		assert(m_stack.length > 0);
		assert(isAssociativeArray!(ElementTraits.ContainerType) || name.length > 0);
		static if (containsValue!(SDLSingleAttribute, ElementTraits.Attributes)) {
			current.singleArrayName = name;
			current.loc = Loc.subNodes;
		} else static if (isSDLBasicType!(ElementTraits.Type) && containsValue!(SDLAttributeAttribute, ElementTraits.Attributes)) {
			current.attribute = new Attribute(null, name, Value(null));
			current.tag.add(current.attribute);
			current.loc = Loc.attribute;
		} else static if (isSDLBasicType!(ElementTraits.Type) && containsValue!(SDLValueAttribute, ElementTraits.Attributes)) {
			current.loc = Loc.values;
		} else {
			if (current.hasIdentKeys) pushTag(name);
			else pushTag(null, Value(name));
			current.singleArrayName = "entry";
			current.loc = Loc.values;
		}
	}
	void endWriteDictionaryEntry(ElementTraits)(string name) {
		static if (containsValue!(SDLSingleAttribute, ElementTraits.Attributes)) {}
		else static if (isSDLBasicType!(ElementTraits.Type) && containsValue!(SDLAttributeAttribute, ElementTraits.Attributes)) {}
		else static if (isSDLBasicType!(ElementTraits.Type) && containsValue!(SDLValueAttribute, ElementTraits.Attributes)) {}
		else pop();
	}


	void beginWriteArray(Traits)(size_t)
		if (isValueArray!(Traits.Type))
	{
		current.loc = Loc.values;
	}
	void endWriteArray(Traits)() if (isValueArray!(Traits.Type)) {}
	void beginWriteArray(Traits)(size_t) if (!isValueArray!(Traits.Type))
	{
		current.loc = Loc.subNodes;
	}
	void endWriteArray(Traits)() if (!isValueArray!(Traits.Type)) {}
	void beginWriteArrayEntry(ElementTraits)(size_t idx)
	{
		if (current.loc == Loc.subNodes) {
			static if (containsValue!(SDLSingleAttribute, ElementTraits.ContainerAttributes)) {
				if (idx > 0 && m_stack.length > 1) {
					auto name = current.tag.name;
					assert(name.length > 0);
					pop();
					pushTag(name);
					return;
				}
			}

			// import std.stdio:writefln;
			// writefln( "arraName.length: %d", current.singleArrayName.length);

			if(current.singleArrayName.length > 0) {
				pushTag(current.singleArrayName);
				current.isArrayEntry = true;
			}
		}
	}
	void endWriteArrayEntry(ElementTraits)(size_t)
	{
		if (current.isArrayEntry) pop();
	}

	void writeValue(Traits, T)(in T value)
		if (!is(T == Tag))
	{
		import std.traits : isIntegral;

		static if (isSDLSerializable!T) writeValue(value.toSDL());
		else {
			Value val;
			static if (is(T == DateTime)) val = DateTimeFrac(value);
			else {
				Unqual!T uval;
				static if (is(typeof(uval = value))) uval = value;
				else uval = value.dup;
				static if (isIntegral!T) {
					static if (T.sizeof <= int.sizeof) val = cast(int)uval;
					else val = uval;
				} else val = uval;
			}
			
			final switch (current.loc) {
				case Loc.attribute: current.attribute.value = val; break;
				case Loc.values: current.tag.add(val); break;
				case Loc.subNodes: current.tag.add(new Tag(null, null, [val])); break;
			}
		}
	}

	void writeValue(Traits, T)(Tag value) if (is(T == Tag)) { current.tag.add(value); }
	void writeValue(Traits, T)(in Json Tag) if (is(T == Tag)) { current.tag.add(value.clone); }

	//
	// deserialization
	//
	void readDictionary(Traits)(scope void delegate(string) field_handler)
		if (isAssociativeArray!(Traits.Type))
	{
		foreach (st; current.tag.tags) {
			pushTag(st);
			current.valIdx = 1;
			current.loc = Loc.values;
			auto n = st.values[0].get!string;
			field_handler(n);
			pop();
		}
	}

	void readDictionary(Traits)(scope void delegate(string) field_handler)
		if (!isAssociativeArray!(Traits.Type))
	{
		import std.meta : AliasSeq;
		import std.traits : FieldNameTuple, hasUDA;
		foreach (att; current.tag.attributes) {
			current.loc = Loc.attribute;
			current.attribute = att;
			field_handler(att.name);
		}
		size_t first_idx = 0; // FIXME: 1 for non-ident keys
		foreach (st; current.tag.tags) {
			pushTag(st);
			current.loc = Loc.values;
			current.valIdx = 0;
			field_handler(st.name);
			pop();
		}
		static if (is(Traits.Type == struct) || is(Traits.Type == class)) {
			current.valIdx = 0;
			foreach (fname; FieldNameTuple!(Traits.Type)) {
				alias F = AliasSeq!(__traits(getMember, Traits.Type, fname));
				static if (hasUDAValue!(F[0], SDLValueAttribute)) {
					current.loc = Loc.values;
					if (current.valIdx >= current.tag.values.length) {
						import std.format : format;
						throw new Exception(format("Line %s: Missing value number %s (%s) for '%s'.", current.tag.location.line+1, current.valIdx+1, fname, current.tag.name)); // TODO: show line number
					}

					field_handler(__traits(identifier, F[0]));
					current.valIdx++;
				}
			}
		}
	}

	void beginReadDictionaryEntry(Traits)(string name)
	{
	}

	void endReadDictionaryEntry(Traits)(string name)
	{
	}

	void readArray(Traits)(scope void delegate(size_t) size_callback, scope void delegate() entry_callback)
		if (containsValue!(SDLSingleAttribute, Traits.Attributes))
	{
		// FIXME: ensure that this is only called once and not for each array entry tag
		auto name = current.tag.name;
		foreach (t; current.tag.parent.tags) {
			if (t.name == name) {
				pushTag(t);
				entry_callback();
				pop();
			}
		}
	}

	void readArray(Traits)(scope void delegate(size_t) size_callback, scope void delegate() entry_callback)
		if (!containsValue!(SDLSingleAttribute, Traits.Attributes) && isValueArray!(Traits.Type))
	{
		current.loc = Loc.values;
		current.valIdx = 0;
		size_callback(current.tag.values.length);
		while (current.valIdx < current.tag.values.length) {
			entry_callback();
			current.valIdx++;
		}
	}

	void readArray(Traits)(scope void delegate(size_t) size_callback, scope void delegate() entry_callback)
		if (!containsValue!(SDLSingleAttribute, Traits.Attributes) && !isValueArray!(Traits.Type))
	{
		size_callback(current.tag.tags.length);
		foreach (st; current.tag.tags) {
			pushTag(st);
			entry_callback();
			pop();
		}
	}

	void beginReadArrayEntry(Traits)(size_t idx)
	{
	}

	void endReadArrayEntry(Traits)(size_t idx)
	{
	}

	T readValue(Traits, T)()
	{
		import std.conv : to;
		import std.traits : isIntegral;

		auto val = getCurrentValue();
		static if (isIntegral!T) {
			static if (T.sizeof <= int.sizeof) return val.get!int.to!T;
			else return val.get!long;
		} else return val.get!T;
	}

	bool tryReadNull(Traits)()
	{
		auto val = getCurrentValue();
		if (!val.hasValue) return false;
		return val.peek!(typeof(null)) !is null;
	}

	private @property ref inout(StackEntry) current() inout { return m_stack[$-1]; }

	private void pushTag(string name) { pushTag(new Tag(current.tag, null, name)); }
	private void pushTag(string name, Value value) { pushTag(new Tag(current.tag, null, name, [value])); }
	private void pushTag(Tag tag)
	{
		StackEntry se;
		se.tag = tag;
		se.valIdx = tag.values.length;
		m_stack ~= se;
	}

	private void pushAttribute(string name)
	{
		StackEntry se;
		se.attribute = new Attribute(null, name, Value.init);
		se.tag = current.tag;
		se.loc = Loc.attribute;
		current.tag.add(se.attribute);
		m_stack ~= se;
	}

	private void pop()
	{
		assert(m_stack.length > 1, "Popping last element!?");
		m_stack.length--;
		m_stack.assumeSafeAppend();
	}


	private Value getCurrentValue()
	{
		final switch (current.loc) {
			case Loc.attribute: return current.attribute.value;
			case Loc.values:
				if (current.valIdx < current.tag.values.length)
					return current.tag.values[current.valIdx];
				return Value.init;
			case Loc.subNodes:
				if (current.tag.values.length > 0)
					return current.tag.values[0];
				return Value.init;
		}
	}

	private template isValueDictionary(T) {
		static if (isAssociativeArray!T)
			enum isValueDictionary = isSDLBasicType!(ValueType!T);
		else static if (is(T == struct) || is(T == class))
			enum isValueDictionary = anySatisfy!(isValueField, T.tupleof) && allSatisfy!(isValueOrAttributeField, T.tupleof);
		else enum isValueDictionary = false;
	}

	private template isValueArray(T) {
		static if (isArray!T)
			enum isValueArray = isSDLBasicType!(typeof(T.init[0]));
		else enum isValueArray = false;
	}
}

/** Forces a value to be serialized as an SDL attribute.

	This can be applied to plain values in aggregate members and will cause
	the vaule to be seriailzed as an attribute of the parent tag instead of
	as a child tag.
*/
@property SDLAttributeAttribute sdlAttribute() { return SDLAttributeAttribute.init; }

///
unittest {
	struct S {
		int foo;
		@sdlAttribute int bar;
	}

	struct T {
		S s;
	}

	assert(
		serializeSDLang(T(S(1, 2))).toSDLDocument() ==
		"s bar=2 {\n" ~
		"\tfoo 1\n" ~
		"}\n"
	);
}


/** Forces a value to be serialized as an SDL value.

	This can be applied to plain values in aggregate members and will cause
	the vaule to be seriailzed as a value of the parent tag instead of
	as a child tag.
*/
@property SDLValueAttribute sdlValue() { return SDLValueAttribute.init; }

///
unittest {
	struct S {
		int foo;
		@sdlValue int bar;
	}

	struct T {
		S s;
	}

	assert(
		serializeSDLang(T(S(1, 2))).toSDLDocument() ==
		"s 2 {\n" ~
		"\tfoo 1\n" ~
		"}\n"
	);
}


/** Causes an array to be serialized as a plain sequence of entry tags instead
	of wrapping them in a separate parent tag.
*/
@property SDLSingleAttribute sdlSingle() { return SDLSingleAttribute.init; }

///
unittest {
	struct S {
		@sdlAttribute int foo;
		@sdlAttribute int bar;
	}

	struct T {
		S[] arr1;
		@sdlSingle S[] arr2;
	}

	assert(
		serializeSDLang(T([S(1, 2), S(3, 4)], [S(5, 6), S(7, 8)])).toSDLDocument() ==
		"arr1 {\n" ~
		"\tentry foo=1 bar=2\n" ~
		"\tentry foo=3 bar=4\n" ~
		"}\n" ~
		"arr2 foo=5 bar=6\n" ~
		"arr2 foo=7 bar=8\n"
	);
}

enum isSDLSerializable(T) = is(typeof(T.init.toSDL()) == Tag) && is(typeof(T.fromSDL(new Tag())) == T);
enum isValueField(alias F) = hasUDAValue!(F, SDLValueAttribute);
enum isValueOrAttributeField(alias F) = hasUDAValue!(F, SDLValueAttribute) || hasUDAValue!(F, SDLAttributeAttribute);

/// private
private struct SDLAttributeAttribute {}
/// private
private struct SDLSingleAttribute {}
/// private
private struct SDLValueAttribute {}

private enum hasUDAValue(alias DECL, T) = containsValue!(T, __traits(getAttributes, DECL));
private template containsValue(T, V...) {
	static if (V.length > 0)
		enum containsValue = is(typeof(V[0]) == T) || containsValue!(T, V[1 .. $]);
	else enum containsValue = false;
}

unittest {
	struct S {
		@sdlSingle int single;
		@sdlValue int value;
		@sdlAttribute int attribute;
	}

	static assert(hasUDAValue!(S.single, SDLSingleAttribute));
	static assert(!hasUDAValue!(S.single, SDLValueAttribute));
	static assert(!hasUDAValue!(S.single, SDLAttributeAttribute));
	static assert(!hasUDAValue!(S.value, SDLSingleAttribute));
	static assert(hasUDAValue!(S.value, SDLValueAttribute));
	static assert(!hasUDAValue!(S.value, SDLAttributeAttribute));
	static assert(!hasUDAValue!(S.attribute, SDLSingleAttribute));
	static assert(!hasUDAValue!(S.attribute, SDLValueAttribute));
	static assert(hasUDAValue!(S.attribute, SDLAttributeAttribute));
}

unittest {
	struct S {
		short s;
		long l;
		int i;
		float f;
		double d;
	}
	auto s = S(-30000, -80000000000, -2000000000, 0.5f, 0.5);
	Tag serialized = s.serializeSDLang();
	assert(serialized.toSDLDocument() == "s -30000\nl -80000000000L\ni -2000000000\nf 0.5F\nd 0.5D\n", serialized.toSDLDocument());
	assert(serialized.deserializeSDLang!S() == s);
}