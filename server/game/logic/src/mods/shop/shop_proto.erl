%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 01. 八月 2017 下午2:47
%%%-------------------------------------------------------------------
-module(shop_proto).


-include("obj_pub.hrl").

-export([
    handle_info/2
]).



handle_info(?PROTO_SHOP_BUY_GOLD, GoodsId) ->
    int_can:natural_num(GoodsId),
    Uid = erlang:get(?uid),
    ChannelId = erlang:get(?channel_id),
    Currency =
        case config_shop:get_type(GoodsId) of
            [] -> ?return_err(?ERR_CONFIG_NO_DATA);
            {?SHOP_GOLD, CurrencyType} -> CurrencyType;
            {?SHOP_VIP, CurrencyType} -> CurrencyType;
            {?SHOP_DAILY, CurrencyType} ->
                case load_active:is_active(Uid, ?ACTIVE_DAILY_GIFT, GoodsId) of
                    true -> ?return_err(?ERR_SHOP_BUY_DAILY);
                    false -> CurrencyType
                end;
            {?SHOP_HORN, CurrencyType} -> CurrencyType;
            _ ->
                ?return_err(?ERR_ARG_ERROR)
        end,
    Now = integer_to_binary(erl_time:now()),
    OrderId = erl_bin:order_id(),
    load_orders:create_orders(OrderId, Now, integer_to_binary(Uid), integer_to_binary(ChannelId), integer_to_binary(GoodsId), <<"1">>, Currency),
    ?tcp_send(shop_sproto:encode(?PROTO_SHOP_BUY_GOLD, OrderId));


handle_info(?PROTO_SHOP_BUY_ITEM, GoodsId) ->
    int_can:natural_num(GoodsId),
    case config_shop:get_shop(GoodsId) of
        {?SHOP_ITEM, Limit, CostId, PrizeId} ->
            Uid = erlang:get(?uid),
            cost_can:asset_can(Uid, Limit),
            asset_handler:del_asset(Uid, CostId),
            asset_handler:add_asset(Uid, PrizeId),
            ?tcp_send(shop_sproto:encode(?PROTO_SHOP_BUY_ITEM, 1));
        _ -> ?return_err(?ERR_CONFIG_NO_DATA)
    end;

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).
