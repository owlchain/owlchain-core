vibe.d SDLang serialization
===========================

This package provides generic [`vibe.data.serialization`][serialization] based
serialization support for the [SDLang](https://sdlang.org/) data format. It uses 
[sdlang-d](https://code.dlang.org/packages/sdlang-d) to parse and generate
the SDLang format.

[![Build Status](https://travis-ci.org/vibe-d/vibe-sdl.svg?branch=master)](https://travis-ci.org/vibe-d/vibe-sdl)

Example:

```D
import vibe.data.sdl : serializeSDLang;
import sdlang.ast : Tag;
import std.stdio : writeln;

struct Ticket {
	int id;
	string title;
	string[] tags;
}

void main()
{
	Ticket[] tickets = [
		Ticket(0, "foo", ["defect", "critical"]),
		Ticket(1, "bar", ["enhancement"])
	];

	Tag sdl = serializeSDLang(tickets);
	writeln(sdl.toSDLDocument());
}
```
[serialization]: https://vibed.org/api/vibe.data.serialization/