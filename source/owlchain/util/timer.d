module owlchain.util.timer;

import std.datetime;
import owlchain.xdr.type;
import std.container.binaryheap;

import owlchain.main.application;

import owlchain.asio.ioService;

static const uint32 RECENT_CRANK_WINDOW = 1024;
class VirtualClock
{
public:
    alias SysTime time_point;

    static const bool isSteady = false;

    static long to_time_t(time_point point)
    {
        return point.toUnixTime();
    }

    static time_point from_time_t(long timet)
    {
        return SysTime.fromUnixTime(timet);
    }

    static string pointToISOString(time_point point)
    {
        return point.toISOExtString();
    }

    enum Mode
    {
        REAL_TIME,
        VIRTUAL_TIME
    };

private:
    IOService mIOService;
    Mode mMode;

    uint32 mRecentCrankCount;
    uint32 mRecentIdleCrankCount;

    size_t nRealTimerCancelEvents;
    time_point mNow;

    VirtualClockEvent[] mQueue;
    BinaryHeap!(VirtualClockEvent[]) mEvents;
    size_t mFlushesIgnored;

    bool mDestructing;

    time_point next()
    {
        return Clock.currTime();
    }

    void maybeSetRealtimer()
    {

    }

    size_t advanceTo(time_point n)
    {
        return 0;
    }
    size_t advanceToNext()
    {
        return 0;
    }
    size_t advanceToNow()
    {
        return 0;
    }
public:
    this()
    {
        mEvents = BinaryHeap!(VirtualClockEvent[])(mQueue);
        mDestructing = false;
        mFlushesIgnored = 0;
    }

    size_t crank(bool block = true)
    {
        return 0L;
    }

    void noteCrankOccurred(bool hadIdle)
    {
    }

    uint32 recentIdleCrankPercent()
    {
        return 0;
    }

    IOService getIOService()
	{
		return mIOService;
	}

    // Note: this is not a static method, which means that VirtualClock is
    // not an implementation of the C++ `Clock` concept; there is no global
    // virtual time. Each virtual clock has its own time.
    time_point now()
    {
        return Clock.currTime();
    }

    void enqueue(VirtualClockEvent ve)
    {

    }

    void flushCancelledEvents()
    {

    }
    
    bool cancelAllEvents()
    {
        return false;
    }

    // only valid with VIRTUAL_TIME: sets the current value
    // of the clock
    void setCurrentTime(time_point t)
    {

    }
}

alias bool delegate(IOErrorCode code) VirtualClockCallback;

class VirtualClockEvent
{

    VirtualClockCallback mCallback;
    bool mTriggered;

public:
    VirtualClock.time_point mWhen;
    size_t mSeq;
    
    this(VirtualClock.time_point when, size_t seq, VirtualClockCallback callback)
    {
        mWhen = when;
        mSeq = seq;
        mCallback = callback;
        mTriggered = false;
    }

    bool getTriggered()
    {
		return mTriggered;
    }

    void trigger()
    {
		if (!mTriggered)
		{
			mTriggered = true;
			mCallback(new IOErrorCode());
			mCallback = null;
		}
    }

    void cancel()
    {
		if (!mTriggered)
		{
			mTriggered = true;
			mCallback(new IOErrorCode("", 0, "operation_aborted"));
			mCallback = null;
		}
    }
    
    override int opCmp(Object o) 
    {
		// For purposes of priority queue, a timer is "less than"
		// another timer if it occurs in the future (has a higher
		// expiry time). The "greatest" timer is timer 0.
		// To break time-based ties (but preserve the ordering in which
		// events were enqueued) we add an event-sequence number as well,
		// such that a higher sequence number makes an event "less than"
		// another.
        VirtualClockEvent other = cast(VirtualClockEvent) o;
        if ((mWhen > other.mWhen) || (mWhen == other.mWhen && mSeq > other.mSeq))
        {
            return -1;
        }
        else
        {
            return 1;
        }
    }
}

class VirtualTimer
{
private:
    VirtualClock mClock;
    VirtualClock.time_point mExpiryTime;
    VirtualClockEvent[] mEvents;
    bool mCancelled;
    bool mDeleting;

public:
    this(Application app)
    {

    }

    this(VirtualClock app)
    {

    }

    ~this()
    {

    }

    VirtualClock.time_point expiry_time() const 
    {
        return mExpiryTime;
    }

    size_t seq() const 
    {
        return 0L;
    }

    void expires_at(VirtualClock.time_point t)
    {

    }

    void expires_from_now(Duration d)
    {

    }

    void async_wait(void delegate (IOErrorCode errorCode) fn)
    {

    }

    void async_wait(void delegate () onSuccess, void delegate (IOErrorCode errorCode) onFailure)
    {


    }

    void cancel()
    {

    }

    static void onFailureNoop(IOErrorCode errorCode)
    {
    };
}