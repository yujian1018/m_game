#include "erl_nif.h"
#include <stdio.h>

static ERL_NIF_TERM get_bin_address(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ErlNifBinary bin;
    enif_inspect_binary(env, argv[0], &bin);
    char buf[256];
    sprintf(buf, "bin: size=%zu, ptr=%p", bin.size, bin.data);
    return enif_make_string(env, buf, ERL_NIF_LATIN1);
}
static ErlNifFunc nif_funcs[] =
{
    {"get_bin_address", 1, get_bin_address}
};

ERL_NIF_INIT(bintest,nif_funcs,NULL,NULL,NULL,NULL);