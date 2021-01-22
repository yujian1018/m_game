%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 04. 八月 2016 下午5:37
%%%-------------------------------------------------------------------
-module(t_kv).

-export([test/0]).


test() ->
    
    D = d(dict:new(), 0),
    T = t(gb_trees:empty(), 0),
    L = l([], 0),
    
    io:format("start~n"),
    
    T2 = erlang:timestamp(),
    test_dict(D, 0),
    DiffTime2 = timer:now_diff(erlang:timestamp(), T2),
    io:format("test_dict ms_time:~p~n", [DiffTime2]),
    
    T3 = erlang:timestamp(),
    test_trees(T, 0),
    DiffTime3 = timer:now_diff(erlang:timestamp(), T3),
    io:format("test_trees ms_time:~p~n", [DiffTime3]),
    
    T4 = erlang:timestamp(),
    test_list(L, 0),
    DiffTime4 = timer:now_diff(erlang:timestamp(), T4),
    io:format("test_list ms_time:~p~n", [DiffTime4]),
    
    ok.



d(D, 600) -> D;
d(D, Num) ->
    D1 = dict:append(Num, Num, D),
    d(D1, Num + 1).

test_dict(D, 1000000) -> D;
test_dict(D, Num) ->
    dict:fold(fun(I, _V, _Acc) -> I + 1 end, [], D),
    test_dict(D, Num + 1).


t(T, 600) -> T;
t(T, Num) ->
    T1 = gb_trees:insert(Num, Num, T),
    t(T1, Num + 1).

test_trees(T, 1000000) -> T;
test_trees(T, Num) ->
    gb_trees:map(fun(_K, V) -> V + 1 end, T),
    test_trees(T, Num + 1).


l(L, 600) -> L;
l(L, Num) ->
    l([{Num, Num} | L], Num + 1).

test_list(L, 1000000) -> L;
test_list(L, Num) ->
    lists:map(fun({_K, V}) -> V + 1 end, L),
    test_list(L, Num + 1).

