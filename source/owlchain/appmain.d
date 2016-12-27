module owlchain.appmain;

int main()
{
	import vibe.core.core : runApplication;

	version (unittest) {
		return 0;
	} else {
		return runApplication();
	}
}