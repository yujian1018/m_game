%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 创建时间：10-1  次日未登陆, 3日，4日未登陆
%%% 等级，筹码，钻石，活跃点，在线时间，是否打开新手礼包（1没有打开 0打开），是否跳过新手引导（1跳过 0没有跳过），大转盘（1已领 0未领） 救济金（1已领 0未领），在线奖励（1已领 0未领）
%%% 普通场具体场次牌局次数 sng具体场次牌局次数 输赢金币总数 sng是否前2名，当天获得钻石，当天消耗钻石，最后一次下线界面
%%% Created : 10. 十月 2017 上午11:47
%%%-------------------------------------------------------------------
-module(db_s_2).

-include("gm_pub.hrl").

-export([
    data_attr/0
]).
-compile(export_all).

data() ->
    STime = erl_time:localtime_to_now({{2017, 10, 1}, {0, 0, 0}}),
    Attr = attr(STime),
    Uids = [Uid || [Uid, _Lv, _Gold, _Diamon, _ActivePoint] <- Attr],
    ?INFO("111:~w~n", [[length(Uids), hd(Attr)]]),
    [Sng1, Sng2, Sng3, SngItem1, SngItem2, SngItem3] =
        erl_mysql:execute(pool_log_1, <<"select player_id, count(*) from log_attr_id_3 where times >= 1506787200 and times < 1506787200+86400 and type_id = 101001001 group by player_id;
    select player_id, count(*) from log_attr_id_3 where times >= 1506787200 and times < 1506787200+86400 and type_id = 101001002 group by player_id;
    select player_id, count(*) from log_attr_id_3 where times >= 1506787200 and times < 1506787200+86400 and type_id = 101001003 group by player_id;
    SELECT player_id, COUNT(*) FROM log_item_id_404001 WHERE times >= 1506787200 AND times < 1506787200+86400 AND v <0 GROUP BY player_id;
    SELECT player_id, COUNT(*) FROM log_item_id_404002 WHERE times >= 1506787200 AND times < 1506787200+86400 AND v <0 GROUP BY player_id;
    SELECT player_id, COUNT(*) FROM log_item_id_404003 WHERE times >= 1506787200 AND times < 1506787200+86400 AND v <0 GROUP BY player_id;">>),
    S1 = [{PlayerId, Count} || [PlayerId, Count] <- Sng1],
    S2 = [{PlayerId, Count} || [PlayerId, Count] <- Sng2],
    S3 = [{PlayerId, Count} || [PlayerId, Count] <- Sng3],
    SItem1 = [{PlayerId, Count} || [PlayerId, Count] <- SngItem1],
    SItem2 = [{PlayerId, Count} || [PlayerId, Count] <- SngItem2],
    SItem3 = [{PlayerId, Count} || [PlayerId, Count] <- SngItem3],
    Fun =
        fun(Uid, KvLists) ->
            case lists:keyfind(Uid, 1, KvLists) of
                false -> 0;
                {_, V} -> V
            end
        end,
    Data = lists:map(
        fun(Uid) ->
            io_lib:format("~p~n", [{Uid, Fun(Uid, S1), Fun(Uid, S2), Fun(Uid, S3), Fun(Uid, SItem1), Fun(Uid, SItem2), Fun(Uid, SItem3)}])
        end, Uids),
    file:write_file("/root/data.sng.1001", Data).

data_attr() ->
    STime = erl_time:localtime_to_now({{2017, 10, 1}, {0, 0, 0}}),
    Attr = attr(STime),
    Uids = [Uid || [Uid, _Lv, _Gold, _Diamon, _ActivePoint] <- Attr],
    ?INFO("111:~w~n", [[length(Uids), hd(Attr)]]),
    LogOnline = log_online(Uids, STime),
    ?INFO("222:~w~n", [[length(LogOnline), hd(LogOnline)]]),
    Item = item(Uids),
    ?INFO("333:~w~n", [[length(Item), hd(Item)]]),
    LogTask = log_task(Uids, STime),
    ?INFO("444:~w~n", [[length(LogTask), hd(LogTask)]]),
    Turntable = turntable(Uids, STime),
    Fund = fund(Uids, STime),
    Online = online(Uids, STime),
    
    LogFight = log_fight(Uids, STime),
    ?INFO("555:~w~n", [[length(LogFight), hd(LogFight)]]),
    LogAttrId5 = log_attr_id_5(Uids, STime),
    ?INFO("666:~w~n", [[length(LogAttrId5), hd(LogAttrId5)]]),
    LoginOp = login_op(Uids, STime),
    ?INFO("777:~w~n", [[length(LoginOp), hd(LoginOp)]]),
    
    DataAttr = data_attr(Attr, LogOnline, Item, LogTask, Turntable, Fund, Online, LogFight, LogAttrId5, LoginOp, []),
    ?INFO("888:~w~n", [[length(DataAttr), hd(DataAttr)]]),
    file:write_file("/root/data." ++ integer_to_list(STime), DataAttr).


data_attr([], _LogOnline, _Item, _LogTask, _Turntable, _Fund, _Online, _LogFight, _LogAttrId5, _LoginOp, Acc) -> Acc;
data_attr([[Uid, Lv, Gold, Diamond, ActivePoint] | Attr], [HLogOnline | LogOnline], [HItem | Item],
    [HLogTask | LogTask], [[[T1]] | Turntable], [[[F1]] | Fund], [[[O1]] | Online],
    [HLogFight | LogFight], [HLogAttrId5 | LogAttrId5], [HLoginOp | LoginOp], Acc) ->
    IsItem = case HItem of
                 [] -> 0;
                 [[0]] -> 0;
                 _ -> 1
             end,
    IsTask =
        case HLogTask of
            [] -> 1;
            [[-1]] -> 1;
            _ -> 0
        end,
    IsTurntable =
        if
            T1 > 0 -> 1;
            true -> 0
        end,
    IsFund =
        if
            F1 > 0 -> 1;
            true -> 0
        end,
    IsOnline =
        if
            O1 > 0 -> 1;
            true -> 0
        end,
    OnlineTime = case HLogOnline of
                     [[LogonlineTime]] -> LogonlineTime;
                     _ -> 0
                 end,
    {fight_record, N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11,
        S1, Sc1, S2, Sc2, S3, Sc3, S4, Sc4, S5, Sc5, S6, Sc6,
        GoldAdd, GoldCost, SngGoldAdd, SngGoldCost, Rank} = p_fight(HLogFight),
    {DiamondAdd, DaimondCost} = p_attr_id_5(HLogAttrId5),
    OfflineOp = p_login_op(HLoginOp),
    data_attr(Attr, LogOnline, Item, LogTask, Turntable, Fund, Online, LogFight, LogAttrId5, LoginOp, [io_lib:format("~p~n", [{Uid, Lv, Gold, Diamond, ActivePoint, OnlineTime, IsItem, IsTask, IsTurntable, IsFund, IsOnline, N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, S1, Sc1, S2, Sc2, S3, Sc3, S4, Sc4, S5, Sc5, S6, Sc6, GoldAdd, GoldCost, SngGoldAdd, SngGoldCost, Rank, DiamondAdd, DaimondCost, OfflineOp}]) | Acc]).

-record(fight_record, {
    n1 = 0,
    n2 = 0,
    n3 = 0,
    n4 = 0,
    n5 = 0,
    n6 = 0,
    n7 = 0,
    n8 = 0,
    n9 = 0,
    n10 = 0,
    n11 = 0,
    s1 = 0,
    sc1 = 0,
    s2 = 0,
    sc2 = 0,
    s3 = 0,
    sc3 = 0,
    s4 = 0,
    sc4 = 0,
    s5 = 0,
    sc5 = 0,
    s6 = 0,
    sc6 = 0,
    gold_add = 0,
    gold_cost = 0,
    sng_gold_add = 0,
    sng_gold_cost = 0,
    rank = 0
}).

p_fight(LogFight) ->
    Fun =
        fun([RoomType, RoomId, Gold, Count, Rank], FightRecord) ->
            if
                RoomType =:= 1 ->
                    FightRecord1 =
                        if
                            Gold >= 0 -> FightRecord#fight_record{gold_add = FightRecord#fight_record.gold_add + Gold};
                            true -> FightRecord#fight_record{gold_cost = FightRecord#fight_record.gold_cost + Gold}
                        end,
                    Index =
                        if
                            RoomId =:= 2 -> #fight_record.n1;
                            RoomId =:= 4 -> #fight_record.n2;
                            RoomId =:= 6 -> #fight_record.n3;
                            RoomId =:= 8 -> #fight_record.n4;
                            RoomId =:= 9 -> #fight_record.n5;
                            RoomId =:= 10 -> #fight_record.n6;
                            RoomId =:= 11 -> #fight_record.n7;
                            RoomId =:= 12 -> #fight_record.n8;
                            RoomId =:= 14 -> #fight_record.n9;
                            RoomId =:= 16 -> #fight_record.n10;
                            RoomId =:= 18 -> #fight_record.n11
                        end,
                    V = element(Index, FightRecord1),
                    setelement(Index, FightRecord1, V + 1);
                RoomType =:= 2 ->
                    FightRecord1 =
                        if
                            Gold >= 0 ->
                                FightRecord#fight_record{sng_gold_add = FightRecord#fight_record.sng_gold_add + Gold};
                            true ->
                                FightRecord#fight_record{sng_gold_cost = FightRecord#fight_record.sng_gold_cost + Gold}
                        end,
                    FightRecord2 =
                        if
                            Rank =:= 1 orelse Rank =:= 2 -> FightRecord1#fight_record{rank = 1};
                            true -> FightRecord1
                        end,
                    Index =
                        if
                            RoomId =:= 1 -> #fight_record.s1;
                            RoomId =:= 2 -> #fight_record.s2;
                            RoomId =:= 3 -> #fight_record.s3;
                            RoomId =:= 4 -> #fight_record.s4;
                            RoomId =:= 5 -> #fight_record.s5;
                            RoomId =:= 6 -> #fight_record.s6
                        end,
                    V = element(Index, FightRecord2),
                    C = element(Index + 1, FightRecord2),
                    FightRecord3 = setelement(Index, FightRecord2, V + 1),
                    setelement(Index + 1, FightRecord3, C + Count)
            end
        end,
    lists:foldl(Fun, #fight_record{}, LogFight).


p_attr_id_5(LogAttrId5) ->
    Fun =
        fun([_TypeId, V], {Add, Cost}) ->
            if
                V >= 0 -> {Add + V, Cost};
                true -> {Add, Cost + V}
            end
        end,
    lists:foldl(Fun, {0, 0}, LogAttrId5).


p_login_op([]) ->
    [];
p_login_op(LogLoginOp) ->
    [Op] = lists:last(LogLoginOp),
    Op.


attr(STime) ->
    erl_mysql:execute(pool_dynamic_1, <<"SELECT uid, lv, gold, diamond, active_point FROM attr WHERE c_times >= ",
        (integer_to_binary(STime))/binary, " AND c_times < ",
        (integer_to_binary(STime + 86400))/binary, " AND uid NOT IN (SELECT uid FROM log_online WHERE times >= ",
        (integer_to_binary(STime + 86400))/binary, " AND times < ",
        (integer_to_binary(STime + 86400 * 2))/binary, " );">>).


log_online(Uids, STime) ->
    erl_mysql:execute(pool_dynamic_1, [<<"select time from log_online where uid = ",
        (integer_to_binary(Uid))/binary, " and times >= ",
        (integer_to_binary(STime))/binary, " and times < ",
        (integer_to_binary(STime + 86400))/binary, ";">> || Uid <- Uids]).


log_fight(Uids, STime) ->
    Fun =
        fun(NewUids) ->
            erl_mysql:execute(pool_log_1, [<<"select room_type, room_id, log_gold_3, play_count, play_rank from log_fight where uid = ",
                (integer_to_binary(Uid))/binary, " and c_times >= ",
                (integer_to_binary(STime))/binary, " and c_times < ",
                (integer_to_binary(STime + 86400))/binary, ";">> || Uid <- NewUids])
        end,
    erl_db:do_mysql(Fun, Uids, []).


item(Uids) ->
    erl_mysql:execute(pool_dynamic_1, [<<"select count(*) from item where uid = ",
        (integer_to_binary(Uid))/binary, " and item_id = 501001;">> || Uid <- Uids]).


log_attr_id_5(Uids, STime) ->
    Fun =
        fun(NewUids) ->
            erl_mysql:execute(pool_log_1, [<<"select type_id, v from log_attr_id_5 where player_id = ",
                (integer_to_binary(Uid))/binary, " and times >= ",
                (integer_to_binary(STime))/binary, " and times < ",
                (integer_to_binary(STime + 86400))/binary, ";">> || Uid <- NewUids])
        end,
    erl_db:do_mysql(Fun, Uids, []).


turntable(Uids, STime) ->
    Fun =
        fun(NewUids) ->
            erl_mysql:execute(pool_log_1, [<<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ",
                (integer_to_binary(STime))/binary, " AND times < ",
                (integer_to_binary(STime + 86400))/binary, " and player_id = ",
                (integer_to_binary(Uid))/binary, " and (type_id = 101501001 or type_id = 101501002 or type_id = 101501003 or type_id = 101501004 or type_id = 101501005 or type_id = 101501006 or type_id = 101501007 or type_id = 101501008 or type_id = 101501009 or type_id = 101501010);">> || Uid <- NewUids])
        end,
    erl_db:do_mysql(Fun, Uids, []).


fund(Uids, STime) ->
    Fun =
        fun(NewUids) ->
            erl_mysql:execute(pool_log_1, [<<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ",
                (integer_to_binary(STime))/binary, " AND times < ",
                (integer_to_binary(STime + 86400))/binary, " and player_id = ",
                (integer_to_binary(Uid))/binary, " and (type_id = 1801001 or type_id = 1801002 or type_id = 1801003 or type_id = 1801004);">> || Uid <- NewUids])
        end,
    erl_db:do_mysql(Fun, Uids, []).


online(Uids, STime) ->
    Fun =
        fun(NewUids) ->
            erl_mysql:execute(pool_log_1, [<<"SELECT count(player_id) FROM log_attr_id_3  WHERE times >= ",
                (integer_to_binary(STime))/binary, " AND times < ",
                (integer_to_binary(STime + 86400))/binary, " and player_id = ", (integer_to_binary(Uid))/binary, " and (type_id = 1401001 or type_id = 1401002 or type_id = 1401003 or type_id = 1401004 or type_id = 1401005 or type_id = 1401006);">> || Uid <- NewUids])
        end,
    erl_db:do_mysql(Fun, Uids, []).


login_op(Uids, STime) ->
    Fun =
        fun(NewUids) ->
            erl_mysql:execute(pool_log_1, [<<"SELECT v FROM log_login_op  WHERE uid = ",
                (integer_to_binary(Uid))/binary, " and  type = 1 and c_times >= ",
                (integer_to_binary(STime))/binary, " AND c_times < ",
                (integer_to_binary(STime + 86400))/binary, ";">> || Uid <- NewUids])
        end,
    erl_db:do_mysql(Fun, Uids, []).


log_task(Uids, STime) ->
    erl_mysql:execute(pool_log_1, [<<"SELECT `index` FROM log_task  WHERE uid = ",
        (integer_to_binary(Uid))/binary, " and  u_times >= ",
        (integer_to_binary(STime))/binary, " AND u_times < ",
        (integer_to_binary(STime + 86400))/binary, ";">> || Uid <- Uids]).
