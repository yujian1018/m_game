%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 六月 2016 下午4:29
%%%-------------------------------------------------------------------
-module(t_catch).

-compile(export_all).

test() ->
    case catch test_1() of
        Ret ->
            io:format("111:~p~n", [Ret])
    end.




test_1() ->
    case test_2() of
        error -> erlang:throw(test_1);
        false ->
            test_3()
    end.


%%test_2() -> error.
test_2() -> false.

test_3() ->
    A = get(a),
    B = 2,
    A = B.
%%    erlang:throw(test_3).