#include "erl_nif.h"
#include <string.h>
#include <stdio.h>


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
