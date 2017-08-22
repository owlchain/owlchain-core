module owlchain.database.database;

import core.time;

import owlchain.main.application;
import owlchain.meterics.meter;
import owlchain.meterics.timerContext;

class Database
{
public:
    // Instantiate object and connect to app.getConfig().DATABASE;
    // if there is a connection error, this will throw.
    this(Application app)
    {

    }

    // Return a crude meter of total queries to the db, for use in
    // overlay/LoadManager.
    Meter getQueryMeter()
    {
        return null;
    }

    // Number of nanoseconds spent processing queries since app startup,
    // without any reference to excluded time or running counters.
    // Strictly a sum of measured time.
    Duration totalQueryTime()
    {
        return dur!"seconds"(1);
    }

    // Subtract a number of nanoseconds from the running time counts,
    // due to database usage spikes, specifically during ledger-close.
    void excludeTime(ref const Duration queryTime, ref const Duration totalTime)
    {

    }

    // Return the percent of the time since the last call to this
    // method that database has been idle, _excluding_ the times
    // excluded above via `excludeTime`.
    uint recentIdleDbPercent()
    {
        return 0;
    }

    // Return a logging helper that will capture all SQL statements made
    // on the main connection while active, and will log those statements
    // to the process' log for diagnostics. For testing and perf tuning.
    //std::shared_ptr<SQLLogContext> captureAndLogSQL(std::string contextName);

    // Return a helper object that borrows, from the Database, a prepared
    // statement handle for the provided query. The prepared statement handle
    // is ceated if necessary before borrowing, and reset (unbound from data)
    // when the statement context is destroyed.
    //StatementContext getPreparedStatement(std::string const& query);

    // Purge all cached prepared statements, closing their handles with the
    // database.
    void clearPreparedStatementCache()
    {

    }

    // Return metric-gathering timers for various families of SQL operation.
    // These timers automatically count the time they are alive for,
    // so only acquire them immediately before executing an SQL statement.
    TimerContext getInsertTimer(const string entityName)
    {
        return null;
    }

    TimerContext getSelectTimer(const string entityName)
    {
        return null;
    }

    TimerContext getDeleteTimer(const string entityName)
    {
        return null;
    }

    TimerContext getUpdateTimer(const string entityName)
    {
        return null;
    }


    // If possible (i.e. "on postgres") issue an SQL pragma that marks
    // the current transaction as read-only. The effects of this last
    // only as long as the current SQL transaction.
    void setCurrentTransactionReadOnly()
    {
    }

    // Return true if the Database target is SQLite, otherwise false.
    bool isSqlite()
    {
        return true;
    }

    // Return true if a connection pool is available for worker threads
    // to read from the database through, otherwise false.
    bool canUsePool()
    {
        return true;
    }

    // Drop and recreate all tables in the database target. This is called
    // by the --newdb command-line flag on stellar-core.
    void initialize()
    {
    }

    // Save `vers` as schema version.
    void putSchemaVersion(ulong vers)
    {
    }

    // Get current schema version in DB.
    ulong getDBSchemaVersion()
    {
        return 0L;
    }

    // Get current schema version of running application.
    ulong getAppSchemaVersion()
    {
        return 0L;
    }

    // Check schema version and apply any upgrades if necessary.
    void upgradeToCurrentSchema()
    {

    }

    // Access the LedgerEntry cache. Note: clients are responsible for
    // invalidating entries in this cache as they perform statements
    // against the database. It's kept here only for ease of access.
    //typedef cache::lru_cache<std::string, std::shared_ptr<LedgerEntry const>> EntryCache;
    //EntryCache& getEntryCache();
};
