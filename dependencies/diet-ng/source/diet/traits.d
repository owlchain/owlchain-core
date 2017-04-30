/** Definitions to support customization of the Diet compilation process.
*/
module diet.traits;

import diet.dom;


/** Marks a struct as a Diet traits container.

	A traits struct can contain any of the following:

	$(UL
		$(LI `string translate(string)` - A function that takes a `string` and
			returns the translated version of that string. This is used for
			translating the text of nodes marked with `&` at compile time. Note
			that the input string may contain string interpolations.)
		$(LI `void filterX(string)` - Any number of compile-time filter
			functions, where "X" is a placeholder for the actual filter name. 
			The first character will be converted to lower case, so that a
			function `filterCss` will be available as `:css` within the Diet
			template.)
		$(LI `SafeFilterCallback[string] filters` - A dictionary of runtime filter
			functions that will be used to for filter nodes that don't have an
			available compile-time filter or contain string interpolations.)
	)
*/
@property DietTraitsAttribute dietTraits() { return DietTraitsAttribute.init; }

///
unittest {
	import diet.html : compileHTMLDietString;
	import std.array : appender, array;
	import std.string : toUpper;

	@dietTraits
	static struct CTX {
		static string translate(string text) {
			return text == "Hello, World!" ? "Hallo, Welt!" : text;
		}

		static string filterUppercase(I)(I input) {
			return input.toUpper();
		}
	}

	auto dst = appender!string;
	dst.compileHTMLDietString!("p& Hello, World!", CTX);
	assert(dst.data == "<p>Hallo, Welt!</p>");

	dst = appender!string;
	dst.compileHTMLDietString!(":uppercase testing", CTX);
	assert(dst.data == "TESTING");
}


/** Translates a line of text based on the traits passed to the Diet parser.

	The input text may contain string interpolations of the form `#{...}` or
	`!{...}`, where the contents form an arbitrary D expression. The
	translation function is required to pass these through unmodified.
*/
string translate(TRAITS...)(string text)
{
	import std.traits : hasUDA;

	foreach (T; TRAITS) {
		static assert(hasUDA!(T, DietTraitsAttribute));
		static if (is(typeof(&T.translate)))
			text = T.translate(text);
	}
	return text;
}


/** Applies any transformations that are defined in the 
*/
Document applyTraits(TRAITS...)(Document doc)
{
	import diet.defs : enforcep;
	import std.algorithm.searching : startsWith;
	import std.array : split;

	void processNode(ref Node n, bool in_filter)
	{
		bool is_filter = n.name == Node.SpecialName.filter;

		// process children first
		for (size_t i = 0; i < n.contents.length;) {
			auto nc = n.contents[i];
			if (nc.kind == NodeContent.Kind.node) {
				processNode(nc.node, is_filter || in_filter);
				if ((is_filter || in_filter) && nc.node.name == Node.SpecialName.text) {
					n.contents = n.contents[0 .. i] ~ nc.node.contents ~ n.contents[i+1 .. $];
					i += nc.node.contents.length;
				} else i++;
			} else i++;
		}

		// then consolidate text
		for (size_t i = 1; i < n.contents.length;) {
			if (n.contents[i-1].kind == NodeContent.Kind.text && n.contents[i].kind == NodeContent.Kind.text) {
				n.contents[i-1].value ~= n.contents[i].value;
				n.contents = n.contents[0 .. i] ~ n.contents[i+1 .. $];
			} else i++;
		}

		// finally process filters
		if (is_filter) {
			enforcep(n.isProceduralTextNode, "Only text is supported as filter contents.", n.loc);
			auto chain = n.getAttribute("filterChain").expectText().split(' ');
			n.attributes = null;
			n.attribs = NodeAttribs.none;

			if (n.isTextNode) {
				while (chain.length) {
					if (hasFilterCT!TRAITS(chain[$-1])) {
						n.contents[0].value = runFilterCT!TRAITS(n.contents[0].value, chain[$-1]);
						chain.length--;
					} else break;
				}
			}

			if (!chain.length) n.name = Node.SpecialName.text;
			else {
				n.name = Node.SpecialName.code;
				n.contents = [NodeContent.text(generateFilterChainMixin(chain, n.contents), n.loc)];
			}
		}
	}

	foreach (ref n; doc.nodes) processNode(n, false);

	return doc;
}

deprecated("Use SafeFilterCallback instead.")
alias FilterCallback = void delegate(in char[] input, scope CharacterSink output);
alias SafeFilterCallback = void delegate(in char[] input, scope CharacterSink output) @safe;
alias CharacterSink = void delegate(in char[]) @safe;

void filter(ALIASES...)(in char[] input, string filter, CharacterSink output)
{
	import std.traits : hasUDA;

	foreach (A; ALIASES)
		static if (hasUDA!(A, DietTraitsAttribute)) {
			static if (is(typeof(A.filters)))
				if (auto pf = filter in A.filters) {
					(*pf)(input, output);
					return;
				}
		}

	// FIXME: output location information
	throw new Exception("Unknown filter: "~filter);
}

private string generateFilterChainMixin(string[] chain, NodeContent[] contents)
{
	import std.format : format;
	import diet.defs : enforcep, dietOutputRangeName;
	import diet.internal.string : dstringEscape;

	string ret = `{ import std.array : appender; import std.format : formattedWrite; `;
	auto tloname = format("__f%s", chain.length);

	if (contents.length == 1 && contents[0].kind == NodeContent.Kind.text) {
		ret ~= q{enum %s = "%s";}.format(tloname, dstringEscape(contents[0].value));
	} else {
		ret ~= q{auto %s_app = appender!(char[])();}.format(tloname);
		foreach (c; contents) {
			switch (c.kind) {
				default: assert(false, "Unexpected node content in filter.");
				case NodeContent.Kind.text:
					ret ~= q{%s_app.put("%s");}.format(tloname, dstringEscape(c.value));
					break;
				case NodeContent.Kind.rawInterpolation:
					ret ~= q{%s_app.formattedWrite("%%s", %s);}.format(tloname, c.value);
					break;
				case NodeContent.Kind.interpolation:
					enforcep(false, "Non-raw interpolations are not supported within filter contents.", c.loc);
					break;
			}
			ret ~= "\n";
		}
		ret ~= q{auto %s = %s_app.data;}.format(tloname, tloname);
	}

	foreach_reverse (i, f; chain) {
		ret ~= "\n";
		string iname = format("__f%s", i+1);
		string oname;
		if (i > 0) {
			oname = format("__f%s_app", i);
			ret ~= q{auto %s = appender!(char[]);}.format(oname);
		} else oname = dietOutputRangeName;
		ret ~= q{%s.filter!ALIASES("%s", (in char[] s) @safe { %s.put(s); });}.format(iname, dstringEscape(f), oname);
		if (i > 0) ret ~= q{auto __f%s = %s.data;}.format(i, oname);
	}

	return ret ~ `}`;
}

unittest {
	import std.array : appender;
	import diet.html : compileHTMLDietString;

	@dietTraits
	static struct CTX {
		static string filterFoo(string str) { return "("~str~")"; }
		static SafeFilterCallback[string] filters;
	}

	CTX.filters["foo"] = (input, scope output) { output("(R"); output(input); output("R)"); };
	CTX.filters["bar"] = (input, scope output) { output("(RB"); output(input); output("RB)"); };

	auto dst = appender!string;
	dst.compileHTMLDietString!(":foo text", CTX);
	assert(dst.data == "(text)");

	dst = appender!string;
	dst.compileHTMLDietString!(":foo text\n\tmore", CTX);
	assert(dst.data == "(text\nmore)");

	dst = appender!string;
	dst.compileHTMLDietString!(":foo :foo text", CTX);
	assert(dst.data == "((text))");

	dst = appender!string;
	dst.compileHTMLDietString!(":bar :foo text", CTX);
	assert(dst.data == "(RB(text)RB)");

	dst = appender!string;
	dst.compileHTMLDietString!(":foo :bar text", CTX);
	assert(dst.data == "(R(RBtextRB)R)");

	dst = appender!string;
	dst.compileHTMLDietString!(":foo text !{1}", CTX);
	assert(dst.data == "(Rtext 1R)");
}

@safe unittest {
	import diet.html : compileHTMLDietString;

	static struct R {
		void put(char) @safe {}
		void put(in char[]) @safe {}
		void put(dchar) @safe {}
	}

	@dietTraits
	static struct CTX {
		static SafeFilterCallback[string] filters;
	}
	CTX.filters["foo"] = (input, scope output) { output(input); };

	R r;
	r.compileHTMLDietString!(":foo bar", CTX);
}

private struct DietTraitsAttribute {}

private bool hasFilterCT(TRAITS...)(string filter)
{
	alias Filters = FiltersFromTraits!TRAITS;
	static if (Filters.length) {
		switch (filter) {
			default: break;
			foreach (i, F; Filters) {
				case FilterName!(Filters[i]): return true;
			}
		}
	}
	return false;
}

private string runFilterCT(TRAITS...)(string text, string filter)
{
	alias Filters = FiltersFromTraits!TRAITS;
	static if (Filters.length) {
		switch (filter) {
			default: break;
			foreach (i, F; Filters) {
				case FilterName!(Filters[i]): return F(text);
			}
		}
	}
	return text; // FIXME: error out?
}

private template FiltersFromTraits(TRAITS...)
{
	import std.meta : AliasSeq;
	template impl(size_t i) {
		static if (i < TRAITS.length) {
			// FIXME: merge lists avoiding duplicates
			alias impl = AliasSeq!(FiltersFromContext!(TRAITS[i]), impl!(i+1));
		} else alias impl = AliasSeq!();
	}
	alias FiltersFromTraits = impl!0;
}

/** Extracts all Diet traits structs from a set of aliases as passed to a render function.
*/
template DietTraits(ALIASES...)
{
	import std.meta : AliasSeq;
	import std.traits : hasUDA;

	template impl(size_t i) {
		static if (i < ALIASES.length) {
			static if (is(ALIASES[i]) && hasUDA!(ALIASES[i], DietTraitsAttribute)) {
				alias impl = AliasSeq!(ALIASES[i], impl!(i+1));
			} else alias impl = impl!(i+1);
		} else alias impl = AliasSeq!();
	}
	alias DietTraits = impl!0;
}

private template FiltersFromContext(Context)
{
	import std.meta : AliasSeq;
	import std.algorithm.searching : startsWith;

	alias members = AliasSeq!(__traits(allMembers, Context));
	template impl(size_t i) {
		static if (i < members.length) {
			static if (members[i].startsWith("filter") && members[i].length > 6 && members[i] != "filters")
				alias impl = AliasSeq!(__traits(getMember, Context, members[i]), impl!(i+1));
			else alias impl = impl!(i+1);
		} else alias impl = AliasSeq!();
	}
	alias FiltersFromContext = impl!0;
}

private template FilterName(alias FilterFunction)
{
	import std.algorithm.searching : startsWith;
	import std.ascii : toLower;

	enum ident = __traits(identifier, FilterFunction);
	static if (ident.startsWith("filter") && ident.length > 6)
		enum FilterName = ident[6].toLower ~ ident[7 .. $];
	else static assert(false,
		"Filter function must start with \"filter\" and must have a non-zero length suffix: " ~ ident);
}
