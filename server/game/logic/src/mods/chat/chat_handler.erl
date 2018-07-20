%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 玩家属性
%%%
%%% Created : 22. 七月 2016 下午5:07
%%%-------------------------------------------------------------------
-module(chat_handler).

-include("obj_pub.hrl").

-export([
    handler_call/2,
    handler_msg/4
]).

handler_call(_Uid, _Msg) -> ok.


handler_msg(_Uid, _FromPid, _FromModule, {abcast, ScrollId}) ->
    case cache_marquee:lookup(ScrollId) of
        [] -> ok;
        {ChannelId, Content} ->
            RChannelId = erlang:get(?channel_id),
            if
                ChannelId =:= -999 ->
                    ?tcp_send(chat_sproto:encode(?PROTO_PUSH_NOTICE, Content));
                ChannelId =:= RChannelId ->
                    ?tcp_send(chat_sproto:encode(?PROTO_PUSH_NOTICE, Content));
                true -> ok
            end
    end;

handler_msg(_Uid, _FromPid, _FromModule, {abcast, notice, Msg}) ->
    ?tcp_send(chat_sproto:encode(?PROTO_PUSH_NOTICE, Msg));

handler_msg(_Uid, _FromPid, _FromModule, {abcast, horn, Msg}) ->
    ?tcp_send(chat_sproto:encode(?PROTO_CHAT_HORN, Msg));

handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).
