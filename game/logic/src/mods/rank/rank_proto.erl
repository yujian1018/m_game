%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 15. 八月 2016 下午12:01
%%%-------------------------------------------------------------------
-module(rank_proto).

-include("logic_pub.hrl").

-export([handle_info/2]).


handle_info(?PROTO_RANK, [Type]) ->
    counter_can:get(?counter_rank_gold, ?COUNTER_RANK_GOLD, ?TIMEOUT_MI_5 / 1000),
    RankID =
        if
            Type =:= ?RANK_GOLD -> integer_to_binary(?RANK_GOLD);
            Type =:= ?RANK_LV -> integer_to_binary(?RANK_LV)
        end,
    {ok, Pack} = ?rpc_db_call(redis_set, get, [RankID]),
    ?tcp_send(rank_sproto:encode(?PROTO_RANK, ?decode(Pack)));

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).
