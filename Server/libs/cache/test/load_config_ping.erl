%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 27. 十一月 2015 上午10:35
%%%-------------------------------------------------------------------
-module(load_config_ping).

-include("../include/cache_mate.hrl").
-record(ping_config, {
    id,
    point
}).

-record(ping_test, {
    id,
    test
}).

load_cache() ->
    [
        #cache_mate{
            name = ping_config,
            record = #ping_config{},
            fields = record_info(fields, ping_config),
            all = [#ping_config.id, #ping_config.point],
            group = [#ping_config.id, #ping_config.point],
            verify = fun verify_ping_config/1
        },
        
        #cache_mate{
            name = ping_test,
            record = #ping_test{},
            fields = record_info(fields, ping_test),
            verify = fun verify_ping_config/1
        }
    
    ].

verify_ping_config(Item) ->
    io:format("ping_config:~p~n", [Item]),
    true.