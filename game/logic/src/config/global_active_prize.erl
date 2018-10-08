%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 27. 七月 2016 下午7:14
%%%-------------------------------------------------------------------
-module(global_active_prize).

-include_lib("cache/include/cache_mate.hrl").
-include("logic_pub.hrl").

-export([
    get_prize/3,
    active_asset/3
]).


-define(tab_name, global_active_prize).

-record(global_active_prize, {
    active_id,
    privilege_type,
    prize_id,
    asset_type,
    asset_id,
    all_type,
    all_v
}).


load_cache() ->
    [
        #cache_mate{
            name = ?tab_name,
            fields = record_info(fields, ?tab_name),
            verify = fun verify_prize/1,
            rewrite = fun rewrite_prize/1,
            priority = 11
        }
    ].


verify_prize(VerifyPrize) ->
    lists:map(
        fun(#global_active_prize{active_id = ActiveId, prize_id = PrizeId, asset_type = AssetType, asset_id = AttrId, all_type = Type, all_v = V}) ->
            if
                PrizeId =:= -1 -> ok;
                true ->
                    ?check(global_prize:exit(PrizeId), "active_id:~p prize_id error:~p~n", [ActiveId, PrizeId])
            end,
            ?check(((AssetType =:= 0) orelse (AssetType =:= 1) orelse (AssetType =:= 2) orelse (AssetType =:= 3) orelse (AssetType =:= 4)), "active_id:~p asset_type error:~p~n", [ActiveId, AssetType]),
            ?check(AttrId =:= 0 orelse (config_asset:exit_attr(AttrId)), "active_id:~p asset_id error:~p~n", [ActiveId, AttrId]),
            ?check(((Type =:= 0) orelse (Type =:= 1) orelse (Type =:= 2) orelse (Type =:= 3)), "active_id:~p type error:~p~n", [ActiveId, Type]),
            ?check(is_integer(V), "active_id:~p v error:~p~n", [ActiveId, V])
        end,
        VerifyPrize),
    true.


rewrite_prize(Config = #global_active_prize{active_id = ActiveId, privilege_type = PriType, prize_id = PrizeIds}) ->
    {ok, Scan1, _} = erl_scan:string(binary_to_list(PrizeIds) ++ "."),
    {ok, PrizeIdParse} = erl_parse:parse_term(Scan1),
    Key = fun(PrizeId) -> {ActiveId, PriType, PrizeId} end,
    if
        is_list(PrizeIdParse) ->
            [Config#global_active_prize{active_id = Key(PrizeId), prize_id = PrizeId} || PrizeId <- PrizeIdParse];
        true ->
            [Config#global_active_prize{active_id = Key(PrizeIdParse), prize_id = PrizeIdParse}]
    end.


active_asset(ActiveId, PrizeId, KvList) ->
    case global_active:exit(ActiveId) of
        ?false -> KvList;
        ?true ->
            case ets:lookup(?tab_name, {ActiveId, ?PRIVILEGE_TYPE_1, PrizeId}) of
                [] -> KvList;
                [RecordPrize] ->
                    asset_handler:asset_v(-1,
                        RecordPrize#?tab_name.asset_type, RecordPrize#?tab_name.asset_id, RecordPrize#?tab_name.all_type, RecordPrize#?tab_name.all_v,
                        KvList)
            end
    end.


get_prize(ActiveId, PriType, -1) ->
    case ets:lookup(?tab_name, {ActiveId, PriType, -1}) of
        [] -> [];
        [Record] ->
            {Record#global_active_prize.asset_type, Record#global_active_prize.asset_id}
    end;

get_prize(ActiveId, PriType, PrizeId) ->
    case ets:lookup(?tab_name, {ActiveId, PriType, PrizeId}) of
        [] -> get_prize(ActiveId, PriType, -1);
        [Record] -> {Record#global_active_prize.asset_type, Record#global_active_prize.asset_id}
    end.
