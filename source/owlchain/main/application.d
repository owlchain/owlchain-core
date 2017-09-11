module owlchain.main.application;

import owlchain.main.config;
import owlchain.main.persistentState;

import owlchain.database.database;
import owlchain.xdr.hash;

import owlchain.ledger.ledgerManager;

import owlchain.meterics;
import owlchain.util.timer;

import owlchain.asio.ioService;

import owlchain.herder.herder;
import owlchain.overlay.overlayManager;

class Application
{

public:
    enum State
    {
        // Loading state from database, not yet active. SCP is inhibited.
        APP_BOOTING_STATE,

        // Out of sync with SCP peers
        APP_ACQUIRING_CONSENSUS_STATE,

        // Connected to other SCP peers

        // in sync with network but ledger subsystem still booting up
        APP_CONNECTED_STANDBY_STATE,

        // some work required to catchup to the consensus ledger
        // ie: downloading from history, applying buckets and replaying
        // transactions
        APP_CATCHING_UP_STATE,

        // In sync with SCP peers, applying transactions. SCP is active,
        APP_SYNCED_STATE,

        // application is shutting down
        APP_STOPPING_STATE,

        APP_NUM_STATE
    };

    ~this()
    {

    }


    // Return the time in seconds since the POSIX epoch, according to the
    // VirtualClock this Application is bound to. Convenience method.
    ulong timeNow()
    {
        return 0;
    }

    // Return a reference to the Application-local copy of the Config object
    // that the Application was constructed with.
    Config getConfig()
    {
        return mConfig;
    }

    // Gets the current execution-state of the Application
    // (derived from the state of other modules
    Application.State getState()
    {
        return Application.State.APP_CONNECTED_STANDBY_STATE;
    }

    string getStateHuman()
    {
        return "";
    }

    bool isStopping()
    {
        return false;
    }

    // Get the external VirtualClock to which this Application is bound.
    VirtualClock getClock()
    {
        return null;
    }

    // Get the registry of meterics owned by this application. Metrics are
    // reported through the administrative HTTP interface, see CommandHandler.
    MetricsRegistry getMetrics()
    {
        return mMetricsRegistry;
    }

    // Ensure any App-local meterics that are "current state" gauge-like counters
    // reflect the current reality as best as possible.
    void syncOwnMetrics()
    {

    }

    // Call syncOwnMetrics on self and syncMetrics all objects owned by App.
    void syncAllMetrics()
    {

    }

    // Get references to each of the "subsystem" objects.
    //abstract TmpDirManager getTmpDirManager() = 0;
    LedgerManager getLedgerManager()
    {
        return null;
    }
    //abstract BucketManager getBucketManager() = 0;
    //abstract CatchupManager getCatchupManager() = 0;
    //abstract HistoryManager getHistoryManager() = 0;
    //abstract ProcessManager getProcessManager() = 0;
    Herder getHerder() 
    {
        return null;
    }
    //abstract Invariants getInvariants() = 0;
    OverlayManager getOverlayManager() 
    {
        return null;
    }

    Database getDatabase()
    {
        return null;
    }

    PersistentState getPersistentState()
    {
        return null;
    }

    //abstract CommandHandler getCommandHandler() = 0;
    //abstract WorkManager getWorkManager() = 0;
    //abstract BanManager getBanManager() = 0;
    //abstract StatusManager getStatusManager() = 0;

    // Get the worker IO service, served by background threads. Work posted to
    // this io_service will execute in parallel with the calling thread, so use
    // with caution.
    IOService getWorkerIOService()
    {
        return null;
    }

    // Perform actions necessary to transition from BOOTING_STATE to other
    // states. In particular: either reload or reinitialize the database, and
    // either restart or begin reacquiring SCP consensus (as instructed by
    // Config).
    void start()
    {

    }

    // Stop the io_services, which should cause the threads to exit once they
    // finish running any work-in-progress.
    void gracefulStop()
    {

    }

    // Wait-on and join all the threads this application started; should only
    // return when there is no more work to do or someone has force-stopped the
    // worker io_service. Application can be safely destroyed after this
    // returns.
    void joinAllThreads()
    {

    }

    // If config.MANUAL_MODE=true, force the current ledger to close and return
    // true. Otherwise return false. This method exists only for testing.
    bool manualClose()
    {
        return true;
    }

    // If config.ARTIFICIALLY_GENERATE_LOAD_FOR_TESTING=true, generate some load
    // against the current application.
    void generateLoad(ulong nAccounts, ulong nTxs, ulong txRate, bool autoRate)
    {

    }

    // Access the load generator for manual operation.
    //abstract ref LoadGenerator getLoadGenerator() = 0;

    // Run a consistency check between the database and the bucketlist.
    void checkDB()
    {

    }

    // perform maintenance tasks
    void maintenance()
    {

    }

    // Execute any administrative commands written in the Config.COMMANDS
    // variable of the config file. This permits scripting certain actions to
    // occur automatically at startup.
    void applyCfgCommands()
    {

    }

    // Report, via standard logging, the current state any meterics defined in
    // the Config.REPORT_METRICS (or passed on the command line with --metric)
    void reportCfgMetrics()
    {

    }

    // Report information about the instance to standard logging
    void reportInfo()
    {

    }

    // Returns the hash of the passphrase, used to separate various network
    // instances
    Hash mNetworkID;
    ref Hash getNetworkID()
    {
        return mNetworkID;
    }

    void newDB()
    {

    }

    // Factory: create a new Application object bound to `clock`, with a local
    // copy made of `cfg`.
    //static Application create(VirtualClock clock, const Config cfg, bool newDB = true)
    //{
    //    return null;
    //}

protected:
    Config mConfig;
    MetricsRegistry mMetricsRegistry;

    this()
    {
        mConfig = new Config();
        mMetricsRegistry = new MetricsRegistry();
    }

}