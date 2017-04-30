module owlchain.store.sqlstore;

@system
unittest {

	import vibe.data.sdl : serializeSDLang;
	import sdlang.ast : Tag;
	import std.stdio : writeln;
	
	writeln("test ==== vibe.data.sdl");

	struct Ticket {
		int id;
		string title;
		string[] tags;
	}

	bool serialized()
	{
		Ticket[] tickets = [
			Ticket(0, "foo", ["defect", "critical"]),
			Ticket(1, "bar", ["enhancement"])
		];

		Tag sdl = serializeSDLang(tickets);
		writeln(sdl.toSDLDocument());

		return true;
	}

	assert( serialized() == true);
}
