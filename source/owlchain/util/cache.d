module owlchain.util.cache;


struct Cache(T, U)
{
private:
    U[T] base;

public:
    ref U get(T t)
    {
        auto p = t in base;
        if (p is null)
        {
            throw new Exception("There is no such key in cache");
        } else {
            return base[t];
        }
    }

    void put(T t, U u)
    {
        auto p = t in base;
        if (p is null)
        {
            base[t] = u;
        } else {
            *p = u;
        }
    }

    bool exists(T t)
    {
        auto p = t in base;
        if (p is null)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    void update(T t, U u)
    {
        auto p = t in base;
        if (p is null)
        {
        } else {
            *p = u;
        }
    }

    void eraseIf(bool delegate (ref U) condition)
    {
        auto keys = base.keys.dup;
        for (int i = 0; i < keys.length; i++)
        {
            if (condition(base[keys[i]])) 
            {
                base.remove(keys[i]);
            }
        }
    }
}