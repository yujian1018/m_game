%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 15. 九月 2017 下午3:00
%%%-------------------------------------------------------------------
-module(load_active).


-include_lib("cache/include/cache_mate.hrl").
-include("load_active.hrl").
-include("obj_pub.hrl").

-export([load_data/1, save_data/1, del_data/1, data/1]).

-export([
    change/2,
    set_active/3, set_active_2/3,
    is_active/3,
    reset_v/1,
    limit/3
]).

load_cache() ->
    [
        #cache_mate{
            name = ?tab_name,
            key_pos = #active.uid
        }
    ].


load_data(Uid) ->
    Fun =
        fun([VO | VOAcc]) ->
            Record = load_active_sql:to_record(Uid, VO),
            insert(Record),
            VOAcc
        end,
    {load_active_sql:sql(Uid), Fun}.


save_data(Uid) ->
    load_active_sql:save_data(lookup(Uid)).


del_data(Uid) ->
    cache:delete(?tab_name, Uid).


lookup(Uid) ->
    [Item = #active{items = Items}] = cache:lookup(?tab_name, Uid),
    Item#active{items = [erl_record:diff_record(Record, #?tab_last_name{}) || Record <- Items]}.


insert(Record) ->
    cache:insert(?tab_name, Record).


data(Uid) ->
    load_active_sql:to_data(lookup(Uid)).


is_active(Uid, ActiveId, GiftId) ->
    Record = lookup(Uid),
    case lists:keyfind(ActiveId, #?tab_last_name.active_id, Record#active.items) of
        false -> ?false;
        Item -> lists:member(GiftId, Item#?tab_last_name.prize)
    end.


set_active(Uid, ActiveId, GiftId) ->
    case global_active:exit(ActiveId) of
        ?false -> ?false;
        ?true ->
            Record = lookup(Uid),
            {NewItems, Progress, PrizeIds} =
                case lists:keytake(ActiveId, #?tab_last_name.active_id, Record#active.items) of
                    ?false ->
                        {[#?tab_last_name{active_id = ActiveId, prize = [GiftId], op = ?OP_ADD} | Record#active.items], 0, [GiftId]};
                    {value, Item, R} ->
                        case lists:member(GiftId, Item#?tab_last_name.prize) of
                            ?true -> {?false, 0, 0};
                            ?false ->
                                {[Item#?tab_last_name{prize = [GiftId | Item#?tab_last_name.prize], op = ?OP_ADD} | R], Item#?tab_last_name.progress, [GiftId | Item#?tab_last_name.prize]}
                        end
                end,
            if
                NewItems =:= ?false -> ?false;
                true ->
                    insert(Record#active{items = NewItems}),
                    active_proto:send(Uid, [ActiveId, Progress, PrizeIds]),
                    ?true
            end
    end.

%% @doc 只能领取一种奖励
set_active_2(Uid, ActiveId, GiftId) ->
    Record = lookup(Uid),
    {NewItems, Progress, PrizeIds} =
        case lists:keytake(ActiveId, #?tab_last_name.active_id, Record#active.items) of
            ?false ->
                {[#?tab_last_name{active_id = ActiveId, prize = [GiftId], op = ?OP_ADD} | Record#active.items], 0, [GiftId]};
            {value, Item, R} ->
                case Item#?tab_last_name.prize of
                    [] ->
                        {[Item#?tab_last_name{prize = [GiftId], op = ?OP_ADD} | R], Item#?tab_last_name.progress, [GiftId | Item#?tab_last_name.prize]};
                    _ -> {?false, 0, 0}
                end
        end,
    if
        NewItems =:= ?false -> ?false;
        true ->
            insert(Record#active{items = NewItems}),
            active_proto:send(Uid, [ActiveId, Progress, PrizeIds]),
            ?true
    end.


set_progress(Uid, ActiveId, V) ->
    Record = lookup(Uid),
    {NewItems, NewV, NewPrizes} =
        case lists:keytake(ActiveId, #?tab_last_name.active_id, Record#active.items) of
            false ->
                Prizes =
                    case global_active_gift:get_gift_prizes(ActiveId, 0, V) of
                        [] -> [];
                        GiftPrizeIds ->
                            [asset_handler:add_asset(Uid, GiftPrizeId) || GiftPrizeId <- GiftPrizeIds],
                            GiftPrizeIds
                    end,
                {[#?tab_last_name{active_id = ActiveId, progress = V, prize = Prizes, op = ?OP_ADD} | Record#active.items], V, []};
            {value, Item, R} ->
                Prizes =
                    case global_active_gift:get_gift_prizes(ActiveId, length(Item#?tab_last_name.prize), Item#?tab_last_name.progress + V) of
                        [] -> Item#?tab_last_name.prize;
                        GiftPrizeIds ->
                            [asset_handler:add_asset(Uid, GiftPrizeId) || GiftPrizeId <- GiftPrizeIds],
                            Item#?tab_last_name.prize ++ GiftPrizeIds
                    end,
                {[Item#?tab_last_name{progress = Item#?tab_last_name.progress + V, prize = Prizes, op = ?OP_ADD} | R], Item#?tab_last_name.progress + V, Prizes}
        end,
    insert(Record#active{items = NewItems}),
    active_proto:send(Uid, [ActiveId, NewV, NewPrizes]).


reset_v(Uid) ->
    ActiveIds = global_active:all_date_type(?ACTIVE_DATE_DAILY),
    Record = lookup(Uid),
    Fun =
        fun(ActiveId, ItemsAcc) ->
            case global_active:exit(ActiveId) of
                ?false -> ItemsAcc;
                ?true ->
                    case lists:keytake(ActiveId, #?tab_last_name.active_id, ItemsAcc) of
                        false ->
                            ItemsAcc;
                        {value, Item, R} -> [Item#?tab_last_name{prize = [], op = ?OP_ADD} | R]
                    end
            end
        end,
    NewItems = lists:foldl(Fun, Record#active.items, ActiveIds),
    insert(Record#active{items = NewItems}).


limit(Uid, ActiveId, ConfigNum) ->
    Record = lookup(Uid),
    case lists:keyfind(ActiveId, #?tab_last_name.active_id, Record#active.items) of
        false -> ?return_err(?ERR_ACTIVE_NOT_NUM);
        Item ->
            if
                Item#?tab_last_name.progress >= ConfigNum -> true;
                true -> ?return_err(?ERR_ACTIVE_NOT_NUM)
            end
    end.


change(Uid, KvList) ->
    ActiveIds = global_active:all_progress_type(?ACTIVE_TYPE_ADDUP) ++ global_active:all_progress_type(?ACTIVE_TYPE_EX_ADDUP),
    Fun =
        fun(ActiveId) ->
            case global_active:exit(ActiveId) of
                ?false -> [];
                ?true ->
                    case global_active_prize:get_prize(ActiveId, ?PRIVILEGE_TYPE_7, -1) of
                        [] -> ok;
                        {?ATTR, AssetId} ->
                            case [[K | V] || [K | V] <- KvList, K =:= AssetId] of
                                [[_K, V]] ->
                                    set_progress(Uid, ActiveId, V);
                                _Other ->
                                    ok
                            end
                    end
            end
        end,
    lists:map(Fun, ActiveIds),
    KvList.


