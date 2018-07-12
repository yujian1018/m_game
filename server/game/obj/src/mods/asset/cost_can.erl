%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 18. 七月 2016 上午9:17
%%%-------------------------------------------------------------------
-module(cost_can).

-include("game_pub.hrl").

-export([
    asset/2, asset_can/2,
    asset_attr/2,
    asset_item/2
]).

asset(_Uid, 0) -> ok;

asset(Uid, CostId) when is_integer(CostId) ->
    CostList = global_cost:get(CostId),
    asset_can(Uid, CostList);

asset(Uid, CostIds) ->
    Fun =
        fun(CostId) ->
            CostList = global_cost:get(CostId),
            case catch asset_can(Uid, CostList) of
                {throw, _} -> false;
                _ -> true
            end
        end,
    case erl_list:map_break(Fun, CostIds) of
        true -> ok;
        false -> ?return_err(?ERR_ATTR_NOT_ENOUGH_NUM)
    end.

asset_can(_Uid, []) -> ok;
asset_can(Uid, Asset) ->
    {AssetsAttr, AssetItem, _AssetEip, _AssetBuff, _AssetCard} = asset_handler:asset_type(Asset),
    asset_attr(Uid, AssetsAttr),
    asset_item(Uid, AssetItem).

asset_attr(_Uid, []) -> ok;
asset_attr(Uid, AssetsAttr) ->
    AttrIds = [AttrId || [AttrId, _V] <- AssetsAttr],
    AttrVs = [V || [_AttrId, V] <- AssetsAttr],
    HaveNums =
        case ?rpc_db_call(redis_online, is_online, [Uid]) of
            {ok, _Pid} ->
                load_attr:get_v(Uid, AttrIds);
            {ok, _Node, _Pid} ->
                rpc:call(_Node, load_attr, get_v, [Uid, AttrIds]);
            false ->
                load_attr:get_vo(Uid, AttrIds)
        end,
    check_num(AttrVs, HaveNums).

asset_item(_Uid, []) -> ok;
asset_item(Uid, AssetItem) ->
    ItemIds = [ItemId || [ItemId, _V] <- AssetItem],
    ItemVs = [V || [_ItemId, V] <- AssetItem],
    HaveNums =
        case ?rpc_db_call(redis_online, is_online, [Uid]) of
            {ok, _Pid} ->
                load_item:get_v(Uid, ItemIds);
            {ok, _Node, _Pid} ->
                rpc:call(_Node, load_item, get_v, [Uid, ItemIds]);
            false ->
                load_item:get_vo(Uid, ItemIds)
        end,
    check_num(ItemVs, HaveNums).

check_num([], _) -> ok;
check_num([CostNum | CostNums], [HaveNum | HaveNums]) ->
    if
        abs(CostNum) =< HaveNum ->
            check_num(CostNums, HaveNums);
        true ->
            ?return_err(?ERR_ATTR_NOT_ENOUGH_NUM)
    end.
