%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 27. 七月 2016 下午7:14
%%%-------------------------------------------------------------------
-module(global_active_gift).

-include_lib("cache/include/cache_mate.hrl").
-include("obj_pub.hrl").

-export([
    get_active_id/1, get_gift_id/2,
    get_gift_prizes/3
]).


-define(tab_name, global_active_gift).


-record(global_active_gift, {
    gift_id,
    active_id,
    limit,
    prize_id,
    ex_id
}).


load_cache() ->
    [
        
        #cache_mate{
            name = ?tab_name,
            record = #global_active_gift{},
            fields = record_info(fields, ?tab_name),
            group = [#global_active_gift.active_id],
            verify = fun verify_gift/1,
            rewrite = fun rewrite_gift/1,
            priority = 11
        }
    ].


verify_gift(#global_active_gift{gift_id = GiftId, prize_id = PrizeId}) ->
    ?check(global_prize:exit(PrizeId), "gift_id:~p...no prize_id:~p~n", [GiftId, PrizeId]).


rewrite_gift(Config = #global_active_gift{limit = Limit}) ->
    NewLimit =
        if
            Limit =:= <<>> -> [];
            true ->
                {ok, Scan1, _} = erl_scan:string(binary_to_list(Limit) ++ "."),
                {ok, LimitParse} = erl_parse:parse_term(Scan1),
                LimitParse
        end,
    Config#global_active_gift{limit = NewLimit}.



get_gift_id(ActiveId, ExId) ->
    case ets:match(?tab_name, #?tab_name{gift_id = '$1', prize_id = '$2', active_id = ActiveId, ex_id = ExId, _ = '_'}) of
        [Data] -> Data;
        _Other ->
            []
    end.


get_active_id(GiftId) ->
    case ets:lookup(?tab_name, GiftId) of
        [] -> [];
        [Record] ->
            {Record#global_active_gift.active_id, Record#global_active_gift.limit, Record#global_active_gift.prize_id}
    end.


get_gift_prizes(ActiveId, Index, V) ->
    case lists:member(ActiveId, global_active:all_prize_type(?ACTIVE_PRIZE_TYPE_SERVER)) of
        true ->
            case ets:lookup(?tab_name, {'group', #global_active_gift.active_id, ActiveId}) of
                [] -> [];
                [{_, _, Ids}] ->
                    Len = length(Ids),
                    if
                        Len > Index ->
                            get_gift_prize(Index + 1, Len, Ids, V, []);
                        true -> []
                    end
            end;
        false ->
            []
    end.


get_gift_prize(MaxLen, MaxLen, _Ids, _V, Acc) -> lists:reverse(Acc);
get_gift_prize(Index, MaxLen, Ids, V, Acc) ->
    GiftId = lists:nth(Index, Ids),
    case ets:lookup(?tab_name, GiftId) of
        [] -> get_gift_prize(Index + 1, MaxLen, Ids, V, Acc);
        [Record] ->
            case Record#global_active_gift.limit of
                ["active", Num] ->
                    if
                        V >= Num ->
                            get_gift_prize(Index + 1, MaxLen, Ids, V, [Record#global_active_gift.prize_id | Acc]);
                        true -> get_gift_prize(Index + 1, MaxLen, Ids, V, Acc)
                    end;
                _Limit -> get_gift_prize(Index + 1, MaxLen, Ids, V, Acc)
            end
    end.