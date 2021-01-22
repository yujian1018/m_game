%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 18. 七月 2016 上午9:17
%%%-------------------------------------------------------------------
-module(int_can).

-include("erl_pub.hrl").

-export([
    natural_num/1,
    is_int/1,
    min_max/3
]).

%% @doc 自然数（0,正整数）
natural_num(Int) ->
    case is_integer(Int) of
        true ->
            case Int >= 0 of
                true -> Int;
                false -> ?return_err(?ERR_INVALID_NATURAL_NUM)
            end;
        false ->
            ?return_err(?ERR_INVALID_NATURAL_NUM)
    end.

is_int(Int) ->
    case is_integer(Int) of
        true -> Int;
        false -> ?return_err(?ERR_INVALID_INTEGER)
    end.

min_max(Key, Min, Max) ->
    if
        Key >= Min andalso Key =< Max -> Key;
        true -> ?ERR_NOT_IN_SIZE
    end.