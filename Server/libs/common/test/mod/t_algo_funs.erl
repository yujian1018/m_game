%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 14. 九月 2018 下午1:51
%%%-------------------------------------------------------------------
-module(t_algo_funs).


-export([
    t/0,
    test/1
]).


t() ->
    timer:tc(?MODULE, test, [1]).


test(1000000) -> ok;
test(N) ->
    algo:edit_distance(<<"dakaichangweiybbbbbbi">>, <<"feichaadfaabaaaaaaaaa">>),
    test(N + 1).