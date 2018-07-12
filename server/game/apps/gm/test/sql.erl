%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 6-27至7.1 次日没有登陆的玩家的UID  三个游戏的点击和游戏数、三个游戏各消耗或获取多少金币及积分、在线时长是多少  目前剩余多少金币 是否有充值
%%%
%%% Created : 03. 七月 2017 下午2:34
%%%-------------------------------------------------------------------
-module(sql).

-export([
    sql1/1
]).


sql1(Time) ->
    Time1 = integer_to_binary(Time),
    Time2 = integer_to_binary(Time + 86400),
    Time3 = integer_to_binary(Time + 86400 * 2),
    AllUids = erl_mysql:execute(pool_dynamic_1, <<"SELECT a.uid, a.gold, l.time, a.in_game FROM attr AS a, log_online AS l
    WHERE a.c_times >= ", Time1/binary, " AND a.c_times < ", Time2/binary, " AND a.uid = l.uid AND l.uid NOT IN
    (SELECT uid FROM log_online WHERE times >= ", Time2/binary, " AND times < ", Time3/binary, ")">>),
    {AllUidBin, Uids} =
        lists:foldl(
            fun([UidInt, _, _], {Acc, UidsAcc}) ->
                Uid = integer_to_binary(UidInt),
                if
                    Acc == <<>> ->
                        {<<"(uid =", Uid/binary, ")">>, [Uid | UidsAcc]};
                    true ->
                        {<<Acc/binary, " OR (uid =", Uid/binary, ")">>, [Uid | UidsAcc]}
                end
            end,
            {<<>>, []},
            AllUids),
    {LoginLog, Order, GoldLog, FightLog} = sql2(AllUidBin, Uids),
    FunTime =
        fun(TheTime) ->
            if
                TheTime =:= undefined -> 0;
                true ->
                    timer2time(erl_time:sec_to_localtime(TheTime))
            end
        end,
    Fun =
        fun([UidInt, Gold, OnlineTimes]) ->
            {T7, T8, T9} =
                case lists:keyfind(UidInt, 1, LoginLog) of
                    false -> {0, 0, 0};
                    {_, T7Key, T8Key, T9Key} ->
                        {FunTime(T7Key), FunTime(T8Key), FunTime(T9Key)}
                end,
            Rmb = proplists:get_value(UidInt, Order, 0),
            G1 = proplists:get_value({UidInt, 8}, GoldLog, 0),
            G2 = proplists:get_value({UidInt, 9}, GoldLog, 0),
            F1 = proplists:get_value({UidInt, 1}, FightLog, 0),
            F2 = proplists:get_value({UidInt, 2}, FightLog, 0),
            F3 = proplists:get_value({UidInt, 3}, FightLog, 0),
            io_lib:format("~p~n", [{UidInt, Gold, OnlineTimes, T7, T8, T9, Rmb, G1, G2, F1, F2, F3}])
        end,
    file:write_file("/root/aaa", lists:map(Fun, AllUids)).


sql2(AllUids, Uids) ->
    SqlLogin = <<"select uid, t7_times, t8_times, t9_times from log_login_log where ", AllUids/binary, ";">>,
    SqlOrder = <<"select uid, sum(rmb) from dz_account.orders where state = 2 and (", AllUids/binary, ") group by uid;">>,
    SqlLog = <<"select player_id, type_id, v from log_attr_id_3 where (type_id = 8 or type_id = 9) and (", (binary:replace(AllUids, <<"uid">>, <<"player_id">>, [global]))/binary, ");">>,
    Sql = [<<"SELECT uid, 1, SUM(log_gold_3) FROM log_fight  WHERE uid = ", Uid/binary, " AND room_type = 1 group by uid;
    SELECT uid, 2, SUM(log_gold_3) FROM log_fight  WHERE uid = ", Uid/binary, " AND room_type = 2 group by uid;
    SELECT uid, 3, SUM(log_gold_3) FROM log_fight  WHERE uid = ", Uid/binary, " AND room_type = 3  group by uid;"/utf8>> || Uid <- Uids],
    [LoginLog, Order, GoldLog | R] = erl_mysql:execute(pool_log, [SqlLogin, SqlOrder, SqlLog, Sql]),
    {[list_to_tuple(I) || I <- LoginLog], [list_to_tuple(I) || I <- Order], [{{Uid, Type}, V} || [Uid, Type, V] <- GoldLog], parse_data(R, [])}.

parse_data([], Acc) -> Acc;
parse_data([[] | R], Acc) -> parse_data(R, Acc);
parse_data([[[K1, Type, V1]] | R], Acc) ->
    if
        V1 =:= undefined -> parse_data(R, Acc);
        true ->
            parse_data(R, [{{K1, Type}, V1} | Acc])
    end.


timer2time({{Y, Mo, D}, {H, Mi, S}}) ->
    Fun =
        fun(I) ->
            if
                I < 10 -> <<"0", (integer_to_binary(I))/binary>>;
                true -> integer_to_binary(I)
            end
        end,
    <<(Fun(Y))/binary, "-", (Fun(Mo))/binary, "-", (Fun(D))/binary, " ", (Fun(H))/binary, ":", (Fun(Mi))/binary, ":", (Fun(S))/binary>>.