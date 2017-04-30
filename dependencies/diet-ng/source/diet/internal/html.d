/**
	HTML character entity escaping - taken from the vibe.d project.

	TODO: Make things @safe once Appender is.

	Copyright: © 2012-2014 RejectedSoftware e.K.
	License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	Authors: Sönke Ludwig
*/
module diet.internal.html;

import std.array;
import std.conv;
import std.range;


/** Returns the HTML escaped version of a given string.
*/
string htmlEscape(R)(R str)
	if (isInputRange!R)
{
	if (__ctfe) { // appender is a performance/memory hog in ctfe
		StringAppender dst;
		filterHTMLEscape(dst, str);
		return dst.data;
	} else {
		auto dst = appender!string();
		filterHTMLEscape(dst, str);
		return dst.data;
	}
}

///
unittest {
	assert(htmlEscape(`"Hello", <World>!`) == `"Hello", &lt;World&gt;!`);
}


/** Writes the HTML escaped version of a given string to an output range.
*/
void filterHTMLEscape(R, S)(ref R dst, S str, HTMLEscapeFlags flags = HTMLEscapeFlags.escapeNewline)
	if (isOutputRange!(R, dchar) && isInputRange!S)
{
	for (;!str.empty;str.popFront())
		filterHTMLEscape(dst, str.front, flags);
}


/** Returns the HTML escaped version of a given string (also escapes double quotes).
*/
string htmlAttribEscape(R)(R str)
	if (isInputRange!R)
{
	if (__ctfe) { // appender is a performance/memory hog in ctfe
		StringAppender dst;
		filterHTMLAttribEscape(dst, str);
		return dst.data;
	} else {
		auto dst = appender!string();
		filterHTMLAttribEscape(dst, str);
		return dst.data;
	}
}

///
unittest {
	assert(htmlAttribEscape(`"Hello", <World>!`) == `&quot;Hello&quot;, &lt;World&gt;!`);
}


/** Writes the HTML escaped version of a given string to an output range (also escapes double quotes).
*/
void filterHTMLAttribEscape(R, S)(ref R dst, S str)
	if (isOutputRange!(R, dchar) && isInputRange!S)
{
	for (; !str.empty; str.popFront())
		filterHTMLEscape(dst, str.front, HTMLEscapeFlags.escapeNewline|HTMLEscapeFlags.escapeQuotes);
}


/** Returns the HTML escaped version of a given string (escapes every character).
*/
string htmlAllEscape(R)(R str)
	if (isInputRange!R)
{
	if (__ctfe) { // appender is a performance/memory hog in ctfe
		StringAppender dst;
		filterHTMLAllEscape(dst, str);
		return dst.data;
	} else {
		auto dst = appender!string();
		filterHTMLAllEscape(dst, str);
		return dst.data;
	}
}

///
unittest {
	assert(htmlAllEscape("Hello!") == "&#72;&#101;&#108;&#108;&#111;&#33;");
}


/** Writes the HTML escaped version of a given string to an output range (escapes every character).
*/
void filterHTMLAllEscape(R, S)(ref R dst, S str)
	if (isOutputRange!(R, dchar) && isInputRange!S)
{
	for (; !str.empty; str.popFront()) {
		dst.put("&#");
		dst.put(to!string(cast(uint)str.front));
		dst.put(';');
	}
}


/**
	Minimally escapes a text so that no HTML tags appear in it.
*/
string htmlEscapeMin(R)(R str)
	if (isInputRange!R)
{
	auto dst = appender!string();
	for (; !str.empty; str.popFront())
		filterHTMLEscape(dst, str.front, HTMLEscapeFlags.escapeMinimal);
	return dst.data();
}


void htmlEscape(R, T)(ref R dst, T val)
{
	import std.format : formattedWrite;
	auto r = HTMLEscapeOutputRange!R(dst, HTMLEscapeFlags.defaults);
	() @trusted { return &r; } ().formattedWrite("%s", val);
}

@safe unittest {
	static struct R { @safe @nogc nothrow: void put(char) {} void put(dchar) {} void put(in char[]) {}}
	R r;
	r.htmlEscape("foo");
	r.htmlEscape(12);
	r.htmlEscape(12.4);
}

void htmlAttribEscape(R, T)(ref R dst, T val)
{
	import std.format : formattedWrite;
	auto r = HTMLEscapeOutputRange!R(dst, HTMLEscapeFlags.attribute);
	() @trusted { return &r; } ().formattedWrite("%s", val);
}

/**
	Writes the HTML escaped version of a character to an output range.
*/
void filterHTMLEscape(R)(ref R dst, dchar ch, HTMLEscapeFlags flags = HTMLEscapeFlags.escapeNewline )
{
	switch (ch) {
		default:
			if (flags & HTMLEscapeFlags.escapeUnknown) {
				dst.put("&#");
				dst.put(to!string(cast(uint)ch));
				dst.put(';');
			} else dst.put(ch);
			break;
		case '"':
			if (flags & HTMLEscapeFlags.escapeQuotes) dst.put("&quot;");
			else dst.put('"');
			break;
		case '\'':
			if (flags & HTMLEscapeFlags.escapeQuotes) dst.put("&#39;");
			else dst.put('\'');
			break;
		case '\r', '\n':
			if (flags & HTMLEscapeFlags.escapeNewline) {
				dst.put("&#");
				dst.put(to!string(cast(uint)ch));
				dst.put(';');
			} else dst.put(ch);
			break;
		case 'a': .. case 'z': goto case;
		case 'A': .. case 'Z': goto case;
		case '0': .. case '9': goto case;
		case ' ', '\t', '-', '_', '.', ':', ',', ';',
			 '#', '+', '*', '?', '=', '(', ')', '/', '!',
			 '%' , '{', '}', '[', ']', '`', '´', '$', '^', '~':
			dst.put(cast(char)ch);
			break;
		case '<': dst.put("&lt;"); break;
		case '>': dst.put("&gt;"); break;
		case '&': dst.put("&amp;"); break;
	}
}


enum HTMLEscapeFlags {
	escapeMinimal = 0,
	escapeQuotes = 1<<0,
	escapeNewline = 1<<1,
	escapeUnknown = 1<<2,	
	defaults = escapeNewline,
	attribute = escapeNewline|escapeQuotes
}

private struct HTMLEscapeOutputRange(R)
{
	R* dst;
	HTMLEscapeFlags flags;
	char[4] u8seq;
	uint u8seqfill;

	this(ref R dst, HTMLEscapeFlags flags)
	@safe nothrow @nogc {
		() @trusted { this.dst = &dst; } ();
		this.flags = flags;
	}

	@disable this(this);

	void put(char ch)
	{
		import std.utf : stride;
		assert(u8seqfill < u8seq.length);
		u8seq[u8seqfill++] = ch;
		if (u8seqfill >= 4 || stride(u8seq) <= u8seqfill) {
			char[] str = u8seq[0 .. u8seqfill];
			put(u8seq[0 .. u8seqfill]);
			u8seqfill = 0;
		}
	}
	void put(dchar ch) { filterHTMLEscape(*dst, ch); }
	void put(in char[] str) { foreach (dchar ch;  str) put(ch); }

	static assert(isOutputRange!(HTMLEscapeOutputRange, char));
}

private struct StringAppender {
	string data;
	void put(string s) { data ~= s; }
	void put(char ch) { data ~= ch; }
	void put(dchar ch) {
		import std.utf;
		char[4] dst;
		data ~= dst[0 .. encode(dst, ch)];
	}
}
