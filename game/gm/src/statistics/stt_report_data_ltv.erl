%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午4:25
%%%-------------------------------------------------------------------
-module(stt_report_data_ltv).

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
                        STimeBin/binary, " AND c_times < ", ETimeBin/binary, " and uid not in (select uid from dz_account.white_list);">>,
                        [
                            <<"SELECT ", (integer_to_binary(STime - (I) * 86400))/binary, ", ", (integer_to_binary(I))/binary,
                                "+1, SUM(b.rmb) FROM attr AS a, dz_account.orders AS b WHERE a.c_times >= ",
                                (integer_to_binary(STime - (I) * 86400))/binary, " AND a.c_times < ",
                                (integer_to_binary(STime - (I) * 86400))/binary, "+86400 and a.uid not in (select uid from dz_account.white_list) AND a.uid = b.uid AND b.`state` = 2 AND b.e_times >= ",
                                (integer_to_binary(STime - (I) * 86400))/binary, " AND b.`e_times` < ",
                                ETimeBin/binary, ";">> || I <- [0, 1, 2, 3, 4, 5, 14, 29]]];
                true ->
                    [<<"select ", ChannelId/binary, ", count(*) from attr where c_times >= ",
                        STimeBin/binary, " AND c_times < ", ETimeBin/binary, " and channel_id='", ChannelId/binary, "';">>,
                        [<<"SELECT ", (integer_to_binary(STime - (I) * 86400))/binary, ", ", (integer_to_binary(I))/binary,
                            "+1, SUM(b.rmb) FROM attr AS a, dz_account.orders AS b WHERE a.c_times >= ",
                            (integer_to_binary(STime - (I) * 86400))/binary, " AND a.c_times < ",
                            (integer_to_binary(STime - (I) * 86400))/binary, "+86400 and a.channel_id = ",
                            ChannelId/binary, " and a.uid not in (select uid from dz_account.white_list) AND a.uid = b.uid AND b.`state` = 2 AND b.e_times >= ",
                            (integer_to_binary(STime - (I) * 86400))/binary, " AND b.`e_times` < ",
                            ETimeBin/binary, ";">> || I <- [0, 1, 2, 3, 4, 5, 14, 29]]]
            end
        end,
    Data = erl_mysql:execute(pool_dynamic_1, lists:map(FunSql, ChannelIds)),
    calculate(STimeBin, Data, []).



calculate(_STimeBin, [], Acc) ->
    erl_mysql:execute(pool_log_1, Acc);

calculate(STimeBin, [[[ChannelId, CountRoles]], [[STime1, Index1, Num1]], [[STime2, Index2, Num2]],
    [[STime3, Index3, Num3]], [[STime4, Index4, Num4]], [[STime5, Index5, Num5]],
    [[STime6, Index6, Num6]], [[STime7, Index7, Num7]], [[STime8, Index8, Num8]] | R], Acc) ->
    FunSum =
        fun(I) ->
            if
                I =:= undefined -> 0;
                true -> I
            end
        end,
    Fun =
        fun(STime, Index, Num) ->
            if
                Index =:= 1 ->
                    <<"INSERT INTO report_data_ltv (times,channel_id,count_roles, ltv_1) VALUES (",
                        (integer_to_binary(STime))/binary, " , '",
                        (integer_to_binary(ChannelId))/binary, "' , ",
                        (integer_to_binary(CountRoles))/binary, ", '",
                        (integer_to_binary(FunSum(Num)))/binary, "');">>;
                true ->
                    <<"update report_data_ltv set ltv_", (integer_to_binary(Index))/binary, " = ",
                        (integer_to_binary(FunSum(Num)))/binary, " where times = ",
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