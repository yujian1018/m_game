%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 11. 八月 2017 下午4:30
%%%-------------------------------------------------------------------
-module(global_task).

-include_lib("cache/include/cache_mate.hrl").

-export([
    get_data/2
]).


-define(tab_name_1, global_task).
-define(tab_name_2, global_task_chain).

-record(global_task, {
    id,
    chain_id,
    prize_id,
    limit,
    completion,
    client_set
}).

-record(global_task_chain, {
    chain_id
}).


load_cache() ->
    [
        #cache_mate{
            name = ?tab_name_1,
            fields = record_info(fields, ?tab_name_1),
            group = [#?tab_name_1.chain_id]
        },
        #cache_mate{
            name = ?tab_name_2,
            fields = record_info(fields, ?tab_name_2)
        }
    ].


get_data(ChainId, Index) ->
    case ets:lookup(?tab_name_1, {group, #global_task.chain_id, ChainId}) of
        [] -> [];
        [{_TabName, _K, Ids}] ->
            Id = lists:nth(Index, Ids),
            case ets:lookup(?tab_name_1, Id) of
                [] -> [];
                [Record] ->
                    {
                        Record#?tab_name_1.prize_id,
                        Record#?tab_name_1.limit,
                        Record#?tab_name_1.completion,
                        Record#?tab_name_1.client_set
                    }
            end
    end.
    