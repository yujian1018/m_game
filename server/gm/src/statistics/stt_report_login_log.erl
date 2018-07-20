%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午5:06
%%%-------------------------------------------------------------------
-module(stt_report_login_log).

-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, ETimeBin, ChannelIds) ->
    FunSql =
        fun(ChannelId) ->
            if
                ChannelId =:= <<"-999">> -> [
                    <<"SELECT -999, COUNT(*) FROM log_login_log WHERE t0_times >= ", STimeBin/binary, " AND t0_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t1_times >= ", STimeBin/binary, " AND t1_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t2_times >= ", STimeBin/binary, " AND t2_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t3_times >= ", STimeBin/binary, " AND t3_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t4_times >= ", STimeBin/binary, " AND t4_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE (t5_times >= ", STimeBin/binary, " AND t5_times < ", ETimeBin/binary, ") or (t6_times >= ", STimeBin/binary, " AND t6_times < ", ETimeBin/binary, ");">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t51_times >= ", STimeBin/binary, " AND t51_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t52_times >= ", STimeBin/binary, " AND t52_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t53_times >= ", STimeBin/binary, " AND t53_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t54_times >= ", STimeBin/binary, " AND t54_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t101_times >= ", STimeBin/binary, " AND t101_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t102_times >= ", STimeBin/binary, " AND t102_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t103_times >= ", STimeBin/binary, " AND t103_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t104_times >= ", STimeBin/binary, " AND t104_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t105_times >= ", STimeBin/binary, " AND t105_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t106_times >= ", STimeBin/binary, " AND t106_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t109_times >= ", STimeBin/binary, " AND t109_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t110_times >= ", STimeBin/binary, " AND t110_times < ", ETimeBin/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t111_times >= ", STimeBin/binary, " AND t111_times < ", ETimeBin/binary, ";">>
                ];
                true -> [
                    <<"SELECT ", ChannelId/binary, ", COUNT(*) FROM log_login_log WHERE t0_times >= ", STimeBin/binary, " AND t0_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t1_times >= ", STimeBin/binary, " AND t1_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t2_times >= ", STimeBin/binary, " AND t2_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t3_times >= ", STimeBin/binary, " AND t3_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t4_times >= ", STimeBin/binary, " AND t4_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE ((t5_times >= ", STimeBin/binary, " AND t5_times < ", ETimeBin/binary, ") or (t6_times >= ", STimeBin/binary, " AND t6_times < ", ETimeBin/binary, ")) and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t51_times >= ", STimeBin/binary, " AND t51_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t52_times >= ", STimeBin/binary, " AND t52_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t53_times >= ", STimeBin/binary, " AND t53_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t54_times >= ", STimeBin/binary, " AND t54_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t101_times >= ", STimeBin/binary, " AND t101_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t102_times >= ", STimeBin/binary, " AND t102_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t103_times >= ", STimeBin/binary, " AND t103_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t104_times >= ", STimeBin/binary, " AND t104_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t105_times >= ", STimeBin/binary, " AND t105_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t106_times >= ", STimeBin/binary, " AND t106_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t109_times >= ", STimeBin/binary, " AND t109_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t110_times >= ", STimeBin/binary, " AND t110_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>,
                    <<"SELECT COUNT(*) FROM log_login_log WHERE t111_times >= ", STimeBin/binary, " AND t111_times < ", ETimeBin/binary, " and channel_id = ", ChannelId/binary, ";">>
                ]
            end
        end,
    Data = erl_mysql:execute(pool_log_1, lists:map(FunSql, ChannelIds)),
    calculate(STimeBin, Data, []).


calculate(_STimeBin, [], Acc) ->
    erl_mysql:execute(pool_log_1, [
        <<"INSERT INTO report_login_log (times,channel_id,c0, c1,c2,c3,c4,c5,c51,c52,c53,c54,c101,c102,c103,c104,c105,c106,c109,c110,c111) VALUES ">>,
        lists:foldl(
            fun(ISql, AccBin) ->
                if
                    AccBin =:= <<>> -> ISql;
                    true -> <<AccBin/binary, ",", ISql/binary>>
                end
            end, <<>>, Acc),
        <<";">>
    ]);

calculate(STimeBin, [[[ChannelId, C0]], [[C1]], [[C2]], [[C3]], [[C4]], [[C5]], [[C51]], [[C52]], [[C53]], [[C54]], [[C101]], [[C102]],
    [[C103]], [[C104]], [[C105]], [[C106]], [[C109]], [[C110]], [[C111]] | Data1], Acc) ->
    calculate(STimeBin, Data1,
        [erl_mysql:sql([STimeBin, ChannelId, C0, C1, C2, C3, C4, C5, C51, C52, C53, C54, C101, C102, C103, C104, C105, C106, C109, C110, C111]) | Acc]).