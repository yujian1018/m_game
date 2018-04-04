%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 06. 五月 2017 下午3:19
%%%-------------------------------------------------------------------
-module(redis_offline).

-include("db_pub.hrl").


-define(TAB(Uid), <<"offline:", Uid/binary>>).

-export([
    get/1,
    set/2, set/3
]).


get(Uid) ->
    UidBin = integer_to_binary(Uid),
    Key = ?TAB(UidBin),
    case ?rpc_db_call(db_redis, q, [[<<"GET">>, Key]]) of
        {ok, ?undefined} -> error;
        {ok, RoomIdBin} ->
            ?rpc_db_call(db_redis, q, [[<<"DEL">>, Key]]),
            RoomIdBin;
        _ -> error
    end.



set(Uid, RoomId) ->
    UidBin = integer_to_binary(Uid),
    Key = ?TAB(UidBin),
    ?rpc_db_call(db_redis, qp, [[
        [<<"SET">>, Key, <<"room_id">>, RoomId],
        [<<"EXPIRE">>, Key, 86400]
    ]]).


set(Uid, Deadline, RoomIdBin) ->
    UidBin = integer_to_binary(Uid),
    Now = erl_time:now(),
    DiffTime = Deadline - Now + 5,
    Key = ?TAB(UidBin),
    ?rpc_db_call(db_redis, qp, [[
        [<<"SET">>, Key, RoomIdBin],
        [<<"EXPIRE">>, Key, DiffTime]
    ]]).