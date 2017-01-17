module owlchain.utils.config;

import sdlang;
import vibe.core.file:readFile,writeFile;

class Config {

    private string filePath;
    private Tag _root;

    this(){
        _root = new Tag;
    }

    this(string path){
        loadFile(path);
    }

    Tag root() {
        return _root;
    }

    void loadFile(string path){
        filePath = path;
        _root = parseFile(filePath);
    }

    void loadString(string contents){
         _root = parseSource(contents,filePath);
    }

    void loadString(ubyte[] contents){
         loadString(cast(string)contents);
    }

    void saveFile(string path){
        writeFile(path, cast(ubyte[])_root.toSDLDocument());
    }

    string ipv4(){
        return _root.getTagValue!string("ipv4", "127.0.0.1");
    }

    string ipv6(){
        return _root.getTagValue!string("ipv6", "::");
    }

    int port() {
        return _root.getTagValue!int("port", 80);
    }
}

// more detail info refer to
// https://github.com/Abscissa/SDLang-D/blob/master/HOWTO.md
unittest
{
    import std.algorithm;
    import std.stdio;

    auto cfg = new Config;
    Tag root = cfg.root();
    assert(cfg.ipv4() == "127.0.0.1");
    assert(cfg.ipv6() == "::");
    assert(cfg.port() == 80);

    cfg.loadString(`
        ipv4 "8.8.8.8"
        ipv6 "::1"
        port 1111
        relay "1.1.1.1"
        wallet "mywallet"
        `);

    assert(cfg.ipv4() == "8.8.8.8");
    assert(cfg.ipv6() == "::1");
    assert(cfg.port() == 1111);
}


private static Config _config;
private static bool loaded=false;

enum DEFAULT_CONFIG_PATH = "owlchain-config.sdl";

Config config(string path=DEFAULT_CONFIG_PATH){
    if(!loaded){
        _config = new Config(path);
    }
    return _config;
}

unittest {
    auto cfg = config();
    assert(cfg.ipv4() == "127.0.0.1");
    assert(cfg.ipv6() == "::");
    assert(cfg.port() == 8080);
}


