module owlchain.meterics.metricName;

import core.sync.mutex;
import core.atomic;

import owlchain.meterics.metricProcessor;
import owlchain.meterics.metricInterface;

class MetricName
{
public:
    this(string domain, string type, string name, string area = "")
    {
        mImpl = new Impl(domain, type, name, area);
    }

    this(MetricName other)
    {
        mImpl = new Impl(other.domain, other.type, other.name, other.area);
    }

    ~this()
    {

    }

    string domain()
    {
        return mImpl.domain();
    }

    string type()
    {
        return mImpl.type();
    }

    string name()
    {
        return mImpl.name();
    }

    string area()
    {
        return mImpl.area();
    }

    const string ToString()
    {
        return mImpl.ToString();
    }

    bool has_area()
    {
        return mImpl.has_area();
    }

    override bool opEquals(Object o)
    {
        MetricName other = cast(MetricName) o;
        return mImpl.opEquals(other.mImpl);
    }

    override int opCmp(Object o)
    {
        MetricName other = cast(MetricName) o;
        return mImpl.opCmp(other.mImpl);
    }

    override size_t toHash()
    {
        return mImpl.toHash();
    }

private:
    class Impl
    {
    public:
        this(string domain, string type, string name, string area = "")
        {
            mDomain = domain;
            mType = type;
            mName = name;
            mArea = area;
            mRepresent = domain ~ "." ~ type ~ "." ~ name ~ (area == "" ? "" : "." ~ area);

            if (domain == "")
            {
                throw new Exception("domain must be non-empty");
            }
            if (type == "")
            {
                throw new Exception("type must be non-empty");
            }
            if (name == "")
            {
                throw new Exception("name must be non-empty");
            }
        }

        ~this()
        {
        }

        string domain()
        {
            return mDomain;
        }

        string type()
        {
            return mType;
        }

        string name()
        {
            return mName;
        }

        string area()
        {
            return mArea;
        }

        const string ToString()
        {
            return mRepresent;
        }

        bool has_area()
        {
            return mArea != "";
        }

        override bool opEquals(Object o)
        {
            MetricName.Impl other = cast(MetricName.Impl) o;
            return mRepresent == other.mRepresent;
        }

        override int opCmp(Object o)
        {
            MetricName.Impl other = cast(MetricName.Impl) o;
            if (mRepresent < other.mRepresent)
            {
                return -1;
            }
            else if (mRepresent > other.mRepresent)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }

        override size_t toHash()
        {
            size_t hash;
            foreach (char c; mRepresent)
                hash = (hash * 9) + c;
            return hash;
        }

    private:
        string mDomain;
        string mType;
        string mName;
        string mArea;
        string mRepresent;
    }

    Impl mImpl;
}
