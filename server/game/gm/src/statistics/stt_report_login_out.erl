%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 14. 十一月 2017 下午4:25
%%%-------------------------------------------------------------------
-module(stt_report_login_out).


-export([
    report/3
]).

report(STimeBin, ETimeBin, _ChannelIds) ->
    LoginOutLayer = erl_mysql:execute(pool_log_1, [
        <<"SELECT v, count(*), COUNT(distinct uid) FROM log_login_op WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, " AND type = 1 and uid not in (select uid from dz_account.white_list) GROUP BY v;">>
    ]),
    if
        LoginOutLayer =:= [] -> ok;
        true ->
            erl_mysql:execute(pool_log_1, [
                <<"INSERT INTO report_login_out (c_times,channel_id,layer_id,v, count_roles) VALUES ">>, calculate(STimeBin, LoginOutLayer, <<>>), <<";">>
            ])
    end.


calculate(_STimeBin, [], Acc) ->
    Acc;

calculate(STimeBin, [[LayerId, Count, CountRoles] | Data1], Acc) ->
    NewAcc =
        if
            LayerId =:= <<"">> -> Acc;
            Acc =:= <<>> -> erl_mysql:sql([STimeBin, <<"-999">>, LayerId, Count, CountRoles]);
            true -> <<Acc/binary, ",", (erl_mysql:sql([STimeBin, <<"-999">>, LayerId, Count, CountRoles]))/binary>>
        end,
    calculate(STimeBin, Data1, NewAcc).
