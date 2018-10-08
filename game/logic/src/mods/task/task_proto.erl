%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 11. 八月 2017 下午4:25
%%%-------------------------------------------------------------------
-module(task_proto).


-include("obj_pub.hrl").


-export([
    handle_info/2,
    online_send/1,
    send_to_client/1
]).


handle_info(?PROTO_TASK_RECEIVE, [ChainId, Index]) ->
    case global_task:get_data(ChainId, Index) of
        [] -> ?return_err(?ERR_ARG_ERROR);
        {PrizeId, LimitId, _ConditionNum, AllowSetting} ->
            Uid = erlang:get(?uid),
            cost_can:asset(Uid, LimitId),
            if
                AllowSetting =:= ?TRUE -> task_auto_sql:set_guide_client(ChainId, Index, PrizeId);
                true -> task_auto_sql:set_guide(ChainId, Index, PrizeId)
            end,
            log_ex:log_task(Uid, ChainId, Index)
    end,
    ?tcp_send(guide_sproto:encode(?PROTO_TASK_RECEIVE, 1));

handle_info(?PROTO_TASK_GIVE_UP, ChainId) ->
    case global_task:get_data(ChainId, 1) of
        [] -> ?return_err(?ERR_ARG_ERROR);
        {_PrizeId, _LimitId, _ConditionNum, AllowSetting} ->
            if
                AllowSetting =:= ?TRUE ->
                    Uid = erlang:get(?uid),
                    log_ex:log_task(Uid, ChainId, -1);
                true ->
                    ok
            end
    end,
    ?tcp_send(guide_sproto:encode(?PROTO_TASK_GIVE_UP, 1));

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).


online_send(Data) ->
    ?tcp_send(guide_sproto:encode(?PROTO_TASK_ONLINE_DATA, Data)).

send_to_client(Data) ->
    ?tcp_send(guide_sproto:encode(?PROTO_TASK_UPDATE, Data)).
