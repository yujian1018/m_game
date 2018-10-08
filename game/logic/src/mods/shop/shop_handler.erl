%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 21. 九月 2017 上午10:26
%%%-------------------------------------------------------------------

-module(shop_handler).


-include("logic_pub.hrl").

-export([
    add_asset/1
]).


add_asset(OrderId) ->
    case load_orders:get_goods_id(OrderId) of
        [] -> {error, <<"order is done">>};
        GoodsId ->
            {Type, PrizeId, Amount} = config_shop:get_prize(GoodsId),
            Uid = erlang:get(?uid),
            if
                Type =:= ?SHOP_GOLD ->
                    %% 充值金币。 首冲和返利
                    Assest = global_prize:get(PrizeId),
                    [GiftId, _] = global_active_gift:get_gift_id(?ACTIVE_RECHAGE_DOUBLE, GoodsId),
                    NewAsset =
                        case load_active:set_active(Uid, ?ACTIVE_RECHAGE_DOUBLE, GiftId) of
                            true ->
                                global_active_prize:active_asset(?ACTIVE_RECHAGE_DOUBLE, PrizeId, Assest);
                            false ->
                                global_active_prize:active_asset(?ACTIVE_RECHARGE_PER, PrizeId, Assest)
                        end,
                    asset_handler:add_asset(Uid, PrizeId, NewAsset);
                
                Type =:= ?SHOP_VIP ->
%% 月卡。送时间和金币
                    asset_handler:add_asset(Uid, PrizeId);
                Type =:= ?SHOP_DAILY ->
                    [GiftId, _] = global_active_gift:get_gift_id(?ACTIVE_DAILY_GIFT, GoodsId),
                    load_active:set_active(Uid, ?ACTIVE_DAILY_GIFT, GiftId),
                    asset_handler:add_asset(Uid, PrizeId);
                true ->
                    ok
            end,
            load_attr:set_v(Uid, [[?ALL_RMB, Amount], [?VIP_EXP, Amount]]),
            ok
    end.

