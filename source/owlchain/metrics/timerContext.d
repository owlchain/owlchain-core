module owlchain.meterics.timerContext;

import std.datetime;

import owlchain.meterics.timer;

class TimerContext
{
public:
    this(ref Timer timer)
    {
        mImpl = new Impl(timer);
    }

    this(ref TimerContext context)
    {
        mImpl = context.mImpl;
        context.mImpl = null;
    }

    ~this()
    {

    }

    void reset()
    {
        checkImpl();
        mImpl.reset();
    }

    Duration stop()
    {
        checkImpl();
        return mImpl.stop();
    }

private:
    class Impl
    {
        this(ref Timer timer)
        {
            mTimer = timer;
            reset();
        }

        ~this()
        {
            stop();
        }

        void reset()
        {
            mStartTime = Clock.currTime();
            mActive = true;
        }

        Duration stop()
        {
            if (mActive)
            {
                auto duration = Clock.currTime() - mStartTime;
                mTimer.update(duration);
                mActive = false;
                return duration;
            }
            else
            {
                return dur!"nsecs"(0);
            }
        }

        Timer mTimer;
        bool mActive;
        SysTime mStartTime;
    }

    Impl mImpl;

    void checkImpl()
    {
        if (!mImpl)
        {
            throw new Exception("Access to moved TimerContext::mImpl");
        }
    }
}
