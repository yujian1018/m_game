%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 七月 2016 下午5:20
%%%-------------------------------------------------------------------
-module(global_config).

-include_lib("cache/include/cache_mate.hrl").

-export([
    get_v/2
]).

-define(tab_name, global_config).

-record(global_config, {
    k1,
    k2,
    v
}).

load_cache() ->
    [
        #cache_mate{
            name = ?tab_name,
            record = #global_config{},
            fields = record_info(fields, ?tab_name),
            rewrite = fun rewrite/1
        }
    ].


rewrite(Item) ->
    #global_config{k1 = K1, k2 = K2, v = V} = Item,
    {ok, Scan1, _} = erl_scan:string(binary_to_list(K1) ++ "."),
    {ok, Team1} = erl_parse:parse_term(Scan1),
    
    {ok, Scan2, _} = erl_scan:string(binary_to_list(K2) ++ "."),
    {ok, Team2} = erl_parse:parse_term(Scan2),
    
    {ok, Scan3, _} = erl_scan:string(binary_to_list(V) ++ "."),
    {ok, Team3} = erl_parse:parse_term(Scan3),
    
    Item#global_config{k1 = {Team1, Team2}, v = Team3}.

get_v(K1, K2) ->
    case ets:lookup(?tab_name, {K1, K2}) of
        [] -> [];
        [#global_config{v = V}] ->
            V
    end.