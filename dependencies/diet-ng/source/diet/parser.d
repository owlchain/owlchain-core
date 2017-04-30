/**
	Generic Diet format parser.

	Performs generic parsing of a Diet template file. The resulting AST is
	agnostic to the output format context in which it is used. Format
	specific constructs, such as inline code or special tags, are parsed
	as-is without any preprocessing.

	The supported features of the are:
	$(UL
		$(LI string interpolations)
		$(LI assignment expressions)
		$(LI blocks/extensions)
		$(LI includes)
		$(LI text paragraphs)
		$(LI translation annotations)
		$(LI class and ID attribute shortcuts)
	)
*/
module diet.parser;

import diet.dom;
import diet.defs;
import diet.input;
import diet.internal.string;

import std.algorithm.searching : endsWith, startsWith;
import std.range.primitives : empty, front, popFront, popFrontN;


/** Parses a Diet template document and outputs the resulting DOM tree.

	The overload that takes a list of files will automatically resolve
	includes and extensions.

	Params:
		TR = An optional translation function that takes and returns a string.
			This function will be invoked whenever node text contents need
			to be translated at compile tile (for the `&` node suffix).
		text = For the single-file overload, specifies the contents of the Diet
			template.
		filename = For the single-file overload, specifies the file name that
			is displayed in error messages and stored in the DOM `Location`s.
		files = A full set of Diet template files. All files referenced in
			includes or extension directives must be present.

	Returns:
		The list of parsed root nodes is returned.
*/
Document parseDiet(alias TR = identity)(string text, string filename = "string")
	if (is(typeof(TR(string.init)) == string))
{
	InputFile[1] f;
	f[0].name = filename;
	f[0].contents = text;
	return parseDiet!TR(f);
}

Document parseDiet(alias TR = identity)(InputFile[] files)
	if (is(typeof(TR(string.init)) == string))
{
	import diet.traits;
	import std.algorithm.iteration : map;
	import std.array : array;
	FileInfo[] parsed_files = files.map!(f => FileInfo(f.name, parseDietRaw!TR(f))).array;
	BlockInfo[] blocks;
	return new Document(parseDietWithExtensions(parsed_files, 0, blocks, null));
}

unittest { // test basic functionality
	Location ln(int l) { return Location("string", l); }

	// simple node
	assert(parseDiet("test").nodes == [
		new Node(ln(0), "test")
	]);

	// nested nodes
	assert(parseDiet("foo\n  bar").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.tag(new Node(ln(1), "bar"))
		])
	]);

	// node with id and classes
	assert(parseDiet("test#id.cls1.cls2").nodes == [
		new Node(ln(0), "test", [
			Attribute(ln(0), "id", [AttributeContent.text("id")]),
			Attribute(ln(0), "class", [AttributeContent.text("cls1")]),
			Attribute(ln(0), "class", [AttributeContent.text("cls2")])
		])
	]);
	assert(parseDiet("test.cls1#id.cls2").nodes == [ // issue #9
		new Node(ln(0), "test", [
			Attribute(ln(0), "class", [AttributeContent.text("cls1")]),
			Attribute(ln(0), "id", [AttributeContent.text("id")]),
			Attribute(ln(0), "class", [AttributeContent.text("cls2")])
		])
	]);

	// empty tag name (only class)
	assert(parseDiet(".foo").nodes == [
		new Node(ln(0), "", [
			Attribute(ln(0), "class", [AttributeContent.text("foo")])
		])
	]);
	assert(parseDiet("a.download-button\n\t.bs-hbtn.right.black").nodes == [
		new Node(ln(0), "a", [
			Attribute(ln(0), "class", [AttributeContent.text("download-button")]),
		], [
			NodeContent.tag(new Node(ln(1), "", [
				Attribute(ln(1), "class", [AttributeContent.text("bs-hbtn")]),
				Attribute(ln(1), "class", [AttributeContent.text("right")]),
				Attribute(ln(1), "class", [AttributeContent.text("black")])
			]))
		])
	]);

	// empty tag name (only id)
	assert(parseDiet("#foo").nodes == [
		new Node(ln(0), "", [
			Attribute(ln(0), "id", [AttributeContent.text("foo")])
		])
	]);

	// node with attributes
	assert(parseDiet("test(foo1=\"bar\", foo2=2+3)").nodes == [
		new Node(ln(0), "test", [
			Attribute(ln(0), "foo1", [AttributeContent.text("bar")]),
			Attribute(ln(0), "foo2", [AttributeContent.interpolation("2+3")])
		])
	]);

	// node with pure text contents
	assert(parseDiet("foo.\n\thello\n\t   world").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.text("hello", ln(1)),
			NodeContent.text("\n   world", ln(2))
		], NodeAttribs.textNode)
	]);
	assert(parseDiet("foo.\n\thello\n\n\t   world").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.text("hello", ln(1)),
			NodeContent.text("\n", ln(2)),
			NodeContent.text("\n   world", ln(3))
		], NodeAttribs.textNode)
	]);

	// translated text
	assert(parseDiet("foo& test").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.text("test", ln(0))
		], NodeAttribs.translated)
	]);

	// interpolated text
	assert(parseDiet("foo hello #{\"world\"} #bar \\#{baz}").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.text("hello ", ln(0)),
			NodeContent.interpolation(`"world"`, ln(0)),
			NodeContent.text(" #bar #{baz}", ln(0))
		])
	]);

	// expression
	assert(parseDiet("foo= 1+2").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.interpolation(`1+2`, ln(0)),
		])
	]);

	// expression with empty tag name
	assert(parseDiet("= 1+2").nodes == [
		new Node(ln(0), "", null, [
			NodeContent.interpolation(`1+2`, ln(0)),
		])
	]);

	// raw expression
	assert(parseDiet("foo!= 1+2").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.rawInterpolation(`1+2`, ln(0)),
		])
	]);

	// interpolated attribute text
	assert(parseDiet("foo(att='hello #{\"world\"} #bar')").nodes == [
		new Node(ln(0), "foo", [
			Attribute(ln(0), "att", [
				AttributeContent.text("hello "),
				AttributeContent.interpolation(`"world"`),
				AttributeContent.text(" #bar")
			])
		])
	]);

	// attribute expression
	assert(parseDiet("foo(att=1+2)").nodes == [
		new Node(ln(0), "foo", [
			Attribute(ln(0), "att", [
				AttributeContent.interpolation(`1+2`),
			])
		])
	]);

	// special nodes
	assert(parseDiet("//comment").nodes == [
		new Node(ln(0), Node.SpecialName.comment, null, [NodeContent.text("comment", ln(0))], NodeAttribs.rawTextNode)
	]);
	assert(parseDiet("//-hide").nodes == [
		new Node(ln(0), Node.SpecialName.hidden, null, [NodeContent.text("hide", ln(0))], NodeAttribs.rawTextNode)
	]);
	assert(parseDiet("!!! 5").nodes == [
		new Node(ln(0), "doctype", null, [NodeContent.text("5", ln(0))])
	]);
	assert(parseDiet("<inline>").nodes == [
		new Node(ln(0), Node.SpecialName.text, null, [NodeContent.text("<inline>", ln(0))])
	]);
	assert(parseDiet("|text").nodes == [
		new Node(ln(0), Node.SpecialName.text, null, [NodeContent.text("text", ln(0))])
	]);
	assert(parseDiet("|text\n").nodes == [
		new Node(ln(0), Node.SpecialName.text, null, [NodeContent.text("text", ln(0))])
	]);
	assert(parseDiet("| text\n").nodes == [
		new Node(ln(0), Node.SpecialName.text, null, [NodeContent.text("text", ln(0))])
	]);
	assert(parseDiet("|.").nodes == [
		new Node(ln(0), Node.SpecialName.text, null, [NodeContent.text(".", ln(0))])
	]);
	assert(parseDiet("|:").nodes == [
		new Node(ln(0), Node.SpecialName.text, null, [NodeContent.text(":", ln(0))])
	]);
	assert(parseDiet("|&x").nodes == [
		new Node(ln(0), Node.SpecialName.text, null, [NodeContent.text("x", ln(0))], NodeAttribs.translated)
	]);
	assert(parseDiet("-if(x)").nodes == [
		new Node(ln(0), Node.SpecialName.code, null, [NodeContent.text("if(x)", ln(0))])
	]);
	assert(parseDiet("-if(x)\n\t|bar").nodes == [
		new Node(ln(0), Node.SpecialName.code, null, [
			NodeContent.text("if(x)", ln(0)),
			NodeContent.tag(new Node(ln(1), Node.SpecialName.text, null, [
				NodeContent.text("bar", ln(1))
			]))
		])
	]);
	assert(parseDiet(":foo\n\tbar").nodes == [
		new Node(ln(0), ":", [Attribute(ln(0), "filterChain", [AttributeContent.text("foo")])], [
			NodeContent.text("bar", ln(1))
		], NodeAttribs.textNode)
	]);
	assert(parseDiet(":foo :bar baz").nodes == [
		new Node(ln(0), ":", [Attribute(ln(0), "filterChain", [AttributeContent.text("foo bar")])], [
			NodeContent.text("baz", ln(0))
		], NodeAttribs.textNode)
	]);
	assert(parseDiet(":foo\n\t:bar baz").nodes == [
		new Node(ln(0), ":", [Attribute(ln(0), "filterChain", [AttributeContent.text("foo")])], [
			NodeContent.text(":bar baz", ln(1))
		], NodeAttribs.textNode)
	]);
	assert(parseDiet(":foo\n\tbar\n\t\t:baz").nodes == [
		new Node(ln(0), ":", [Attribute(ln(0), "filterChain", [AttributeContent.text("foo")])], [
			NodeContent.text("bar", ln(1)),
			NodeContent.text("\n\t:baz", ln(2))
		], NodeAttribs.textNode)
	]);

	// nested nodes
	assert(parseDiet("a: b").nodes == [
		new Node(ln(0), "a", null, [
			NodeContent.tag(new Node(ln(0), "b"))
		])
	]);

	assert(parseDiet("a: b\n\tc\nd").nodes == [
		new Node(ln(0), "a", null, [
			NodeContent.tag(new Node(ln(0), "b", null, [
				NodeContent.tag(new Node(ln(1), "c"))
			]))
		]),
		new Node(ln(2), "d")
	]);

	// inline nodes
	assert(parseDiet("a #[b]").nodes == [
		new Node(ln(0), "a", null, [
			NodeContent.tag(new Node(ln(0), "b"))
		])
	]);
	assert(parseDiet("a #[b #[c d]]").nodes == [
		new Node(ln(0), "a", null, [
			NodeContent.tag(new Node(ln(0), "b", null, [
				NodeContent.tag(new Node(ln(0), "c", null, [
					NodeContent.text("d", ln(0))
				]))
			]))
		])
	]);

	// whitespace fitting
	assert(parseDiet("a<>").nodes == [
		new Node(ln(0), "a", null, [], NodeAttribs.fitInside|NodeAttribs.fitOutside)
	]);
	assert(parseDiet("a><").nodes == [
		new Node(ln(0), "a", null, [], NodeAttribs.fitInside|NodeAttribs.fitOutside)
	]);
	assert(parseDiet("a<").nodes == [
		new Node(ln(0), "a", null, [], NodeAttribs.fitInside)
	]);
	assert(parseDiet("a>").nodes == [
		new Node(ln(0), "a", null, [], NodeAttribs.fitOutside)
	]);
}

unittest {
	Location ln(int l) { return Location("string", l); }

	// angular2 html attributes tests
	assert(parseDiet("div([value]=\"firstName\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "[value]", [
				AttributeContent.text("firstName"),
			])
		])
	]);

	assert(parseDiet("div([attr.role]=\"myRole\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "[attr.role]", [
				AttributeContent.text("myRole"),
			])
		])
	]);

	assert(parseDiet("div([attr.role]=\"{foo:myRole}\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "[attr.role]", [
				AttributeContent.text("{foo:myRole}"),
			])
		])
	]);

	assert(parseDiet("div([attr.role]=\"{foo:myRole, bar:MyRole}\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "[attr.role]", [
				AttributeContent.text("{foo:myRole, bar:MyRole}")
			])
		])
	]);

	assert(parseDiet("div((attr.role)=\"{foo:myRole, bar:MyRole}\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "(attr.role)", [
				AttributeContent.text("{foo:myRole, bar:MyRole}")
			])
		])
	]);

	assert(parseDiet("div([class.extra-sparkle]=\"isDelightful\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "[class.extra-sparkle]", [
				AttributeContent.text("isDelightful")
			])
		])
	]);

	auto t = parseDiet("div((click)=\"readRainbow($event)\")");
	assert(t.nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "(click)", [
				AttributeContent.text("readRainbow($event)")
			])
		])
	]);

	assert(parseDiet("div([(title)]=\"name\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "[(title)]", [
				AttributeContent.text("name")
			])
		])
	]);

	assert(parseDiet("div(*myUnless=\"myExpression\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "*myUnless", [
				AttributeContent.text("myExpression")
			])
		])
	]);

	assert(parseDiet("div([ngClass]=\"{active: isActive, disabled: isDisabled}\")").nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "[ngClass]", [
				AttributeContent.text("{active: isActive, disabled: isDisabled}")
			])
		])
	]);

	t = parseDiet("div(*ngFor=\"\\#item of list\")");
	assert(t.nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "*ngFor", [
				AttributeContent.text("#"),
				AttributeContent.text("item of list")
			])
		])
	]);

	t = parseDiet("div(({*ngFor})=\"{args:\\#item of list}\")");
	assert(t.nodes == [
		new Node(ln(0), "div", [
			Attribute(ln(0), "({*ngFor})", [
				AttributeContent.text("{args:"),
				AttributeContent.text("#"),
				AttributeContent.text("item of list}")
			])
		])
	]);
}

unittest { // translation
	import std.string : toUpper;

	static Location ln(int l) { return Location("string", l); }

	static string tr(string str) { return "("~toUpper(str)~")"; }

	assert(parseDiet!tr("foo& test").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.text("(TEST)", ln(0))
		], NodeAttribs.translated)
	]);

	assert(parseDiet!tr("foo& test #{x} it").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.text("(TEST ", ln(0)),
			NodeContent.interpolation("X", ln(0)),
			NodeContent.text(" IT)", ln(0)),
		], NodeAttribs.translated)
	]);

	assert(parseDiet!tr("|&x").nodes == [
		new Node(ln(0), Node.SpecialName.text, null, [NodeContent.text("(X)", ln(0))], NodeAttribs.translated)
	]);

	assert(parseDiet!tr("foo&.\n\tbar\n\tbaz").nodes == [
		new Node(ln(0), "foo", null, [
			NodeContent.text("(BAR)", ln(1)),
			NodeContent.text("\n(BAZ)", ln(2))
		], NodeAttribs.translated|NodeAttribs.textNode)
	]);
}

unittest { // test expected errors
	void testFail(string diet, string msg)
	{
		try {
			parseDiet(diet);
			assert(false, "Expected exception was not thrown.");
		} catch (DietParserException ex) assert(ex.msg == msg, "Unexpected error message: "~ex.msg);
	}

	testFail("+test", "Expected node text separated by a space character or end of line, but got '+test'.");
	testFail("  test", "First node must not be indented.");
	testFail("test\n  test\n\ttest", "Mismatched indentation style.");
	testFail("test\n\ttest\n\t\t\ttest", "Line is indented too deeply.");
	testFail("test#", "Expected identifier but got nothing.");
	testFail("test.()", "Expected identifier but got '('.");
	testFail("a #[b.]", "Multi-line text nodes are not permitted for inline-tags.");
	testFail("a #[b: c]", "Nested inline-tags not allowed.");
	testFail("a#foo#bar", "Only one \"id\" definition using '#' is allowed.");
}

unittest { // includes
	Node[] parse(string diet) {
		auto files = [
			InputFile("main.dt", diet),
			InputFile("inc.dt", "p")
		];
		return parseDiet(files).nodes;
	}

	void testFail(string diet, string msg)
	{
		try {
			parse(diet);
			assert(false, "Expected exception was not thrown");
		} catch (DietParserException ex) {
			assert(ex.msg == msg, "Unexpected error message: "~ex.msg);
		}
	}

	assert(parse("include inc") == [
		new Node(Location("inc.dt", 0), "p", null, null)
	]);
	testFail("include main", "Dependency cycle detected for this module.");
	testFail("include inc2", "Missing include input file: inc2");
	testFail("include #{p}", "Dynamic includes are not supported.");
	testFail("include inc\n\tp", "Includes cannot have children.");
	testFail("p\ninclude inc\n\tp", "Includes cannot have children.");
}

unittest { // extensions
	Node[] parse(string diet) {
		auto files = [
			InputFile("main.dt", diet),
			InputFile("root.dt", "html\n\tblock a\n\tblock b"),
			InputFile("intermediate.dt", "extends root\nblock a\n\tp"),
			InputFile("direct.dt", "block a")
		];
		return parseDiet(files).nodes;
	}

	void testFail(string diet, string msg)
	{
		try {
			parse(diet);
			assert(false, "Expected exception was not thrown");
		} catch (DietParserException ex) {
			assert(ex.msg == msg, "Unexpected error message: "~ex.msg);
		}
	}

	assert(parse("extends root") == [
		new Node(Location("root.dt", 0), "html", null, null)
	]);
	assert(parse("extends root\nblock a\n\tdiv\nblock b\n\tpre") == [
		new Node(Location("root.dt", 0), "html", null, [
			NodeContent.tag(new Node(Location("main.dt", 2), "div", null, null)),
			NodeContent.tag(new Node(Location("main.dt", 4), "pre", null, null))
		])
	]);
	assert(parse("extends intermediate\nblock b\n\tpre") == [
		new Node(Location("root.dt", 0), "html", null, [
			NodeContent.tag(new Node(Location("intermediate.dt", 2), "p", null, null)),
			NodeContent.tag(new Node(Location("main.dt", 2), "pre", null, null))
		])
	]);
	assert(parse("extends intermediate\nblock a\n\tpre") == [
		new Node(Location("root.dt", 0), "html", null, [
			NodeContent.tag(new Node(Location("main.dt", 2), "pre", null, null))
		])
	]);
	assert(parse("extends intermediate\nappend a\n\tpre") == [
		new Node(Location("root.dt", 0), "html", null, [
			NodeContent.tag(new Node(Location("intermediate.dt", 2), "p", null, null)),
			NodeContent.tag(new Node(Location("main.dt", 2), "pre", null, null))
		])
	]);
	assert(parse("extends intermediate\nprepend a\n\tpre") == [
		new Node(Location("root.dt", 0), "html", null, [
			NodeContent.tag(new Node(Location("main.dt", 2), "pre", null, null)),
			NodeContent.tag(new Node(Location("intermediate.dt", 2), "p", null, null))
		])
	]);
	assert(parse("extends intermediate\nprepend a\n\tfoo\nappend a\n\tbar") == [ // issue #13
		new Node(Location("root.dt", 0), "html", null, [
			NodeContent.tag(new Node(Location("main.dt", 2), "foo", null, null)),
			NodeContent.tag(new Node(Location("intermediate.dt", 2), "p", null, null)),
			NodeContent.tag(new Node(Location("main.dt", 4), "bar", null, null))
		])
	]);
	assert(parse("extends intermediate\nprepend a\n\tfoo\nprepend a\n\tbar\nappend a\n\tbaz\nappend a\n\tbam") == [
		new Node(Location("root.dt", 0), "html", null, [
			NodeContent.tag(new Node(Location("main.dt", 2), "foo", null, null)),
			NodeContent.tag(new Node(Location("main.dt", 4), "bar", null, null)),
			NodeContent.tag(new Node(Location("intermediate.dt", 2), "p", null, null)),
			NodeContent.tag(new Node(Location("main.dt", 6), "baz", null, null)),
			NodeContent.tag(new Node(Location("main.dt", 8), "bam", null, null))
		])
	]);
	assert(parse("extends direct") == []);
	assert(parse("extends direct\nblock a\n\tp") == [
		new Node(Location("main.dt", 2), "p", null, null)
	]);
}

unittest { // test CTFE-ability
	static const result = parseDiet("foo#id.cls(att=\"val\", att2=1+3, att3='test#{4}it')\n\tbar");
	static assert(result.nodes.length == 1);
}

unittest { // regression tests
	Location ln(int l) { return Location("string", l); }

	// last line contains only whitespace
	assert(parseDiet("test\n\t").nodes == [
		new Node(ln(0), "test")
	]);
}

unittest { // issue #14 - blocks in includes
	auto files = [
		InputFile("main.dt", "extends layout\nblock nav\n\tbaz"),
		InputFile("layout.dt", "foo\ninclude inc"),
		InputFile("inc.dt", "bar\nblock nav"),
	];
	assert(parseDiet(files).nodes == [
		new Node(Location("layout.dt", 0), "foo", null, null),
		new Node(Location("inc.dt", 0), "bar", null, null),
		new Node(Location("main.dt", 2), "baz", null, null)
	]);
}


/** Dummy translation function that returns the input unmodified.
*/
string identity(string str) nothrow @safe @nogc { return str; }


private string parseIdent(in ref string str, ref size_t start,
	   	string breakChars, in ref Location loc)
{
	import std.array : back;
	/* The stack is used to keep track of opening and
	closing character pairs, so that when we hit a break char of
	breakChars we know if we can actually break parseIdent.
	*/
	char[] stack;
	size_t i = start;
	outer: while(i < str.length) {
		if(stack.length == 0) {
			foreach(char it; breakChars) {
				if(str[i] == it) {
					break outer;
				}
			}
		}

		if(stack.length && stack.back == str[i]) {
			stack = stack[0 .. $ - 1];
		} else if(str[i] == '"') {
			stack ~= '"';
		} else if(str[i] == '(') {
			stack ~= ')';
		} else if(str[i] == '[') {
			stack ~= ']';
		} else if(str[i] == '{') {
			stack ~= '}';
		}
		++i;
	}

	/* We could have consumed the complete string and still have elements
	on the stack or have ended non breakChars character.
	*/
	if(stack.length == 0) {
		foreach(char it; breakChars) {
			if(str[i] == it) {
				size_t startC = start;
				start = i;
				return str[startC .. i];
			}
		}
	}
	enforcep(false, "Identifier was not ended by any of these characters: "
		~ breakChars, loc);
	assert(false);
}

private Node[] parseDietWithExtensions(FileInfo[] files, size_t file_index, ref BlockInfo[] blocks, size_t[] import_stack)
{
	import std.algorithm : all, any, canFind, countUntil, filter, find, map;
	import std.array : array;
	import std.path : stripExtension;
	import std.typecons : Nullable;

	auto floc = Location(files[file_index].name, 0);
	enforcep(!import_stack.canFind(file_index), "Dependency cycle detected for this module.", floc);

	auto nodes = files[file_index].nodes;
	if (!nodes.length) return null;

	if (nodes[0].name == "extends") {
		// extract base template name/index
		enforcep(nodes[0].isTextNode, "'extends' cannot contain children or interpolations.", nodes[0].loc);
		enforcep(nodes[0].attributes.length == 0, "'extends' cannot have attributes.", nodes[0].loc);

		string base_template = nodes[0].contents[0].value.ctstrip;
		auto base_idx = files.countUntil!(f => matchesName(f.name, base_template, files[file_index].name));
		assert(base_idx >= 0, "Missing base template: "~base_template);

		// collect all blocks
		foreach (n; nodes[1 .. $]) {
			BlockInfo.Mode mode;
			switch (n.name) {
				default:
					enforcep(false, "Extension templates may only contain blocks definitions at the root level.", n.loc);
					break;
				case Node.SpecialName.comment, Node.SpecialName.hidden: continue; // also allow comments at the root level
				case "block": mode = BlockInfo.Mode.replace; break;
				case "prepend": mode = BlockInfo.Mode.prepend; break;
				case "append": mode = BlockInfo.Mode.append; break;
			}
			enforcep(n.contents.length > 0 && n.contents[0].kind == NodeContent.Kind.text,
				"'block' must have a name.", n.loc);
			auto name = n.contents[0].value.ctstrip;
			auto contents = n.contents[1 .. $].filter!(n => n.kind == NodeContent.Kind.node).map!(n => n.node).array;
			blocks ~= BlockInfo(name, mode, contents);
		}

		// parse base template
		return parseDietWithExtensions(files, base_idx, blocks, import_stack ~ file_index);
	}

	static string extractFilename(Node n)
	{
		enforcep(n.contents.length >= 1 && n.contents[0].kind != NodeContent.Kind.node,
			"Missing block name.", n.loc);
		enforcep(n.contents[0].kind == NodeContent.Kind.text,
			"Dynamic includes are not supported.", n.loc);
		enforcep(n.contents.length == 1 || n.contents[1 .. $].all!(nc => nc.kind == NodeContent.Kind.node),
			"'"~n.name~"' must only contain a block name and child nodes.", n.loc);
		enforcep(n.attributes.length == 0, "'"~n.name~"' cannot have attributes.", n.loc);
		return n.contents[0].value.ctstrip;
	}

	Nullable!(Node[]) processNode(Node n) {
		Nullable!(Node[]) ret;

		void insert(Node[] nodes) {
			foreach (i, n; nodes) {
				auto np = processNode(n);
				if (!np.isNull()) {
					if (ret.isNull) ret = nodes[0 .. i];
					ret ~= np;
				} else if (!ret.isNull) ret ~= n;
			}
			if (ret.isNull && nodes.length) ret = nodes;
		}

		if (n.name == "block") {
			auto name = extractFilename(n);
			auto blockdefs = blocks.filter!(b => b.name == name);

			foreach (b; blockdefs.save.filter!(b => b.mode == BlockInfo.Mode.prepend))
				insert(b.contents);

			auto replblocks = blockdefs.save.find!(b => b.mode == BlockInfo.Mode.replace);
			if (!replblocks.empty) {
				insert(replblocks.front.contents);
			} else {
				insert(n.contents[1 .. $].map!((nc) {
					assert(nc.kind == NodeContent.Kind.node, "Block contains non-node child!?");
					return nc.node;
				}).array);
			}

			foreach (b; blockdefs.save.filter!(b => b.mode == BlockInfo.Mode.append))
				insert(b.contents);

			if (ret.isNull) ret = [];
		} else if (n.name == "include") {
			auto name = extractFilename(n);
			enforcep(n.contents.length == 1, "Includes cannot have children.", n.loc);
			auto fidx = files.countUntil!(f => matchesName(f.name, name, files[file_index].name));
			enforcep(fidx >= 0, "Missing include input file: "~name, n.loc);
			insert(parseDietWithExtensions(files, fidx, blocks, import_stack ~ file_index));
		} else {
			n.contents.modifyArray!((nc) {
				Nullable!(NodeContent[]) rn;
				if (nc.kind == NodeContent.Kind.node) {
					auto mod = processNode(nc.node);
					if (!mod.isNull()) rn = mod.map!(n => NodeContent.tag(n)).array;
				}
				assert(rn.isNull || rn.get.all!(n => n.node.name != "block"));
				return rn;
			});
		}

		assert(ret.isNull || ret.get.all!(n => n.name != "block"));

		return ret;
	}

	nodes.modifyArray!(processNode);

	assert(nodes.all!(n => n.name != "block"));

	return nodes;
}

private struct BlockInfo {
	enum Mode {
		prepend,
		replace,
		append
	}
	string name;
	Mode mode = Mode.replace;
	Node[] contents;
}

private struct FileInfo {
	string name;
	Node[] nodes;
}


/** Parses a single Diet template file, without resolving includes and extensions.

	See_Also: `parseDiet`
*/
Node[] parseDietRaw(alias TR)(InputFile file)
{
	import std.algorithm.iteration : map;
	import std.algorithm.comparison : among;
	import std.array : array;

	string indent_style;
	auto loc = Location(file.name, 0);
	int prevlevel = -1;
	string input = file.contents;
	Node[] ret;
	// nested stack of nodes
	// the first dimension is corresponds to indentation based nesting
	// the second dimension is for in-line nested nodes
	Node[][] stack;
	stack.length = 8;
	string previndent; // inherited by blank lines

	next_line:
	while (input.length) {
		Node pnode;
		if (prevlevel >= 0 && stack[prevlevel].length) pnode = stack[prevlevel][$-1];

		// skip whitespace at the beginning of the line
		string indent = input.skipIndent();

		// treat empty lines as if they had the indendation level of the last non-empty line
		if (input.empty || input[0].among('\n', '\r'))
			indent = previndent;
		else previndent = indent;

		enforcep(prevlevel >= 0 || indent.length == 0, "First node must not be indented.", loc);

		// determine the indentation style (tabs/spaces) from the first indented
		// line of the file
		if (indent.length && !indent_style.length) indent_style = indent;

		// determine nesting level
		bool is_text_line = pnode && (pnode.attribs & (NodeAttribs.textNode|NodeAttribs.rawTextNode)) != 0;
		int level = 0;
		if (indent_style.length) {
			while (indent.startsWith(indent_style)) {
				if (level > prevlevel) {
					enforcep(is_text_line, "Line is indented too deeply.", loc);
					break;
				}
				level++;
				indent = indent[indent_style.length .. $];
			}
		}

		enforcep(is_text_line || indent.length == 0, "Mismatched indentation style.", loc);

		// read the whole line as text if the parent node is a pure text node
		// ("." suffix) or pure raw text node (e.g. comments)
		if (level > prevlevel && prevlevel >= 0) {
			if (pnode.attribs & NodeAttribs.textNode) {
				if (!pnode.contents.empty)
					pnode.addText("\n", loc);
				if (indent.length) pnode.addText(indent, loc);
				if (pnode.attribs & NodeAttribs.translated) {
					size_t idx;
					Location loccopy = loc;
					auto ln = TR(skipLine(input, idx, loc));
					input = input[idx .. $];
					parseTextLine(ln, pnode, loccopy);
				} else parseTextLine(input, pnode, loc);
				continue;
			} else if (pnode.attribs & NodeAttribs.rawTextNode) {
				if (!pnode.contents.empty)
					pnode.addText("\n", loc);
				if (indent.length) pnode.addText(indent, loc);
				auto tmploc = loc;
				pnode.addText(skipLine(input, loc), tmploc);
				continue;
			}
		}

		// skip empty lines
		if (input.empty) break;
		else if (input[0] == '\n') { loc.line++; input.popFront(); continue; }
		else if (input[0] == '\r') {
			loc.line++;
			input.popFront();
			if (!input.empty && input[0] == '\n')
				input.popFront();
			continue;
		}

		// parse the line and write it to the stack:

		if (stack.length < level+1) stack.length = level+1;

		if (input.startsWith("//")) {
			// comments
			auto n = new Node;
			n.loc = loc;
			if (input[2 .. $].startsWith("-")) { n.name = Node.SpecialName.hidden; input = input[3 .. $]; }
			else { n.name = Node.SpecialName.comment; input = input[2 .. $]; }
			n.attribs |= NodeAttribs.rawTextNode;
			auto tmploc = loc;
			n.addText(skipLine(input, loc), tmploc);
			stack[level] = [n];
		} else if (input.startsWith('-')) {
			// D statements
			input = input[1 .. $];
			auto n = new Node;
			n.loc = loc;
			n.name = Node.SpecialName.code;
			auto tmploc = loc;
			n.addText(skipLine(input, loc), tmploc);
			stack[level] = [n];
		} else if (input.startsWith(':')) {
			// filters
			stack[level] = [];


			string chain;

			do {
				input = input[1 .. $];
				size_t idx = 0;
				if (chain.length) chain ~= ' ';
				chain ~= skipIdent(input, idx, "-_", loc);
				input = input[idx .. $];
				if (input.startsWith(' ')) input = input[1 .. $];
			} while (input.startsWith(':'));

			Node chn = new Node;
			chn.loc = loc;
			chn.name = Node.SpecialName.filter;
			chn.attribs = NodeAttribs.textNode;
			chn.attributes = [Attribute(loc, "filterChain", [AttributeContent.text(chain)])];
			stack[level] ~= chn;

			/*auto tmploc = loc;
			auto trailing = skipLine(input, loc);
			if (trailing.length) parseTextLine(input, chn, tmploc);*/
			parseTextLine(input, chn, loc);
		} else {
			// normal tag line
			bool has_nested;
			stack[level] = null;
			do stack[level] ~= parseTagLine!TR(input, loc, has_nested);
			while (has_nested);
		}

		// add it to its parent contents
		foreach (i; 1 .. stack[level].length)
			stack[level][i-1].contents ~= NodeContent.tag(stack[level][i]);
		if (level > 0) stack[level-1][$-1].contents ~= NodeContent.tag(stack[level][0]);
		else ret ~= stack[0][0];

		// remember the nesting level for the next line
		prevlevel = level;
	}

	return ret;
}

private Node parseTagLine(alias TR)(ref string input, ref Location loc, out bool has_nested)
{
	size_t idx = 0;

	auto ret = new Node;
	ret.loc = loc;

	if (input.startsWith("!!! ")) { // legacy doctype support
		input = input[4 .. $];
		ret.name = "doctype";
		parseTextLine(input, ret, loc);
		return ret;
	}

	if (input.startsWith('<')) { // inline HTML/XML
		ret.name = Node.SpecialName.text;
		parseTextLine(input, ret, loc);
		return ret;
	}

	if (input.startsWith('|')) { // text line
		input = input[1 .. $];
		ret.name = Node.SpecialName.text;
		if (idx < input.length && input[idx] == '&') { ret.attribs |= NodeAttribs.translated; idx++; }
	} else { // normal tag
		if (parseTag(input, idx, ret, has_nested, loc))
			return ret;
	}

	if (idx+1 < input.length && input[idx .. idx+2] == "!=") {
		enforcep(!(ret.attribs & NodeAttribs.translated), "Compile-time translation is not supported for (raw) assignments.", ret.loc);
		idx += 2;
		auto l = loc;
		ret.contents ~= NodeContent.rawInterpolation(ctstrip(skipLine(input, idx, loc)), l);
		input = input[idx .. $];
	} else if (idx < input.length && input[idx] == '=') {
		enforcep(!(ret.attribs & NodeAttribs.translated), "Compile-time translation is not supported for assignments.", ret.loc);
		idx++;
		auto l = loc;
		ret.contents ~= NodeContent.interpolation(ctstrip(skipLine(input, idx, loc)), l);
		input = input[idx .. $];
	} else {
		auto tmploc = loc;
		auto remainder = skipLine(input, idx, loc);
		input = input[idx .. $];

		if (remainder.length && remainder[0] == ' ') {
			// parse the rest of the line as text contents (if any non-ws)
			remainder = remainder[1 .. $];
			if (ret.attribs & NodeAttribs.translated)
				remainder = TR(remainder);
			parseTextLine(remainder, ret, tmploc);
		} else if (ret.name == Node.SpecialName.text) {
			// allow omitting the whitespace for "|" text nodes
			if (ret.attribs & NodeAttribs.translated)
				remainder = TR(remainder);
			parseTextLine(remainder, ret, tmploc);
		} else {
			import std.string : strip;
			enforcep(remainder.strip().length == 0,
				"Expected node text separated by a space character or end of line, but got '"~remainder~"'.", loc);
		}
	}

	return ret;
}

private bool parseTag(ref string input, ref size_t idx, ref Node dst, ref bool has_nested, ref Location loc)
{
	import std.ascii : isWhite;

	dst.name = skipIdent(input, idx, ":-_", loc, true);
	
	// a trailing ':' is not part of the tag name, but signals a nested node
	if (dst.name.endsWith(":")) {
		dst.name = dst.name[0 .. $-1];
		idx--;
	}

	bool have_id = false;
	while (idx < input.length) {
		if (input[idx] == '#') {
		 	// node ID
			idx++;
			auto value = skipIdent(input, idx, "-_", loc);
			enforcep(value.length > 0, "Expected id.", loc);
			enforcep(!have_id, "Only one \"id\" definition using '#' is allowed.", loc);
			have_id = true;
			dst.attributes ~= Attribute(loc, "id", [AttributeContent(AttributeContent.Kind.text, value)]);
		} else if (input[idx] == '.') {
			// node classes
			if (idx+1 >= input.length || input[idx+1].isWhite)
				goto textBlock;
			idx++;
			auto value = skipIdent(input, idx, "-_", loc);
			enforcep(value.length > 0, "Expected class name identifier.", loc);
			dst.attributes ~= Attribute(loc, "class", [AttributeContent(AttributeContent.Kind.text, value)]);
		} else break;
	}

	// generic attributes
	if (idx < input.length && input[idx] == '(')
		parseAttributes(input, idx, dst, loc);

	// avoid whitespace inside of tag
	if (idx < input.length && input[idx] == '<') {
		idx++;
		dst.attribs |= NodeAttribs.fitInside;
	}

	// avoid whitespace outside of tag
	if (idx < input.length && input[idx] == '>') {
		idx++;
		dst.attribs |= NodeAttribs.fitOutside;
	}

	// avoid whitespace inside of tag (also allowed after >)
	if (!(dst.attribs & NodeAttribs.fitInside) && idx < input.length && input[idx] == '<') {
		idx++;
		dst.attribs |= NodeAttribs.fitInside;
	}

	// translate text contents
	if (idx < input.length && input[idx] == '&') {
		idx++;
		dst.attribs |= NodeAttribs.translated;
	}

	// treat nested lines as text
	if (idx < input.length && input[idx] == '.') {
		textBlock:
		dst.attribs |= NodeAttribs.textNode;
		idx++;
		skipLine(input, idx, loc); // ignore the rest of the line
		input = input[idx .. $];
		return true;
	}

	// another nested tag on the same line
	if (idx < input.length && input[idx] == ':') {
		idx++;

		// skip trailing whitespace (but no line breaks)
		while (idx < input.length && (input[idx] == ' ' || input[idx] == '\t'))
			idx++;

		// see if we got anything left on the line
		if (idx < input.length) {
			if (input[idx] == '\n' || input[idx] == '\r') {
				// FIXME: should we rather error out here?
				skipLine(input, idx, loc);
			} else {
				// leaves the rest of the line to parse another tag
				has_nested = true;
			}
		}
		input = input[idx .. $];
		return true;
	}

	return false;
}

/**
	Parses a single line of text (possibly containing interpolations and inline tags).

	If there a a newline at the end, it will be appended to the contents of the
	destination node.
*/
private void parseTextLine(ref string input, ref Node dst, ref Location loc)
{
	import std.algorithm.comparison : among;

	size_t sidx = 0, idx = 0;

	void flushText()
	{
		if (idx > sidx) dst.addText(input[sidx .. idx], loc);
	}

	while (idx < input.length) {
		char cur = input[idx];
		switch (cur) {
			default: idx++; break;
			case '\\':
				if (idx+1 < input.length && input[idx+1].among('#', '!')) {
					flushText();
					sidx = idx+1;
					idx += 2;
				} else idx++;
				break;
			case '!', '#':
				if (idx+1 < input.length && input[idx+1] == '{') {
					flushText();
					idx += 2;
					auto expr = skipUntilClosingBrace(input, idx, loc);
					idx++;
					if (cur == '#') dst.contents ~= NodeContent.interpolation(expr, loc);
					else dst.contents ~= NodeContent.rawInterpolation(expr, loc);
					sidx = idx;
				} else if (cur == '#' && idx+1 < input.length && input[idx+1] == '[') {
					flushText();
					idx += 2;
					auto tag = skipUntilClosingBracket(input, idx, loc);
					idx++;
					bool has_nested;
					auto itag = parseTagLine!identity(tag, loc, has_nested);
					enforcep(!(itag.attribs & (NodeAttribs.textNode|NodeAttribs.rawTextNode)),
						"Multi-line text nodes are not permitted for inline-tags.", loc);
					enforcep(!(itag.attribs & NodeAttribs.translated),
						"Inline-tags cannot be translated individually.", loc);
					enforcep(!has_nested, "Nested inline-tags not allowed.", loc);
					dst.contents ~= NodeContent.tag(itag);
					sidx = idx;
				} else idx++;
				break;
			case '\r':
				flushText();
				idx++;
				if (idx < input.length && input[idx] == '\n') idx++;
				input = input[idx .. $];
				loc.line++;
				return;
			case '\n':
				flushText();
				idx++;
				input = input[idx .. $];
				loc.line++;
				return;
		}
	}

	flushText();
	assert(idx == input.length);
	input = null;
}

private string skipLine(ref string input, ref size_t idx, ref Location loc)
{
	auto sidx = idx;

	while (idx < input.length) {
		char cur = input[idx];
		switch (cur) {
			default: idx++; break;
			case '\r':
				auto ret = input[sidx .. idx];
				idx++;
				if (idx < input.length && input[idx] == '\n') idx++;
				loc.line++;
				return ret;
			case '\n':
				auto ret = input[sidx .. idx];
				idx++;
				loc.line++;
				return ret;
		}
	}

	return input[sidx .. $];
}

private string skipLine(ref string input, ref Location loc)
{
	size_t idx = 0;
	auto ret = skipLine(input, idx, loc);
	input = input[idx .. $];
	return ret;
}

private void parseAttributes(ref string input, ref size_t i, ref Node node, in ref Location loc)
{
	assert(i < input.length && input[i] == '(');
	i++;

	skipWhitespace(input, i);
	while (i < input.length && input[i] != ')') {
		string name = parseIdent(input, i, ",)=", loc);
		string value;
		skipWhitespace(input, i);
		if( i < input.length && input[i] == '=' ){
			i++;
			skipWhitespace(input, i);
			enforcep(i < input.length, "'=' must be followed by attribute string.", loc);
			value = skipExpression(input, i, loc);
			assert(i <= input.length);
			if (isStringLiteral(value) && value[0] == '\'') {
				auto tmp = dstringUnescape(value[1 .. $-1]);
				value = '"' ~ dstringEscape(tmp) ~ '"';
			}
		} else value = "true";

		enforcep(i < input.length, "Unterminated attribute section.", loc);
		enforcep(input[i] == ')' || input[i] == ',', "Unexpected text following attribute: '"~input[0..i]~"' ('"~input[i..$]~"')", loc);
		if (input[i] == ',') {
			i++;
			skipWhitespace(input, i);
		}

		if (name == "class" && value == `""`) continue;

		if (isStringLiteral(value)) {
			AttributeContent[] content;
			parseAttributeText(value[1 .. $-1], content, loc);
			node.attributes ~= Attribute(loc, name, content);
		} else {
			node.attributes ~= Attribute(loc, name, [AttributeContent.interpolation(value)]);
		}
	}

	enforcep(i < input.length, "Missing closing clamp.", loc);
	i++;
}

private void parseAttributeText(string input, ref AttributeContent[] dst, in ref Location loc)
{
	size_t sidx = 0, idx = 0;

	void flushText()
	{
		if (idx > sidx) dst ~= AttributeContent.text(input[sidx .. idx]);
	}

	while (idx < input.length) {
		char cur = input[idx];
		switch (cur) {
			default: idx++; break;
			case '\\':
				flushText();
				dst ~= AttributeContent.text(dstringUnescape(sanitizeEscaping(input[idx .. idx+2])));
				idx += 2;
				sidx = idx;
				break;
			case '!', '#':
				if (idx+1 < input.length && input[idx+1] == '{') {
					flushText();
					idx += 2;
					auto expr = dstringUnescape(skipUntilClosingBrace(input, idx, loc));
					idx++;
					if (cur == '#') dst ~= AttributeContent.interpolation(expr);
					else dst ~= AttributeContent.rawInterpolation(expr);
					sidx = idx;
				} else idx++;
				break;
		}
	}

	flushText();
	input = input[idx .. $];
}

private string skipUntilClosingBrace(in ref string s, ref size_t idx, in ref Location loc)
{
	import std.algorithm.comparison : among;

	int level = 0;
	auto start = idx;
	while( idx < s.length ){
		if( s[idx] == '{' ) level++;
		else if( s[idx] == '}' ) level--;
		enforcep(!s[idx].among('\n', '\r'), "Missing '}' before end of line.", loc);
		if( level < 0 ) return s[start .. idx];
		idx++;
	}
	enforcep(false, "Missing closing brace", loc);
	assert(false);
}

private string skipUntilClosingBracket(in ref string s, ref size_t idx, in ref Location loc)
{
	import std.algorithm.comparison : among;

	int level = 0;
	auto start = idx;
	while( idx < s.length ){
		if( s[idx] == '[' ) level++;
		else if( s[idx] == ']' ) level--;
		enforcep(!s[idx].among('\n', '\r'), "Missing ']' before end of line.", loc);
		if( level < 0 ) return s[start .. idx];
		idx++;
	}
	enforcep(false, "Missing closing bracket", loc);
	assert(false);
}

private string skipIdent(in ref string s, ref size_t idx, string additional_chars, in ref Location loc, bool accept_empty = false)
{
	import std.ascii : isAlpha;

	size_t start = idx;
	while (idx < s.length) {
		if (isAlpha(s[idx])) idx++;
		else if (start != idx && s[idx] >= '0' && s[idx] <= '9') idx++;
		else {
			bool found = false;
			foreach (ch; additional_chars)
				if (s[idx] == ch) {
					found = true;
					idx++;
					break;
				}
			if (!found) {
				enforcep(accept_empty || start != idx, "Expected identifier but got '"~s[idx]~"'.", loc);
				return s[start .. idx];
			}
		}
	}
	enforcep(start != idx, "Expected identifier but got nothing.", loc);
	return s[start .. idx];
}

/// Skips all trailing spaces and tab characters of the input string.
private string skipIndent(ref string input)
{
	size_t idx = 0;
	while (idx < input.length && isIndentChar(input[idx]))
		idx++;
	auto ret = input[0 .. idx];
	input = input[idx .. $];
	return ret;
}

private bool isIndentChar(dchar ch) { return ch == ' ' || ch == '\t'; }

private string skipWhitespace(in ref string s, ref size_t idx)
{
	size_t start = idx;
	while (idx < s.length) {
		if (s[idx] == ' ') idx++;
		else break;
	}
	return s[start .. idx];
}

private bool isStringLiteral(string str)
{
	size_t i = 0;

	// skip leading white space
	while (i < str.length && (str[i] == ' ' || str[i] == '\t')) i++;

	// no string literal inside
	if (i >= str.length) return false;

	char delimiter = str[i++];
	if (delimiter != '"' && delimiter != '\'') return false;

	while (i < str.length && str[i] != delimiter) {
		if (str[i] == '\\') i++;
		i++;
	}

	// unterminated string literal
	if (i >= str.length) return false;

	i++; // skip delimiter

	// skip trailing white space
	while (i < str.length && (str[i] == ' ' || str[i] == '\t')) i++;

	// check if the string has ended with the closing delimiter
	return i == str.length;
}

unittest {
	assert(isStringLiteral(`""`));
	assert(isStringLiteral(`''`));
	assert(isStringLiteral(`"hello"`));
	assert(isStringLiteral(`'hello'`));
	assert(isStringLiteral(` 	"hello"	 `));
	assert(isStringLiteral(` 	'hello'	 `));
	assert(isStringLiteral(`"hel\"lo"`));
	assert(isStringLiteral(`"hel'lo"`));
	assert(isStringLiteral(`'hel\'lo'`));
	assert(isStringLiteral(`'hel"lo'`));
	assert(isStringLiteral(`'#{"address_"~item}'`));
	assert(!isStringLiteral(`"hello\`));
	assert(!isStringLiteral(`"hello\"`));
	assert(!isStringLiteral(`"hello\"`));
	assert(!isStringLiteral(`"hello'`));
	assert(!isStringLiteral(`'hello"`));
	assert(!isStringLiteral(`"hello""world"`));
	assert(!isStringLiteral(`"hello" "world"`));
	assert(!isStringLiteral(`"hello" world`));
	assert(!isStringLiteral(`'hello''world'`));
	assert(!isStringLiteral(`'hello' 'world'`));
	assert(!isStringLiteral(`'hello' world`));
	assert(!isStringLiteral(`"name" value="#{name}"`));
}

private string skipExpression(in ref string s, ref size_t idx, in ref Location loc)
{
	string clamp_stack;
	size_t start = idx;
	outer:
	while (idx < s.length) {
		switch (s[idx]) {
			default: break;
			case '\n', '\r':
				enforcep(false, "Unexpected end of line.", loc);
				break;
			case ',':
				if (clamp_stack.length == 0)
					break outer;
				break;
			case '"', '\'':
				idx++;
				skipAttribString(s, idx, s[idx-1], loc);
				break;
			case '(': clamp_stack ~= ')'; break;
			case '[': clamp_stack ~= ']'; break;
			case '{': clamp_stack ~= '}'; break;
			case ')', ']', '}':
				if (s[idx] == ')' && clamp_stack.length == 0)
					break outer;
				enforcep(clamp_stack.length > 0 && clamp_stack[$-1] == s[idx],
					"Unexpected '"~s[idx]~"'", loc);
				clamp_stack.length--;
				break;
		}
		idx++;
	}

	enforcep(clamp_stack.length == 0, "Expected '"~clamp_stack[$-1]~"' before end of attribute expression.", loc);
	return ctstrip(s[start .. idx]);
}

private string skipAttribString(in ref string s, ref size_t idx, char delimiter, in ref Location loc)
{
	size_t start = idx;
	while( idx < s.length ){
		if( s[idx] == '\\' ){
			// pass escape character through - will be handled later by buildInterpolatedString
			idx++;
			enforcep(idx < s.length, "'\\' must be followed by something (escaped character)!", loc);
		} else if( s[idx] == delimiter ) break;
		idx++;
	}
	enforcep(idx < s.length, "Unterminated attribute string: "~s[start-1 .. $]~"||", loc);
	return s[start .. idx];
}

private bool matchesName(string filename, string logical_name, string parent_name)
{
	import std.path : extension;
	if (filename == logical_name) return true;
	auto ext = extension(parent_name);
	if (filename.endsWith(ext) && filename[0 .. $-ext.length] == logical_name) return true;
	return false;
}

private void modifyArray(alias modify, T)(ref T[] arr)
{
	size_t i = 0;
	while (i < arr.length) {
		auto mod = modify(arr[i]);
		if (mod.isNull()) i++;
		else {
			arr = arr[0 .. i] ~ mod.get() ~ arr[i+1 .. $];
			i += mod.length;
		}
	}
}
