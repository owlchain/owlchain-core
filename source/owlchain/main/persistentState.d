module owlchain.main.persistentState;

import owlchain.database.database;
import owlchain.main.application;

class PersistentState
{
public:
    this(Application app)
    {

    }

    enum Entry
    {
        kLastClosedLedger = 0,
        kHistoryArchiveState,
        kForceBCPOnNextLaunch,
        kLastBCPData,
        kDatabaseSchema,
        kLastEntry,
    };

    static void dropAll(ref Database db)
    {
    }

    string getStoreStateName(Entry n)
    {
        if (n < 0 || n >= Entry.kLastEntry)
        {
            throw new Exception("unknown entry");
        }
        return mapping[n];
    }

    string getState(Entry stateName)
    {
        string res;
        return res;
    }

    void setState(Entry stateName, ref const string value)
    {
    }

private:
    static string kSQLCreateStatement =
        "CREATE TABLE IF NOT EXISTS storestate (" ~
        "statename   CHARACTER(32) PRIMARY KEY," ~
        "state       TEXT" ~
        "); ";
    static string[Entry.kLastEntry] mapping = [
        "lastclosedledger", "historyarchivestate", "forcescponnextlaunch",
        "lastscpdata", "databaseschema"];

    Application mApp;
}
