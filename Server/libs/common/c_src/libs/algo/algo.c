#include "algo.h"

#define min(x, y) (x < y ? x : y)

// algo:edit_distance(<<"dakaichangweiyi">>,<<"feichaadfaabaaaaa">>).

static ERL_NIF_TERM edit_distance(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary src_bin, dest_bin;
    enif_inspect_binary(env, argv[0], &src_bin);
    enif_inspect_binary(env, argv[1], &dest_bin);

    char *src = enif_alloc(src_bin.size + 1);
    char *dest = enif_alloc(dest_bin.size + 1);

    memcpy(src, src_bin.data, src_bin.size);
    memcpy(dest, dest_bin.data, dest_bin.size);

    src[src_bin.size] = '\0';
    dest[dest_bin.size] = '\0';

    // printf("aaa %ld  %ld %s  %s\n", src_bin.size, dest_bin.size, src, dest);

    int i, j;
    int len1 = (int)strlen(src);
    int len2 = (int)strlen(dest);
    int d[len1][len2];

    for (i = 0; i < len1; ++i)
    {
        d[i][0] = i;
    }
    for (j = 0; j < len2; ++j)
    {
        d[0][j] = j;
    }
    // printf("bbb %s  %s %d %d\n", src, dest, len1, len2);
    for (i = 1; i <= len1; i++)
    {
        for (j = 1; j <= len2; j++)
        {
            //            printf("i:%d j:%d len1:%d len2:%d %c %c \n", i, j, len1, len2, src[i-1], dest[j-1]);
            if (src[i - 1] == dest[j - 1])
            {
                // printf("aaa %d %d", i, j);
                d[i][j] = d[i - 1][j - 1];
            }
            else
            {
                // printf("bbb %d", i);
                // printf("ccc %d", j);
                int ins = d[i][j - 1] + 1;
                int del = d[i - 1][j] + 1;
                int rep = d[i - 1][j - 1] + 1;

                d[i][j] = min(min(ins, del), rep);
            }
        }
    }

    enif_free(src);
    enif_free(dest);

    return enif_make_int(env, d[len1][len2]);
}

static ErlNifFunc nif_funcs[] =
    {
        {"edit_distance", 2, edit_distance}};

ERL_NIF_INIT(algo, nif_funcs, load, reload, upgrade, unload)