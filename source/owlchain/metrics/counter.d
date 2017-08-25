module owlchain.meterics.counter;

import core.sync.mutex;
import core.atomic;

import owlchain.meterics.metricProcessor;
import owlchain.meterics.metricInterface;

class Counter : MetricInterface
{
public:
    this(long init)
    {
        mImpl = new Impl(init);
    }

    ~this()
    {

    }

    void Process(MetricProcessor processor)
    {
        processor.Process(this);
    }

    long count()
    {
        return mImpl.count();
    }

    void setCount(long n)
    {
        mImpl.setCount(n);
    }

    void inc(long n = 1)
    {
        mImpl.inc(n);
    }

    void dec(long n = 1)
    {
        mImpl.dec(n);
    }

    void clear()
    {
        mImpl.clear();
    }

private:

    class Impl
    {
    public:
        this(long init = 0)
        {
            atomicStore(mCount, init);
        }

        ~this()
        {

        }

        void Process(MetricProcessor processor)
        {

        }

        long count() @safe nothrow
        {
            return atomicLoad(mCount);
        }

        void setCount(long n) @safe nothrow
        {
            atomicStore(mCount, n);
        }

        void inc(long n = 1) @safe nothrow
        {
            atomicOp!"+="(mCount, n);
        }

        void dec(long n = 1) @safe nothrow
        {
            atomicOp!"-="(mCount, n);
        }

        void clear() @safe nothrow
        {
            atomicStore(mCount, 0L);
        }

    private:
        shared long mCount;
    }

    Impl mImpl;
}
