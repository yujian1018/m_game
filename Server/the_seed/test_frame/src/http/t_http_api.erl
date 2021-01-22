%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 24. 一月 2018 下午3:18
%%%-------------------------------------------------------------------
-module(t_http_api).

-include("t_pub.hrl").

-export([
    get_server/0
]).

get_server() ->
    Date = erl_time:now(),
    DateBin = integer_to_binary(Date),
    Sign = ?SIGN(Date),
    ArgBin = cow_qs:qs([
        {<<"date">>, DateBin},
        {<<"sign">>, Sign},
        {<<"channel_id">>, ?CHANNEL_ID},
        {<<"version">>, ?VERSION}
    ]),
    Url = binary_to_list(<<(?HTTP_ADDR)/binary, "api/get_server/?", ArgBin/binary>>),
    ?INFO("get_server:~p~n", [Url]),
    {ok, Response} = erl_httpc:get(Url, []),
    {[{<<"code">>, CODE}, {<<"url">>, URL}, {<<"port">>, _PORT}, {<<"switchs">>, _SWITCHS}, {<<"ip">>, _IP}]} = ?decode(Response),
    if
        CODE =:= 200 -> URL;
        true ->
            ?ERROR("get_server err url:~p...response:~p~n", [Url, Response]),
            ?RETURN_ERR(?ERR_ARG_ERROR)
    end.
    