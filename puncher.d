#!/usr/bin/env rdmd

/*
Copyright 2016 Owlchain communities and contributors. Licensed under 
the GNU General Public License, Version 3.0. See the LICENSE.md file 
at the root of this distribution or at https://www.gnu.org/licenses/gpl-3.0.html
*/

import std.stdio;
import std.getopt;
import std.string;
import std.file;
import std.array;

immutable enum VER = 0.1;

immutable string SYNOPSIS = `
License punching utility for program source file.

[synopsis]

puncher [-r] [file ...]

ex) puncher -r *.d 
-r, --recursive Recursive subdirectories 
-h, --help: 	Listing help text
`;

enum SOURCE_HEADER=`/*
Copyright 2016 Owlchain communities and contributors. Licensed under 
the GNU General Public License, Version 3.0. See the LICENSE.md file 
at the root of this distribution or at https://www.gnu.org/licenses/gpl-3.0.html
*/`;


int main(string[] args){
	version(Windows)
	{
		writeln("This program does not work on Windows.");
	}
	else
	{
		string license ;
		bool recursive = false;

		auto helpInformation = getopt(
	    args,
	    "r|recursive", &recursive);

		if (helpInformation.helpWanted)
		{
			defaultGetoptPrinter("License punching utilility for program source file.",
		  		helpInformation.options);
		}

		if(!recursive)
		{
			foreach(i, arg; args[1..$])
			{
				if(arg[$-2..$] != ".d")
				{
					writeln("The type of ", arg, " is not '*.d'.");
				}
				else
				{
					punchFile(arg);
				}
			}
		}
		else
		{
			auto dFiles = dirEntries("", "*.{d,di}", SpanMode.depth);
			foreach (d; dFiles)
			{
	    		punchFile(d.name);
	    	}
		}
	}
	return 0;
}

void punchFile(string fileName)
{
	if (fileName[0..7] == "backup/")
	{
		return;
	}
	string buffer = readFile(fileName);
	if(checkBuffer(buffer, fileName))
	{
		backupFile(fileName);
		writeFile(buffer, fileName);
	}				
}	

string readFile(string fileName)
{
	string buffer;
	File file = File(fileName, "r");
				
	foreach(line; file.byLine)
	{
		buffer ~= line;
		buffer ~= "\n";
	}

	file.close();

	return buffer;
}

void writeFile(string buffer, string fileName)
{
	File file = File(fileName, "w");
	file.writeln(SOURCE_HEADER, "\n");
	file.writeln(buffer);
	file.close();

	writeln(fileName, " is complety punched.");
}

bool checkBuffer(string buffer, string fileName)
{
	if(buffer.length > 19 && buffer[0..19] == "#!/usr/bin/env rdmd")
	{
		writeln("You can not punch a shell script file(", fileName, ").");
		return false;
	}

	if(buffer.length > 56 && buffer[0..56] == SOURCE_HEADER[0..56]) // SOURCE_HEADER[0..56] == /*\nCopyright 2016 Owlchain communities and contributors.
	{
		writeln(fileName, " is already punched.");
		return false;
	}

	return true;
}

void backupFile(string fileName)
{
	string path = "backup/";

	foreach(s; split(fileName, "/")[0..$-1])
	{
		path = path ~ s ~ "/";
	}

	if (!exists(path))
	{
		mkdirRecurse(path.dup);
	}
	
	copy(fileName, "backup/" ~ fileName);
}
