%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 19. 九月 2017 上午10:30
%%%-------------------------------------------------------------------
-module(db_update).

-include("gm_pub.hrl").

-compile(export_all).

item() ->
    case erl_mysql:execute(pool_dynamic_1, <<"select uid from attr where is_ai= 0 and offline_times >= 1501381630 and uid not in (select uid from item where item_id = 501001);">>) of
        [] -> ok;
        Uids ->
            Now = erl_time:now_bin(),
            FunFoldl =
                fun([Uid], Acc) ->
                    Vs = erl_mysql:sql([Uid, <<"501001">>, <<"1">>, Now]),
                    if
                        Acc =:= <<>> -> Vs;
                        true -> <<Acc/binary, ",", Vs/binary>>
                    end
                end,
            Sql = lists:foldl(FunFoldl, <<>>, Uids),
            erl_mysql:execute(pool_dynamic_1, <<"insert into item (`uid`, `item_id`, `num`, `c_times`) values ", Sql/binary, ";">>)
    end.

mail() ->
    case erl_mysql:execute(pool_dynamic_2, <<"select uid from attr where is_ai= 0 and offline_times >= 1503905730;">>) of
        [] -> ok;
        Uids ->
            FunFoldl =
                fun([Uid], Acc) ->
                    Vs = erl_mysql:sql([Uid, <<"0">>, <<"1506497730">>, <<"Award">>,
                        <<"\"Lucky Texas Holdem Poker\" has been updated, thank you for your patience, update compensation package is diamond * 30, chips * 20,000, Roman SNG ticket * 3，London SNG ticket *3, please get it as soon as possible, wish you a happy game!">>,
                        <<"[[1,5,30],[1,3,20000],[2,404002,3],[2,404003,3]]">>]),
                    if
                        Acc =:= <<>> -> Vs;
                        true -> <<Acc/binary, ",", Vs/binary>>
                    end
                end,
            Sql = lists:foldl(FunFoldl, <<>>, Uids),
            erl_mysql:execute(pool_dynamic_1, <<"insert into mail (`uid`, `from_uid`, `receive_time`, `title`, `info`, `appendix`) values ", Sql/binary, ";">>)
    end.



attr_sng_score(Num) ->
    SIndex = integer_to_binary((Num - 1) * 5000),
    case erl_mysql:execute(pool_dynamic_2, <<"select uid, sng_score from attr limit ", SIndex/binary, ", 5000;">>) of
        [] -> ok;
        List ->
            FunFoldl =
                fun([Uid, SngScore], Acc) ->
                    if
                        SngScore =/= 0 ->
                            [<<"update attr set sng_score = ", (integer_to_binary(SngScore))/binary, " where uid = ", (integer_to_binary(Uid))/binary, ";">> | Acc];
                        true -> Acc
                    end
                end,
            Sql = lists:foldl(FunFoldl, <<>>, List),
            erl_mysql:execute(pool_dynamic_1, Sql),
            attr_sng_score(Num + 1)
    end.


update_attr(Num) ->
    SIndex = integer_to_binary((Num - 1) * 5000),
    case erl_mysql:execute(pool_dynamic_2, <<"select uid, is_ai, sex, name, nick_name, gold, icon, address, infullmount,sng_score, bank_poll,sign, c_times, refresh_times, offline_times,packet_id, channel_id, gmt_offset from attr limit ", SIndex/binary, ", 5000;">>) of
        [] -> ok;
        List ->
            FunFoldl =
                fun([Uid, IsAi, Sex, Name, NickName, Gold, Icon, Address, AllRmb, SngScore, BankPoll, Sign, CTimes, RefreshTimes, OfflineTimes, PacketId, ChannelId, GMTOffset], Acc) ->
                    NewName = case NickName of
                                  <<>> -> Name;
                                  ?undefined -> Name;
                                  NickName -> NickName
                              end,
                    Vs = erl_mysql:sql([Uid, IsAi, Sex, NewName, Gold, Icon, Address, AllRmb, SngScore, BankPoll, Sign, CTimes, RefreshTimes, OfflineTimes, PacketId, ChannelId, GMTOffset]),
                    if
                        Acc =:= <<>> -> Vs;
                        true -> <<Acc/binary, ",", Vs/binary>>
                    end
                end,
            Sql = lists:foldl(FunFoldl, <<>>, List),
            erl_mysql:execute(pool_dynamic_1, <<"insert into attr (`uid`, `is_ai`, `sex`, `name`, `gold`, `icon`, `address`, `infullmount`, `sng_score`, `bank_poll`, `sign`,
            `c_times`, `refresh_times`, `offline_times`, `packet_id`, `channel_id`, `gmt_offset`) values ", Sql/binary, ";">>),
            update_attr(Num + 1)
    end.

update_career(Num) ->
    SIndex = integer_to_binary((Num - 1) * 5000),
    case erl_mysql:execute(pool_dynamic_2, <<"select uid,win,lose,in_game,add_gold,folp_add,max_score,max_poker,max_win_gold,sng_champion,sng_second,sng_lose from attr limit ", SIndex/binary, ", 5000;">>) of
        [] -> ok;
        List2 ->
            FunFoldl =
                fun([Uid, Win, Lose, Ingame, AddGold, FolpAdd, MaxScore, MaxPoker, MaxWinGold, SngC, SngS, SngL], Acc) ->
                    Vs = erl_mysql:sql([Uid, Win, Lose, Ingame, AddGold, FolpAdd, MaxScore, MaxPoker, MaxWinGold, SngC, SngS, SngL]),
                    if
                        Acc =:= <<>> -> Vs;
                        true -> <<Acc/binary, ",", Vs/binary>>
                    end
                end,
            Sql = lists:foldl(FunFoldl, <<>>, List2),
            erl_mysql:execute(pool_dynamic_1, <<"insert into career (`uid`,`win`,`lose`,`in_game`,`add_gold`,`folp_add`,`max_score`,`max_poker`,`max_win_gold`,`sng_champion`,`sng_second`,`sng_lose`) values ", Sql/binary, ";">>),
            update_career(Num + 1)
    end.


redis_rank_3() ->
    case erl_mysql:execute(pool_dynamic_1, <<"select uid, sng_score from attr  where sng_score > 0 order by sng_score desc limit 0, 50;">>) of
        [] -> ok;
        List ->
            eredis_pool:qp(pool, [[<<"ZADD">>, <<"rank:3">>, Score, Uid] || [Uid, Score] <- List])
    end,
    case erl_mysql:execute(pool_dynamic_1, <<"select uid, gold from attr where gold > 0 order by gold desc limit 0, 50;">>) of
        [] -> ok;
        List2 ->
            eredis_pool:qp(pool, [[<<"ZADD">>, <<"rank:2">>, Score, Uid] || [Uid, Score] <- List2])
    end,
    case erl_mysql:execute(pool_dynamic_1, <<"select uid, win from career where win > 0 order by win desc limit 0, 50;">>) of
        [] -> ok;
        List3 ->
            eredis_pool:qp(pool, [[<<"ZADD">>, <<"rank:1">>, Score, Uid] || [Uid, Score] <- List3])
    end.



