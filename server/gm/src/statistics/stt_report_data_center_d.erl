%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午3:43
%%%-------------------------------------------------------------------
-module(stt_report_data_center_d).

-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, ETimeBin, ChannelIds) ->
    Sql1 = lists:map(
        fun(ChannelId) ->
            if
                ChannelId =:= <<"-999">> ->
                    [
                        %% @doc 帐号注册数
                        <<"SELECT -999, COUNT(*) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, ";">>,
                        %% @doc 充值金额
                        <<"SELECT -999, SUM(rmb) FROM  orders  WHERE s_times >= ", STimeBin/binary, " AND s_times < ", ETimeBin/binary, " AND state = 2;">>,
                        %% @doc 充值用户数,充值次数
                        <<"SELECT -999, COUNT(DISTINCT uid), COUNT(*) FROM orders WHERE s_times >= ", STimeBin/binary, " AND s_times < ", ETimeBin/binary, " AND state = 2;">>
                    ];
                true ->
                    [
                        %% @doc 帐号注册数
                        <<"SELECT ", ChannelId/binary, ", COUNT(*) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, "
                        and channel_id = ", ChannelId/binary, ";">>,
                        
                        %% @doc 充值金额
                        <<"SELECT ", ChannelId/binary, ",SUM(o.rmb) FROM orders as o, account AS a WHERE
                        o.s_times >= ", STimeBin/binary, " AND o.s_times < ", ETimeBin/binary, " AND o.state = 2 and o.is_sandbox = 0 and o.uin = a.uin
                        AND a.channel_id = ", ChannelId/binary, ";">>,
                        %% @doc 充值用户数,充值次数
                        <<"SELECT ", ChannelId/binary, ",COUNT(DISTINCT o.uid), COUNT(*) FROM orders as o, account AS a WHERE
                        o.s_times >= ", STimeBin/binary, " AND o.s_times < ", ETimeBin/binary, " AND o.state = 2 and o.is_sandbox = 0 and o.uin = a.uin
                        AND a.channel_id = ", ChannelId/binary, ";">>
                    ]
            end
        end, ChannelIds),
    Data1 = erl_mysql:execute(pool_account_1, Sql1),
    
    Sql2 = lists:map(
        fun(ChannelId) ->
            if
                ChannelId =:= <<"-999">> ->
                    <<"SELECT -999, COUNT(*) FROM log_online WHERE times >=  ", STimeBin/binary, " AND times < ", ETimeBin/binary, ";">>;
                true ->
                    %% @doc 登陆角色数
                    <<"SELECT ", ChannelId/binary, ",COUNT(*) FROM log_online as l, attr as a WHERE l.times >=  ",
                        STimeBin/binary, " AND l.times < ", ETimeBin/binary, " AND l.uid = a.uid AND a.channel_id = ", ChannelId/binary, ";">>
            end
        end, ChannelIds),
    Data2 = erl_mysql:execute(pool_dynamic_1, Sql2),
    calculate(ETimeBin, Data1, Data2, []).


calculate(_ETimeBin, [], _, Acc) ->
    erl_mysql:execute(pool_log_1, [
        <<"INSERT INTO report_data_center_d (times,channel_id,c_accounts,recharge_amount, recharge_accounts, recharge_count, login_roles) VALUES ">>,
        lists:foldl(
            fun(ISql, AccBin) ->
                if
                    AccBin =:= <<>> -> ISql;
                    true -> <<AccBin/binary, ",", ISql/binary>>
                end
            end, <<>>, Acc),
        <<";">>
    ]);

calculate(ETimeBin, [[[ChannelId1, CAccounts]], [[ChannelId1, PayAmout]], [[ChannelId1, PayAccounts, PayCounts]] | Data1], [[[ChannelId1, OnlineCounts]] | Data2], Acc) ->
    FunSum =
        fun(I) ->
            if
                I =:= ?undefined -> 0;
                true -> I
            end
        end,
    calculate(ETimeBin, Data1, Data2,
        [erl_mysql:sql([ETimeBin, ChannelId1, CAccounts, FunSum(PayAmout), PayAccounts, PayCounts, OnlineCounts]) | Acc]).
