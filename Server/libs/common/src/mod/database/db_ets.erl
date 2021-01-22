%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 06. 十一月 2018 上午9:29
%%%-------------------------------------------------------------------
-module(db_ets).

-export([
    foldl/3
]).


foldl(Fun, DataInit, TabName) ->
    ets:foldl(fun(Record, DataAcc) -> Fun(Record, DataAcc) end, DataInit, TabName).