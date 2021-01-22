%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 16. 十月 2017 下午2:48
%%%-------------------------------------------------------------------
-module(cache_global).

-include("cache_pub.hrl").

-export([
    insert/2,
    lookup/1
]).


load_cache() ->
    [
        #cache_mate{
            name = cache_global,
            keypos = 1
        }
    ].


insert(K, V) ->
    ets:insert(cache_global, {K, V}).


lookup(K) ->
    case ets:lookup(cache_global, K) of
        [] -> [];
        [{K, V}] -> V
    end.
