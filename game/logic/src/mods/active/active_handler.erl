%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 04. 八月 2017 下午3:52
%%%-------------------------------------------------------------------
-module(active_handler).


-include("logic_pub.hrl").
-include("player_behaviour.hrl").

-export([
]).


load_data(Uid) ->
    load_active:load_data(Uid).


online(_Uid) -> ok.


online_send_data(Uid) ->
    active_proto:online_send(load_active:data(Uid)).


save_data(Uid) ->
    load_active:save_data(Uid).


terminate(Uid) ->
    load_active:del_data(Uid).


handler_call(Uid, ?event_zero_refresh) ->
    load_active:reset_v(Uid);

handler_call(Uid, ?event_create_role) ->
    active_proto:get_prize(Uid, ?ACTIVE_LV_GIFT, ?ACTIVE_GIFT_LV_1, ?ACTIVE_PRIZE_TYPE_SERVER);

handler_call(_Uid, _Msg) -> ok.


handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).