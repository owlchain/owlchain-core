module owlchain.api.app;

import vibe.d;
import vibe.utils.array;

final class ApiService {
	void get(){

	}
}

shared static this()
{
	auto router = new URLRouter;
	router.registerWebInterface(new ApiService);

	auto settings = new HTTPServerSettings;
	settings.port = 8888;
	//settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.bindAddresses = ["127.0.0.1"];
	listenHTTP(settings, router);

	logInfo("Please open http://127.0.0.1:8888/ in your browser.");
}
