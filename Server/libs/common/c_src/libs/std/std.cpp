#include "std.h"

static ERL_NIF_TERM t(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);

    char *c = new char[bin.size + 1];
    memcpy(c, bin.data, bin.size);
    c[bin.size] = '\0';

    string s1 = c;
    cout << s1 << endl;

//    u16string b = to_utf16(s1);
    // cout << b << endl;

//    string s2 = to_utf8(b);
//    cout << s2 << endl;

    int len = s1.length();
    ErlNifBinary h;
    enif_alloc_binary(len, &h);
    memcpy(h.data, s1.c_str(), len);
    return enif_make_binary(env, &h);
}

static ErlNifFunc nif_funcs[] =
    {
        {"t", 1, t}};

ERL_NIF_INIT(std, nif_funcs, &load, &reload, &upgrade, &unload)

// g++  /home/yj/project/lan-erlang/haowenjiao/server/health/lib/common/c_src/libs/std/std.cpp -shared -fPIC -I /usr/local/lib/erlang/usr/include/ -o /home/yj/project/lan-erlang/haowenjiao/server/health/lib/common/priv/std.so