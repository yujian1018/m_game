%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 28. 十二月 2017 下午3:55
%%%-------------------------------------------------------------------
-module(load_mail_link).

-include("obj_pub.hrl").
-include("mail_link_auto_sql.hrl").

-export([
    add_mail_link/2
]).


add_mail_link(Uid, MngId) ->
    Record = mail_link_auto_sql:lookup(Uid),
    mail_link_auto_sql:insert(Record#mail_link{items = #?tab_last_name{mail_id = MngId, op = ?OP_ADD}}).