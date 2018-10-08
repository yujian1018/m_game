%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc redis 操作
%%%
%%% Created : 14. 九月 2016 下午3:56
%%%-------------------------------------------------------------------
-module(redis_rank).

-include("db_pub.hrl").

-export([
    set/3,
    get/3,
    get_my_rank/2
]).

-define(TAB_RANK(RankName), <<"rank:", RankName/binary>>).


-spec set(Uid :: integer(), RankType :: binary(), V :: integer()) -> ok.
set(Uid, RankType, V) ->
    RankTypeBin = integer_to_binary(RankType),
    ?rpc_db_call(db_redis, q, [[<<"ZADD">>, ?TAB_RANK(RankTypeBin), V, Uid]]).


get(RankType, SIndex, EIndex) ->
    case ?rpc_db_call(db_redis, q, [[<<"ZREVRANGE">>, ?TAB_RANK(RankType), SIndex, EIndex]]) of
        {ok, ?undefined} -> [];
        {ok, Zlist} -> Zlist;
        _ -> []
    end.


get_my_rank(Uid, RankType) ->
    Key = ?TAB_RANK(RankType),
    case ?rpc_db_call(db_redis, qp, [[
        [<<"ZREVRANK">>, Key, Uid],
        [<<"ZSCORE">>, Key, Uid]
    ]]) of
        [{ok, Rank}, {ok, Score}] ->
            NewRank =
                if
                    Rank =:= ?undefined -> 0;
                    true -> binary_to_integer(Rank)
                end,
            NewScore =
                if
                    Score =:= ?undefined -> 1;
                    true -> binary_to_integer(Score)
                end,
            {NewRank, NewScore};
        _ -> {0, 1}
    end.

