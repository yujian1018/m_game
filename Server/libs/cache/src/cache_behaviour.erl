%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 04. 十二月 2015 上午11:44
%%%-------------------------------------------------------------------
-module(cache_behaviour).

-callback load_cache() -> [] | [tuple()].

-define(no_cache_behaviour, 1).
-include("cache_pub.hrl").

-export([
    init/1,
    load_file/1,
    set/2,
    cache_data/4
]).


init(Config) when Config#cache_mate.store =:= ets ->
    ?put(cache_behaviour_mod, to_ets),
    to_ets:init(Config);
init(Config) when Config#cache_mate.store =:= mnesia ->
    ?put(cache_behaviour_mod, to_mnesia),
    to_mnesia:init(Config).


load_file(Config) when Config#cache_mate.db_type =:= mysql ->
    if
        Config#cache_mate.fields =:= none -> ok;
        Config#cache_mate.mysql_pool =:= none -> ok;
        Config#cache_mate.store =:= mnesia ->
            IsSync =
                case application:get_env(cache, is_sync) of
                    {ok, true} -> true;
                    _ -> false
                end,
            if
                IsSync -> aof_mysql:load_file(Config);
                true -> ok
            end;
        true ->
            aof_mysql:load_file(Config)
    end;

load_file(Config) when Config#cache_mate.db_type =:= file ->
    aof_file:load_file(Config).


set(Config, Items) ->
    (?get(cache_behaviour_mod)):set(Config, Items).


cache_data(Config, Md5, FileRecords, AllData) ->
    (?get(cache_behaviour_mod)):cache_data(Config, Md5, FileRecords, AllData).