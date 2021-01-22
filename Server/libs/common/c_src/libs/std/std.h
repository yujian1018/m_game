#include "erl_nif.h"
//#include "std_string.h"

#include <cstring>
#include <iostream>
#include <string>

using namespace std;

static int load(ErlNifEnv *env, void **priv, ERL_NIF_TERM load_info)
{
    return 0;
}
static int reload(ErlNifEnv *env, void **priv, ERL_NIF_TERM load_info)
{
    return 0;
}
static int upgrade(ErlNifEnv *env, void **priv, void **old_priv, ERL_NIF_TERM load_info)
{
    return 0;
}

static void unload(ErlNifEnv *env, void *priv)
{
    return;
}
