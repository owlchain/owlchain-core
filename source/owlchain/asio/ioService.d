module owlchain.asio.ioService;

class IOService
{
public:
    this()
    {

    }

    void post(void delegate () trigger)
    {


    }
}

class IOErrorCode
{
private:
    string mName;
    string mMessage;
    int mCode;

public:
    this()
    {

    }

    this(string name, int code, string message)
    {
        mName = name;
        mCode = code;
        mMessage = message;
    }

    @property void name(string n)
    {
        mName = n;
    }
    @property string name()
    {
        return mName;
    }
    @property void code(int n)
    {
        mCode = n;
    }
    @property int code()
    {
        return mCode;
    }
    @property void message(string n)
    {
        mMessage = n;
    }
    @property string message()
    {
        return mMessage;
    }
}