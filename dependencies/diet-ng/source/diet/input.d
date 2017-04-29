/** Contains common definitions and logic to collect input dependencies.

	This module is typically only used by generator implementations.
*/
module diet.input;

import diet.traits : DietTraitsAttribute;


/** Converts a `Group` with alternating file names and contents to an array of
	`InputFile`s.
*/
@property InputFile[] filesFromGroup(alias FILES_GROUP)()
{
	static assert(FILES_GROUP.expand.length % 2 == 0);
	auto ret = new InputFile[FILES_GROUP.expand.length / 2];
	foreach (i, F; FILES_GROUP.expand) {
		static if (i % 2 == 0) {
			ret[i / 2].name = FILES_GROUP.expand[i+1];
			ret[i / 2].contents = FILES_GROUP.expand[i];
		}
	}
	return ret;
}

/** Using the file name of a string import Diet file, returns a list of all
	required files.

	These files recursively include all imports or extension templates that
	are used. The type of the list is `InputFile[]`.
*/
template collectFiles(string root_file)
{
	import diet.internal.string : stripUTF8BOM;
	enum collectFiles = collectFiles!(root_file, stripUTF8BOM(import(root_file)));
}
/// ditto
template collectFiles(string root_file, string root_contents)
{
	import std.algorithm.searching : canFind;
	enum baseFiles = collectReferencedFiles!(root_file, root_contents);
	static if (baseFiles.canFind!(f => f.name == root_file))
		enum collectFiles = baseFiles;
	else enum collectFiles = InputFile(root_file, root_contents) ~ baseFiles;
}

/// Encapsulates a single input file.
struct InputFile {
	string name;
	string contents;
}

/** Helper template to aggregate a list of compile time values.
	
	This is similar to `AliasSeq`, but does not auto-expand.
*/
template Group(A...) {
	import std.typetuple;
	alias expand = TypeTuple!A;
}

/** Returns a mixin string that makes all passed symbols available in the
	mixin's scope.
*/
template localAliasesMixin(int i, ALIASES...)
{
	import std.traits : hasUDA;
	static if (i < ALIASES.length) {
		import std.conv : to;
		static if (hasUDA!(ALIASES[i], DietTraitsAttribute)) enum string localAliasesMixin = localAliasesMixin!(i+1);
		else enum string localAliasesMixin = "alias ALIASES["~i.to!string~"] "~__traits(identifier, ALIASES[i])~";\n"
			~localAliasesMixin!(i+1, ALIASES);
	} else {
		enum string localAliasesMixin = "";
	}
}

private template collectReferencedFiles(string file_name, string file_contents)
{
	import std.path : extension;

	enum references = collectReferences(file_contents);
	template impl(size_t i) {
		static if (i < references.length) {
			enum rfiles = impl!(i+1);
			static if (__traits(compiles, import(references[i]))) {
				enum ifiles = collectFiles!(references[i]);
				enum impl = merge(ifiles, rfiles);
			} else static if (__traits(compiles, import(references[i] ~ extension(file_name)))) {
				enum ifiles = collectFiles!(references[i] ~ extension(file_name));
				enum impl = merge(ifiles, rfiles);
			} else enum impl = rfiles;
		} else enum InputFile[] impl = [];
	}
	alias collectReferencedFiles = impl!0;
}

private string[] collectReferences(string content)
{
	import std.string : strip, stripLeft, splitLines;
	import std.algorithm.searching : startsWith;

	string[] ret;
	foreach (i, ln; content.stripLeft().splitLines()) {
		// FIXME: this produces false-positives when a text paragraph is used:
		// p.
		//     This is some text.
		//     import oops, this is also just text.
		ln = ln.stripLeft();
		if (i == 0 && ln.startsWith("extends "))
			ret ~= ln[8 .. $].strip();
		else if (ln.startsWith("include "))
			ret ~= ln[8 .. $].strip();
	}
	return ret;
}

private InputFile[] merge(InputFile[] a, InputFile[] b)
{
	import std.algorithm.searching : canFind;
	auto ret = a;
	foreach (f; b)
		if (!a.canFind!(g => g.name == f.name))
			ret ~= f;
	return ret;
}
