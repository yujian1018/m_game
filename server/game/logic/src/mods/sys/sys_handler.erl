%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 19. 七月 2016 下午1:25
%%%-------------------------------------------------------------------
-module(sys_handler).

-include("obj_pub.hrl").
-include("player_behaviour.hrl").


load_data(_Uid) -> {<<>>, ?undefined}.


online(_Uid) -> ok.


online_send_data(_Uid) -> sys_proto:send_tips().


save_data(_Uid) -> <<>>.


terminate(_Uid) -> ok.


handler_call(_Uid, _Msg) -> ok.


handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).