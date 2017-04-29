module diet.internal.string;

import std.ascii : isWhite;

pure @safe nothrow:

string ctstrip(string s)
{
	size_t strt = 0, end = s.length;
	while (strt < s.length && s[strt].isWhite) strt++;
	while (end > 0 && s[end-1].isWhite) end--;
	return strt < end ? s[strt .. end] : null;
}

string ctstripLeft(string s)
{
	size_t i = 0;
	while (i < s.length && s[i].isWhite) i++;
	return s[i .. $];
}

string ctstripRight(string s)
{
	size_t i = s.length;
	while (i > 0 && s[i-1].isWhite) i--;
	return s[0 .. i];
}

string dstringEscape(char ch)
{
	switch (ch) {
		default: return ""~ch;
		case '\\': return "\\\\";
		case '\r': return "\\r";
		case '\n': return "\\n";
		case '\t': return "\\t";
		case '\"': return "\\\"";
	}
}

string dstringEscape(in ref string str)
{
	string ret;
	foreach( ch; str ) ret ~= dstringEscape(ch);
	return ret;
}

string dstringUnescape(in string str)
{
	string ret;
	size_t i, start = 0;
	for( i = 0; i < str.length; i++ )
		if( str[i] == '\\' ){
			if( i > start ){
				if( start > 0 ) ret ~= str[start .. i];
				else ret = str[0 .. i];
			}
			assert(i+1 < str.length, "The string ends with the escape char: " ~ str);
			switch(str[i+1]){
				default: ret ~= str[i+1]; break;
				case 'r': ret ~= '\r'; break;
				case 'n': ret ~= '\n'; break;
				case 't': ret ~= '\t'; break;
			}
			i++;
			start = i+1;
		}

	if( i > start ){
		if( start == 0 ) return str;
		else ret ~= str[start .. i];
	}
	return ret;
}

string sanitizeEscaping(string str)
{
	str = dstringUnescape(str);
	return dstringEscape(str);
}

string stripUTF8BOM(string input)
{
	if (input.length >= 3 && input[0 .. 3] == [0xEF, 0xBB, 0xBF])
		return input[3 .. $];
	return input;
}
