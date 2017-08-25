module owlchain.meterics.abstractPollingReporter;

import core.time;
import core.thread;

class AbstractPollingReporter
{
public:
    this()
    {
        mImpl = new Impl(this);
    }

    ~this()
    {
    }

    void shutdown()
    {
        mImpl.shutdown();
    }

    void start(Duration period = dur!"seconds"(5))
    {
        mImpl.start(period);
    }

    void run()
    {

    }

private:
    class Impl
    {
    public:
        this(AbstractPollingReporter self)
        {
            mSelf = self;
            mRunning = false;
        }

        ~this()
        {
            shutdown();
        }

        void shutdown()
        {
            if (mRunning)
            {
                mRunning = false;
                mThread.join();
            }
        }

        void start(Duration period = dur!"seconds"(5))
        {
            if (!mRunning)
            {
                mRunning = true;
                mThread = new Thread(() { loop(period); }).start();
            }
        }

        void loop(Duration period)
        {
            while (mRunning)
            {
                Thread.sleep(period);
                mSelf.run();
            }
        }

    private:
        AbstractPollingReporter mSelf;
        bool mRunning;
        Thread mThread;
    }

    Impl mImpl;
}
