%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午3:08
%%%-------------------------------------------------------------------
-module(stt_report_asset).

-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, ETimeBin, _ChannelIds) ->
    [
        [[G1]], [[G2]], [[D1]], [[D2]], [[CountShare]], [[CountShare1]], [[CountFight]], [[CountTurntable]],
        [[Task1]], [[Task2]], [[Task3]], [[Task4]], [[Task5]],
        [[Active1]], [[Active2]], [[Active3]], [[Active4]],
        [[Fund1]], [[Fund2]], [[Fund3]], [[Fund4]],
        [[Online1]], [[Online2]], [[Online3]], [[Online4]], [[Online5]], [[Online6]]
    ] = erl_mysql:execute(pool_log_1, [
        <<"SELECT SUM(v) FROM log_attr_id_3  WHERE v>0 AND times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id != -1 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT SUM(v) FROM log_attr_id_3  WHERE v<0 AND times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id != -1 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT SUM(v) FROM log_attr_id_5  WHERE v>0 AND times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT SUM(v) FROM log_attr_id_5  WHERE v<0 AND times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT COUNT(*) FROM log_share  WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, " and uid not in (select uid from dz_account.white_list);">>,
        <<"SELECT COUNT(*) FROM log_share  WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, " and `state` = 2 and uid not in (select uid from dz_account.white_list);">>,
        <<"SELECT COUNT(*) FROM log_fight  WHERE c_times >= ", STimeBin/binary, " AND c_times < ", ETimeBin/binary, " and uid not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ",
            ETimeBin/binary, " and (type_id = 101501001 or type_id = 101501002 or type_id = 101501003 or type_id = 101501004 or type_id = 101501005 or type_id = 101501006 or type_id = 101501007 or type_id = 101501008 or type_id = 101501009 or type_id = 101501010) and player_id not in (select uid from dz_account.white_list);">>,
        <<"select count(uid) from log_task where u_times >= ", STimeBin/binary, " AND u_times < ", ETimeBin/binary, " and `index` = -1 and uid not in (select uid from dz_account.white_list);">>,
        <<"select count(uid) from log_task where u_times >= ", STimeBin/binary, " AND u_times < ", ETimeBin/binary, " and `index` >= 1 and uid not in (select uid from dz_account.white_list);">>,
        <<"select count(uid) from log_task where u_times >= ", STimeBin/binary, " AND u_times < ", ETimeBin/binary, " and `index` >= 2 and uid not in (select uid from dz_account.white_list);">>,
        <<"select count(uid) from log_task where u_times >= ", STimeBin/binary, " AND u_times < ", ETimeBin/binary, " and `index` >= 3 and uid not in (select uid from dz_account.white_list);">>,
        <<"select count(uid) from log_task where u_times >= ", STimeBin/binary, " AND u_times < ", ETimeBin/binary, " and `index` >= 4 and uid not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 100101001 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 100101002 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 100101003 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 100101004 and player_id not in (select uid from dz_account.white_list);">>,
        
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1801001 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1801002 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1801003 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1801004 and player_id not in (select uid from dz_account.white_list);">>,
        
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1401001 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1401002 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1401003 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1401004 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1401005 and player_id not in (select uid from dz_account.white_list);">>,
        <<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ", STimeBin/binary, " AND times < ", ETimeBin/binary, " and type_id = 1401006 and player_id not in (select uid from dz_account.white_list);">>
    ]),
    
    Funconv =
        fun(I) ->
            if
                I =:= ?undefined -> 0;
                true -> I
            end
        end,
    
    erl_mysql:execute(pool_log_1, [
        <<"INSERT INTO report_asset (times,gold_prize,gold_cost, diamond_prize, diamond_cost, count_share, count_share2,
        count_fight, count_turntable, count_guide_skip, count_guide_1,count_guide_2,
        count_guide_3,count_guide_4, count_active_1,count_active_2,count_active_3,count_active_4,
        count_online_1,count_online_2,count_online_3,count_online_4,count_online_5,count_online_6,count_fund_1,count_fund_2,count_fund_3,count_fund_4) VALUES ">>,
        erl_mysql:sql([STimeBin, Funconv(G1), Funconv(G2), Funconv(D1), Funconv(D2), CountShare, CountShare1, CountFight, CountTurntable,
            Task1, Task2, Task3, Task4, Task5, Active1, Active2, Active3, Active4, Online1, Online2, Online3, Online4, Online5, Online6,
            Fund1, Fund2, Fund3, Fund4]),
        <<";">>]).