%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午5:21
%%%-------------------------------------------------------------------
-module(stt_report_lv).

-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, _ETimeBin, _ChannelIds) ->
    [LvData, LvDataAll, Vip, VipAll] = erl_mysql:execute(pool_dynamic_1, [
        <<"SELECT -999, lv, COUNT(uid) FROM attr WHERE is_ai = 0 and uid not in (select uid from dz_account.white_list) GROUP BY lv;">>,
        <<"SELECT channel_id, lv, COUNT(uid) FROM attr WHERE is_ai = 0 and uid not in (select uid from dz_account.white_list) GROUP BY channel_id, lv;">>,
        <<"SELECT -999, vip_lv, COUNT(uid) FROM attr WHERE is_ai = 0 AND vip_lv > 0 and uid not in (select uid from dz_account.white_list) GROUP BY vip_lv;">>,
        <<"SELECT channel_id, vip_lv, COUNT(uid) FROM attr WHERE is_ai = 0 AND vip_lv > 0 and uid not in (select uid from dz_account.white_list) GROUP BY channel_id, vip_lv;">>
    ]),
    
    Sql1 =
        if
            LvData =:= [] andalso LvDataAll =:= [] -> [];
            LvData =:= [] ->
                [<<"INSERT INTO report_lv (c_times,channel_id,lv,count_num) VALUES ">>,
                    calculate(STimeBin, LvDataAll, <<>>),
                    <<";">>];
            LvDataAll =:= [] ->
                [<<"INSERT INTO report_lv (c_times,channel_id,lv,count_num) VALUES ">>,
                    calculate(STimeBin, LvData, <<>>),
                    <<";">>];
            true ->
                [<<"INSERT INTO report_lv (c_times,channel_id,lv,count_num) VALUES ">>,
                    calculate(STimeBin, LvData, <<>>),
                    <<",">>, calculate(STimeBin, LvDataAll, <<>>), <<";">>]
        end,
    Sql3 =
        if
            Vip =:= [] andalso VipAll =:= [] -> [];
            Vip =:= [] ->
                [<<"INSERT INTO report_vip (c_times,channel_id,lv,count_num) VALUES ">>, calculate(STimeBin, VipAll, <<>>),
                    <<";">>];
            VipAll =:= [] ->
                [<<"INSERT INTO report_vip (c_times,channel_id,lv,count_num) VALUES ">>, calculate(STimeBin, VipAll, <<>>),
                    <<";">>];
            true ->
                [<<"INSERT INTO report_vip (c_times,channel_id,lv,count_num) VALUES ">>, calculate(STimeBin, Vip, <<>>),
                    <<",">>, calculate(STimeBin, VipAll, <<>>), <<";">>]
        end,
    erl_mysql:execute(pool_log_1, [Sql1, Sql3]).


calculate(_STimeBin, [], Acc) ->
    Acc;

calculate(STimeBin, [[ChannelId, Lv, Count] | Data1], Acc) ->
    NewAcc =
        if
            Acc =:= <<>> -> erl_mysql:sql([STimeBin, ChannelId, Lv, Count]);
            true -> <<Acc/binary, ",", (erl_mysql:sql([STimeBin, ChannelId, Lv, Count]))/binary>>
        end,
    calculate(STimeBin, Data1, NewAcc).