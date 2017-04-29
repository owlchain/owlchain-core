import diet.html;
import vibe.http.server;
import vibe.stream.wrapper;

void render(scope HTTPServerRequest req, scope HTTPServerResponse res)
{
	auto dst = StreamOutputRange(res.bodyWriter);
	int iterations = 10;
	dst.compileHTMLDietFile!("index.dt", iterations);
}

shared static this()
{
	auto settings = new HTTPServerSettings;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.port = 8080;
	listenHTTP(settings, &render);
}
