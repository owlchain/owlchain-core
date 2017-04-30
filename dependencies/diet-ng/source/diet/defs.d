/** Contains common types and constants.
*/
module diet.defs;

import diet.dom;


/** The name of the output range variable within a Diet template.

	D statements can access the variable with this name to directly write to the
	output.
*/
enum dietOutputRangeName = "_diet_output";


/// Thrown by the parser for malformed input.
alias DietParserException = Exception;


/** Throws an exception if the condition evaluates to `false`.

	This function will generate a proper error message including file and line
	number when called at compile time. An assertion is used in this case
	instead of an exception:

	Throws:
		Throws a `DietParserException` when called with a `false` condition at
		run time.
*/
void enforcep(bool cond, lazy string text, in ref Location loc)
{
	if (__ctfe) {
		import std.conv : to;
		assert(cond, loc.file~"("~(loc.line+1).to!string~"): "~text);
	} else {
		if (!cond) throw new DietParserException(text, loc.file, loc.line+1);
	}
}
