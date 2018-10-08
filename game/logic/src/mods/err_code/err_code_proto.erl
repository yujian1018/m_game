%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 14. 七月 2016 下午2:31
%%%-------------------------------------------------------------------
-module(err_code_proto).

-include("logic_pub.hrl").

-export([
    err_code/1,
    err_code/4,
    handle_info/3
]).

err_code(Err) ->
    ?WARN("err_code:~w...MSG:~w~n", [Err, self()]),
    {ErrCode, ErrMsg} =
        case Err of
            {throw, {_ErrCode, _ErrMsg}} -> {_ErrCode, _ErrMsg};
            {throw, _ErrCode} -> {_ErrCode, <<>>}
        end,
    case get(?proto_id) of
        ?undefined ->
            ?tcp_send([0, 0, ErrCode]);
        {ModId, ProtoId} ->
            ?tcp_send([ModId, ProtoId, [<<"err_code">>, ErrCode, ErrMsg]])
    end.


err_code(Err, ModId, ProtoId, Data) ->
    case Err of
        {throw, {ErrCode, ErrMsg}} ->
            ?WARN("data:~p...err:~p~n", [[ModId, ProtoId, Data], Err]),
            ?tcp_send([ModId, ProtoId, [<<"err_code">>, ErrCode, ErrMsg]]);
        {throw, ErrCode} ->
            ?WARN("data:~p...err:~p~n", [[ModId, ProtoId, Data], Err]),
            ?tcp_send([ModId, ProtoId, [<<"err_code">>, ErrCode]]);
        _ ->
            ?ERROR("crash:~p~n", [[ModId, ProtoId, Data, Err]]),
            ?tcp_send([0, 0, 0])
    end.


handle_info(_Uid, _Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).