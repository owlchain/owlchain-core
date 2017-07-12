module owlchain.core.stream;

import core.time;
import std.algorithm;
import std.conv;

/**
Interface for all classes implementing readable streams.
*/
interface InputStream {
	/** Returns true $(I iff) the end of the input stream has been reached.
	*/
	@property bool empty();

	/**	Returns the maximum number of bytes that are known to remain in this stream until the
    end is reached. After leastSize() bytes have been read, the stream will either have
    reached EOS and empty() returns true, or leastSize() returns again a number > 0.
	*/
	@property ulong leastSize();

	/** Queries if there is data available for immediate, non-blocking read.
	*/
	@property bool dataAvailableForRead();

	/** Returns a temporary reference to the data that is currently buffered.

    The returned slice typically has the size `leastSize()` or `0` if
    `dataAvailableForRead()` returns false. Streams that don't have an
    internal buffer will always return an empty slice.

    Note that any method invocation on the same stream potentially
    invalidates the contents of the returned buffer.
	*/
	const(ubyte)[] peek();

	/**	Fills the preallocated array 'bytes' with data from the stream.

    Throws: An exception if the operation reads past the end of the stream
	*/
	void read(ubyte[] dst);
}

/**
Interface for all classes implementing writeable streams.
*/
interface OutputStream {
	/** Writes an array of bytes to the stream.
	*/
	void write(in ubyte[] bytes);

	/** Flushes the stream and makes sure that all data is being written to the output device.
	*/
	void flush();

	/** Flushes and finalizes the stream.

    Finalize has to be called on certain types of streams. No writes are possible after a
    call to finalize().
	*/
	void finalize();

	/** Writes an array of chars to the stream.
	*/
	final void write(in char[] bytes)
	{
		write(cast(const(ubyte)[])bytes);
	}

	/** Pipes an InputStream directly into this OutputStream.

    The number of bytes written is either the whole input stream when nbytes == 0, or exactly
    nbytes for nbytes > 0. If the input stream contains less than nbytes of data, an exception
    is thrown.
	*/
	void write(InputStream stream, ulong nbytes = 0);

}