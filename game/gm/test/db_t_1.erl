%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 设备留存数量
%%%
%%% Created : 10. 十月 2017 下午6:22
%%%-------------------------------------------------------------------
-module(db_t_1).

-include("gm_pub.hrl").

-export([
    account/0
]).

%% @doc 设备留存数量
account() ->
    Fun = fun(STime) ->
        FunSql =
            fun(NewUdids) ->
                erl_mysql:execute(pool_account, [[<<"SELECT count(*) FROM dz_account.`account` AS a, dz_d_en_2.`player` AS p, dz_d_en_2.`log_online` AS l WHERE a.`udid` = '",
                    NewUdid/binary, "' AND a.`uin` = p.`uin` AND p.`uid` = l.`uid` AND l.`times` >= ",
                    (integer_to_binary(STime + (I) * 86400))/binary, " AND l.`times` < ",
                    (integer_to_binary(STime + (I + 1) * 86400))/binary, ";">> || I <- [1, 2, 3, 4, 5, 6]] || [NewUdid] <- NewUdids])
            end,
        STimeBin = integer_to_binary(STime),
        [[[UdidCount]], Udids] = erl_mysql:execute(pool_account, <<"SELECT count(distinct udid) FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ",
            (integer_to_binary(STime + 86400))/binary, " AND channel_id = 10003;SELECT distinct udid FROM account WHERE c_times >= ", STimeBin/binary, " AND c_times < ",
            (integer_to_binary(STime + 86400))/binary, " AND channel_id = 10003;">>),
        [UdidCount, to_num(erl_db:do_mysql(FunSql, Udids, []), {0, 0, 0, 0, 0, 0})]
          end,
    lists:map(Fun, [1506528000, 1506528000 + 86400, 1506528000 + 86400 * 2,
        1506528000 + 86400 * 3, 1506528000 + 86400 * 4, 1506528000 + 86400 * 5,
        1506528000 + 86400 * 6, 1506528000 + 86400 * 7, 1506528000 + 86400 * 8,
        1506528000 + 86400 * 9, 1506528000 + 86400 * 10, 1506528000 + 86400 * 11]).

to_num([], {N1, N2, N3, N4, N5, N6}) -> {N1, N2, N3, N4, N5, N6};
to_num([[[C1]], [[C2]], [[C3]], [[C4]], [[C5]], [[C6]] | CR], {N1, N2, N3, N4, N5, N6}) ->
    NewN1 = if
                C1 =/= 0 -> N1 + 1;
                true -> N1
            end,
    NewN2 = if
                C2 =/= 0 -> N2 + 1;
                true -> N2
            end,
    NewN3 = if
                C3 =/= 0 -> N3 + 1;
                true -> N3
            end,
    NewN4 = if
                C4 =/= 0 -> N4 + 1;
                true -> N4
            end,
    NewN5 = if
                C5 =/= 0 -> N5 + 1;
                true -> N5
            end,
    NewN6 = if
                C6 =/= 0 -> N6 + 1;
                true -> N6
            end,
    to_num(CR, {NewN1, NewN2, NewN3, NewN4, NewN5, NewN6}).
    