#!/usr/bin/env rdmd

import std.stdio;
import std.getopt;

immutable enum VER = 0.1;

immutable string SYNOPSIS = `
License punching utilility for program source file.

[synopsis]

puncher [-r] [-l license_symbol] [file ...]

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
	string license ;
	bool recursive=false;

	auto helpInformation = getopt(
    args,
    "r|recursive", &recursive);

	if (helpInformation.helpWanted)
	{
		defaultGetoptPrinter("License punching utilility for program source file.",
	  		helpInformation.options);
	}

	return 0;
}