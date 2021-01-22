%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 15. 三月 2016 下午2:51
%%%-------------------------------------------------------------------
-module(type_can).

-include("erl_pub.hrl").

-export([
    %% @doc 类型验证,类型转换
    is_type/2, is_t2t/3, t2t/3
]).

is_t2t(Data, TypeFrom, TypeTo) ->
    try t2t(Data, TypeFrom, TypeTo) of
        error -> ?return_err(?ERR_INVALID_CONVERT_TYPE);
        NewData -> {ok, NewData}
    catch
        _C:_W ->
            ?return_err(?ERR_INVALID_CONVERT_TYPE)
    end.

t2t(Data, ?list, ?integer) ->
    case string:to_integer(Data) of
        {Int, []} -> Int;
        _ -> error
    end;
t2t(Data, ?binary, ?integer) ->
    binary_to_integer(Data).


is_type(Type, Data) ->
    case check_type(Type, Data) of
        false -> ?return_err(?ERR_INVALID_TYPE);
        true -> Data
    end.

check_type(?list, L) -> erlang:is_list(L);
check_type(?binary, Bin) -> erlang:is_binary(Bin);
check_type(?integer, Int) -> erlang:is_integer(Int).




