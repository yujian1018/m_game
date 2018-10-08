%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 游戏中所有资产的产出 消耗 走这里
%%%
%%% Created : 27. 十二月 2017 上午11:33
%%%-------------------------------------------------------------------
-module(global_asset).

-include_lib("cache/include/cache_mate.hrl").
-include("obj_pub.hrl").

-export([
    exit_cost_id/1, exit_prize_id/1,
    get_cost_id/1, get_prize_id/1
]).

-define(tab_name_1, global_cost).
-define(tab_name_2, global_prize).

-record(global_cost, {
    cost_id,
    cost
}).

-record(global_prize, {
    prize_id,
    prize
}).

load_cache() ->
    [
        #cache_mate{
            name = ?tab_name_1,
            fields = record_info(fields, ?tab_name_1),
            rewrite = fun rewrite_cost/1,
            verify = fun verify_cost/1,
            priority = 10
        },
        #cache_mate{
            name = ?tab_name_2,
            fields = record_info(fields, ?tab_name_2),
            rewrite = fun rewrite_prize/1,
            verify = fun verify_prize/1,
            priority = 10
        }
    ].


rewrite_cost(Item) ->
    #global_cost{cost_id = CostId, cost = List} = Item,
    
    {ok, Scan, _} = erl_scan:string(binary_to_list(List) ++ "."),
    {ok, Team} = erl_parse:parse_term(Scan),
    
    Item#global_cost{cost_id = CostId, cost = Team}.

verify_cost(#global_cost{cost = 0}) -> true;
verify_cost(#global_cost{cost = List}) ->
    Fun =
        fun([Type, Id, _V]) ->
            true = is_integer(_V),
            case Type of
                ?ATTR -> config_asset:exit_attr(Id);
                ?ITEM -> config_asset:exit_item(Id)
            end
        end,
    lists:all(Fun, List).


rewrite_prize(#global_prize{prize_id = PrizeId, prize = List}) ->
    {ok, Scan, _} = erl_scan:string(binary_to_list(List) ++ "."),
    {ok, Team} = erl_parse:parse_term(Scan),
    #global_prize{prize_id = PrizeId, prize = Team}.


verify_prize(#global_prize{prize = 0}) -> true;
verify_prize(#global_prize{prize_id = PrizeId, prize = List}) ->
    Fun =
        fun([Type, Id | _R]) ->
            case Type of
                ?ATTR -> config_asset:exit_attr(Id);
                ?ITEM -> config_asset:exit_item(Id)
            end
        end,
    case lists:all(Fun, List) of
        true -> true;
        false ->
            ?ERROR("global_prize id:~p...data:~p~n", [PrizeId, List]),
            error
    end.


exit_cost_id(0) -> true;
exit_cost_id(CostId) ->
    ets:member(?tab_name_1, CostId).

exit_prize_id(0) -> true;
exit_prize_id(PrizeId) ->
    ets:member(?tab_name_2, PrizeId).


get_cost_id(CostId) ->
    case ets:lookup(?tab_name_1, CostId) of
        [] -> [];
        [#global_cost{cost = Cost}] -> Cost
    end.


get_prize_id(0) -> [];
get_prize_id(PrizeId) ->
    [#global_prize{prize = List}] = ets:lookup(?tab_name_2, PrizeId),
    List.
