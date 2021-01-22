%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 23. 5月 2020 下午8:00
%%%-------------------------------------------------------------------
-module(db_clickhouse).

-include("erl_pub.hrl").

-export([
    execute/2
]).




execute(_Pool, <<>>) ->
    <<>>;
execute(_Pool, []) ->
    [];
execute(_Pool, SQL) ->
    {'ok', Confs} = application:get_env(gateway, pool_log_clickhouse_1),
    Host = proplists:get_value(host, Confs, "localhost"),
    Port = proplists:get_value(port, Confs, "8123"),
    User = proplists:get_value(user, Confs, "default"),
    Password = proplists:get_value(password, Confs, ""),
    Database = proplists:get_value(database, Confs, "default"),
    
    Post = iolist_to_binary(SQL),
    Url = "http://" ++ Host ++ ":" ++ integer_to_list(Port) ++ "/?user=" ++
        User ++ "&password=" ++ Password ++ "&database=" ++ Database,
    Ret = erl_httpc:post(Url, [], [], Post),
%%    ?INFO("aaa:~tp", [[Url, Post, Ret]]),
    Ret.