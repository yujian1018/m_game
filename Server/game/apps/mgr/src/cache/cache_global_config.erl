%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 管理器节点获取一个服务器的最大人数
%%%
%%% Created : 26. 十二月 2016 上午10:01
%%%-------------------------------------------------------------------
-module(cache_global_config).

-behaviour(cache_srv).
-include("mgr_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").


-export([
    select/0,
    refresh/0,
    get_v/1
]).


-define(ETS_TAB_1, cache_config).

-record(cache_config, {
    k,
    v
}).

load_cache() ->
    [
        #cache_mate{
            name = ?ETS_TAB_1,
            key_pos = #?ETS_TAB_1.k
        }
    ].


get_v(Key) ->
    case ets:lookup(?ETS_TAB_1, Key) of
        [] -> <<>>;
        [#?ETS_TAB_1{v = V}] ->
            V
    end.


refresh() ->
    refresh_config().


select() ->
    ?rpc_db_call(db_mysql, es, [<<"SELECT k1, k2, v from global_config WHERE k1 = 'fight';">>]).

refresh_config() ->
    Data = select(),
    FunFoldl =
        fun([K1, K2, V], {RecordsAcc, IdsAcc}) ->
            {
                [#?ETS_TAB_1{k = {binary_to_atom(K1, utf8), binary_to_atom(K2, utf8)}, v = V} | RecordsAcc],
                [{binary_to_atom(K1, utf8), binary_to_atom(K2, utf8)} | IdsAcc]
            }
        end,
    {AllRecords, AllIds} = lists:foldl(FunFoldl, {[], []}, Data),
    cache_srv:reset_record(?ETS_TAB_1, AllRecords, AllIds).

