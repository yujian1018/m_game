%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 28. 十二月 2017 下午3:55
%%%-------------------------------------------------------------------
-module(load_mail).

-include("logic_pub.hrl").
-include("mail_auto_sql.hrl").

-export([
    load_data/1, to_data/1,
    add_mail/3, add_mail/4,
    set_st/3
]).

load_data(Uid) ->
    Fun =
        fun([MaxAutoId, VO | VOAcc]) ->
            Record = mail_auto_sql:to_record(Uid, VO),
            mail_auto_sql:insert(Record#mail{max_auto_id = MaxAutoId}),
            VOAcc
        end,
    UidBin = integer_to_binary(Uid),
    {
        <<"select max(`auto_id`) from `mail` where uid = ", UidBin/binary,
            ";select `auto_id`, `from_uid`, `c_times`, `mail_id`, `title`, `content`, `attachment`, `status` from mail where uid = ",
            UidBin/binary, ";">>,
        Fun}.


to_data(Uid) ->
    Record = mail_auto_sql:lookup(Uid),
    Fun =
        fun(Item) ->
            MailId = Item#?tab_last_name.mail_id,
            if
                is_integer(MailId) andalso MailId > 0 ->
                    {Title, Content, PrizeId} = global_mail:get_v(MailId),
                    Attachment = global_asset:get_prize_id(PrizeId),
                    [Item#?tab_last_name.auto_id, Item#?tab_last_name.from_uid, Item#?tab_last_name.c_times, Title, Content,
                        Attachment, Item#?tab_last_name.status];
                true ->
                    [Item#?tab_last_name.auto_id, Item#?tab_last_name.from_uid, Item#?tab_last_name.c_times,
                        Item#?tab_last_name.title, Item#?tab_last_name.content,
                        Item#?tab_last_name.attachment, Item#?tab_last_name.status]
            end
        end,
    lists:map(Fun, Record#mail.items).


add_mail(Uid, MailId, MailMngId) ->
    Record = mail_auto_sql:lookup(Uid),
    Now = erl_time:now(),
    AutoId = Record#mail.max_auto_id + 1,
    Item = #?tab_last_name{auto_id = AutoId, from_uid = ?MAIL_ADMIN, c_times = Now, mail_id = MailId, op = ?OP_ADD},
    mail_auto_sql:insert(Record#mail{max_auto_id = AutoId, items = [Item | Record#mail.items]}),
    load_mail_link:add_mail_link(Uid, MailMngId).


add_mail(FromUid, Title, Content, Attachment) ->
    Uid = ?get(?uid),
    Record = mail_auto_sql:lookup(Uid),
    Now = erl_time:now(),
    AutoId = Record#mail.max_auto_id + 1,
    Item = #?tab_last_name{auto_id = AutoId, from_uid = FromUid, c_times = Now, title = Title, content = Content, attachment = Attachment, op = ?OP_ADD},
    mail_auto_sql:insert(Record#mail{max_auto_id = AutoId, items = [Item | Record#mail.items]}),
    mail_proto:send([AutoId, ?MAIL_ADMIN, Now, Title, Content, Attachment, ?MAIL_ST_DEFAULT]).


set_st(Uid, MailId, St) ->
    Record = mail_auto_sql:lookup(Uid),
    case lists:keytake(MailId, #?tab_last_name.mail_id, Record#mail.items) of
        false -> ?return_err(?ERR_MAIL_NO_ID);
        {value, Item, R} ->
            NewItems =
                if
                    St =:= ?MAIL_ST_READ andalso Item#?tab_last_name.status =:= ?MAIL_ST_DEFAULT ->
                        if
                            Item#?tab_last_name.op =:= ?OP_ADD ->
                                [Item#?tab_last_name{status = ?MAIL_ST_READ, op = ?OP_ADD} | R];
                            true ->
                                [Item#?tab_last_name{status = ?MAIL_ST_READ, op = ?OP_UPDATE} | R]
                        end;
                    St =:= ?MAIL_ST_GET andalso Item#?tab_last_name.status =:= ?MAIL_ST_READ ->
                        if
                            Item#?tab_last_name.op =:= ?OP_ADD ->
                                [Item#?tab_last_name{status = ?MAIL_ST_GET, op = ?OP_ADD} | R];
                            true ->
                                [Item#?tab_last_name{status = ?MAIL_ST_GET, op = ?OP_UPDATE} | R]
                        end;
                    true -> ?return_err(?ERR_MAIL_NO_ID)
                end,
            mail_auto_sql:insert(Record#mail{items = NewItems})
    end.