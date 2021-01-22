%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 13. 八月 2018 下午3:45
%%%-------------------------------------------------------------------
-module(tcp_mod).

-include("network_pub.hrl").

-export([
    send/1, send/2,
    sign/0, sign/1
]).


send(Port, Pack) ->
%%    ?DEBUG("debug:~p~n", [[self(), Pack]]),
    if
        Pack =:= <<>> -> ok;
        Pack =:= [] -> ok;
        is_binary(Pack) ->
            erlang:port_command(Port, Pack, [force]);
        true ->
            erlang:port_command(Port, ?encode(Pack), [force])
    end.

send(Pack) ->
%%    ?DEBUG("debug:~p~n", [[self(), Pack]]),
    Port = erlang:get(?c_socket),
    send(Port, Pack).

sign() ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    put(?pack_random, {MegaSecs, Secs, MicroSecs}),
    {MegaSecs, Secs, MicroSecs}.


sign(Sign) ->
    case Sign =:= tcp_uniform() of
        true ->
            ok;
        false ->
            ?return_err(?ERR_BAD_SIGN)
    end.


tcp_uniform() ->
    {A1, A2, A3} = get(?pack_random),
    B1 = (A1 * 171) rem 30269,
    B2 = (A2 * 172) rem 30307,
    B3 = (A3 * 170) rem 30323,
    put(?pack_random, {B1, B2, B3}),
    (B1 + B2 + B3) rem 255.