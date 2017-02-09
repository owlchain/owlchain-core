module owlchain.appmain;

import vibe.core.core;
import vibe.core.args;
import vibe.core.concurrency;
import vibe.core.log;
import vibe.utils.array;

int runApplication(string[]* args_out = null)
{
	try if (!finalizeCommandLineOptions()) return 0;
	catch (Exception e) {
		logDiagnostic("Error processing command line: %s", e.msg);
		return 1;
	}

	lowerPrivileges();

	logDiagnostic("Running event loop...");
	int status;
	version (VibeDebugCatchAll) {
		try {
			status = runEventLoop();
		} catch( Throwable th ){
			logError("Unhandled exception in event loop: %s", th.msg);
			logDiagnostic("Full exception: %s", th.toString().sanitize());
			return 1;
		}
	} else {
		status = runEventLoop();
	}

	logDiagnostic("Event loop exited with status %d.", status);
	return status;
}


int main()
{
	version (unittest) {
		return 0;
	} else {
		return runApplication();
	}
}