import diet.html;
import std.stdio;

void main()
{
	auto file = File("index.html", "wt");
	auto dst = file.lockingTextWriter;
	int iterations = 10;
	dst.compileHTMLDietFile!("index.dt", iterations);
	writeln("Generated index.html.");
}
