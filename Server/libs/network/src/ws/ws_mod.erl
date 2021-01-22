%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 13. 八月 2018 下午3:44
%%%-------------------------------------------------------------------
-module(ws_mod).

-include("network_pub.hrl").

-export([
    sign/0, sign/1,
    header/2,
    send/1, send/2
]).



sign() ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    put(?pack_random, {MegaSecs, Secs, MicroSecs}),
    [MegaSecs, Secs, MicroSecs].


sign(Sign) ->
    case Sign =:= ws_uniform() of
        true -> ok;
        false -> ?return_err(?ERR_BAD_SIGN)
    end.


ws_uniform() ->
    {A1, A2, A3} = get(?pack_random),
    B1 = (A1 * 171) rem 30269,
    B2 = (A2 * 172) rem 30307,
    B3 = (A3 * 170) rem 30323,
    put(?pack_random, {B1, B2, B3}),
    B1 + B2 + B3.


%%258EAFA5-E914-47DA-95CA-C5AB0DC85B11（它是一个“ 魔术字符串”）
header(Socket, RecvBin) ->
    HeaderList = binary:split(RecvBin, <<"\r\n">>, [global]),
    HeaderList1 = [list_to_tuple(binary:split(I, <<": ">>)) || I <- HeaderList, I /= <<>>],
    SecWebSocketKey = proplists:get_value(<<"Sec-WebSocket-Key">>, HeaderList1, <<>>),
    IP =
        case proplists:get_value(<<"X-Real-IP">>, HeaderList1, <<>>) of
            Ip -> Ip
        end,
    Sha1 = crypto:hash(sha, [SecWebSocketKey, <<"258EAFA5-E914-47DA-95CA-C5AB0DC85B11">>]),
    Base64 = base64:encode(Sha1),
    Handshake = [<<"HTTP/1.1 101 Switching Protocols\r\n">>, <<"Upgrade: websocket\r\n">>, <<"Connection: Upgrade\r\n">>,
        <<"Sec-WebSocket-Accept: ">>, Base64, <<"\r\n">>, <<"\r\n">>],
    gen_tcp:send(Socket, Handshake),
    ?put_new(?c_ip, IP).


send(Port, Pack) ->
%%    ?DEBUG("debug:~p~n", [[self(), Pack]]),
    if
        Pack =:= <<>> -> ok;
        Pack =:= [] -> ok;
        is_binary(Pack) ->
            erlang:port_command(Port, l2c_ws:encode(Pack), [force]);
        true ->
            erlang:port_command(Port, l2c_ws:encode(?encode(Pack)), [force])
    end.

send(Pack) ->
%%    ?DEBUG("debug:~p~n", [[self(), Pack]]),
    Port = erlang:get(?c_socket),
    send(Port, Pack).