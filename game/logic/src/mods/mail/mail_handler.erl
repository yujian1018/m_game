%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2017 下午3:16
%%%-------------------------------------------------------------------
-module(mail_handler).

-include("logic_pub.hrl").
-include("player_behaviour.hrl").

-export([
    add_mail/5
]).


load_data(Uid) ->
    {Sql1, Fun1} = load_mail:load_data(Uid),
    {Sql2, Fun2} = mail_link_auto_sql:load_data(Uid),
    {[Sql1, Sql2], [Fun1, Fun2]}.


online(Uid) ->
    MailMngIds = mail_link_auto_sql:data(Uid),
    case cache_mail_mng:all_ids() of
        [] -> ok;
        MailMngs ->
            MyChannelId = ?get(?channel_id),
            FunMap =
                fun({MngId, ChannelId, _Expires, MailId, _Limit}) ->
                    if
                        ChannelId =:= -999 orelse ChannelId =:= MyChannelId ->
                            case lists:member([MngId], MailMngIds) of
                                true -> ok;
                                false -> load_mail:add_mail(Uid, MailId, MngId)
                            end;
                        true -> error
                    end
                end,
            lists:map(FunMap, MailMngs)
    end.


online_send_data(Uid) ->
    mail_proto:online_send(load_mail:to_data(Uid)).


save_data(Uid) ->
    [mail_auto_sql:save_data(Uid), mail_link_auto_sql:save_data(Uid)].


terminate(Uid) ->
    mail_auto_sql:del_data(Uid),
    mail_link_auto_sql:del_data(Uid).


handler_call(_Uid, _Msg) -> ok.


handler_msg(_Uid, _FromPid, _FromModule, {FromUid, Title, Content, Attachment}) ->
    load_mail:add_mail(FromUid, Title, Content, Attachment);

handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).


add_mail(Uid, FromUid, Title, Content, Attachment) ->
    ?send_cast_msg(Uid, ?mail_handler, {FromUid, Title, Content, Attachment}).