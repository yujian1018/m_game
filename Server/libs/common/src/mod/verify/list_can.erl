%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 18. 七月 2016 上午9:17
%%%-------------------------------------------------------------------
-module(list_can).

-include("erl_pub.hrl").

-export([
    member/3, member/4,
    exit_v/2, exit_v/3, exit_v/4, exit_v_not_null/2, exit_v_not_null/3, exit_v_not_null/4,
    get_arg/2, get_arg/3
]).

member(Key, List, ErrCode) -> member(Key, List, ErrCode, <<"">>).
member(Key, List, ErrCode, Msg) ->
    case lists:member(Key, List) of
        true -> Key;
        false -> ?return_err(ErrCode, Msg)
    end.


exit_v(K, Arg) -> exit_v(K, Arg, ?ERR_ARG_ERROR).
exit_v(K, Arg, Err) ->
    case proplists:get_value(K, Arg) of
        undefined -> ?return_err(Err);
        Value -> binary_can:illegal(Value)
    end.
exit_v(K, Arg, Err, ErrMsg) ->
    case proplists:get_value(K, Arg) of
        undefined -> ?return_err(Err, ErrMsg);
        Value -> binary_can:illegal(Value)
    end.

exit_v_not_null(K, Arg) -> exit_v_not_null(K, Arg, ?ERR_ARG_ERROR).
exit_v_not_null(K, Arg, Err) ->
    case proplists:get_value(K, Arg) of
        undefined -> ?return_err(Err);
        <<"">> -> ?return_err(Err);
        Value -> binary_can:illegal(Value)
    end.
exit_v_not_null(K, Arg, Err, ErrMsg) ->
    case proplists:get_value(K, Arg) of
        undefined -> ?return_err(Err, ErrMsg);
        <<"">> -> ?return_err(Err, ErrMsg);
        Value -> binary_can:illegal(Value)
    end.


get_arg(Key, Arg) -> binary_can:illegal(proplists:get_value(Key, Arg, <<"">>)).
get_arg(Key, Arg, Default) -> binary_can:illegal(proplists:get_value(Key, Arg, Default)).