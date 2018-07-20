%% Author: Administrator
%% Created: 2012-9-21
%% Description: 负责登陆,注册
%% 
-module(login_handler).

-include("obj_pub.hrl").
-include("player_behaviour.hrl").


load_data(Uid) ->
    load_log_online:load_data(Uid).


online(_Uid) -> ok.


online_send_data(_Uid) -> ok.


save_data(Uid) ->
    load_log_online:save_data(Uid).


terminate(Uid) ->
    log_online_auto_sql:del_data(Uid).


handler_call(_Uid, _Msg) -> ok.


handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).


