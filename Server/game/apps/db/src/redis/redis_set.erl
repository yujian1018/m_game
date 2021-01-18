%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc redis 操作
%%%
%%% Created : 14. 九月 2016 下午3:56
%%%-------------------------------------------------------------------
-module(redis_set).

-include("db_pub.hrl").

-define(TAB_SET(Key), <<"set:", Key/binary>>).

-export([
    exit/2,
    set/2,
    get/1
]).

exit(Key, V) ->
    Key1 = ?TAB_SET(Key),
    case ?rpc_db_call(db_redis, q, [[<<"GET">>, Key1]]) of
        {ok, V} -> true;
        _ -> false
    end.


set(Key, V) ->
    Key1 = ?TAB_SET(Key),
    ?rpc_db_call(db_redis, q, [[<<"SET">>, Key1, V]]).


get(Key) ->
    Key1 = ?TAB_SET(Key),
    ?rpc_db_call(db_redis, q, [[<<"GET">>, Key1]]).