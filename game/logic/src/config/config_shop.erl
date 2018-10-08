%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 11. 五月 2017 下午5:05
%%%-------------------------------------------------------------------
-module(config_shop).

-include_lib("cache/include/cache_mate.hrl").
-include("logic_pub.hrl").

-export([
    get_type/1,
    get_shop/1,
    get_prize/1
]).

-define(tab_name, config_shop).


-record(config_shop, {
    id,
    shop_type,
    item_id,
    amount,
    limit,
    cost_id,
    prize_id,
    currency_type
}).

load_cache() ->
    [
        #cache_mate{
            name = ?tab_name,
            type = mysql,
            fields = record_info(fields, ?tab_name),
            verify = fun verify/1,
            rewrite = fun rewrite/1,
            priority = 11
        }
    ].


verify(#config_shop{id = Id, item_id = ItemId, cost_id = CostId, prize_id = PrizeId}) ->
    ?check(config_asset:exit_item(ItemId), "id:~p asset_id item_id:~p~n", [Id, ItemId]),
    ?check(global_cost:exit(CostId), "id:~p cost_id:~p~n", [Id, CostId]),
    ?check(global_prize:exit(PrizeId), "id:~p prize_id:~p~n", [Id, PrizeId]).

rewrite(Item) ->
    Fun =
        fun(Bin) ->
            if
                Bin =:= <<>> -> [];
                true ->
                    {ok, Scan, _} = erl_scan:string(binary_to_list(Bin) ++ "."),
                    {ok, Term} = erl_parse:parse_term(Scan),
                    Term
            end
        end,
    Item#config_shop{limit = Fun(Item#config_shop.limit)}.

get_type(GoodsId) ->
    case ets:lookup(?tab_name, GoodsId) of
        [VO] ->
            {VO#config_shop.shop_type, VO#config_shop.currency_type};
        _ -> []
    end.

get_shop(GoodsId) ->
    case ets:lookup(?tab_name, GoodsId) of
        [VO] -> {VO#config_shop.shop_type, VO#config_shop.limit, VO#config_shop.cost_id, VO#config_shop.prize_id};
        _ -> []
    end.

get_prize(GoodsId) ->
    case ets:lookup(?tab_name, GoodsId) of
        [VO] ->
            {VO#config_shop.shop_type, VO#config_shop.prize_id, VO#config_shop.amount};
        _ -> []
    end.