%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 玩家属性
%%%
%%% Created : 22. 七月 2016 下午5:07
%%%-------------------------------------------------------------------
-module(chat_proto).

-include("im_pub.hrl").

-export([
    handle_info/2
]).

handle_info(?PROTO_CHAT_TO_USER, [ToUid, MsgType, Msg, Attach]) ->
    int_can:natural_num(ToUid),
    list_can:member(MsgType, chat_def:msg_type_b(), ?ERR_IM_NO_MSG_TYPE),
    binary_can:illegal(Msg),
    binary_can:max_size(Msg, 1024),
    binary_can:illegal(Attach),
    binary_can:max_size(Attach, 256),
    ToPid =
        case player_mgr:get(ToUid) of
            false -> ?return_err(?ERR_NOT_ONLINE);
            Pid -> Pid
        end,
    MyAppId = ?get(?app_id),
    catch gen_server:call(ToPid, ?call_msg(chat_handler, {?PROTO_CHAT_TO_USER, MyAppId, MsgType, Msg, Attach})),
    ?tcp_send(chat_sproto:encode(?PROTO_CHAT_TO_USER, 1));

handle_info(?PROTO_CHAT_TO_ROOM, [RoomId, MsgType, Msg, Attach]) ->
    binary_can:illegal(RoomId),
    binary_can:max_size(RoomId, 32),
    list_can:member(MsgType, chat_def:msg_type_b(), ?ERR_IM_NO_MSG_TYPE),
    binary_can:illegal(Msg),
    binary_can:max_size(Msg, 1024),
    binary_can:illegal(Attach),
    binary_can:max_size(Attach, 256),
    Iid = ?get(?i_id),
    room_mgr:abcast(Iid, RoomId, MsgType, Msg, Attach),
    ?tcp_send(chat_sproto:encode(?PROTO_CHAT_TO_ROOM, 1));

handle_info(?PROTO_CHAT_TO_WORLD, [MsgType, Msg, Attach]) ->
    list_can:member(MsgType, chat_def:msg_type_b(), ?ERR_IM_NO_MSG_TYPE),
    binary_can:illegal(Msg),
    binary_can:max_size(Msg, 1024),
    binary_can:illegal(Attach),
    binary_can:max_size(Attach, 256),
    player_mgr:abcast(chat_handler, {?PROTO_CHAT_TO_WORLD, MsgType, Msg, Attach}),
    ?tcp_send(chat_sproto:encode(?PROTO_CHAT_TO_WORLD, 1));


handle_info(_Cmd, _RawData) ->
    ?LOG("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).