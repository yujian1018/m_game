%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2017 上午10:33
%%%-------------------------------------------------------------------
-module(cache_config).


-behaviour(cache_srv).
-include("http_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").

-export([
    get_v/1,
    select/0,
    refresh/0
]).


-record(cache_config, {
    k,
    v
}).


load_cache() ->
    [
        #cache_mate{
            name = cache_config,
            key_pos = #cache_config.k
        }
    ].

get_v(Key) ->
    case ets:lookup(cache_config, Key) of
        [] -> <<>>;
        [#cache_config{v = V}] ->
            V
    end.


select() ->
    ?rpc_db_call(db_mysql, ea, [<<"SELECT k, v from config WHERE op_state = 1 limit 0, 1000;">>]).


refresh() ->
    Data = select(),
    FunFoldl =
        fun([K, V], {RecordsAcc, IdsAcc}) ->
            {
                [#cache_config{k = K, v = V} | RecordsAcc],
                [K | IdsAcc]
            }
        end,
    {AllRecords, AllIds} = lists:foldl(FunFoldl, {[], []}, Data),
    cache_srv:reset_record(cache_config, AllRecords, AllIds).