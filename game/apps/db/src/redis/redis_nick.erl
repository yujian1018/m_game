%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc redis 操作
%%%
%%% Created : 14. 九月 2016 下午3:56
%%%-------------------------------------------------------------------
-module(redis_nick).

-include("db_pub.hrl").

-define(TAB_NICK(Nick), <<"nick:", Nick/binary>>).

-export([
    get/1,
    set/2, set/1,
    del/1
]).


get(Nick) ->
    case db_redis:q([<<"GET">>, ?TAB_NICK(Nick)]) of
        {ok, ?undefined} -> [];
        {ok, Data} -> {ok, Data};
        _ -> []
    end.

set(Nick, PlayerId) ->
    case redis_nick:get(Nick) of
        {ok, _Data} ->
            error;
        [] ->
            db_redis:q([<<"SET">>, ?TAB_NICK(Nick), PlayerId])
    end.

set(List) ->
    db_redis:qp([
        [<<"SET">>, ?TAB_NICK(Nick), Uid] || [Nick, Uid] <- List, Nick =/= ?undefined
    ]).

del(Nick) ->
    db_redis:q([<<"DEL">>, ?TAB_NICK(Nick)]).