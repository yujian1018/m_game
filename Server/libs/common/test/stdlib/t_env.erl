%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 14. 二月 2017 下午5:41
%%%-------------------------------------------------------------------
-module(t_env).

-export([t/0]).


t() ->
    T1 = os:timestamp(),
    test(0),
    io:format("time cost:~p~n", [timer:now_diff(os:timestamp(), T1)]).


test(3000000) -> ok;
test(Int) ->
    {ok, Node} = application:get_env(map, db_node),
    Node,
    test(Int + 1).