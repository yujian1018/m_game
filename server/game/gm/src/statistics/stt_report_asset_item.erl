%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午3:18
%%%-------------------------------------------------------------------
-module(stt_report_asset_item).

-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, ETimeBin, ChannelIds) ->
    AllItems = [<<"101001">>, <<"101002">>, <<"101003">>, <<"101004">>,
        <<"104001">>, <<"104002">>, <<"104003">>, <<"104004">>,
        <<"201001">>, <<"201002">>,
        <<"404001">>, <<"404002">>, <<"404003">>, <<"404004">>, <<"404005">>, <<"404006">>,
        <<"406001">>, <<"406002">>],
    
    FunSql =
        fun(ChannelId) ->
            if
                ChannelId =:= <<"-999">> ->
                    [[
                        <<"SELECT -999, ", I/binary, ", type_id, SUM(v), count(distinct player_id) FROM log_item_id_",
                            I/binary, " WHERE times >= ",
                            STimeBin/binary, " AND times < ",
                            ETimeBin/binary, " And v>0  and player_id not in (select uid from dz_account.white_list) GROUP BY type_id;">>,
                        <<"SELECT -999, ", I/binary, ", -type_id, SUM(v), count(distinct player_id) FROM log_item_id_",
                            I/binary, "  WHERE times >= ",
                            STimeBin/binary, " AND times < ",
                            ETimeBin/binary, " AND v<0  and player_id not in (select uid from dz_account.white_list) GROUP BY type_id;">>
                    ] || I <- AllItems];
                true ->
                    [[
                        <<"SELECT ", ChannelId/binary, ", ", I/binary, ", type_id, SUM(v), count(distinct player_id) FROM log_item_id_",
                            I/binary, " AS a, ", (?DYNAMIC_POOL)/binary, ".`attr` AS b  WHERE a.times >= ",
                            STimeBin/binary, " AND a.times < ",
                            ETimeBin/binary, " and a.v>0 and a.player_id not in (select uid from dz_account.white_list) AND a.`player_id` = b.`uid` AND b.`channel_id` = ",
                            ChannelId/binary, " GROUP BY type_id;">>,
                        <<"SELECT ", ChannelId/binary, ", ", I/binary, ", -type_id, SUM(v), count(distinct player_id) FROM log_item_id_",
                            I/binary, " AS a, ", (?DYNAMIC_POOL)/binary, ".`attr` AS b  WHERE a.times >= ",
                            STimeBin/binary, " AND a.times < ",
                            ETimeBin/binary, " and a.v<0 and a.player_id not in (select uid from dz_account.white_list) AND a.`player_id` = b.`uid` AND b.`channel_id` = ",
                            ChannelId/binary, " GROUP BY type_id;">>
                    ] || I <- AllItems]
            end
        end,
    Data = lists:append(erl_mysql:execute(pool_log_1, lists:map(FunSql, ChannelIds))),
    {Sql, Sql2} = lists:foldl(
        fun([ChannelId2, ItemId, AssetId, Sum, Count], {Acc1, Acc2}) ->
            NewAssetId =
                if
                    Sum < 0 andalso AssetId > 0 -> -AssetId;
                    true -> AssetId
                end,
            if
                Sum > 0 andalso Acc1 =:= <<>> ->
                    {erl_mysql:sql([STimeBin, ChannelId2, ItemId, NewAssetId, Sum, Count]), Acc2};
                Sum < 0 andalso Acc2 =:= <<>> ->
                    {Acc1, erl_mysql:sql([STimeBin, ChannelId2, ItemId, NewAssetId, Sum, Count])};
                Sum > 0 ->
                    {<<Acc1/binary, ",", (erl_mysql:sql([STimeBin, ChannelId2, ItemId, NewAssetId, Sum, Count]))/binary>>, Acc2};
                true ->
                    {Acc1, <<Acc2/binary, ",", (erl_mysql:sql([STimeBin, ChannelId2, ItemId, NewAssetId, Sum, Count]))/binary>>}
            end
        end, {<<>>, <<>>}, Data),
    if
        Sql =:= <<>> andalso Sql2 =:= <<>> -> ok;
        Sql =:= <<>> ->
            erl_mysql:execute(pool_log_1, <<"INSERT INTO report_asset_item_cost (c_times, channel_id, item_id, asset_id, v, count_roles) VALUES ", Sql2/binary, ";">>);
        Sql2 =:= <<>> ->
            erl_mysql:execute(pool_log_1, <<"INSERT INTO report_asset_item (c_times, channel_id, item_id, asset_id, v, count_roles) VALUES ", Sql/binary, ";">>);
        true ->
            erl_mysql:execute(pool_log_1, [
                <<"INSERT INTO report_asset_item (c_times, channel_id, item_id, asset_id, v, count_roles) VALUES ", Sql/binary, ";">>,
                <<"INSERT INTO report_asset_item_cost (c_times, channel_id, item_id, asset_id, v, count_roles) VALUES ", Sql2/binary, ";">>])
    end.
    
        
    
    