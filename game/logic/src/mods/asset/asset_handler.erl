%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 道具管理
%%%
%%% Created : 22. 七月 2016 下午5:19
%%%-------------------------------------------------------------------
-module(asset_handler).

-include("logic_pub.hrl").

-export([
    handler_call/1,
    handler_msg/3
]).

-export([
    asset_type/1,
    add_asset/2, add_asset/3,
    del_asset/2, del_asset/3

]).

-export([
    asset_v/6
]).


asset_type(Asset) ->
    FunFoldl =
        fun([AssetType | AssetR], {AttrAcc, ItemAcc, EipAcc, BuffAcc, CardAcc}) ->
            case AssetType of
                ?ATTR -> {[AssetR | AttrAcc], ItemAcc, EipAcc, BuffAcc, CardAcc};
                ?ITEM -> {AttrAcc, [AssetR | ItemAcc], EipAcc, BuffAcc, CardAcc}
            end
        end,
    lists:foldl(FunFoldl, {[], [], [], [], []}, Asset).

add_asset(_Uid, 0) -> ok;
add_asset(Uid, PrizeId) ->
    Asset = global_prize:get(PrizeId),
    add_asset(Uid, PrizeId, Asset).

add_asset(Uid, PrizeId, Asset) ->
    {AssetsAttr, AssetItem, AssetEip, AssetBuff, AssetCard} = asset_type(Asset),
    if
        AssetsAttr =:= [] -> ok;
        true -> load_attr:change(Uid, PrizeId, AssetsAttr)
    end,
    if
        AssetItem =:= [] -> ok;
        true -> load_item:change(Uid, PrizeId, AssetItem)
    end,
    if
        AssetEip =:= [] -> ok;
        true -> load_eip:change(Uid, PrizeId, AssetEip)
    end,
    if
        AssetBuff =:= [] -> ok;
        true -> load_buff:change(Uid, PrizeId, AssetBuff)
    end,
    if
        AssetCard =:= [] -> ok;
        true -> load_card:change(Uid, PrizeId, AssetCard)
    end.


del_asset(_Uid, 0) -> ok;
del_asset(Uid, CostIds) when is_integer(hd(CostIds)) ->
    Fun =
        fun(CostId) ->
            CostList = global_cost:get(CostId),
            case catch del_asset(Uid, CostId, CostList) of
                {throw, _} -> false;
                _ -> true
            end
        end,
    case erl_list:map_break(Fun, CostIds) of
        true -> ok;
        false -> ?return_err(?ERR_ATTR_NOT_ENOUGH_NUM)
    end;

del_asset(Uid, CostId) ->
    CostList = global_cost:get(CostId),
    del_asset(Uid, CostId, CostList).


del_asset(Uid, CostId, Asset) ->
    cost_can:asset_can(Uid, Asset),
    {AssetsAttr, AssetItem, _AssetEip, _AssetBuff, _AssetCard} = asset_type(Asset),
    if
        AssetsAttr =:= [] -> ok;
        true -> load_attr:change(Uid, -CostId, AssetsAttr)
    end,
    if
        AssetItem =:= [] -> ok;
        true -> load_item:change(Uid, -CostId, AssetItem)
    end.


handler_call({add_item, OrderId, IsSandbox}) ->
    case shop_handler:add_asset(OrderId) of
        ok ->
            load_orders:set_orders(OrderId, IsSandbox),
            ok;
        {error, _Err} ->
            {error, _Err}
    end.

handler_msg(_FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: from_pid:~p...from_module:~p...msg:~p~n", [_FromPid, _FromModule, _Msg]).


%% @doc ConfAssetType = -1 表示所有奖励都生效
asset_v(_AssetType, -1, _ConfAssetId, ConfAllType, ConfV, KvList) ->
    FunV =
        fun(Item) ->
            [V | R] = lists:reverse(Item),
            NewV =
                if
                    ConfAllType =:= 1 -> V + ConfV;
                    ConfAllType =:= 2 -> round(V * (1 + ConfV / 100));
                    ConfAllType =:= 3 -> ConfV;
                    true -> V
                end,
            lists:reverse([NewV | R])
        end,
    lists:map(FunV, KvList);

%% @doc ConfAssetType = -2 表示ConfigAssetId是一个列表
asset_v(_AssetType, -2, ConfAssetId, ConfAllType, ConfV, KvList) ->
    Fun =
        fun([K | R]) ->
            case lists:member(K, ConfAssetId) of
                true ->
                    [V | R2] = lists:reverse([K | R]),
                    NewV =
                        if
                            ConfAllType =:= 1 -> V + ConfV;
                            ConfAllType =:= 2 -> round(V * (1 + ConfV / 100));
                            ConfAllType =:= 3 -> ConfV;
                            true -> V
                        end,
                    lists:reverse([NewV | R2]);
                false ->
                    [K | R]
            end
        end,
    erl_list:set_element(Fun, KvList);

%% @doc AssetType = -1 表示KvList = [[asset_id, id, num],...]]
asset_v(-1, ConfAssetType, ConfAssetId, ConfAllType, ConfV, KvList) ->
    Fun =
        fun([AssetType, K | R]) ->
            if
                ConfAssetId =:= K andalso ConfAssetType =:= AssetType ->
                    [V | R2] = lists:reverse([AssetType, K | R]),
                    NewV =
                        if
                            ConfAllType =:= 1 -> V + ConfV;
                            ConfAllType =:= 2 -> round(V * (1 + ConfV / 100));
                            ConfAllType =:= 3 -> ConfV;
                            true -> V
                        end,
                    lists:reverse([NewV | R2]);
                true ->
                    [AssetType, K | R]
            end
        end,
    erl_list:set_element(Fun, KvList);

asset_v(AssetType, ConfAssetType, ConfAssetId, ConfAllType, ConfV, KvList) ->
    Fun =
        fun([K | R]) ->
            if
                ConfAssetId =:= K andalso ConfAssetType =:= AssetType ->
                    [V | R2] = lists:reverse([K | R]),
                    NewV =
                        if
                            ConfAllType =:= 1 -> V + ConfV;
                            ConfAllType =:= 2 -> round(V * (1 + ConfV / 100));
                            ConfAllType =:= 3 -> ConfV;
                            true -> V
                        end,
                    lists:reverse([NewV | R2]);
                true ->
                    [K | R]
            end
        end,
    erl_list:set_element(Fun, KvList).