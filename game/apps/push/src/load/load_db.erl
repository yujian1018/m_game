%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 九月 2017 下午5:27
%%%-------------------------------------------------------------------
-module(load_db).

-include("push_pub.hrl").

-export([
    all_uids/0,
    card_uids/0
]).



all_uids() ->
    Now = integer_to_binary(erl_time:now() - 86400 * 10),
    ordsets:from_list([Uin || [Uin] <- ?rpc_db_call(db_mysql, ed, [<<"SELECT DISTINCT b.`uin` FROM attr AS a, player AS b WHERE a.`is_ai` = 0 AND a.`offline_times` >= ", Now/binary, " AND a.uid = b.uid;">>])]).

card_uids() ->
    NowBin = integer_to_binary(erl_time:now() + 86400),
    ordsets:from_list([Uin || [Uin] <- ?rpc_db_call(db_mysql, ed, [<<"SELECT DISTINCT b.uin FROM card AS a, player AS b  WHERE a.deadline_times >= ", NowBin/binary, " AND a.uid = b.`uid`;">>])]).