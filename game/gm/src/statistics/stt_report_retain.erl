%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午5:34
%%%-------------------------------------------------------------------
-module(stt_report_retain).

-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, ETimeBin, ChannelIds) ->
    STime = binary_to_integer(STimeBin),
    FunSql =
        fun(ChannelId) ->
            if
                ChannelId =:= <<"-999">> ->
                    [<<"select -999, count(*) from attr where c_times >= ",
                        STimeBin/binary, "-86400 AND c_times < ", ETimeBin/binary, "-86400;">>,
                        [<<"SELECT ", (integer_to_binary(STime - (I) * 86400))/binary, ", ",
                            (integer_to_binary(I))/binary, ", COUNT(*) FROM attr AS a, `log_online` AS b WHERE a.c_times >= ",
                            (integer_to_binary(STime - (I) * 86400))/binary, " AND a.c_times < ",
                            (integer_to_binary(STime - (I - 1) * 86400))/binary, " and a.uid not in (select uid from dz_account.white_list) AND a.`uid` = b.`uid` AND b.`times` >= ",
                            STimeBin/binary, " AND b.`times` < ", ETimeBin/binary, ";">> || I <- [1, 2, 3, 4, 5, 6, 15, 30]]];
                true ->
                    %% @doc 留存数量
                    [<<"select ", ChannelId/binary, ", count(*) from attr where c_times >= ",
                        STimeBin/binary, "-86400 AND c_times < ", ETimeBin/binary, "-86400 and channel_id='", ChannelId/binary, "';">>,
                        [<<"SELECT ", (integer_to_binary(STime - (I) * 86400))/binary, ", ",
                            (integer_to_binary(I))/binary, ", COUNT(*) FROM `attr` AS a, `log_online` AS b WHERE a.c_times >= ",
                            (integer_to_binary(STime - (I) * 86400))/binary, " AND a.c_times < ",
                            (integer_to_binary(STime - (I - 1) * 86400))/binary, " AND a.channel_id = '",
                            ChannelId/binary, "' and a.uid not in (select uid from dz_account.white_list) AND a.`uid` = b.`uid` AND b.`times` >= ", STimeBin/binary, " AND b.`times` < ",
                            ETimeBin/binary, ";">> || I <- [1, 2, 3, 4, 5, 6, 15, 30]]]
            end
        end,
    Data = erl_mysql:execute(pool_dynamic_1, iolist_to_binary(lists:map(FunSql, ChannelIds))),
    
    calculate(STimeBin, Data, []).

calculate(_STimeBin, [], Acc) ->
    erl_mysql:execute(pool_log_1, Acc);
calculate(STimeBin, [[[ChannelId, CountRoles]], [[STime1, Index1, Num1]], [[STime2, Index2, Num2]],
    [[STime3, Index3, Num3]], [[STime4, Index4, Num4]], [[STime5, Index5, Num5]],
    [[STime6, Index6, Num6]], [[STime7, Index7, Num7]], [[STime8, Index8, Num8]] | R], Acc) ->
    Fun =
        fun(STime, Index, Num) ->
            if
                Index =:= 1 ->
                    <<"INSERT INTO report_retain (times,channel_id,count_roles, re_1) VALUES (", (integer_to_binary(STime))/binary, " , '",
                        (integer_to_binary(ChannelId))/binary, "' , ",
                        (integer_to_binary(CountRoles))/binary, ", '",
                        (integer_to_binary(Num))/binary, "');">>;
                true ->
                    <<"update report_retain set re_", (integer_to_binary(Index))/binary, " = ",
                        (integer_to_binary(Num))/binary, " where times = ",
                        (integer_to_binary(STime))/binary, " and channel_id = '",
                        (integer_to_binary(ChannelId))/binary, "';">>
            end
        end,
    calculate(STimeBin, R,
        [
            Fun(STime1, Index1, Num1),
            Fun(STime2, Index2, Num2),
            Fun(STime3, Index3, Num3),
            Fun(STime4, Index4, Num4),
            Fun(STime5, Index5, Num5),
            Fun(STime6, Index6, Num6),
            Fun(STime7, Index7, Num7),
            Fun(STime8, Index8, Num8) | Acc
        ]).
    