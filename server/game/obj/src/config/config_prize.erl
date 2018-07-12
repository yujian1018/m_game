%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 八月 2017 下午2:44
%%%-------------------------------------------------------------------
-module(config_prize).

-include_lib("cache/include/cache_mate.hrl").
-include("obj_pub.hrl").

-export([
    vip_asset/4, vip_fun/2, vip_fun_count/2, vip_daily_prize/1, vip_lvup/1
]).

-define(tab_name_1, config_vip).

-record(config_vip, {
    vip_lv,
    privilege_type,
    prize_id,
    asset_type,
    asset_id,
    type,
    v
}).

load_cache() ->
    [
        #cache_mate{
            name = ?tab_name_1,
            fields = record_info(fields, ?tab_name_1),
            verify = fun verify_vip/1,
            rewrite = fun rewrite_vip/1,
            priority = 11
            
        }
    ].

verify_vip(VerifyVip) ->
    Fun =
        fun(#config_vip{prize_id = PrizeId, asset_type = AssetType, asset_id = AttrId, type = Type, v = V}) ->
            if
                is_integer(PrizeId) ->
                    ?check(global_prize:exit(PrizeId), "id:~p prize_id error:~p~n", [PrizeId, PrizeId]);
                true ->
                    ok
            end,
            ?check(AttrId =:= 0 orelse (config_asset:exit_attr(AttrId)) orelse (AssetType == 0 andalso is_integer(AttrId)) orelse AssetType == -1 orelse AssetType == -2, "prize_id:~p asset_id error:~p~n", [PrizeId, AttrId]),
            ?check(((Type =:= 0) orelse (Type =:= 1) orelse (Type =:= 2) orelse (Type =:= 3)), "prize_id:~p type error:~p~n", [PrizeId, Type]),
            ?check(is_integer(V), "prize_id:~p v error:~p~n", [PrizeId, V])
        end,
    if
        is_record(VerifyVip, config_vip) -> Fun(VerifyVip);
        true -> lists:map(Fun, VerifyVip)
    end,
    true.


rewrite_vip(Config = #config_vip{vip_lv = VipLv, privilege_type = PriType, prize_id = PrizeId, asset_id = AssetIds}) ->
    Fun =
        fun(Bin) ->
            if
                Bin =:= <<>> -> [];
                is_integer(Bin) -> Bin;
                true ->
                    {ok, Scan, _} = erl_scan:string(binary_to_list(Bin) ++ "."),
                    {ok, Term} = erl_parse:parse_term(Scan),
                    Term
            end
        end,
    if
        PriType =:= ?PRIVILEGE_TYPE_4 ->
            Config#config_vip{vip_lv = {VipLv, PriType}, prize_id = Fun(PrizeId), asset_id = Fun(AssetIds)};
        PriType =:= ?PRIVILEGE_TYPE_6 ->
            Config#config_vip{vip_lv = {VipLv, PriType}, prize_id = Fun(PrizeId), asset_id = Fun(AssetIds)};
        true ->
            case Fun(PrizeId) of
                PrizeIdsParse when is_list(PrizeIdsParse) ->
                    [Config#config_vip{vip_lv = {VipLv, PriType, M}, prize_id = M, asset_id = Fun(AssetIds)} || M <- PrizeIdsParse];
                PrizeIdsParse ->
                    Config#config_vip{vip_lv = {VipLv, PriType, PrizeIdsParse}, prize_id = PrizeIdsParse, asset_id = Fun(AssetIds)}
            end
    end.


vip_asset(Uid, PrizeId, AssetType, KvList) ->
    case load_attr:is_vip(Uid) of
        ?false -> KvList;
        VipLv ->
            case ets:lookup(?tab_name_1, {VipLv, ?PRIVILEGE_TYPE_1, PrizeId}) of
                [] -> KvList;
                Records ->
                    lists:foldl(
                        fun(Record, KvListAcc) ->
                            asset_handler:asset_v(AssetType,
                                Record#?tab_name_1.asset_type, Record#?tab_name_1.asset_id, Record#?tab_name_1.type, Record#?tab_name_1.v,
                                KvListAcc)
                        end,
                        KvList,
                        Records)
            
            end
    end.



vip_fun(Uid, PrizeId) ->
    case load_attr:is_vip(Uid) of
        ?false -> [];
        VipLv ->
            case ets:lookup(?tab_name_1, {VipLv, ?PRIVILEGE_TYPE_2, PrizeId}) of
                [] -> [];
                Records ->
                    [{Record#config_vip.type, Record#config_vip.v} || Record <- Records, Record#config_vip.prize_id == PrizeId]
            
            end
    end.


vip_fun_count(Uid, PrizeId) ->
    case load_attr:is_vip(Uid) of
        ?false -> 0;
        VipLv ->
            case ets:lookup(?tab_name_1, {VipLv, ?PRIVILEGE_TYPE_3, PrizeId}) of
                [] -> 0;
                Records ->
                    case lists:keyfind(PrizeId, #config_vip.prize_id, Records) of
                        false -> 0;
                        Record -> Record#config_vip.v
                    end
            end
    end.


%% @doc vip每日奖励
vip_daily_prize(Uid) ->
    case load_attr:is_vip(Uid) of
        ?false -> 0;
        VipLv ->
            case ets:lookup(?tab_name_1, {VipLv, ?PRIVILEGE_TYPE_4}) of
                [] -> ok;
                Records ->
                    {Title, Content, _App} = config_mail:get_v(?MAIL_ID_VIP_ONLINE),
                    Fun =
                        fun(Record) ->
                            Asset = global_prize:get(Record#config_vip.v),
                            mail_handler:add_mail(0, Uid, Title, Content, Asset)
                        end,
                    [Fun(Record) || Record <- Records]
            end,
            case ets:lookup(?tab_name_1, {VipLv, ?PRIVILEGE_TYPE_6}) of
                [] -> ok;
                [Record6] ->
                    [Gold, BankPoll] = load_attr:get_v(Uid, [?GOLD]),
                    if
                        Gold + BankPoll >= Record6#config_vip.v -> ok;
                        true ->
                            load_attr:change(Uid, Record6#config_vip.prize_id, [[?GOLD, Record6#config_vip.v - (Gold + BankPoll)]])
                    end
            end
    end.

vip_lvup(Uid) ->
    case load_attr:is_vip(Uid) of
        ?false -> 0;
        VipLv ->
            case ets:lookup(?tab_name_1, {VipLv, ?PRIVILEGE_TYPE_5}) of
                [] -> ok;
                [Record5] ->
                    asset_handler:add_asset(Uid, Record5#config_vip.prize_id)
            end
    end.