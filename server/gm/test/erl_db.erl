%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 十月 2017 下午8:20
%%%-------------------------------------------------------------------
-module(erl_db).

-include("gm_pub.hrl").

-export([
    do_mysql/3,
    do_mysql/4
]).

do_mysql(Fun, Uids, Acc) -> do_mysql(Fun, Uids, Acc, 100).

do_mysql(_Fun, [], Acc, _Len) -> lists:append(lists:reverse(Acc));
do_mysql(Fun, Uids, Acc, Len) ->
    {NewUids, UidsAcc} = do_uid(0, Len, Uids, []),
    Data = Fun(NewUids),
    ?INFO("do_mysql:~p~n", [[length(Uids), length(UidsAcc), length(Data)]]),
    do_mysql(Fun, UidsAcc, [Data | Acc], Len).


do_uid(_SIndex, _Index, [], Acc) -> {lists:reverse(Acc), []};
do_uid(Index, Index, Uids, Acc) -> {lists:reverse(Acc), Uids};
do_uid(SIndex, Index, [Uid | Uids], Acc) ->
    do_uid(SIndex + 1, Index, Uids, [Uid | Acc]).