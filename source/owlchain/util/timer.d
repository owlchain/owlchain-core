module owlchain.util.timer;

import std.datetime;
import core.thread;
import std.container.dlist;
import std.algorithm : sort;

import owlchain.xdr.type;
import owlchain.main.application;

import owlchain.asio.ioService;
import std.container.binaryheap;

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
    }

private:
    IOService mIOService;
    Mode mMode;

    uint32 mRecentCrankCount;
    uint32 mRecentIdleCrankCount;

    size_t nRealTimerCancelEvents;
    time_point mNow;

    VirtualClockEvent[] mEventArray;
    BinaryHeap!(VirtualClockEvent[], "a > b") mEvents;

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
		if (mDestructing)
		{
			return 0;
		}

        //assert(thread_isMainThread());

		// LOG(DEBUG) << "VirtualClock::advanceTo("
		//            << n.time_since_epoch().count() << ")";
		mNow = n;
		VirtualClockEvent[] toDispatch;

		while (!mEvents.empty)
		{
			if (mEvents.front.mWhen > mNow) break;
			toDispatch ~= mEvents.front();
			mEvents.popFront();
		}

		// Keep the dispatch loop separate from the pop()-ing loop
		// so the triggered events can't mutate the priority queue
		// from underneat us while we are looping.
        for (size_t i; i < toDispatch.length; i++)
        {
			toDispatch[i].trigger();
		}
		// LOG(DEBUG) << "VirtualClock::advanceTo done";
		maybeSetRealtimer();

		return toDispatch.length;
    }

    size_t advanceToNext()
    {
		if (mDestructing)
		{
			return 0;
		}
		assert(mMode == Mode.VIRTUAL_TIME);

        assert(thread_isMainThread());

		if (mEvents.empty)
		{
			return 0;
		}
		return advanceTo(next());
    }

    size_t advanceToNow()
    {
		if (mDestructing)
		{
			return 0;
		}
		assert(mMode == Mode.REAL_TIME);
		return advanceTo(now());
    }

public:
    this()
    {
        mDestructing = false;
        mFlushesIgnored = 0;
        mEvents = heapify!"a > b"(mEventArray);
    }

    size_t crank(bool block = true)
    {
        return 0L;
    }

    void noteCrankOccurred(bool hadIdle)
    {
		// Record execution of a crank and, optionally, whether we had an idle
		// poll event; this is used to estimate overall business of the system
		// via recentIdleCrankPercent().
		++mRecentCrankCount;
		if (hadIdle)
		{
			++mRecentIdleCrankCount;
		}

		// Divide-out older samples once we have a suitable number of cranks to
		// evaluate a ratio. This makes the measurement "present-biased" and
		// the threshold (RECENT_CRANK_WINDOW) sets the size of the window (in
		// cranks) that we consider as "the present". Using an event count
		// rather than a time based EWMA (as in a medida::Meter) makes the
		// ratio more precise, at the expense of accuracy of present-focus --
		// we might accidentally consider samples from 1s, 1m or even 1h ago as
		// "present" if the system is very lightly loaded. But since we're
		// going to use this value to disconnect peers when overloaded, this is
		// the preferred tradeoff.
		if (mRecentCrankCount > RECENT_CRANK_WINDOW)
		{
			mRecentCrankCount >>= 1;
			mRecentIdleCrankCount >>= 1;
		}
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
		if (mDestructing)
		{
			return;
		}
        assert(thread_isMainThread());

		mEvents.insert(ve);
		maybeSetRealtimer();
    }

    void flushCancelledEvents()
    {
		if (mDestructing)
		{
			return;
		}

		if (mFlushesIgnored <= mEvents.length)
		{
			// Flushing all the canceled events immediately can lead to
			// a O(n^2) loop if many events in the queue are canceled one a time.
			//
			// By ignoring O(n) flushes, we batch the iterations together and
			// restore O(n) performance.
			mFlushesIgnored++;
			return;
		}
        assert(thread_isMainThread());
		// LOG(DEBUG) << "VirtualClock::cancelAllEventsFrom";

		VirtualClockEvent[] toKeep;

		while (mEvents.length != 0)
		{
			auto e = mEvents.front;
			if (!e.getTriggered())
			{
				toKeep ~= (e);
			}
			mEvents.popFront();
		}
		mFlushesIgnored = 0;

        mEvents.clear();
        for (size_t i; i < toKeep.length; i++)
        {
			mEvents.insert(toKeep[i]);
		}
		maybeSetRealtimer();
    }
    
    bool cancelAllEvents()
    {
        assert(thread_isMainThread());

		bool wasEmpty = mEvents.empty;
		while (mEvents.length != 0)
		{
			auto ev = mEvents.front;
			mEvents.popFront();
			ev.cancel();
		}
        mEvents.clear();
		return !wasEmpty;
    }

    // only valid with VIRTUAL_TIME: sets the current value
    // of the clock
    void setCurrentTime(time_point t)
    {
		assert(mMode == Mode.VIRTUAL_TIME);
        mNow = t;
    }
}

alias void delegate(IOErrorCode code) VirtualClockCallback;

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
    
    override int opCmp(const Object o) const 
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
            return  1;
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
        mClock = app.getClock();
        mExpiryTime = mClock.now();
        mCancelled = false;
        mDeleting = false;
    }

    this(VirtualClock clock)
    {
	    mClock = clock;
        mExpiryTime = mClock.now();
        mCancelled = false;
        mDeleting = false;
    }

    ~this()
    {
		mDeleting = true;
		cancel();
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
		cancel();
		mExpiryTime = t;
		mCancelled = false;
    }

    void expires_from_now(Duration d)
    {
		cancel();
		mExpiryTime = mClock.now() + d;
		mCancelled = false;
    }

    void async_wait(void delegate (IOErrorCode errorCode) fn)
    {
		if (!mCancelled)
		{
			assert(!mDeleting);
			auto ve = new VirtualClockEvent(mExpiryTime, seq(), fn);
			mClock.enqueue(ve);
			mEvents ~= (ve);
		}
    }

    void async_wait(void delegate () onSuccess, void delegate (IOErrorCode errorCode) onFailure)
    {
		if (!mCancelled)
		{
			assert(!mDeleting);
			auto ve = new VirtualClockEvent(mExpiryTime, 
                                            seq(), 
                                            (IOErrorCode errorCode) {
                                                         if (errorCode)
                                                             onFailure(errorCode);
                                                         else
                                                             onSuccess();
                                                     });
			mClock.enqueue(ve);
			mEvents ~= (ve);
		}
    }

    void cancel()
    {
		if (!mCancelled)
		{
			mCancelled = true;
		    foreach (ref VirtualClockEvent ev; mEvents)
			{
				ev.cancel();
			}
			mClock.flushCancelledEvents();
			mEvents.length = 0;
		}
    }

    static void onFailureNoop(IOErrorCode errorCode)
    {
    };
}