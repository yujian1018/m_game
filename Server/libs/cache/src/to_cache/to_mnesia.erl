%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 30. 五月 2018 下午3:12
%%%-------------------------------------------------------------------
-module(to_mnesia).

-define(no_cache_behaviour, 1).
-include("cache_pub.hrl").

-export([
    init/1,
    set/2,
    cache_data/4
]).


init(Config) ->
    mnesia:start(),
    {ok, MnesiaDir} = application:get_env(mnesia, dir),
    case filelib:is_dir(MnesiaDir) of
        true -> ok;
        false ->
            [file:make_dir(I) || I <- erl_file:dirs(MnesiaDir)],
            mnesia:stop(),
            mnesia:delete_schema([node()]),
            mnesia:create_schema([node()]),
            mnesia:start()
    end,
    case ?mnesia_new(Config#cache_mate.name, Config#cache_mate.cache_copies, Config#cache_mate.type, Config#cache_mate.fields, []) of
        {atomic, ok} -> ok;
        Err -> ?WARN("WARN mnesia, ~tp~n ERR:~tp", [Config, Err])
    end.


%% @doc 同时插入两张表的情况
set(_Config, Items) -> [mnesia:dirty_write(Item) || Item <- Items].


cache_data(CacheConfig, _Md5, FileRecords, _AllData) ->
    if
        is_function(CacheConfig#cache_mate.callback) ->
            Records = (CacheConfig#cache_mate.callback)(FileRecords),
            [mnesia:dirty_write(Record) || Record <- Records];
        true ->
            ok
    end,
    [mnesia:add_table_index(CacheConfig#cache_mate.name, Ix) || Ix <- CacheConfig#cache_mate.index].