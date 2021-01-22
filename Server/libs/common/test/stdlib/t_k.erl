%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 04. 八月 2016 下午5:37
%%%-------------------------------------------------------------------
-module(t_k).

-export([test/0]).


test() ->
    S = s(sets:new(), 0),
    Gs = gs(gb_sets:new(), 0),
    Os = os(ordsets:new(), 0),
    
    io:format("start~n"),
    
    T1 = erlang:timestamp(),
    {_, R1} = erlang:process_info(self(), reductions),
    test_sets(S, 0),
    DiffTime = timer:now_diff(erlang:timestamp(), T1),
    {_, R2} = erlang:process_info(self(), reductions),
    io:format("test_sets ms_time:~p...reductions:~p~n", [DiffTime, R2 - R1]),
    
    T2 = erlang:timestamp(),
    {_, R3} = erlang:process_info(self(), reductions),
    test_gs(Gs, 0),
    DiffTime2 = timer:now_diff(erlang:timestamp(), T2),
    {_, R4} = erlang:process_info(self(), reductions),
    io:format("test_gs ms_time:~p...reductions:~p~n", [DiffTime2, R4 - R3]),
    
    T3 = erlang:timestamp(),
    {_, R5} = erlang:process_info(self(), reductions),
    test_os(Os, 0),
    DiffTime3 = timer:now_diff(erlang:timestamp(), T3),
    {_, R6} = erlang:process_info(self(), reductions),
    io:format("test_os ms_time:~p...reductions:~p~n", [DiffTime3, R6 - R5]),
    ok.


s(S, 600) -> S;
s(S, Num) ->
    S1 = sets:add_element(Num, S),
    s(S1, Num + 1).

test_sets(S, 1000000) -> S;
test_sets(S, Num) ->
%%    sets:is_element(Num, S),
%%    sets:to_list(S),
    sets:fold(fun(I, _Acc) -> I + 1 end, [], S),
    test_sets(S, Num + 1).


gs(Gs, 600) -> Gs;
gs(Gs, Num) ->
    Gs1 = gb_sets:add_element(Num, Gs),
    gs(Gs1, Num + 1).

test_gs(Gs, 1000000) -> Gs;
test_gs(Gs, Num) ->
%%    gb_sets:is_element(Num, Gs),
%%    gb_sets:to_list(Gs),
    gb_sets:fold(fun(X, _Acc) -> X + 1 end, [], Gs),
    test_gs(Gs, Num + 1).

os(Os, 600) -> Os;
os(Os, Num) ->
    Os1 = ordsets:add_element(Num, Os),
    os(Os1, Num + 1).

test_os(Os, 1000000) -> Os;
test_os(Os, Num) ->
%%    ordsets:is_element(Num, Os),
%%    ordsets:to_list(Os),
    ordsets:fold(fun(X, _Acc) -> X + 1 end, [], Os),
    
    test_os(Os, Num + 1).