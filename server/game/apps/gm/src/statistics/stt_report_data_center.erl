%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午3:43
%%%-------------------------------------------------------------------
-module(stt_report_data_center).

-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, ETimeBin, ChannelIds) ->
    Fun1 =
        fun(ChannelId) ->
            if
                ChannelId =:= <<"-999">> ->
                    [
                        %% @doc 帐号注册数
                        <<"SELECT -999, COUNT(*) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, " AND sdk_platform='SDK' and uin not in (select uin from white_list);">>,
                        %% @doc 游客注册数
                        <<"SELECT -999, COUNT(*) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, " AND sdk_platform='GUEST' and uin not in (select uin from white_list);">>,
                        %% @doc 设备注册数
                        <<"SELECT -999, COUNT(DISTINCT udid) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, " and uin not in (select uin from white_list);">>,
                        
                        %% @doc 充值金额
                        <<"SELECT -999, SUM(rmb) FROM  orders  WHERE s_times >= ", STimeBin/binary, " AND s_times < ", ETimeBin/binary, " AND state = 2 and uin not in (select uin from white_list);">>,
                        %% @doc 充值用户数,充值次数
                        <<"SELECT -999, COUNT(DISTINCT uid), COUNT(*) FROM orders WHERE s_times >= ", STimeBin/binary, " AND s_times < ", ETimeBin/binary, " AND state = 2 and uin not in (select uin from white_list);">>,
                        %% @doc 当日注册并充值的用户
                        <<"SELECT -999, COUNT(DISTINCT a.uin) FROM account AS a, orders AS b where a.`c_times` >= ", STimeBin/binary, " AND a.`c_times` < ", ETimeBin/binary, " AND a.uin = b.`uin` AND b.`state` = 2 and a.uin not in (select uin from white_list);">>,
                        %% @doc 当日注册并充值的金额数量
                        <<"SELECT -999, SUM(b.`rmb`) FROM account AS a, orders AS b where a.`c_times` >= ", STimeBin/binary, " AND a.`c_times` < ", ETimeBin/binary, " AND a.uin = b.`uin` AND b.`state` = 2 and a.uin not in (select uin from white_list);">>
                    ];
                true ->
                    [
                        %% @doc 帐号注册数
                        <<"SELECT ", ChannelId/binary, ", COUNT(*) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary,
                            " and channel_id = ", ChannelId/binary, " AND sdk_platform='SDK' and uin not in (select uin from white_list);">>,
                        %% @doc 游客注册数
                        <<"SELECT ", ChannelId/binary, ", COUNT(*) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary,
                            " and channel_id = ", ChannelId/binary, " AND sdk_platform='GUEST' and uin not in (select uin from white_list);">>,
                        %% @doc 设备注册数
                        <<"SELECT ", ChannelId/binary, ", COUNT(DISTINCT udid) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ",
                            ETimeBin/binary, " and channel_id = ", ChannelId/binary, " and uin not in (select uin from white_list);">>,
                        
                        %% @doc 充值金额
                        <<"SELECT ", ChannelId/binary, ",SUM(o.rmb) FROM orders as o, account AS a WHERE o.s_times >= ", STimeBin/binary, " AND o.s_times < ",
                            ETimeBin/binary, " AND o.state = 2 and o.is_sandbox = 0 and o.uin = a.uin AND  a.channel_id = ", ChannelId/binary, " and o.uin not in (select uin from white_list);">>,
                        
                        %% @doc 充值用户数,充值次数
                        <<"SELECT ", ChannelId/binary, ", COUNT(DISTINCT o.uid), COUNT(*) FROM orders as o, account AS a WHERE o.s_times >= ", STimeBin/binary, " AND o.s_times < ",
                            ETimeBin/binary, " AND o.state = 2 and o.is_sandbox = 0 and o.uin = a.uin AND a.channel_id = ", ChannelId/binary, " and o.uin not in (select uin from white_list);">>,
                        
                        %% @doc 当日注册并充值的用户
                        <<"SELECT ", ChannelId/binary, ", COUNT(DISTINCT a.uin) FROM account AS a, orders AS b where a.`c_times` >= ",
                            STimeBin/binary, " AND a.`c_times` < ", ETimeBin/binary, " AND a.channel_id = ",
                            ChannelId/binary, " AND a.uin = b.`uin` AND b.`state` = 2 and a.uin not in (select uin from white_list);">>,
                        
                        %% @doc 当日注册并充值的金额数量
                        <<"SELECT ", ChannelId/binary, ", SUM(b.`rmb`) FROM account AS a, orders AS b where a.`c_times` >= ",
                            STimeBin/binary, " AND a.`c_times` < ", ETimeBin/binary, " AND a.channel_id = ",
                            ChannelId/binary, " AND a.uin = b.`uin` AND b.`state` = 2 and a.uin not in (select uin from white_list);">>
                    ]
            end
        end,
    Data1 = erl_mysql:execute(pool_account_1, lists:map(Fun1, ChannelIds)),
    
    Fun2 =
        fun(ChannelId) ->
            if
                ChannelId =:= <<"-999">> ->
                    [
                        %% @doc 角色数量
                        <<"SELECT -999, COUNT(*) FROM attr WHERE c_times >= ", STimeBin/binary, " AND c_times < ",
                            ETimeBin/binary, " and uid not in (select uid from dz_account.white_list);">>,
                        %% @doc 登陆角色数
                        <<"SELECT -999, COUNT(*) FROM log_online WHERE times >=  ", STimeBin/binary, " AND times < ",
                            ETimeBin/binary, " and uid not in (select uid from dz_account.white_list);">>,
                        %% @doc 玩家在线时长
                        <<"SELECT -999, SUM(`time`) FROM log_online WHERE times >= ", STimeBin/binary, " AND times < ",
                            ETimeBin/binary, " and uid not in (select uid from dz_account.white_list);">>
                    ];
                true ->
                    [
                        %% @doc 角色数量
                        <<"SELECT ", ChannelId/binary, ",COUNT(*) FROM attr WHERE c_times >= ",
                            STimeBin/binary, " AND c_times < ", ETimeBin/binary, " AND channel_id = ",
                            ChannelId/binary, " and uid not in (select uid from dz_account.white_list);">>,
                        %% @doc 登陆角色数
                        <<"SELECT ", ChannelId/binary, ",COUNT(*) FROM log_online as l, attr as a WHERE l.times >=  ",
                            STimeBin/binary, " AND l.times < ",
                            ETimeBin/binary, " and l.uid not in (select uid from dz_account.white_list) AND l.uid = a.uid AND a.channel_id = ",
                            ChannelId/binary, ";">>,
                        %% @doc 玩家在线时长
                        <<"SELECT ", ChannelId/binary, ",SUM(`l`.`time`) FROM log_online as l ,attr AS a WHERE l.times >= ",
                            STimeBin/binary, " AND l.times < ",
                            ETimeBin/binary, " and l.uid not in (select uid from dz_account.white_list) AND l.uid = a.uid AND a.channel_id = ",
                            ChannelId/binary, ";">>
                    ]
            end
        end,
    Data2 = erl_mysql:execute(pool_dynamic_1, lists:map(Fun2, ChannelIds)),
    
    [[[LoginOnCounts]], SCounts] = erl_mysql:execute(pool_log_1, [
        <<"SELECT COUNT(*) from log_login_op where c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, " AND type = 0;">>,
        <<"SELECT times, sum(player_num) FROM log_s_count  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " group by times;">>
    ]),
    
    
    {Pcu, PcuData, Acu} =
        if
            SCounts =:= [] -> {0, 0, 0};
            true ->
                Fun =
                    fun([Times1, PlayerCounts1], [Times2, PlayerCounts2]) ->
                        if
                            PlayerCounts2 >= PlayerCounts1 -> [Times2, PlayerCounts2];
                            true -> [Times1, PlayerCounts1]
                        end
                    end,
                [PcuData2, Pcu2] = max(SCounts, Fun, [0, 0]),
                Acu2 = round(lists:sum(
                    [case PlayerCounts of
                         undefined -> 0;
                         _ -> PlayerCounts
                     end || [_Times, PlayerCounts] <- SCounts]) / length(SCounts)),
                {Pcu2, PcuData2, Acu2}
        end,
    
    calculate(STimeBin, Data1, Data2, Acu, Pcu, PcuData, LoginOnCounts, []).


max([], _Fun, Max) -> Max;
max([I1 | R], Fun, MaxI) ->
    MaxI2 = Fun(I1, MaxI),
    max(R, Fun, MaxI2).

calculate(_STimeBin, [], _, _Acu, _Pcu, _PcuData, _LoginOnCounts, Acc) ->
    Sql = [
        <<"INSERT INTO report_data_center (times,channel_id,c_roles,c_devices,c_accounts,c_guests,login_roles,login_count, recharge_amount, recharge_accounts, recharge_count, new_recharge_accounts, new_recharge_amount, pcu, pcu_date, acu, acu_duration) VALUES ">>,
        lists:foldl(
            fun(ISql, AccBin) ->
                if
                    AccBin =:= <<>> -> erl_mysql:sql(ISql);
                    true -> <<AccBin/binary, ",", (erl_mysql:sql(ISql))/binary>>
                end
            end, <<>>, Acc),
        <<";">>],
    erl_mysql:execute(pool_log_1, Sql);

calculate(STimeBin, [[[ChannelId, CAccounts]], [[ChannelId, CGuests]], [[ChannelId, UdidCount]], [[ChannelId, Sum1]],
    [[ChannelId, PayAccounts, PayCount]], [[ChannelId, NewPayAccounts]], [[ChannelId, Sum7]] | Data1], [[[ChannelId, CRoles]],
    [[ChannelId, LoginRoles]], [[ChannelId, AttrCount3]] | Data2], Acu, Pcu, PcuData, LoginOnCounts, Acc) ->
    FunSum =
        fun(I) ->
            if
                I =:= ?undefined -> 0;
                true -> I
            end
        end,
    PayAmount = FunSum(Sum1),
    NewPayCount = FunSum(Sum7),
    OnlineTimes = FunSum(AttrCount3),
    RetAcc =
        if
            ChannelId =:= -999 ->
                AcuDur =
                    if
                        Acu =:= 0 -> 0;
                        OnlineTimes =:= 0 -> 0;
                        OnlineTimes =:= undefined -> 0;
                        true ->
                            round(OnlineTimes / LoginRoles)
                    end,
                [STimeBin, ChannelId, CRoles, UdidCount, CAccounts, CGuests, LoginRoles, LoginOnCounts, PayAmount, PayAccounts, PayCount, NewPayAccounts, NewPayCount, Pcu, PcuData, Acu, AcuDur];
            true ->
                [STimeBin, ChannelId, CRoles, UdidCount, CAccounts, CGuests, LoginRoles, 0, PayAmount, PayAccounts, PayCount, NewPayAccounts, NewPayCount, 0, 0, 0, 0]
        end,
    calculate(STimeBin, Data1, Data2, Acu, Pcu, PcuData, LoginOnCounts, [RetAcc | Acc]).