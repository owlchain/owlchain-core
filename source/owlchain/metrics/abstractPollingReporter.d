module owlchain.metrics.abstractPollingReporter;

import core.time;
import core.thread;

class AbstractPollingReporter
{
public :
	this()
	{
		mImpl = new lmpl(this);
	}
	~this()
	{
	}

	void Shutdown(){
		mlmpl.Shutdown();
	}

	void Start(Duration period = dur! "seconds"(5))
	{	
		mlmpl.Start(period);
	}

	void Run()
	{
		//writeln("AbstractPollingReporter Start ====> ");
	}


private :
	class lmpl
	{
	public :

		this(AbstractPollingReporter self)
		{
			mSelf = self;
			mRunning = false;
		}

		~this()
		{
			Shutdown();
		}

		void Shutdown() 
		{
			if(mRunning) {
				mRunning = false;
				mThread.join();
			}
		}

		void Start(Duration period)
		{
			if(!mRunning){
				mRunning = true;
				mThread = new Thread(() { loop(period); }).start();
			}
		}

		void loop(Duration period)
		{
			while(mRunning){
				Thread.sleep(period);
				mSelf.Run();
			}
		}

	private :
		AbstractPollingReporter mSelf;
		bool mRunning;
		Thread mThread;
	}

	lmpl mImpl;

}
