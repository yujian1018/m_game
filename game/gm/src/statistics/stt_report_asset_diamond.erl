%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十一月 2017 下午3:18
%%%-------------------------------------------------------------------
-module(stt_report_asset_diamond).

-include("gm_pub.hrl").

-export([
    report/3
]).

report(STimeBin, ETimeBin, ChannelIds) ->
    FunSql =
        fun(ChannelId) ->
            if
                ChannelId =:= <<"-999">> -> [
                    <<"SELECT -999, type_id, SUM(v), count(distinct player_id) FROM log_attr_id_5  WHERE v>0 AND times >= ",
                        STimeBin/binary, " AND times < ",
                        ETimeBin/binary, " and player_id not in (select uid from dz_account.white_list) GROUP BY type_id;">>,
                    <<"SELECT -999, type_id, SUM(v), count(distinct player_id) FROM log_attr_id_5  WHERE v<0 AND times >= ",
                        STimeBin/binary, " AND times < ",
                        ETimeBin/binary, " and player_id not in (select uid from dz_account.white_list) GROUP BY type_id;">>];
                true -> [
                    <<"SELECT ", ChannelId/binary, ", type_id, SUM(v), count(distinct player_id) FROM log_attr_id_5 AS a, ",
                        (?DYNAMIC_POOL)/binary, ".`attr` AS b  WHERE a.v>0 AND a.times >= ",
                        STimeBin/binary, " AND a.times < ",
                        ETimeBin/binary, " and a.player_id not in (select uid from dz_account.white_list) AND a.`player_id` = b.`uid` AND b.`channel_id` = ",
                        ChannelId/binary, " GROUP BY type_id;">>,
                    <<"SELECT ", ChannelId/binary, ", type_id, SUM(v), count(distinct player_id) FROM log_attr_id_5 AS a, ",
                        (?DYNAMIC_POOL)/binary, ".`attr` AS b  WHERE a.v<0 AND a.times >= ",
                        STimeBin/binary, " AND a.times < ",
                        ETimeBin/binary, " and a.player_id not in (select uid from dz_account.white_list) AND a.`player_id` = b.`uid` AND b.`channel_id` = ",
                        ChannelId/binary, " GROUP BY type_id;">>]
            end
        end,
    Data = lists:append(erl_mysql:execute(pool_log_1, lists:map(FunSql, ChannelIds))),
    Sql = lists:foldl(
        fun([ChannelId2, AssetId, Sum, Count], Acc) ->
            NewAssetId =
                if
                    Sum < 0 andalso AssetId > 0 -> -AssetId;
                    true -> AssetId
                end,
            if
                Acc =:= <<>> -> erl_mysql:sql([STimeBin, ChannelId2, NewAssetId, Sum, Count]);
                true -> <<Acc/binary, ",", (erl_mysql:sql([STimeBin, ChannelId2, NewAssetId, Sum, Count]))/binary>>
            end
        end, <<>>, Data),
    
    if
        Sql == <<>> -> ok;
        true ->
            erl_mysql:execute(pool_log_1, <<"INSERT INTO report_asset_diamond (c_times, channel_id, asset_id, v, count_roles) VALUES ", Sql/binary, ";">>)
    end.
    
        
    
    