%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 11. 八月 2017 下午4:26
%%%-------------------------------------------------------------------
-module(task_handler).


-include("obj_pub.hrl").
-include("player_behaviour.hrl").


load_data(Uid) ->
    task_auto_sql:load_data(Uid).


online(_Uid) -> ok.


online_send_data(Uid) ->
    Data = task_auto_sql:data(task_auto_sql:lookup(Uid)),
    task_proto:online_send([[ChainId, Index, length(PrizeLen), ProGress] || [ChainId, Index, PrizeLen, ProGress] <- Data]).


save_data(Uid) ->
    task_auto_sql:save_data(Uid).


terminate(Uid) ->
    task_auto_sql:del_data(Uid).


handler_call(_Uid, _Msg) -> ok.


handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).