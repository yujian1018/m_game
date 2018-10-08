%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 道具管理
%%%
%%% Created : 22. 七月 2016 下午5:19
%%%-------------------------------------------------------------------
-module(item_handler).

-include("logic_pub.hrl").
-include("player_behaviour.hrl").


load_data(Uid) ->
    load_item:load_data(Uid).


online(_Uid) -> ok.


online_send_data(Uid) ->
    Data = load_item:get_v(Uid),
    item_proto:online_send(Uid, Data).


save_data(Uid) ->
    load_item:save_data(Uid).


terminate(Uid) ->
    load_item:del_data(Uid).


handler_call(_Uid, _Msg) -> ok.


handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).