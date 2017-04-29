/** Types to represent the DOM tree.

	The DOM tree is used as an intermediate representation between the parser
	and the generator. Filters and other kinds of transformations can be
	executed on the DOM tree. The generator itself will apply filters and
	other traits using `diet.traits.applyTraits`.
*/
module diet.dom;

import diet.internal.string;


string expectText(const(Attribute) att)
{
	import diet.defs : enforcep;
	if (att.contents.length == 0) return null;
	enforcep(att.isText, "'"~att.name~"' expected to be a pure text attribute.", att.loc);
	return att.contents[0].value;
}

string expectText(const(Node) n)
{
	import diet.defs : enforcep;
	if (n.contents.length == 0) return null;
	enforcep(n.contents.length > 0 && n.contents[0].kind == NodeContent.Kind.text &&
		(n.contents.length == 1 || n.contents[1].kind != NodeContent.Kind.node),
		"Expected pure text node.", n.loc);
	return n.contents[0].value;
}

string expectExpression(const(Attribute) att)
{
	import diet.defs : enforcep;
	enforcep(att.isExpression, "'"~att.name~"' expected to be an expression attribute.", att.loc);
	return att.contents[0].value;
}

bool isExpression(const(Attribute) att) { return att.contents.length == 1 && att.contents[0].kind == AttributeContent.Kind.interpolation; }
bool isText(const(Attribute) att) { return att.contents.length == 0 || att.contents.length == 1 && att.contents[0].kind == AttributeContent.Kind.text; }


/** Encapsulates a full Diet template document.
*/
/*final*/ class Document { // non-final because of https://issues.dlang.org/show_bug.cgi?id=17146
	Node[] nodes;

	this(Node[] nodes) { this.nodes = nodes; }
}


/** Represents a single node in the DOM tree.
*/
/*final*/ class Node { // non-final because of https://issues.dlang.org/show_bug.cgi?id=17146
	@safe nothrow:

	/// A set of names that identify special-purpose nodes
	enum SpecialName {
		/** Normal comment. The content will appear in the output if the output
			format supports comments.
		*/
		comment = "//",

		/** Hidden comment. The content will never appear in the output.
		*/
		hidden = "//-",

		/** D statement. A node that has pure text as its first content,
			optionally followed by any number of child nodes. The text content
			is either a complete D statement, or an open block statement
			(without a block statement appended). In the latter case, all nested
			nodes are considered to be part of the block statement's body by
			the generator.
		*/
		code = "-",

		/** A dummy node that contains only text and string interpolations.
			These nodes behave the same as if their node content would be
			inserted in their place, except that they will cause whitespace
			(usually a space or a newline) to be prepended in the output, if
			they are not the first child of their parent.
		*/
		text = "|",

		/** Filter node. These nodes contain only text and string interpolations
			and have a "filterChain" attribute that contains a space separated
			list of filter names that are applied in reverse order when the
			traits (see `diet.traits.applyTraits`) are applied by the generator.
		*/
		filter = ":"
	}

	/// Start location of the node in the source file.
	Location loc;
	/// Name of the node
	string name;
	/// A key-value set of attributes.
	Attribute[] attributes;
	/// The main contents of the node.
	NodeContent[] contents;
	/// Flags that control the parser and generator behavior.
	NodeAttribs attribs;

	/// Constructs a new node.
	this(Location loc = Location.init, string name = null, Attribute[] attributes = null, NodeContent[] contents = null, NodeAttribs attribs = NodeAttribs.none)
	{
		this.loc = loc;
		this.name = name;
		this.attributes = attributes;
		this.contents = contents;
		this.attribs = attribs;
	}

	/// Returns the "id" attribute.
	@property inout(Attribute) id() inout { return getAttribute("id"); }
	/// Returns "class" attribute - a white space separated list of style class identifiers.
	@property inout(Attribute) class_() inout { return getAttribute("class"); }

	/** Adds a piece of text to the node's contents.

		If the node already has some content and the last piece of content is
		also text, with a matching location, the text will be appended to that
		`NodeContent`'s value. Otherwise, a new `NodeContent` will be appended.

		Params:
			text = The text to append to the node
			loc = Location in the source file
	*/
	void addText(string text, in ref Location loc)
	{
		if (contents.length && contents[$-1].kind == NodeContent.Kind.text && contents[$-1].loc == loc)
			contents[$-1].value ~= text;
		else contents ~= NodeContent.text(text, loc);
	}

	/** Removes all content if it conists of only white space. */
	void stripIfOnlyWhitespace()
	{
		if (!this.hasNonWhitespaceContent)
			contents = null;
	}

	/** Determines if this node has any non-whitespace contents. */
	bool hasNonWhitespaceContent()
	const {
		import std.algorithm.searching : any;
		return contents.any!(c => c.kind != NodeContent.Kind.text || c.value.ctstrip.length > 0);
	}

	/** Strips any leading whitespace from the contents. */
	void stripLeadingWhitespace()
	{
		while (contents.length >= 1 && contents[0].kind == NodeContent.Kind.text) {
			contents[0].value = ctstripLeft(contents[0].value);
			if (contents[0].value.length == 0)
				contents = contents[1 .. $];
			else break;
		}
	}

	/** Strips any trailign whitespace from the contents. */
	void stripTrailingWhitespace()
	{
		while (contents.length >= 1 && contents[$-1].kind == NodeContent.Kind.text) {
			contents[$-1].value = ctstripRight(contents[$-1].value);
			if (contents[$-1].value.length == 0)
				contents = contents[0 .. $-1];
			else break;
		}
	}

	/// Tests if the node consists of only a single, static string.
	bool isTextNode() const { return contents.length == 1 && contents[0].kind == NodeContent.Kind.text; }

	/// Tests if the node consists only of text and interpolations, but doesn't contain child nodes.
	bool isProceduralTextNode() const { import std.algorithm.searching : all; return contents.all!(c => c.kind != NodeContent.Kind.node); }

	/** Returns a given named attribute.

		If the attribute doesn't exist, an empty value will be returned.
	*/
	inout(Attribute) getAttribute(string name)
	inout {
		foreach (ref a; this.attributes)
			if (a.name == name)
				return a;
		return Attribute(this.loc, name, null);
	}

	void setAttribute(Attribute att)
	{
		foreach (ref da; attributes)
			if (da.name == att.name) {
				da = att;
				return;
			}
		attributes ~= att;
	}

	/// Outputs a simple string representation of the node.
	override string toString() const {
		scope (failure) assert(false);
		import std.string : format;
		return format("Node(%s, %s, %s, %s, %s)", this.tupleof);
	}

	/// Compares all properties of two nodes for equality.
	override bool opEquals(Object other_) {
		auto other = cast(Node)other_;
		if (!other) return false;
		return this.opEquals(other);
	}

	bool opEquals(in Node other) const { return this.tupleof == other.tupleof; }
}


/** Flags that control parser or generator behavior.
*/
enum NodeAttribs {
	none = 0,
	translated = 1<<0,  /// Translate node contents
	textNode = 1<<1,    /// All nested lines are treated as text
	rawTextNode = 1<<2, /// All nested lines are treated as raw text (no interpolations or inline tags)
	fitOutside = 1<<3,  /// Don't insert white space outside of the node when generating output (currently ignored by the HTML generator)
	fitInside = 1<<4,   /// Don't insert white space around the node contents when generating output (currently ignored by the HTML generator)
}


/** A single node attribute.

	Attributes are key-value pairs, where the value can either be empty
	(considered as a Boolean value of `true`), a string with optional
	string interpolations, or a D expression (stored as a single
	`interpolation` `AttributeContent`).
*/
struct Attribute {
	@safe nothrow:

	/// Location in source file
	Location loc;
	/// Name of the attribute
	string name;
	/// Value of the attribute
	AttributeContent[] contents;

	/// Creates a copy of the attribute.
	@property Attribute dup() const { return Attribute(loc, name, contents.dup); }

	/** Appends raw text to the attribute.

		If the attribute already has contents and the last piece of content is
		also text, then the text will be appended to the value of that
		`AttributeContent`. Otherwise, a new `AttributeContent` will be
		appended to `contents`.
	*/
	void addText(string str)
	{
		if (contents.length && contents[$-1].kind == AttributeContent.Kind.text)
			contents[$-1].value ~= str;
		else
			contents ~= AttributeContent.text(str);
	}

	/** Appends a list of contents.

		If the list of contents starts with a text `AttributeContent`, then this
		first part will be appended using the same rules as for `addText`. The
		remaining parts will be appended normally.
	*/
	void addContents(const(AttributeContent)[] contents)
	{
		if (contents.length > 0 && contents[0].kind == AttributeContent.Kind.text) {
			addText(contents[0].value);
			contents = contents[1 .. $];
		}
		this.contents ~= contents;
	}
}


/** A single piece of an attribute value.
*/
struct AttributeContent {
	@safe nothrow:

	/// 
	enum Kind {
		text,             /// Raw text (will be escaped by the generator as necessary)
		interpolation,    /// A D expression that will be converted to text at runtime (escaped as necessary)
		rawInterpolation  /// A D expression that will be converted to text at runtime (not escaped)
	}

	/// Kind of this attribute content
	Kind kind;
	/// The value - either text or a D expression
	string value;

	/// Creates a new text attribute content value.
	static AttributeContent text(string text) { return AttributeContent(Kind.text, text); }
	/// Creates a new string interpolation attribute content value.
	static AttributeContent interpolation(string expression) { return AttributeContent(Kind.interpolation, expression); }
	/// Creates a new raw string interpolation attribute content value.
	static AttributeContent rawInterpolation(string expression) { return AttributeContent(Kind.rawInterpolation, expression); }
}


/** A single piece of node content.
*/
struct NodeContent {
	@safe nothrow:

	///
	enum Kind {
		node,            /// A child node
		text,            /// Raw text (not escaped in the output)
		interpolation,   /// A D expression that will be converted to text at runtime (escaped as necessary)
		rawInterpolation /// A D expression that will be converted to text at runtime (not escaped)
	}

	/// Kind of this node content
	Kind kind;
	/// Location of the content in the source file
	Location loc;
	/// The node - only used for `Kind.node`
	Node node;
	/// The string value - either text or a D expression
	string value;

	/// Creates a new child node content value.
	static NodeContent tag(Node node) { return NodeContent(Kind.node, node.loc, node); }
	/// Creates a new text node content value.
	static NodeContent text(string text, Location loc) { return NodeContent(Kind.text, loc, Node.init, text); }
	/// Creates a new string interpolation node content value.
	static NodeContent interpolation(string text, Location loc) { return NodeContent(Kind.interpolation, loc, Node.init, text); }
	/// Creates a new raw string interpolation node content value.
	static NodeContent rawInterpolation(string text, Location loc) { return NodeContent(Kind.rawInterpolation, loc, Node.init, text); }

	/// Compares node content for equality.
	bool opEquals(in ref NodeContent other)
	const {
		if (this.kind != other.kind) return false;
		if (this.loc != other.loc) return false;
		if (this.value != other.value) return false;
		if (this.node is other.node) return true;
		if (this.node is null || other.node is null) return false;
		return this.node.opEquals(other.node);
	}
}


/// Represents the location of an entity within the source file.
struct Location {
	/// Name of the source file
	string file;
	/// Zero based line index within the file
	int line;
}
