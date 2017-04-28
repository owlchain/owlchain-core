module clips.environment;

import clips.c.clips;
import clips.value;
import clips.utility;

import std.string:toStringz;
import core.sync.mutex:Mutex;

class Environment 
{
    void *m_cobj; 
    shared Mutex m_mutex_run;
    shared Mutex m_mutex_run_signal;
    
    this(){
        m_cobj = CreateEnvironment();
        m_mutex_run = new shared Mutex;
        m_mutex_run_signal = new shared Mutex;
    }

    ~this()
    {
        EnvRemovePeriodicFunction( m_cobj, cast(char *)"clips_periodic_callback" );
        EnvRemoveResetFunction( m_cobj, cast(char *)"clips_reset_callback" );
        EnvRemoveRunFunction( m_cobj, cast(char *)"clips_rule_firing_callback" );

        //m_environment_map.erase(m_cobj);

        DestroyEnvironment( m_cobj );

        // std::map<std::string, char *>::iterator r;
        // for (r = m_func_restr.begin(); r != m_func_restr.end(); ++r) {
        //     free(r->second);
        // }
        // m_func_restr.clear();
    }

    void * cobj() { return m_cobj; }    

    bool batchEvaluate( scope string filename ) {
        return cast(bool)EnvBatchStar( m_cobj, cast(char*)filename.toStringz );
    }

    Values evaluate( scope string expression )
    {
        DATA_OBJECT clipsdo;
        int result;
        result = EnvEval( m_cobj, cast(char*)expression.toStringz, &clipsdo );
        if ( result )
            return data_object_to_values( clipsdo );
        else
            return values();
    }

    bool binaryLoad( scope string filename ) {
        return cast(bool)EnvBload( m_cobj, cast(char*)filename.toStringz );
    }

    bool binarySave( scope string filename ) {
        return cast(bool)EnvBsave( m_cobj, cast(char*)filename.toStringz );
    }

    bool build( scope string construct ) {
        return cast(bool)EnvBuild( m_cobj, cast(char*)construct.toStringz );
    }

    void clear() {
        EnvClear( m_cobj );
    }

    void reset() {
        EnvReset( m_cobj );
    }

    bool save( scope string filename )
    {
        return cast(bool)EnvSave( m_cobj, cast(char *)filename.toStringz );  
    }

    bool isDribbleActive( ) {
        return cast(bool)EnvDribbleActive( m_cobj );
    }

    bool dribbleOff( ) {
        return cast(bool)EnvDribbleOff( m_cobj );
    }

    bool dribbleOn( scope string filename )
    {
        return cast(bool)EnvDribbleOn( m_cobj, cast(char*)filename.toStringz );
    }

    int isWatched( scope string item ) {
        return EnvGetWatchItem( m_cobj, cast(char*)item.toStringz );
    }

    bool watch( scope string item )
    {
        return cast(bool)EnvWatch( m_cobj, cast(char*)item.toStringz );
    }

    bool unwatch( scope string item )
    {
        return cast(bool)EnvUnwatch( m_cobj, cast(char*)item.toStringz );
    }

    long run( long runlimit ) //shared @safe nothrow @nogc
    {
        long executed;
        m_mutex_run.lock_nothrow(); // Grab the lock before running
        executed = EnvRun( m_cobj, runlimit ); // Run CLIPS
        m_mutex_run_signal.lock_nothrow(); // Lock the emit signal to guarantee that another run doesn't emit first
        m_mutex_run.unlock_nothrow(); // Unlock the run, because we have the signal lock
        //m_signal_run.emit(executed); // Emit the signal for this run
        m_mutex_run_signal.unlock_nothrow(); // Unlock the signal
        return executed;
    }
}

unittest {
    auto env = new Environment;

    env.build(`(clear)
    (deftemplate girl
        (slot name)
        (slot sex (default female)) 
        (slot age (default 4)))
    (deftemplate woman
        (slot name)
        (slot sex (default female)) 
        (slot age (default 25)))
    (deftemplate boy
        (slot name)
        (slot sex (default male)) 
        (slot age (default 4)))
    (deftemplate man
        (slot name)
        (slot sex (default male)) 
        (slot age (default 25)))
    (deffacts PEOPLE
        (man (name Man-1) (age 18)) 
        (man (name Man-2) (age 60)) 
        (woman (name Woman-1) (age 18)) 
        (woman (name Woman-2) (age 60)) 
        (woman (name Woman-3))
        (boy (name Boy-1) (age 8)) 
        (boy (name Boy-2))
        (boy (name Boy-3))
        (boy (name Boy-4))
        (girl (name Girl-1) (age 8))
        (girl (name Girl-2)))
    (reset)
    (facts)
    `);
    //env.load("strips.clp");
    auto v = env.evaluate(`(facts)`);
    env.watch("all");
    env.reset();
    //env.build();
    //env.clear();
    env.run(-1);
    writefln("clips.environment!!");
}