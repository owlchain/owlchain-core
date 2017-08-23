module owlchain.metrics.counter;


import owlchain.metrics.metricProcessor;
import core.atomic;

class Counter {
Impl mImpl;

public :
	this(long init)
	{
		mImpl = new lmpl(init);
	}

	~ this()
	{

	}

	void Process(MetricProcess processor) 
	{
		processor.Process(this)	;
	}

	long count()
	{
		return mImpl.count();
	}

	void setCount(long n)
	{
		return mlmpl.setCount(n);
	}

	void inc(long n = 1){
		mlmpl.inc(n);
	}

	void desc(long n = 1){
		mlmpl.dec(n);
	}

	void clear(){
		mlmpl.clear();
	}

private :
	class lmpl
	{
		public :
		this(long init = 0)
		{
			automicStore(mCount,init);	
		}

		~this()
		{

		}

		long count() @safe nothrow
		{
			return atomicLoad(mCount);
		}
	
		void setCount(long n)@safe nothrow
		{
			atomicStore(mCount, n);
		}
	
		void inc(long n)@safe nothrow
		{
			atomicOp!"+="(mCount,n);
		}

		void dec(long n)@safe nothrow
		{
			atomicOp!"-="(mCount,n);
		}

		void clear()@safe nothrow
		{
			atomicStore(mCount, 0L);
		}

		private :
			shared long mCount;
	}
}