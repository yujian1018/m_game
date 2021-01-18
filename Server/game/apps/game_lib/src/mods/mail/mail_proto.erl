%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2017 下午3:16
%%%-------------------------------------------------------------------
-module(mail_proto).

-include("obj_pub.hrl").

-export([handle_info/2]).

-export([
    online_send/1,
    send/1
]).

handle_info(?PROTO_MAIL_SET, [MailId, St]) ->
    Uid = erlang:get(?uid),
    list_can:member(mail_def:mail_st_b(), St, ?ERR_ARG_ERROR),
    load_mail:set_st(Uid, MailId, St),
    ?tcp_send(active_sproto:encode(?PROTO_MAIL_SET, 1));

handle_info(_Cmd, _RawData) ->
    ?LOG("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).


online_send(Pack) ->
    ?tcp_send(mail_sproto:encode(?PROTO_MAIL_ONLINE_DATA, Pack)).


send(Pack) ->
    ?tcp_send(mail_sproto:encode(?PROTO_MAIL_UPDATE, Pack)).
