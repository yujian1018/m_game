%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 玩家属性
%%%
%%% Created : 22. 七月 2016 下午5:07
%%%-------------------------------------------------------------------
-module(chat_handler).

-include("im_pub.hrl").

-export([
    handler_call/2,
    handler_msg/4
]).

handler_call(_Uid, {?PROTO_CHAT_TO_USER, FromAppId, MsgType, Msg, Attach}) ->
    AppId = ?get(?app_id),
    if
        AppId =:= FromAppId ->
            ?tcp_send(chat_sproto:encode(?PROTO_CHAT_ABCAST_TO_USER, [MsgType, Msg, Attach])),
            ok;
        true ->
            {error, ?ERR_NOT_ONLINE}
    end;

handler_call(_Uid, _Msg) -> ok.


handler_msg(_Uid, _From, _FromModule, {add, Tid}) ->
    Tids = ?get(?tid),
    ?put(?tid, sets:add_element(Tid, Tids));

handler_msg(_Uid, _From, _FromModule, {?PROTO_CHAT_TO_WORLD, MsgType, Msg, Attach}) ->
    ?tcp_send(chat_sproto:encode(?PROTO_CHAT_ABCAST_TO_WORLD, [MsgType, Msg, Attach]));

handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).